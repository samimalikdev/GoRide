const { supabase } = require('../config/supabase');
const AppError = require('../utils/AppError');

class MessageService {
  async saveMessage(senderId, receiverId, text, imageUrl = null) {
    const { data, error } = await supabase
      .from('messages')
      .insert([
        {
          sender_id: senderId,
          receiver_id: receiverId,
          text,
          image_url: imageUrl,
        }
      ])
      .select()
      .single();

    if (error) {
      console.error('Error saving message:', error);
      throw new AppError(error.message, 400);
    }
    return data;
  }

  async getChatHistory(userId, otherUserId) {
    const { data, error } = await supabase
      .from('messages')
      .select('*')
      .or(`and(sender_id.eq.${userId},receiver_id.eq.${otherUserId}),and(sender_id.eq.${otherUserId},receiver_id.eq.${userId})`)
      .order('created_at', { ascending: true });

    if (error) {
      console.error('Error fetching chat history:', error);
      throw new AppError(error.message, 400);
    }
    return data;
  }

  async getConversationList(userId) {
    const { data, error } = await supabase.rpc('get_user_conversations', { p_user_id: userId });

    if (error) {
      console.error('Error fetching conversations:', error);
      throw new AppError(error.message, 400);
    }
    return data;
  }
}

module.exports = new MessageService();
