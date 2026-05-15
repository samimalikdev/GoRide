const messageService = require('../services/messageService');

exports.getChatHistory = async (req, res, next) => {
  try {
    const { otherUserId } = req.params;
    const userId = req.user.id;
    
    const history = await messageService.getChatHistory(userId, otherUserId);
    
    res.status(200).json({
      status: 'success',
      data: history
    });
  } catch (err) {
    next(err);
  }
};

exports.getConversations = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const conversations = await messageService.getConversationList(userId);
    
    res.status(200).json({
      status: 'success',
      data: conversations
    });
  } catch (err) {
    next(err);
  }
};
