CREATE OR REPLACE FUNCTION get_user_conversations(p_user_id UUID)
RETURNS TABLE (
    other_user_id UUID,
    other_user_name TEXT,   
    other_user_pic TEXT,
    last_message TEXT,
    last_message_time TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    WITH LatestMessages AS (
        SELECT DISTINCT ON (
            LEAST(sender_id, receiver_id), 
            GREATEST(sender_id, receiver_id)
        )
            CASE WHEN sender_id = p_user_id THEN receiver_id ELSE sender_id END as other_id,
            text,
            created_at
        FROM public.messages
        WHERE sender_id = p_user_id OR receiver_id = p_user_id
        ORDER BY LEAST(sender_id, receiver_id), GREATEST(sender_id, receiver_id), created_at DESC
    )
    SELECT 
        lm.other_id,
        p.full_name,
        p.profile_pic,
        lm.text,
        lm.created_at
    FROM LatestMessages lm
    JOIN public.profiles p ON p.id = lm.other_id
    ORDER BY lm.last_message_time DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
