
const getUserRoom = (userId) => `user_${userId}`;
const notificationService = require('../services/notificationService');
const messageService = require('../services/messageService');


function initSocket(io) {
  io.on('connection', (socket) => {
    console.log('New client connected:', socket.id);

    socket.on('register', ({ userId }) => {
      if (!userId) return;
      socket.userId = userId;
      socket.join(getUserRoom(userId));
      console.log(`User registered & joined room: ${getUserRoom(userId)}`);
    });

    socket.on('join_ride', (rideId) => {
      socket.join(rideId);
      console.log(`Joined ride room: ${rideId}`);
    });

    socket.on('driver_join', (driverId) => {
      socket.join(`driver_${driverId}`);
      console.log(`Driver joined legacy room: driver_${driverId}`);
    });

    socket.on('update_location', (data) => {
      const { rideId, lat, lng } = data;
      if (rideId && lat && lng) {
        io.to(rideId).emit('driver_location_update', { lat, lng });
      }
    });

    socket.on('send_message', async (data, ack) => {
      console.log('send_message received:', data);
      const { senderId, receiverId, text, imageUrl } = data;

      try {
        const savedMessage = await messageService.saveMessage(senderId, receiverId, text, imageUrl);
        
        const messageData = {
          _id: savedMessage.id,
          senderId,
          receiverId,
          text,
          imageUrl,
          createdAt: savedMessage.created_at
        };

        io.to(getUserRoom(senderId)).emit('message', messageData);
        io.to(getUserRoom(receiverId)).emit('message', messageData);

        notificationService.sendToUser(
          receiverId,
          {
            title: 'New Message',
            body: text || 'Sent an image'
          },
          { 
            senderId, 
            type: 'chat_message',
            text: text || ''
          }
        );

        if (ack) ack({ success: true, message: messageData });
      } catch (err) {
        console.error('Failed to send message:', err);
        if (ack) ack({ success: false, error: err.message });
      }
    });


    socket.on('typing', ({ senderId, receiverId, isTyping }) => {
      io.to(getUserRoom(receiverId)).emit('typing', { senderId, isTyping });
    });

    socket.on('call:start', (data) => {
      console.log('call:start:', data.callerName);
      const { receiverId } = data;
      io.to(getUserRoom(receiverId)).emit('call:incoming', data);
    });

    socket.on('call:accept', (data) => {
      console.log('call:accept from:', data.receiverId);
      io.to(getUserRoom(data.callerId)).emit('call:accepted', data);
    });

    socket.on('call:offer', (data) => {
      io.to(getUserRoom(data.receiverId)).emit('call:offer', data);
    });

    socket.on('call:answer', (data) => {
      io.to(getUserRoom(data.callerId)).emit('call:answer', data);
    });

    socket.on('call:ice', (data) => {
      io.to(getUserRoom(data.receiverId)).emit('call:ice', data);
    });

    socket.on('call:end', (data) => {
      const { callerId, receiverId } = data;
      io.to(getUserRoom(receiverId)).emit('call:end');
      io.to(getUserRoom(callerId)).emit('call:end');
    });

    socket.on('disconnect', () => {
      console.log('Client disconnected:', socket.userId || socket.id);
    });
  });
}

module.exports = { initSocket };
