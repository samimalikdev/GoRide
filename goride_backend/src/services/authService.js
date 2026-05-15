const { supabase, getScopedClient } = require('../config/supabase');
const storageService = require('./storageService');
const AppError = require('../utils/AppError');

class AuthService {
  async signup(email, password, fullName, userType = 'rider') {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: { 
        data: { 
          full_name: fullName,
          user_type: userType 
        } 
      }
    });
    if (error) throw new AppError(error.message, 400);
    return data;
  }

  async login(email, password, requiredUserType) {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw new AppError(error.message, 401);

    const userType = data.user.user_metadata?.user_type;
    
    if (requiredUserType === 'driver' && userType !== 'driver') {
      await supabase.auth.signOut();
      throw new AppError('This account is not registered as a Driver.', 403);
    }
    
    if (requiredUserType === 'rider' && userType === 'driver') {
      await supabase.auth.signOut();
      throw new AppError('Driver accounts cannot login to the Rider app.', 403);
    }

    if (!data.session) {
      console.error('Login successful but session is missing!', data);
      throw new AppError('Authentication session not established', 401);
    }

    const client = await getScopedClient(data.session.access_token);
    const { data: factors, error: factorsError } = await client.auth.mfa.listFactors();
    if (factorsError) {
      console.error('MFA Factors Error:', factorsError);
      throw new AppError(factorsError.message, 400);
    }

    const verifiedFactor = factors?.all?.find(f => f.status === 'verified');

    try {
      const { data: profile } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', data.user.id)
        .single();
      if (profile) {
        data.user.user_metadata = {
          ...(data.user.user_metadata || {}),
          full_name: profile.full_name || data.user.user_metadata?.full_name,
          profile_pic: profile.profile_pic || data.user.user_metadata?.profile_pic,
        };
      }
    } catch (err) {
      console.warn('Could not enrich user metadata during login:', err.message);
    }

    if (verifiedFactor) {
      return {
        mfaRequired: true,
        factorId: verifiedFactor.id,
        user: {
          id: data.user.id,
          email: data.user.email,
          user_metadata: data.user.user_metadata,
        },
        session: data.session
      };
    }

    return {
      mfaRequired: false,
      user: data.user,
      session: data.session
    };
  }

  async enrollMfa(token) {
    const client = await getScopedClient(token);
    try {
      const { data: factors } = await client.auth.mfa.listFactors();
      if (factors?.all) {
        const unverified = factors.all.filter(f => f.status === 'unverified');
        for (const factor of unverified) {
          await client.auth.mfa.unenroll({ factorId: factor.id });
        }
      }
    } catch (e) {
      console.error('MFA Cleanup Error:', e);
    }

    const { data, error } = await client.auth.mfa.enroll({
      factorType: 'totp',
      friendlyName: 'GoRide Authenticator'
    });

    if (error) throw new AppError(error.message, 400);
    return data;
  }

  async challengeMfa(token, factorId) {
    const client = await getScopedClient(token);
    const { data, error } = await client.auth.mfa.challenge({ factorId });
    if (error) throw new AppError(error.message, 400);
    return data;
  }

  async verifyMfa(token, factorId, challengeId, code) {
    const client = await getScopedClient(token);
    const { data, error } = await client.auth.mfa.verify({
      factorId,
      challengeId,
      code
    });

    if (error) {
      console.error('SUPABASE MFA ERROR:', error);
      throw new AppError(error.message, 400);
    }
    console.log('SUPABASE MFA SUCCESS:', data);

    let authUser = null;
    try {
      const { data: { user } } = await client.auth.getUser(token);
      if (user) authUser = user;
    } catch (err) {
      console.warn('getUser(token) warning during verifyMfa:', err.message);
    }

    if (authUser) {
      try {
        const { data: profile } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', authUser.id)
          .single();
        if (profile) {
          authUser.user_metadata = {
            ...(authUser.user_metadata || {}),
            full_name: profile.full_name || authUser.user_metadata?.full_name,
            profile_pic: profile.profile_pic || authUser.user_metadata?.profile_pic,
          };
        }
      } catch (err) {
        console.warn('Could not enrich verified user metadata:', err.message);
      }
    }

    return {
      ...data,
      user: authUser || data.user || {}
    };
  }

  async listMfaFactors(token) {
    const client = await getScopedClient(token);
    const { data, error } = await client.auth.mfa.listFactors();
    if (error) throw new AppError(error.message, 400);
    return data;
  }

  async unenrollMfa(token, factorId) {
    const client = await getScopedClient(token);
    const { data, error } = await client.auth.mfa.unenroll({ factorId });
    if (error) throw new AppError(error.message, 400);
    return data;
  }

  async updateFcmToken(token, userId, fcmToken) {
    const { data, error } = await supabase
      .from('profiles')
      .update({ fcm_token: fcmToken })
      .eq('id', userId);

    if (error) throw new AppError(error.message, 400);
    return data;
  }

  async updateProfile(token, userId, fullName, profilePicBase64) {
    const client = await getScopedClient(token);
    let profilePicUrl = null;

    if (profilePicBase64) {
      try {
        const base64Data = profilePicBase64.replace(/^data:image\/\w+;base64,/, '');
        const buffer = Buffer.from(base64Data, 'base64');
        const file = {
          buffer,
          mimetype: 'image/jpeg'
        };
        const path = `profiles/${userId}_${Date.now()}.jpg`;
        profilePicUrl = await storageService.uploadFile(file, path, 'drivers');
      } catch (err) {
        console.error('Error uploading profile pic:', err);
      }
    }

    const metaDataUpdate = {};
    if (fullName) metaDataUpdate.full_name = fullName;
    if (profilePicUrl) metaDataUpdate.profile_pic = profilePicUrl;

    if (fullName || profilePicUrl) {
      const updatePayload = {};
      if (fullName) updatePayload.full_name = fullName;
      if (profilePicUrl) updatePayload.profile_pic = profilePicUrl;

      const { error: dbError } = await supabase
        .from('profiles')
        .update(updatePayload)
        .eq('id', userId);

      if (dbError) {
        console.error('Profiles table update error:', dbError);
        if (fullName && profilePicUrl) {
          await supabase
            .from('profiles')
            .update({ full_name: fullName })
            .eq('id', userId);
        }
      }
    }

    let authUser = null;
    try {
      const { data: { user }, error: getUserError } = await client.auth.getUser(token);
      if (user) {
        authUser = user;
      } else if (getUserError) {
        console.warn('getUser(token) returned error:', getUserError.message);
      }
    } catch (e) {
      console.warn('getUser(token) exception:', e.message);
    }

    let dbProfile = {};
    try {
      const { data: profile } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();
      if (profile) {
        dbProfile = profile;
      }
    } catch (e) {
      console.warn('Could not fetch profile record:', e.message);
    }

    const mergedMetadata = {
      ...(authUser?.user_metadata || {}),
      ...metaDataUpdate
    };
    if (dbProfile.full_name) mergedMetadata.full_name = dbProfile.full_name;
    if (dbProfile.profile_pic) mergedMetadata.profile_pic = dbProfile.profile_pic;

    if (authUser) {
      authUser.user_metadata = mergedMetadata;
      return authUser;
    }

    return {
      id: userId,
      email: '',
      user_metadata: {
        ...metaDataUpdate,
        full_name: dbProfile.full_name || fullName,
        profile_pic: dbProfile.profile_pic || profilePicUrl,
      }
    };
  }

  async logout(token, userId) {
    if (userId) {
      await supabase
        .from('profiles')
        .update({ fcm_token: null })
        .eq('id', userId);
    }

    if (token) {
      const client = await getScopedClient(token);
      await client.auth.signOut();
    }

    return { message: 'Logged out successfully' };
  }
}

module.exports = new AuthService();
