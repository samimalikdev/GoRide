CREATE OR REPLACE FUNCTION topup_wallet(p_user_id UUID, p_amount NUMERIC)
RETURNS NUMERIC AS $$
DECLARE
    v_new_balance NUMERIC;
BEGIN
    UPDATE public.profiles 
    SET wallet_balance = wallet_balance + p_amount 
    WHERE id = p_user_id
    RETURNING wallet_balance INTO v_new_balance;

    INSERT INTO public.transactions (user_id, amount, type, category, description)
    VALUES (p_user_id, p_amount, 'credit', 'topup', 'Wallet top-up');

    RETURN v_new_balance;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
