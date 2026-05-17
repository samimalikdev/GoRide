import 'package:flutter/material.dart';
import 'package:goride_app/core/core.dart';

class OptionsRow extends StatelessWidget {
  const OptionsRow({
    super.key,
    required this.isLoginTab,
    required this.rememberMe,
    required this.acceptTerms,
    required this.onRememberMe,
    required this.onAcceptTerms,
  });

  final bool isLoginTab;
  final bool rememberMe;
  final bool acceptTerms;
  final VoidCallback onRememberMe;
  final VoidCallback onAcceptTerms;

  @override
  Widget build(BuildContext context) {
    if (isLoginTab) {
      return Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          GestureDetector(
            onTap: onRememberMe,
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: rememberMe ? primaryNeon : Colors.transparent,
                    border: Border.all(
                      color: rememberMe ? primaryNeon : Colors.white24,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: rememberMe
                      ? const Icon(Icons.check, color: Colors.black, size: 14)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  'Remember me',
                  style: style(color: Colors.white38, size: 13),
                ),
              ],
            ),
          ),
          Text(
            'Forgot Password?',
            style: style(color: primaryNeon, size: 13, fw: .w600),
          ),
        ],
      );
    } else {
      return GestureDetector(
        onTap: onAcceptTerms,
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: acceptTerms ? primaryNeon : Colors.transparent,
                border: Border.all(
                  color: acceptTerms ? primaryNeon : Colors.white24,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: acceptTerms
                  ? const Icon(Icons.check, color: Colors.black, size: 14)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'I agree to the Terms of Service and Privacy Policy',
                style: style(color: Colors.white38, size: 12),
              ),
            ),
          ],
        ),
      );
    }
  }
}
