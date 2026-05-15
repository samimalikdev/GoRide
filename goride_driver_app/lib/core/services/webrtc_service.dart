
import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'socket_service.dart';

enum CallStatus { idle, ringing, connected, ended }

class WebRTCService {
  final SocketService socketService;
  RTCPeerConnection? _pc;
  MediaStream? localStream;
  MediaStream? remoteStream;

  final _statusController = StreamController<CallStatus>.broadcast();
  Stream<CallStatus> get statusStream => _statusController.stream;

  String? _otherId;
  String? _callerName;
  bool _isCaller = false;
  bool get isCaller => _isCaller;
  String? get callerName => _callerName;
  String? get otherId => _otherId;

  WebRTCService({required this.socketService}) {
    _initSocketListeners();
  }

  void _initSocketListeners() {
    print('WEBRTC_SERVICE: Registering socket call listeners...');

    socketService.onCallEvent('incoming', (data) {
      print('WEBRTC_SERVICE: Incoming call from callerId=${data['callerId']}, name=${data['callerName']}');
      _otherId = data['callerId'];
      _callerName = data['callerName'];
      _isCaller = false;
      _statusController.add(CallStatus.ringing);
    });

    socketService.onCallEvent('accepted', (data) async {
      print('WEBRTC_SERVICE: Call accepted, creating offer. isCaller=$_isCaller, pc=$_pc');
      if (_isCaller && _pc != null) {
        final offer = await _pc!.createOffer();
        await _pc!.setLocalDescription(offer);
        socketService.emitCallEvent('offer', {
          'receiverId': _otherId,
          'offer': offer.toMap(),
        });
      }
    });

    socketService.onCallEvent('offer', (data) async {
      print('WEBRTC_SERVICE: Got offer. isCaller=$_isCaller, pc=$_pc');
      if (!_isCaller && _pc != null) {
        await _pc!.setRemoteDescription(
          RTCSessionDescription(data['offer']['sdp'], data['offer']['type']),
        );
        final answer = await _pc!.createAnswer();
        await _pc!.setLocalDescription(answer);
        socketService.emitCallEvent('answer', {
          'callerId': _otherId,
          'answer': answer.toMap(),
        });
      }
    });

    socketService.onCallEvent('answer', (data) async {
      print('WEBRTC_SERVICE: Got answer. isCaller=$_isCaller, pc=$_pc');
      if (_isCaller && _pc != null) {
        await _pc!.setRemoteDescription(
          RTCSessionDescription(data['answer']['sdp'], data['answer']['type']),
        );
      }
    });

    socketService.onCallEvent('ice', (data) async {
      if (_pc != null && data['candidate'] != null) {
        await _pc!.addCandidate(
          RTCIceCandidate(
            data['candidate']['candidate'],
            data['candidate']['sdpMid'],
            data['candidate']['sdpMLineIndex'],
          ),
        );
      }
    });

    socketService.onCallEvent('end', (data) {
      print('WEBRTC_SERVICE: Call ended');
      _cleanup();
    });
  }

  Future<void> initRenderers() async {}

  Future<void> startCall(String receiverId, [String? myName]) async {
    _isCaller = true;
    _otherId = receiverId;
    _callerName = myName;
    await _setupPeerConnection();

    socketService.emitCallEvent('start', {
      'receiverId': receiverId,
      'callerId': socketService.userId,
      'callerName': myName ?? 'Driver',
      'callType': 'audio',
    });
    
    _statusController.add(CallStatus.ringing);
  }

  Future<void> acceptCall() async {
    _isCaller = false;
    await _setupPeerConnection();
    socketService.emitCallEvent('accept', {
      'callerId': _otherId,     
      'receiverId': socketService.userId, 
    });
  }

