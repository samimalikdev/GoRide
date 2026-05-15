
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/call_bloc.dart';
import '../pages/call_page.dart';
import 'package:goride_app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:goride_app/features/explore/presentation/bloc/explore_state.dart';
import 'package:goride_app/features/explore/presentation/ride_tracking/bloc/ride_tracking_bloc.dart';
import 'package:goride_app/features/explore/presentation/ride_tracking/bloc/ride_tracking_state.dart';
import 'package:goride_app/features/chat/presentation/bloc/chat_bloc.dart';

class IncomingCallOverlay extends StatelessWidget {
  final Widget child;

  const IncomingCallOverlay({super.key, required this.child});

  bool _isCallAllowed(BuildContext context, String? callerId) {
    if (callerId == null) return false;
    final exploreState = context.read<ExploreBloc>().state;
    String? activeDriverId;
    
    if (exploreState is RideAccepted) {
      activeDriverId = exploreState.driver.id.toString();
    } else if (exploreState is RideProposed) {
      activeDriverId = exploreState.driver.id.toString();
    }

    return activeDriverId != null && (callerId == activeDriverId || callerId == "driver_$activeDriverId");
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CallBloc, CallState>(
          listener: (context, state) {
            if (state is CallRinging && state.isIncoming) {
              if (_isCallAllowed(context, state.callerId)) {
                _showIncomingCallDialog(context, state.callerName);
              } else {
                context.read<CallBloc>().add(EndCallEvent());
              }
            } else if (state is CallConnected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: context.read<RideTrackingBloc>()),
                      BlocProvider.value(value: context.read<ExploreBloc>()),
                    ],
                    child: const CallPage(),
                  ),
                ),
              );
            }
          },
        ),
        BlocListener<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatLoaded && state.lastReceivedMessage != null) {
              _showNewMessagePopup(context, state.lastReceivedMessage!.text);
            }
          },
        ),
      ],
      child: child,
    );
  }

  void _showNewMessagePopup(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.chat_bubble_rounded, color: Colors.indigo, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "New Message from Driver",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70),
                  ),
                  Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xff1a1a1a),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showIncomingCallDialog(BuildContext context, String? callerName) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.indigo,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                "Incoming Call",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                callerName ?? "Unknown Driver",
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    label: "Decline",
                    onPressed: () {
                      context.read<CallBloc>().add(EndCallEvent());
                      Navigator.pop(context);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.call,
                    color: Colors.green,
                    label: "Accept",
                    onPressed: () {
                      context.read<CallBloc>().add(AcceptCallEvent());
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
