const { supabase } = require('../config/supabase');
const AppError = require('../utils/AppError');

class DriverService {
  async submitVerification(userId, data) {
    const { fullName, dateOfBirth, vehicleModel, vehicleType, documentUrls, city, postalCode, latitude, longitude } = data;
    
    console.log('DRIVER_SERVICE: Received verification for', fullName);
    
    const formattedDocs = {};
    if (documentUrls && typeof documentUrls === 'object') {
      Object.entries(documentUrls).forEach(([key, value]) => {
        if (typeof value === 'string') {
          formattedDocs[key] = { url: value, status: 'pending' };
        } else {
          formattedDocs[key] = value;
        }
      });
    }

    const upsertData = {
      user_id: userId,
      full_name: fullName,
      date_of_birth: dateOfBirth,
      vehicle_model: vehicleModel,
      vehicle_type: vehicleType,
      city: city,
      postal_code: postalCode,
      status: 'pending',
      cnic_front_url: documentUrls.cnic_front,
      cnic_front_status: 'pending',
      cnic_back_url: documentUrls.cnic_back,
      cnic_back_status: 'pending',
      license_front_url: documentUrls.license_front,
      license_front_status: 'pending',
      reg_book_url: documentUrls.reg_book,
      reg_book_status: 'pending',
      car_front_url: documentUrls.car_front,
      car_front_status: 'pending',
      car_back_url: documentUrls.car_back,
      car_back_status: 'pending',
      lat: latitude,
      lng: longitude
    };

    if (latitude !== undefined && longitude !== undefined && latitude !== null && longitude !== null) {
      upsertData.location = `POINT(${longitude} ${latitude})`;
    }

    const { data: driver, error } = await supabase
      .from('drivers')
      .upsert(upsertData)
      .select()
      .single();

    if (error) {
      console.error('SUPABASE ERROR:', error);
      throw new AppError(error.message, 400);
    }
    return driver;
  }

  async getDriverByUserId(userId) {
    const { data, error } = await supabase
      .from('drivers')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (error && error.code !== 'PGRST116') throw new AppError(error.message, 400);
    return data;
  }

  async updateOnlineStatus(userId, isOnline, lat, lng) {
    const updateData = { 
      is_online: isOnline, 
      last_updated: new Date() 
    };

    if (lat !== undefined && lng !== undefined && lat !== null && lng !== null) {
      const point = `POINT(${lng} ${lat})`;
      updateData.current_location = point;
      updateData.location = point;
      updateData.lat = lat;
      updateData.lng = lng;
    }

    const { data, error } = await supabase
      .from('drivers')
      .update(updateData)
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw new AppError(error.message, 400);
    return data;
  }
}

module.exports = new DriverService();
