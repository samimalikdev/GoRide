import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/mfa_setup_page.dart';

class MfaSettingsPage extends StatefulWidget {
  const MfaSettingsPage({super.key});

  @override
  State<MfaSettingsPage> createState() => _MfaSettingsPageState();
}

class _MfaSettingsPageState extends State<MfaSettingsPage> {
  bool _isMfaEnabled = false;
  String? _factorId;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthMfaStatus) {
      _isMfaEnabled = state.isEnabled;
      final verifiedFactors = state.factors.where((f) => f['status'] == 'verified');
      if (verifiedFactors.isNotEmpty) {
        _factorId = verifiedFactors.first['id'];
      }
    }
    context.read<AuthBloc>().add(GetMfaStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthMfaSetupRequired) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MfaSetupPage(
                qrCode: state.qrCode,
                secret: state.secret,
                factorId: state.factorId,
                challengeId: state.challengeId,
              ),
            ),
          ).then((_) {
            if (context.mounted) {
              context.read<AuthBloc>().add(GetMfaStatusEvent());
            }
          });
        } else if (state is AuthMfaStatus) {
          setState(() {
            _isMfaEnabled = state.isEnabled;
            if (state.isEnabled) {
              final verifiedFactors = state.factors.where((f) => f['status'] == 'verified');
              if (verifiedFactors.isNotEmpty) {
                _factorId = verifiedFactors.first['id'];
              }
            } else {
              _factorId = null;
            }
          });
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xff0a0a0a),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'SECURITY SETTINGS',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Two-Factor Authentication',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add an extra layer of security to your account. We will ask for a verification code when you log in from a new device.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xff1a1a1a),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xff76eb07).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.phonelink_lock_rounded,
                                color: Color(0xff76eb07),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Authenticator App',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _isMfaEnabled ? 'Enabled' : 'Disabled',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: _isMfaEnabled ? const Color(0xff76eb07) : Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isLoading)
                              const CupertinoActivityIndicator(color: Color(0xff76eb07))
                            else
                              CupertinoSwitch(
                                value: _isMfaEnabled,
                                activeColor: const Color(0xff76eb07),
                                trackColor: Colors.white10,
                                onChanged: (value) {
                                  if (value) {
                                    context.read<AuthBloc>().add(EnrollMfaEvent());
                                  } else if (_factorId != null) {
                                    context.read<AuthBloc>().add(UnenrollMfaEvent(_factorId!));
                                  }
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_isMfaEnabled)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Colors.blueAccent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You will need an authenticator app like Google Authenticator or Authy to set this up.',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.blueAccent.withOpacity(0.8),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
