const rideService = require('../services/rideService');
const { supabase } = require('../config/supabase');
const notificationService = require('../services/notificationService');

exports.getExploreData = async (req, res) => {
  try {
    const userId = req.user.id;
    const { lat, lng } = req.query;

    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('full_name')
      .eq('id', userId)
      .single();

    if (profileError) {
      console.error("Profile fetch error:", profileError);
    }

    let nearbyDrivers = [];
    if (lat && lng) {
      nearbyDrivers = await rideService.getNearbyDrivers(parseFloat(lat), parseFloat(lng));
    }

    const data = {
      user: {
        name: profile ? profile.full_name.split(' ')[0] : 'User',
        greeting: 'Where are you going?'
      },
      categories: [
        { id: 1, name: 'Ride', icon: 'https://img.icons8.com/color/96/car.png', color: '0xff76eb07' },
        { id: 2, name: 'Package', icon: 'https://img.icons8.com/color/96/package.png', color: '0xff3498db' },
        { id: 3, name: 'Intercity', icon: 'https://img.icons8.com/color/96/intercity.png', color: '0xffe67e22' },
        { id: 4, name: 'Rentals', icon: 'https://img.icons8.com/color/96/time.png', color: '0xff9b59b6' }
      ],
      nearbyDrivers: nearbyDrivers,
      activePromo: {
        title: '50% OFF',
        subtitle: 'On your first 3 rides',
        code: 'GORIDE50'
      }
    };
    res.status(200).json({ status: 'success', data });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};

exports.requestRide = async (req, res) => {
  try {
    const ride = await rideService.requestRide(req.body);
    const nearbyDrivers = await rideService.getNearbyDrivers(req.body.pickupLatitude, req.body.pickupLongitude);

    const { data: passengerProfile } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', ride.user_id)
      .single();

    if (nearbyDrivers.length > 0) {
      if (global.io) {
        nearbyDrivers.forEach(driver => {
          global.io.to(`driver_${driver.user_id}`).emit('ride_request', {
            rideId: ride.id,
            pickup: ride.pickup_location,
            drop: ride.drop_location,
            fare: ride.fare,
            pickupLat: ride.pickup_latitude,
            pickupLng: ride.pickup_longitude,
            dropLat: ride.drop_latitude,
            dropLng: ride.drop_longitude,
            passengerName: passengerProfile ? passengerProfile.full_name : 'Passenger',
            passengerProfilePic: passengerProfile ? passengerProfile.profile_pic : null,
          });
          console.log(`Sending ride request ${ride.id} to driver_${driver.user_id}`);
        });
      }

      const driverUserIds = nearbyDrivers.map(d => d.user_id);
      notificationService.sendToMultipleUsers(
        driverUserIds,
        {
          title: 'New Ride Request',
          body: `New ride from ${ride.pickup_location} for PKR ${ride.fare}`
        },
        { rideId: ride.id.toString(), type: 'ride_request' }
      );
    }

    res.status(201).json({
      status: 'success',
      data: {
        ride: ride,
        nearbyDrivers: nearbyDrivers
      }
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};

exports.acceptRide = async (req, res) => {
  try {
    const { rideId, driverId } = req.body;

    const { data: driverData, error: driverError } = await supabase
      .from('drivers')
      .select('*')
      .eq('user_id', driverId)
      .single();

    if (driverError || !driverData) {
      throw new Error("Driver not found for this user.");
    }

    const { data: driverProfile } = await supabase
      .from('profiles')
      .select('profile_pic')
      .eq('id', driverId)
      .single();
      
    const driverProfilePic = driverProfile ? driverProfile.profile_pic : driverData.profile_pic;

    const ride = await rideService.acceptRide(rideId, driverData.id);

    const { data: passengerProfile } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', ride.user_id)
      .single();

    const enrichedRide = {
      ...ride,
      rideId: ride.id,
      passengerName: passengerProfile ? passengerProfile.full_name : 'Passenger',
      passengerProfilePic: passengerProfile ? passengerProfile.profile_pic : null,
      passengerId: ride.user_id,
      pickupLat: ride.pickup_latitude,
      pickupLng: ride.pickup_longitude,
      dropLat: ride.drop_latitude,
      dropLng: ride.drop_longitude,
    };

    if (global.io) {
      global.io.to(rideId).emit('ride_accepted', {
        rideId,
        driver: {
          id: driverData.user_id,
          name: driverData.full_name,
          vehicle: driverData.vehicle_type,
          lat: driverData.lat || 31.5204,
          lng: driverData.lng || 74.3587,
          rating: 4.8,
          profile_pic: driverProfilePic
        }
      });
      console.log(`Emitted ride_accepted (Proposed) for room ${rideId}`);
    }

    const { data: rideDataForPush } = await supabase
      .from('rides')
      .select('user_id')
      .eq('id', rideId)
      .single();

    if (rideDataForPush) {
      notificationService.sendToUser(
        rideDataForPush.user_id,
        {
          title: 'Ride Accepted',
          body: `${driverData.full_name} has accepted your ride request.`
        },
        { rideId: rideId.toString(), type: 'ride_accepted' }
      );
    }

    res.status(200).json({ status: 'success', data: enrichedRide });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};

exports.confirmRide = async (req, res) => {
  try {
    const { rideId } = req.body;
    const ride = await rideService.confirmRide(rideId);

    const { data: passengerProfile } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', ride.user_id)
      .single();

    if (ride.driver && ride.driver.user_id) {
      const { data: driverProfile } = await supabase
        .from('profiles')
        .select('profile_pic')
        .eq('id', ride.driver.user_id)
        .single();
      if (driverProfile) {
        ride.driver.profile_pic = driverProfile.profile_pic;
      }
    }

    const enrichedRide = {
      ...ride,
      rideId: ride.id,
      status: 'accepted',
      passengerName: passengerProfile ? passengerProfile.full_name : 'Passenger',
      passengerProfilePic: passengerProfile ? passengerProfile.profile_pic : null,
      passengerId: ride.user_id,
      pickupLat: ride.pickup_latitude,
      pickupLng: ride.pickup_longitude,
      dropLat: ride.drop_latitude,
      dropLng: ride.drop_longitude,
    };

    if (global.io) {
      global.io.to(rideId).emit('ride_confirmed', enrichedRide);
      console.log(`Emitted ride_confirmed for room ${rideId}`);
    }

    if (ride && ride.driver && ride.driver.user_id) {
      notificationService.sendToUser(
        ride.driver.user_id,
        {
          title: 'Ride Confirmed',
          body: 'The passenger has confirmed your ride. You can start the journey now.'
        },
        { rideId: rideId.toString(), type: 'ride_confirmed' }
      );
    }

    res.status(200).json({ status: 'success', data: enrichedRide });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};

exports.rejectDriver = async (req, res) => {
  try {
    const { rideId } = req.body;
    const ride = await rideService.rejectDriver(rideId);

    if (global.io) {
      global.io.to(rideId).emit('driver_rejected', { rideId, message: 'User rejected the driver.' });
      console.log(`Emitted driver_rejected for room ${rideId}`);
    }

    res.status(200).json({ status: 'success', data: ride });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};

exports.cancelRide = async (req, res) => {
  try {
    const { rideId } = req.body;
    const ride = await rideService.cancelRide(rideId);

    if (global.io) {
      global.io.to(rideId).emit('ride_cancelled', { rideId, message: 'The ride has been cancelled.' });
      console.log(`Emitted ride_cancelled for room ${rideId}`);
    }

    if (ride) {
      notificationService.sendToUser(
        ride.user_id,
        {
          title: 'Ride Cancelled',
          body: 'Your ride has been cancelled.'
        },
        { rideId: rideId.toString(), type: 'ride_cancelled' }
      );

      if (ride.driver && ride.driver.user_id) {
        notificationService.sendToUser(
          ride.driver.user_id,
          {
            title: 'Ride Cancelled',
            body: 'The ride has been cancelled.'
          },
          { rideId: rideId.toString(), type: 'ride_cancelled' }
        );
      }
    }

    res.status(200).json({ status: 'success', data: ride });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};

exports.notifyArrived = async (req, res) => {
  try {
    const { rideId } = req.body;
    const ride = await rideService.driverArrived(rideId);

    if (global.io) {
      global.io.to(rideId).emit('driver_arrived', { rideId });
      console.log(`Emitted driver_arrived for room ${rideId}`);
    }

    const { data: rideDataForPush } = await supabase
      .from('rides')
      .select('user_id')
      .eq('id', rideId)
      .single();

    if (rideDataForPush) {
      notificationService.sendToUser(
        rideDataForPush.user_id,
        {
          title: 'Driver Arrived',
          body: `Your driver has arrived at the pickup location.`
        },
        { rideId: rideId.toString(), type: 'driver_arrived' }
      );
    }

    res.status(200).json({ status: 'success', data: ride });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};

exports.startRide = async (req, res) => {
  try {
    const { rideId } = req.body;
    const ride = await rideService.startRide(rideId);

    if (global.io) {
      global.io.to(rideId).emit('ride_started', { rideId });
      console.log(`Emitted ride_started for room ${rideId}`);
    }

    if (ride) {
      notificationService.sendToUser(
        ride.user_id,
        {
          title: 'Ride Started',
          body: 'Your ride has officially started. Have a safe journey!'
        },
        { rideId: rideId.toString(), type: 'ride_started' }
      );
    }

    res.status(200).json({ status: 'success', data: ride });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};

exports.completeRide = async (req, res) => {
  try {
    const { rideId } = req.body;
    const result = await rideService.completeRide(rideId);

    if (result.status === 'success' || result.status === 'already_completed') {
      if (global.io) {
        global.io.to(rideId).emit('ride_completed', { 
          rideId, 
          fare: result.ride.fare 
        });
        console.log(`Emitted ride_completed for room ${rideId} with fare ${result.ride.fare}`);
      }

      notificationService.sendToUser(
        result.ride.user_id,
        {
          title: 'Ride Completed',
          body: `Your ride has been completed. Final fare: PKR ${result.ride.fare}`
        },
        { 
          rideId: rideId.toString(), 
          type: 'ride_completed',
          fare: result.ride.fare.toString()
        }
      );

      res.status(200).json({ status: 'success', data: result.ride });
    } else {
      throw new Error(result.message || 'Failed to complete ride transaction');
    }
  } catch (error) {
    console.error("Error in completeRide:", error);
    res.status(500).json({ status: 'error', message: error.message });
  }
};



exports.getActiveRide = async (req, res) => {
  try {
    const { userId, driverId } = req.query;
    let query = supabase.from('rides').select('*, driver:drivers(*)');

    if (userId) {
      query = query.eq('user_id', userId).in('status', ['pending', 'driver_assigned', 'accepted', 'driver_arrived', 'started']);
    } else if (driverId) {
      const { data: driver } = await supabase.from('drivers').select('id').eq('user_id', driverId).single();
      if (!driver) return res.status(200).json({ status: 'success', data: null });
      query = query.eq('driver_id', driver.id).in('status', ['driver_assigned', 'accepted', 'driver_arrived', 'started']);
    } else {
      return res.status(400).json({ status: 'error', message: 'Missing userId or driverId' });
    }

    const { data, error } = await query.order('created_at', { ascending: false }).limit(1);

    if (error) throw error;

    if (data && data.length > 0) {
      const ride = data[0];
      const { data: passengerProfile } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', ride.user_id)
        .single();
        
      if (ride.driver && ride.driver.user_id) {
        const { data: driverProfile } = await supabase
          .from('profiles')
          .select('profile_pic')
          .eq('id', ride.driver.user_id)
          .single();
        if (driverProfile) {
          ride.driver.profile_pic = driverProfile.profile_pic;
        }
      }
        
      const enrichedRide = {
        ...ride,
        rideId: ride.id,
        passengerName: passengerProfile ? passengerProfile.full_name : 'Passenger',
        passengerProfilePic: passengerProfile ? passengerProfile.profile_pic : null,
      };
      res.status(200).json({ status: 'success', data: enrichedRide });
    } else {
      res.status(200).json({ status: 'success', data: null });
    }
  } catch (error) {
    console.error("Error in getActiveRide:", error);
    res.status(500).json({ status: 'error', message: error.message });
  }
};

exports.getRideHistory = async (req, res) => {
  try {
    const { userId } = req.query;
    if (!userId) {
      return res.status(400).json({ status: 'error', message: 'Missing userId' });
    }

    const { data, error } = await supabase
      .from('rides')
      .select('*, driver:drivers(*)')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;

    res.status(200).json({
      status: 'success',
      data: data
    });
  } catch (error) {
    console.error("Error in getRideHistory:", error);
    res.status(500).json({ status: 'error', message: error.message });
  }
};

