const admin = require('../config/firebase');
const { supabase } = require('../config/supabase');

class NotificationService {

  async sendToUser(userId, notification, data = {}) {
    try {
      const { data: profile, error } = await supabase
        .from('profiles')
        .select('fcm_token')
        .eq('id', userId)
        .single();

      if (error || !profile?.fcm_token) {
        console.warn(`No FCM token found for user ${userId}`);
        return null;
      }

      const message = {
        notification,
        data: {
          ...data,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        token: profile.fcm_token,
      };

      const response = await admin.messaging().send(message);
      console.log(`Successfully sent message to user ${userId}:`, response);
      return response;
    } catch (error) {
      console.error(`Error sending notification to user ${userId}:`, error);
      return null;
    }
  }

  async sendToMultipleUsers(userIds, notification, data = {}) {
    try {
      const { data: profiles, error } = await supabase
        .from('profiles')
        .select('fcm_token')
        .in('id', userIds);

      if (error || !profiles) {
        console.warn(`Could not fetch tokens for users: ${userIds}`);
        return null;
      }

      const tokens = profiles
        .map(p => p.fcm_token)
        .filter(t => t != null);

      if (tokens.length === 0) {
        console.warn('No valid FCM tokens found for the given users.');
        return null;
      }

      const message = {
        notification,
        data: {
          ...data,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        tokens: tokens,
      };

      const response = await admin.messaging().sendEachForMulticast(message);
      console.log(`Successfully sent multicast message:`, response.successCount, 'successes');
      return response;
    } catch (error) {
      console.error('Error sending multicast notification:', error);
      return null;
    }
  }
}

module.exports = new NotificationService();
