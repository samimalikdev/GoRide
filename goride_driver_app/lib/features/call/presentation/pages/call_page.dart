
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../bloc/call_bloc.dart';
import '../../../../injection_container.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> with TickerProviderStateMixin {
  final _callBloc = sl<CallBloc>();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _requestPermissions();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    if (_callBloc.state is! CallEnded && _callBloc.state is! CallIdle) {
      _callBloc.add(EndCallEvent());
    }
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await [Permission.microphone].request();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallBloc, CallState>(
      bloc: _callBloc,
      listener: (context, state) {
        if (state is CallEnded) {
          if (Navigator.canPop(context)) Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff0d2137), 
                Color(0xff0a1628), 
                Color(0xff091220), 
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                BlocBuilder<CallBloc, CallState>(
                  bloc: _callBloc,
                  builder: (context, state) {
                    String status = 'Connecting...';
                    Color statusColor = Colors.orangeAccent;
                    if (state is CallRinging && state.isIncoming) {
                      status = 'Incoming Call';
                      statusColor = const Color(0xff76eb07);
                    } else if (state is CallConnecting) {
                      status = 'Connecting...';
                      statusColor = Colors.orangeAccent;
                    } else if (state is CallConnected) {
                      status = 'Connected';
                      statusColor = const Color(0xff76eb07);
                    } else if (state is CallRinging && !state.isIncoming) {
                      status = 'Calling...';
                      statusColor = Colors.orangeAccent;
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: statusColor.withOpacity(0.4), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 50),

                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnim.value,
                      child: child,
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xff76eb07).withOpacity(0.08),
                          border: Border.all(
                            color: const Color(0xff76eb07).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xff76eb07).withOpacity(0.35),
                              const Color(0xff4a9204).withOpacity(0.55),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff76eb07).withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 72,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                Text(
                  _callBloc.webrtcService.callerName ?? 'Passenger',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'GoRide Passenger',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const Spacer(),

                BlocBuilder<CallBloc, CallState>(
                  bloc: _callBloc,
                  builder: (context, state) {
                    if (state is CallRinging && state.isIncoming) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(48, 0, 48, 60),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRoundBtn(
                              icon: Icons.call_end,
                              bg: Colors.red.shade600,
                              label: 'Decline',
                              size: 72,
                              onTap: () => _callBloc.add(EndCallEvent()),
                            ),
                            _buildRoundBtn(
                              icon: Icons.call,
                              bg: const Color(0xff76eb07),
                              iconColor: Colors.black,
                              label: 'Accept',
                              size: 72,
                              onTap: () => _callBloc.add(AcceptCallEvent()),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                BlocBuilder<CallBloc, CallState>(
                  bloc: _callBloc,
                  builder: (context, state) {
                    final showControls = state is CallConnected ||
                        state is CallConnecting ||
                        (state is CallRinging && !state.isIncoming);
                    if (!showControls) return const SizedBox.shrink();

                    final isMuted =
                        state is CallConnected ? state.isMuted : false;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 50),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRoundBtn(
                              icon: isMuted
                                  ? Icons.mic_off_rounded
                                  : Icons.mic_rounded,
                              bg: isMuted
                                  ? Colors.white.withOpacity(0.25)
                                  : Colors.white.withOpacity(0.12),
                              iconColor:
                                  isMuted ? Colors.redAccent : Colors.white,
                              label: isMuted ? 'Unmute' : 'Mute',
                              size: 60,
                              onTap: () => _callBloc.add(ToggleMuteEvent()),
                            ),
                            _buildRoundBtn(
                              icon: Icons.call_end,
                              bg: Colors.red.shade600,
                              label: 'End',
                              size: 72,
                              onTap: () => _callBloc.add(EndCallEvent()),
                              shadow: true,
                            ),
                            _buildRoundBtn(
                              icon: Icons.volume_up_rounded,
                              bg: Colors.white.withOpacity(0.12),
                              label: 'Speaker',
                              size: 60,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundBtn({
    required IconData icon,
    required Color bg,
    Color iconColor = Colors.white,
    required String label,
    double size = 60,
    bool shadow = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: shadow
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.45),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: iconColor, size: size * 0.42),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
