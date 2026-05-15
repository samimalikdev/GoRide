import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goride_driver_app/features/home/presentation/pages/home_page.dart';
import 'package:goride_driver_app/features/wallet/presentation/pages/wallet_page.dart';
import 'package:goride_driver_app/features/profile/presentation/pages/profile_page.dart';
import 'package:goride_driver_app/features/chat/presentation/pages/chat_list_page.dart';
import 'package:goride_driver_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:goride_driver_app/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:goride_driver_app/features/call/presentation/widgets/incoming_call_overlay.dart';
import 'package:goride_driver_app/features/call/presentation/bloc/call_bloc.dart';
import 'package:goride_driver_app/features/call/presentation/pages/call_page.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:goride_driver_app/features/auth/presentation/pages/auth_page.dart';
import 'package:goride_driver_app/core/services/socket_service.dart';
import 'package:goride_driver_app/injection_container.dart';
import 'package:goride_driver_app/features/chat/presentation/bloc/chat_bloc.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ChatListPage(),
    const WalletPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
       sl<SocketService>().registerUser(authState.user.id);
       sl<SocketService>().joinDriverRoom(authState.user.id);
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthPage()),
                (route) => false,
              );
            }
          },
        ),
        BlocListener<CallBloc, CallState>(
          listener: (context, state) {
            if (state is CallRinging && state.isIncoming) {
              IncomingCallManager.show(
                context,
                callerName: state.callerName ?? 'Passenger',
                callerId: state.callerId ?? '',
                onAccept: () {
                  context.read<CallBloc>().add(AcceptCallEvent());
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CallPage()),
                  );
                },
                onDecline: () {
                  context.read<CallBloc>().add(EndCallEvent());
                },
              );
            } else if (state is CallEnded || state is CallIdle) {
              IncomingCallManager.hide();
            }
          },
        ),
        BlocListener<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatLoaded && state.lastReceivedMessage != null && _selectedIndex != 1) {
              _showNewMessagePopup(state.lastReceivedMessage!.text);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xff0a0a0a),
        extendBody: true,
        body: _pages[_selectedIndex],
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  void _showNewMessagePopup(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.chat_bubble_rounded, color: Color(0xff76eb07), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "New Message from Passenger",
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
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "OPEN",
          textColor: const Color(0xff76eb07),
          onPressed: () {
            setState(() => _selectedIndex = 1);
          },
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 110,
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff121212).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.grid_view_rounded, "Home"),
                  _buildNavItem(1, Icons.chat_bubble_outline_rounded, "Chats"),
                  _buildNavItem(2, Icons.account_balance_wallet_rounded, "Wallet"),
                  _buildNavItem(3, Icons.person_rounded, "Profile"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xff76eb07) : Colors.white24,
              size: 24,
            ),
            const SizedBox(height: 6),
            if (isActive)
              Container(
                height: 4,
                width: 4,
                decoration: const BoxDecoration(
                  color: Color(0xff76eb07),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0xff76eb07), blurRadius: 10, spreadRadius: 1)
                  ],
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
