const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('MISSING SUPABASE CREDENTIALS IN .ENV');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const getScopedClient = async (token) => {
  if (!token) return supabase;
  
  return createClient(supabaseUrl, supabaseKey, {
    global: {
      headers: {
        Authorization: `Bearer ${token}`
      }
    },
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    }
  });
};

module.exports = { supabase, getScopedClient };
