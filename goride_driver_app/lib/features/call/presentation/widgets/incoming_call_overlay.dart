import 'package:flutter/material.dart';

class IncomingCallManager {
  static BuildContext? _dialogContext;
  static bool _isShowing = false;

  static void show(
    BuildContext context, {
    required String callerName,
    required String callerId,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
    if (_isShowing) return;
    _isShowing = true;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        _dialogContext = bottomSheetContext;
        return PopScope(
          canPop: false,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(
                top: BorderSide(color: Color(0xff76eb07), width: 2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff76eb07).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_in_talk_rounded,
                    size: 40,
                    color: Color(0xff76eb07),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Incoming Call",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.call_end_rounded,
                      color: Colors.redAccent,
                      label: "Decline",
                      onPressed: () {
                        hide();
                        onDecline();
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.call_rounded,
                      color: const Color(0xff76eb07),
                      label: "Accept",
                      onPressed: () {
                        hide();
                        onAccept();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      _isShowing = false;
      _dialogContext = null;
    });
  }

  static void hide() {
    if (_isShowing && _dialogContext != null) {
      if (_dialogContext!.mounted) {
        Navigator.of(_dialogContext!).pop();
      }
      _isShowing = false;
      _dialogContext = null;
    }
  }

  static Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Icon(
              icon,
              color: color == const Color(0xff76eb07) ? Colors.black : Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