  Future<void> _setupPeerConnection() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': false,
    };

    localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    
    if (_isCleanupInitiated) {
      localStream?.getTracks().forEach((t) => t.stop());
      await localStream?.dispose();
      localStream = null;
      return;
    }

    _pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    });

    if (_isCleanupInitiated) {
      await _pc?.close();
      await _pc?.dispose();
      _pc = null;
      localStream?.getTracks().forEach((t) => t.stop());
      await localStream?.dispose();
      localStream = null;
      return;
    }

    localStream!.getTracks().forEach((track) {
      _pc!.addTrack(track, localStream!);
    });

    _pc!.onIceCandidate = (candidate) {
      if (_isCleanupInitiated) return;
      if (candidate.candidate != null) {
        socketService.emitCallEvent('ice', {
          'receiverId': _otherId,
          'candidate': candidate.toMap(),
        });
      }
    };

    _pc!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteStream = event.streams[0];
        _statusController.add(CallStatus.connected);
      }
    };
  }

  void endCall() {
    socketService.emitCallEvent('end', {
      'receiverId': _otherId,
      'callerId': socketService.userId, 
    });
    _cleanup();
  }

  void toggleMute() {
    if (localStream != null) {
      for (var track in localStream!.getAudioTracks()) {
        track.enabled = !track.enabled;
      }
    }
  }

  bool _isCleanupInitiated = false;

  void _cleanup() {
    if (_isCleanupInitiated) return;
    if (_pc == null && _otherId == null) return;
    
    _isCleanupInitiated = true;

    try {
      localStream?.getTracks().forEach((t) {
        t.enabled = false;
      });
      remoteStream?.getTracks().forEach((t) {
        t.enabled = false;
      });
      
      _pc?.onIceCandidate = null;
      _pc?.onTrack = null;
      _pc?.onConnectionState = null;
      _pc?.onIceConnectionState = null;
    } catch (e) {
      print('WEBRTC_SERVICE: Immediate track stop error: $e');
    }

    print('WEBRTC_SERVICE: Cleaning up call... status: ${CallStatus.ended}');
    
    _statusController.add(CallStatus.ended);
    _otherId = null;
    _callerName = null;
    Future.delayed(const Duration(milliseconds: 800), () {
      _safeCleanup();
    });
  }

  bool _isCleaningUp = false;

  Future<void> _safeCleanup() async {
    if (_isCleaningUp) return;
    _isCleaningUp = true;

    final pc = _pc;
    final lStream = localStream;
    final rStream = remoteStream;

    try {
      print('WEBRTC_SERVICE: Starting safe cleanup sequence...');

      if (pc != null) {
        pc.onIceCandidate = null;
        pc.onTrack = null;
        pc.onConnectionState = null;
        pc.onIceConnectionState = null;
        pc.onDataChannel = null;

        print('WEBRTC_SERVICE: Closing PeerConnection...');
        await pc.close().timeout(const Duration(milliseconds: 500), onTimeout: () {});
        await Future.delayed(const Duration(milliseconds: 100));
        
        print('WEBRTC_SERVICE: Disposing PeerConnection...');
        await pc.dispose().timeout(const Duration(milliseconds: 500), onTimeout: () {});
      }

      if (rStream != null) {
        print('WEBRTC_SERVICE: Disposing Remote Stream...');
        await rStream.dispose().timeout(const Duration(milliseconds: 300), onTimeout: () {});
      }
      if (lStream != null) {
        print('WEBRTC_SERVICE: Disposing Local Stream...');
        await lStream.dispose().timeout(const Duration(milliseconds: 500), onTimeout: () {});
      }

      print('WEBRTC_SERVICE: Cleanup sequence completed successfully.');
    } catch (e) {
      print('WEBRTC_SERVICE: Cleanup sequence encountered an error: $e');
    } finally {
      _pc = null;
      localStream = null;
      remoteStream = null;
      _isCleaningUp = false;
      _isCleanupInitiated = false;
      print('WEBRTC_SERVICE: Cleanup flags reset.');
    }
  }
  void dispose() {
    _cleanup();
    _statusController.close();
  }
}
