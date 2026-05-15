import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goride_driver_app/features/auth/presentation/pages/auth_page.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';
import '../../../../injection_container.dart' as di;
import 'package:google_fonts/google_fonts.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _sliderPosition = 0;
  bool _isUnlocked = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<SplashBloc>()..add(StartSplashEvent()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.6,
                  child: Image.asset(
                    'assets/background/IMg.png',
                    fit: BoxFit.cover,
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
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black,
                      ],
                      stops: const [0.0, 0.4, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xff76eb07).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xff76eb07).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          "DRIVER PARTNER",
                          style: GoogleFonts.outfit(
                            color: const Color(0xff76eb07),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "DRIVE\nEARN\nREPEAT",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 64,
                          height: 0.9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Join the elite network of GoRide drivers. High earnings, total flexibility.",
                        style: GoogleFonts.outfit(
                          color: Colors.white60,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 60),
                      
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double maxWidth = constraints.maxWidth;
                          double handleSize = 65.0;
                          double maxSlide = maxWidth - handleSize - 10;

                          return Container(
                            height: 75,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Center(
                                  child: Text(
                                    "SLIDE TO START",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white38,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 3,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 5 + _sliderPosition,
                                  child: GestureDetector(
                                    onHorizontalDragUpdate: (details) {
                                      if (!_isUnlocked) {
                                        setState(() {
                                          _sliderPosition += details.delta.dx;
                                          if (_sliderPosition < 0) _sliderPosition = 0;
                                          if (_sliderPosition > maxSlide) _sliderPosition = maxSlide;
                                        });
                                      }
                                    },
                                    onHorizontalDragEnd: (details) {
                                      if (_sliderPosition > maxSlide * 0.8) {
                                        setState(() {
                                          _sliderPosition = maxSlide;
                                          _isUnlocked = true;
                                        });
                                        Future.delayed(const Duration(milliseconds: 300), () {
                                          if (context.mounted) {
                                            Navigator.of(context).pushReplacement(
                                              PageRouteBuilder(
                                                pageBuilder: (c, a1, a2) => const AuthPage(),
                                                transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                                                transitionDuration: const Duration(milliseconds: 500),
                                              ),
                                            );
                                          }
                                        });
                                      } else {
                                        setState(() {
                                          _sliderPosition = 0;
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: handleSize,
                                      width: handleSize,
                                      decoration: BoxDecoration(
                                        color: const Color(0xff76eb07),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xff76eb07).withValues(alpha: 0.4),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _isUnlocked ? Icons.check : Icons.chevron_right_rounded,
                                        color: Colors.black,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
