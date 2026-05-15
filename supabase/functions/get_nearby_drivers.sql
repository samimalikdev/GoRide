CREATE OR REPLACE FUNCTION get_nearby_drivers(user_lat float8, user_lng float8, radius_meters float8 DEFAULT 5000)
RETURNS TABLE (
    id uuid,
    user_id uuid,
    full_name text,
    vehicle_model text,
    vehicle_type text,
    lat float8,
    lng float8,
    distance float8
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.id,
        d.user_id,
        d.full_name,
        d.vehicle_model,
        d.vehicle_type,
        d.lat,
        d.lng,
        ST_Distance(
            d.location,
            ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography
        ) as distance
    FROM public.drivers d
    WHERE d.is_online = true
    AND d.status = 'approved'
    AND ST_DWithin(
        d.location,
        ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
        radius_meters
    )
    ORDER BY distance ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
