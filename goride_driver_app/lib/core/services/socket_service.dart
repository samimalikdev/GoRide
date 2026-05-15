import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  Socket? _socket;
  String? _lastDriverId;
  String? _userId;
  final String baseUrl;

  String? get userId => _userId;

  final Map<String, List<Function(dynamic)>> _callbacks = {};

  SocketService({required this.baseUrl});

  void connect() {
    if (_socket != null && _socket!.connected) return;

    print("SOCKET_SERVICE: Connecting to: $baseUrl");
    _socket = io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.onConnect((_) {
      print('SOCKET_SERVICE: Connected with ID: ${_socket!.id}');

      _callbacks.forEach((event, _) {
        _attachSocketListener(event);
      });

      if (_userId != null) {
        print("SOCKET_SERVICE: Re-registering user room on connect: $_userId");
        _socket!.emit('register', {'userId': _userId});
      }

      if (_lastDriverId != null) {
        joinDriverRoom(_lastDriverId!);
      }
    });

    _socket!.onDisconnect((_) => print('SOCKET_SERVICE: Disconnected'));
    _socket!.onConnectError(
      (data) => print('SOCKET_SERVICE: Connect Error: $data'),
    );
    _socket!.onError((data) => print('SOCKET_SERVICE: Error: $data'));

    _socket!.connect();
  }

  void _attachSocketListener(String event) {
    _socket?.off(event);
    _socket?.on(event, (data) {
      print("SOCKET_SERVICE: Received event '$event' with data: $data");
      final list = _callbacks[event];
      if (list != null) {
        for (var cb in List.from(list)) {
          cb(data);
        }
      }
    });
  }

  void clearCallbacks(String event) {
    print("SOCKET_SERVICE: Clearing callbacks for event: $event");
    _callbacks.remove(event);
    _socket?.off(event);
  }

  void _setSingleCallback(String event, Function(dynamic) callback) {
    _callbacks[event] = [callback]; 
    _attachSocketListener(event);
  }

  void _addCallback(String event, Function(dynamic) callback) {
    if (!_callbacks.containsKey(event)) {
      _callbacks[event] = [];
      _attachSocketListener(event);
    }
    _callbacks[event]!.add(callback);
  }

  void emit(String event, dynamic data) {
    if (_socket == null) {
      connect();
    }
    
    if (_socket!.connected) {
      _socket!.emit(event, data);
    } else {
      print("SOCKET_SERVICE: Socket not connected, queuing emit for $event");
      _socket!.once('connect', (_) {
        _socket!.emit(event, data);
      });
      if (!_socket!.active) {
        _socket!.connect();
      }
    }
  }

  void joinRide(String rideId) {
    if (rideId.isEmpty) {
      print("SOCKET_SERVICE: Warning! joinRide called with empty rideId");
      return;
    }
    print("SOCKET_SERVICE: Joining ride room: $rideId");
    emit('join_ride', rideId);
  }

  void joinDriverRoom(String driverId) {
    _lastDriverId = driverId;
    print("SOCKET_SERVICE: Driver joining room: $driverId");
    emit('driver_join', driverId);
  }

  void updateLocation(String rideId, double lat, double lng) {
    emit('update_location', {'rideId': rideId, 'lat': lat, 'lng': lng});
  }

  void registerUser(String userId) {
    print("SOCKET_SERVICE: Registering user: $userId");
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
    _setSingleCallback('message', (data) {
      if (data != null) {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void setTyping(String receiverId, bool isTyping) {
    emit('typing', {
      'senderId': _userId,
      'receiverId': receiverId,
      'isTyping': isTyping,
    });
  }

  void onTyping(Function(Map<String, dynamic>) callback) {
    _setSingleCallback('typing', (data) {
      if (data != null) {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void emitCallEvent(String event, Map<String, dynamic> data) {
    emit('call:$event', data);
  }

  void onCallEvent(String event, Function(Map<String, dynamic>) callback) {
    _setSingleCallback('call:$event', (data) {
      if (data != null) {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onNewRideRequest(Function(Map<String, dynamic>) callback) {
    _addCallback('ride_request', (data) {
      if (data != null) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  void onRideAccepted(Function(Map<String, dynamic>?) callback) {
    _setSingleCallback('ride_accepted', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onDriverLocationUpdate(Function(Map<String, dynamic>?) callback) {
    _setSingleCallback('driver_location_update', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onDriverArrived(Function(Map<String, dynamic>?) callback) {
    _setSingleCallback('driver_arrived', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onRideConfirmed(Function(Map<String, dynamic>?) callback) {
    _setSingleCallback('ride_confirmed', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onDriverRejected(Function(Map<String, dynamic>?) callback) {
    _setSingleCallback('driver_rejected', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onRideCancelled(Function(Map<String, dynamic>?) callback) {
    _setSingleCallback('ride_cancelled', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onRideStarted(Function(Map<String, dynamic>?) callback) {
    _setSingleCallback('ride_started', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onRideCompleted(Function(Map<String, dynamic>?) callback) {
    _setSingleCallback('ride_completed', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void onRideCancelledGlobal(Function(Map<String, dynamic>?) callback) {
    _setSingleCallback('ride_cancelled_global', (data) {
      if (data == null) {
        callback(null);
      } else {
        callback(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  void stopListener(String event) {
    _callbacks.remove(event);
    _socket?.off(event);
  }

  void removeCallback(String event, Function(dynamic) callback) {
    _callbacks[event]?.remove(callback);
    if (_callbacks[event]?.isEmpty ?? true) {
      stopListener(event);
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _callbacks.clear();
  }

  bool get isConnected => _socket?.connected ?? false;
}
