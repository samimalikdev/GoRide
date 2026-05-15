
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/webrtc_service.dart';

abstract class CallEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartCallEvent extends CallEvent {
  final String receiverId;
  final String? name;
  StartCallEvent(this.receiverId, {this.name});
}

class AcceptCallEvent extends CallEvent {}

class EndCallEvent extends CallEvent {}

class CallStatusChangedEvent extends CallEvent {
  final CallStatus status;
  CallStatusChangedEvent(this.status);
}

class ToggleMuteEvent extends CallEvent {}

abstract class CallState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CallIdle extends CallState {}

class CallRinging extends CallState {
  final bool isIncoming;
  final String? callerName;
  final String? callerId;
  CallRinging({required this.isIncoming, this.callerName, this.callerId});

  @override
  List<Object?> get props => [isIncoming, callerName, callerId];
}

class CallConnected extends CallState {
  final bool isMuted;
  CallConnected({this.isMuted = false});

  @override
  List<Object?> get props => [isMuted];
}

class CallConnecting extends CallState {}

class CallEnded extends CallState {}

class CallBloc extends Bloc<CallEvent, CallState> {
  final WebRTCService webrtcService;

  CallBloc({required this.webrtcService}) : super(CallIdle()) {
    webrtcService.statusStream.listen((status) {
      add(CallStatusChangedEvent(status));
    });

    on<StartCallEvent>((event, emit) async {
      await webrtcService.startCall(event.receiverId, event.name);
    });

    on<AcceptCallEvent>((event, emit) async {
      emit(CallConnecting());
      await webrtcService.acceptCall();
    });

    on<EndCallEvent>((event, emit) {
      if (state is CallEnded || state is CallIdle) return;
      webrtcService.endCall();
    });

    on<CallStatusChangedEvent>((event, emit) {
      switch (event.status) {
        case CallStatus.ringing:
          emit(CallRinging(
            isIncoming: !webrtcService.isCaller,
            callerName: webrtcService.callerName,
            callerId: webrtcService.otherId,
          ));
          break;
        case CallStatus.connected:
          emit(CallConnected());
          break;
        case CallStatus.ended:
          emit(CallEnded());
          break;
        case CallStatus.idle:
          emit(CallIdle());
          break;
      }
    });

    on<ToggleMuteEvent>((event, emit) {
      webrtcService.toggleMute();
      if (state is CallConnected) {
        final currentState = state as CallConnected;
        emit(CallConnected(
          isMuted: !currentState.isMuted,
        ));
      }
    });
  }
}
