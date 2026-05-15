
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:goride_app/features/explore/presentation/ride_tracking/bloc/ride_tracking_bloc.dart';
import 'package:goride_app/features/explore/presentation/ride_tracking/bloc/ride_tracking_state.dart';
import 'package:goride_app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:goride_app/features/explore/presentation/bloc/explore_state.dart';
import '../bloc/call_bloc.dart';
import '../../../../injection_container.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _callBloc = sl<CallBloc>();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _callBloc.webrtcService.initRenderers();
  }

  @override
  void dispose() {
    if (_callBloc.state is! CallEnded && _callBloc.state is! CallIdle) {
      _callBloc.add(EndCallEvent());
    }
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.microphone,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CallBloc, CallState>(
          bloc: _callBloc,
          listener: (context, state) {
            if (state is CallEnded) {
              Navigator.pop(context);
            }
          },
        ),
        BlocListener<RideTrackingBloc, RideTrackingState>(
          listener: (context, state) {
            if (state is RideTrackingActive && state.isCompleted) {
              _callBloc.add(EndCallEvent());
            }
          },
        ),
        BlocListener<ExploreBloc, ExploreState>(
          listener: (context, state) {
            if (state is ExploreInitial || state is ExploreLoaded || state is RideCancelled) {
              _callBloc.add(EndCallEvent());
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xff0a0a0a),
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: const Color(0xff0a0a0a),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xff76eb07).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xff76eb07).withOpacity(0.2), width: 2),
                        ),
                        child: const Icon(Icons.person_rounded, color: Color(0xff76eb07), size: 80),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "AUDIO CALL",
                        style: TextStyle(
                          color: Color(0xff76eb07), 
                          letterSpacing: 4, 
                          fontSize: 12,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  BlocBuilder<CallBloc, CallState>(
                    bloc: _callBloc,
                    builder: (context, state) {
                      String status = "Connecting...";
                      if (state is CallRinging) status = "Ringing...";
                      if (state is CallConnected) status = "Connected";
                      
                      return Column(
                        children: [
                          Text(
                            _callBloc.webrtcService.callerName ?? "Driver",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xff76eb07).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xff76eb07).withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xff76eb07),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xff76eb07),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 60,
              left: 40,
              right: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xff1a1a1a).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMediaToggle(
                      bloc: _callBloc,
                    ),
                    _buildControlButton(
                      icon: Icons.call_end,
                      color: Colors.redAccent,
                      size: 75,
                      isCallEnd: true,
                      onPressed: () {
                        _callBloc.add(EndCallEvent());
                      },
                    ),
                    _buildControlButton(
                      icon: Icons.volume_up_rounded,
                      color: Colors.white.withOpacity(0.1),
                      onPressed: () {
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaToggle({required CallBloc bloc}) {
    return BlocBuilder<CallBloc, CallState>(
      bloc: bloc,
      builder: (context, state) {
        bool isActive = false;
        if (state is CallConnected) {
          isActive = state.isMuted;
        }
        
        IconData icon = isActive ? Icons.mic_off_rounded : Icons.mic_rounded;

        return _buildControlButton(
          icon: icon,
          color: isActive ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
          iconColor: isActive ? Colors.redAccent : Colors.white,
          onPressed: () => bloc.add(ToggleMuteEvent()),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    Color iconColor = Colors.white,
    double size = 60,
    bool isCallEnd = false,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: isCallEnd ? [
            BoxShadow(
              color: Colors.redAccent.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ] : null,
        ),
        child: Icon(icon, color: iconColor, size: size * 0.4),
      ),
    );
  }
}
