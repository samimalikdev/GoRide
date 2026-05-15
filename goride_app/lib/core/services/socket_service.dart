import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  Socket? _socket;
  String? _userId;

  String? get userId => _userId;

  
  final Map<String, List<Function(dynamic)>> _listeners = {};

  void connect(String url) {
    if (_socket != null && _socket!.connected) return;

    print(" Connecting to Socket.io: $url");
    _socket = io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.onConnect((_) {
      print(' Connected to Socket.io: ${_socket!.id}');
      _listeners.forEach((event, callbacks) {
        _socket!.off(event); 
        for (var cb in callbacks) {
          _socket!.on(event, cb);
        }
      });

      if (_userId != null) {
        print(" Re-registering user in socket on connect: $_userId");
        _socket!.emit('register', {'userId': _userId});
      }
    });

    _socket!.onDisconnect((_) => print('Disconnected from Socket.io'));
    _socket!.onConnectError((data) => print('Socket Connect Error: $data'));
    _socket!.onError((data) => print('Socket Error: $data'));

    _socket!.connect();
  }

  void _setSingleListener(String event, Function(dynamic) callback) {
    _listeners[event] = [callback]; 
    if (_socket != null) {
      _socket!.off(event);
      _socket!.on(event, callback);
    }
  }


  void joinRide(String rideId) {
    print("Joining ride room: $rideId");
    _socket?.emit('join_ride', rideId);
  }

  void emit(String event, dynamic data) {
    if (_socket == null) return;
    
    if (_socket!.connected) {
      _socket!.emit(event, data);
    } else {
      print("Socket not connected, queuing emit for $event");
      _socket!.once('connect', (_) {
        _socket!.emit(event, data);
      });
      _socket!.connect();
    }
  }

  void registerUser(String userId) {
    print("Registering user in socket: $userId");
    _userId = userId;
    emit('register', {'userId': userId});
  }


  void sendMessage(String receiverId, String text, {String? imageUrl}) {
    emit('send_message', {
      'senderId': _userId, 
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl ?? "",
    });
  }

  void onMessage(Function(Map<String, dynamic>) callback) {
    _setSingleListener('message', (data) {
      callback(Map<String, dynamic>.from(data as Map));
    });
  }

  void setTyping(String receiverId, bool isTyping) {
    _socket?.emit('typing', {
      'receiverId': receiverId,
      'isTyping': isTyping,
    });
  }

  void onTyping(Function(Map<String, dynamic>) callback) {
    _setSingleListener('typing', (data) {
      callback(Map<String, dynamic>.from(data as Map));
    });
  }

  void emitCallEvent(String event, Map<String, dynamic> data) {
    _socket?.emit('call:$event', data);
  }

  void onCallEvent(String event, Function(Map<String, dynamic>) callback) {
    _setSingleListener('call:$event', (data) {
      callback(Map<String, dynamic>.from(data as Map));
    });
  }

  void onRideAccepted(Function(Map<String, dynamic>?) callback) {
    _setSingleListener('ride_accepted', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onDriverLocationUpdate(Function(Map<String, dynamic>?) callback) {
    _setSingleListener('driver_location_update', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onDriverArrived(Function(Map<String, dynamic>?) callback) {
    _setSingleListener('driver_arrived', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onRideCancelled(Function(Map<String, dynamic>?) callback) {
    _setSingleListener('ride_cancelled', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onRideConfirmed(Function(Map<String, dynamic>?) callback) {
    _setSingleListener('ride_confirmed', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onRideStarted(Function(Map<String, dynamic>?) callback) {
    _setSingleListener('ride_started', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onRideCompleted(Function(Map<String, dynamic>?) callback) {
    _setSingleListener('ride_completed', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void stopListener(String event) {
    _socket?.off(event);
    _listeners.remove(event);
  }

  void stopConfirmationListener() {
    _socket?.off('ride_confirmed');
    _listeners.remove('ride_confirmed');
  }

  void stopCancellationListener() {
    _socket?.off('ride_cancelled');
    _listeners.remove('ride_cancelled');
  }

  void stopLocationUpdates() {
    _socket?.off('driver_location_update');
    _listeners.remove('driver_location_update');
  }

  void stopArrivalListener() {
    _socket?.off('driver_arrived');
    _listeners.remove('driver_arrived');
  }

  void stopRideStartedListener() {
    _socket?.off('ride_started');
    _listeners.remove('ride_started');
  }

  void stopRideCompletedListener() {
    _socket?.off('ride_completed');
    _listeners.remove('ride_completed');
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _listeners.clear();
  }
}
