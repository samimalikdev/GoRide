
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    profile_pic TEXT,
    wallet_balance NUMERIC DEFAULT 0,
    fcm_token TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.drivers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE,
    full_name TEXT,
    date_of_birth DATE,
    vehicle_model TEXT,
    vehicle_type TEXT,
    city TEXT,
    postal_code TEXT,
    status TEXT DEFAULT 'pending',
    cnic_front_url TEXT,
    cnic_front_status TEXT DEFAULT 'pending',
    cnic_back_url TEXT,
    cnic_back_status TEXT DEFAULT 'pending',
    license_front_url TEXT,
    license_front_status TEXT DEFAULT 'pending',
    reg_book_url TEXT,
    reg_book_status TEXT DEFAULT 'pending',
    car_front_url TEXT,
    car_front_status TEXT DEFAULT 'pending',
    car_back_url TEXT,
    car_back_status TEXT DEFAULT 'pending',
    lat DOUBLE PRECISION,
    lng DOUBLE PRECISION,
    location GEOGRAPHY(POINT, 4326),
    current_location GEOGRAPHY(POINT, 4326),
    is_online BOOLEAN DEFAULT FALSE,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.rides (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    driver_id UUID REFERENCES public.drivers(id) ON DELETE SET NULL,
    pickup_location TEXT,
    drop_location TEXT,
    pickup_latitude DOUBLE PRECISION,
    pickup_longitude DOUBLE PRECISION,
    drop_latitude DOUBLE PRECISION,
    drop_longitude DOUBLE PRECISION,
    pickup_coords GEOGRAPHY(POINT, 4326),
    drop_coords GEOGRAPHY(POINT, 4326),
    fare NUMERIC,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    accepted_at TIMESTAMP WITH TIME ZONE,
    arrived_at TIMESTAMP WITH TIME ZONE,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    ride_id UUID REFERENCES public.rides(id) ON DELETE SET NULL,
    amount NUMERIC,
    type TEXT,
    category TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    text TEXT,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.drivers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.rides DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages DISABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS drivers_location_idx ON public.drivers USING GIST (location);
CREATE INDEX IF NOT EXISTS rides_user_id_idx ON public.rides (user_id);
CREATE INDEX IF NOT EXISTS rides_driver_id_idx ON public.rides (driver_id);
CREATE INDEX IF NOT EXISTS messages_sender_receiver_idx ON public.messages (sender_id, receiver_id);

create extension if not exists postgis;