import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goride_app/core/core.dart';
import 'package:goride_app/features/home/presentation/pages/home_page.dart';
import 'package:pinput/pinput.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class MfaPage extends StatefulWidget {
  final String factorId;
  final String challengeId;

  const MfaPage({super.key, required this.factorId, required this.challengeId});

  @override
  State<MfaPage> createState() => _MfaPageState();
}

class _MfaPageState extends State<MfaPage> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: outfitStyle(
        size: 24,
        color: Colors.white,
        fw: .w900,
      ),
      decoration: BoxDecoration(
        borderRadius: .circular(16),
        border: Border.all(color: borderColor),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.read<AuthBloc>().add(LogoutEvent());
            }
          },
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              }
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SafeArea(
              child: Padding(
                padding: const .symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const .all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF76EB07).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF76EB07).withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_person_outlined,
                        color: Color(0xFF76EB07),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Access Control',
                      style: outfitStyle(
                        size: 32,
                        fw: .w900,
                        color: Colors.white,
                      ).copyWith(letterSpacing: -1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Verification required. Enter the 6-digit synchronization code from your authenticator app.',
                      style: outfitStyle(
                        size: 16,
                        color: const Color(0xFF737373),
                        fw: .w500,
                      ).copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 48),
                    Center(
                      child: Pinput(
                        length: 6,
                        controller: pinController,
                        focusNode: focusNode,
                        defaultPinTheme: defaultPinTheme,
                        separatorBuilder: (index) => const SizedBox(width: 8),
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        onCompleted: (pin) {
                          if (state is! AuthLoading) {
                            context.read<AuthBloc>().add(
                              VerifyMfaEvent(
                                factorId: widget.factorId,
                                challengeId: widget.challengeId,
                                code: pin,
                              ),
                            );
                          }
                        },
                        cursor: Column(
                          mainAxisAlignment: .end,
                          children: [
                            Container(
                              margin: const .only(bottom: 9.0),
                              width: 22,
                              height: 1,
                              color: primaryNeon,
                            ),
                          ],
                        ),
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryNeon),
                            boxShadow: [
                              BoxShadow(
                                color: primaryNeon.withValues(alpha: 0.2),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        submittedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            color: fillColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primaryNeon),
                          ),
                        ),
                        errorPinTheme: defaultPinTheme.copyBorderWith(
                          border: Border.all(color: Colors.redAccent),
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (pinController.text.length == 6) {
                                  context.read<AuthBloc>().add(
                                    VerifyMfaEvent(
                                      factorId: widget.factorId,
                                      challengeId: widget.challengeId,
                                      code: pinController.text,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF76EB07),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: .circular(20),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: const Color(
                            0xFF76EB07,
                          ).withValues(alpha: 0.5),
                        ),
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                'Verify Identity',
                                style: outfitStyle(
                                  size: 16,
                                  fw: .w900,
                                ).copyWith(letterSpacing: 0.5),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            context.read<AuthBloc>().add(LogoutEvent());
                          }
                        },
                        child: Text(
                          'BACK TO CREDENTIALS',
                          style: outfitStyle(
                            size: 12,
                            fw: .w900,
                            color: const Color(0xFF737373),
                          ).copyWith(letterSpacing: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
