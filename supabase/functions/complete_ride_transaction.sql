CREATE OR REPLACE FUNCTION complete_ride_transaction(p_ride_id UUID)
RETURNS JSON AS $$
DECLARE
    v_rider_id UUID;
    v_driver_id UUID;
    v_fare NUMERIC;
    v_driver_user_id UUID;
    v_status TEXT;
BEGIN
    SELECT user_id, driver_id, fare, status 
    INTO v_rider_id, v_driver_id, v_fare, v_status
    FROM public.rides 
    WHERE id = p_ride_id;

    IF v_status = 'completed' THEN
        RETURN json_build_object('status', 'already_completed', 'ride', (SELECT row_to_json(r) FROM public.rides r WHERE id = p_ride_id));
    END IF;

    SELECT user_id INTO v_driver_user_id FROM public.drivers WHERE id = v_driver_id;

    UPDATE public.rides 
    SET status = 'completed', completed_at = NOW() 
    WHERE id = p_ride_id;

    UPDATE public.profiles 
    SET wallet_balance = wallet_balance - v_fare 
    WHERE id = v_rider_id;

    UPDATE public.profiles 
    SET wallet_balance = wallet_balance + (v_fare * 0.8) 
    WHERE id = v_driver_user_id;

    INSERT INTO public.transactions (user_id, ride_id, amount, type, category, description)
    VALUES (v_rider_id, p_ride_id, v_fare, 'debit', 'ride_payment', 'Payment for ride');

    INSERT INTO public.transactions (user_id, ride_id, amount, type, category, description)
    VALUES (v_driver_user_id, p_ride_id, v_fare * 0.8, 'credit', 'ride_earning', 'Earnings from ride');

    RETURN json_build_object('status', 'success', 'ride', (SELECT row_to_json(r) FROM public.rides r WHERE id = p_ride_id));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
