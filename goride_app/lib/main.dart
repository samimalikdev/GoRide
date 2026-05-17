import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:goride_app/features/auth/presentation/pages/mfa_page.dart';
import 'package:goride_app/features/auth/presentation/pages/mfa_setup_page.dart';
import 'package:goride_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:goride_app/features/explore/presentation/ride_tracking/bloc/ride_tracking_bloc.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/bookings/presentation/bloc/bookings_bloc.dart';
import 'features/call/presentation/bloc/call_bloc.dart';
import 'features/call/presentation/widgets/incoming_call_overlay.dart';
import 'package:goride_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';

import 'firebase_options.dart';
import 'features/explore/presentation/bloc/explore_bloc.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  await di.init();
  di.sl<NotificationService>().init().catchError((e) => print('Notification init error: $e'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(CheckAuthSession())),
        BlocProvider(create: (_) => di.sl<ExploreBloc>()),
        BlocProvider(create: (_) => di.sl<WalletBloc>()),
        BlocProvider(create: (_) => di.sl<RideTrackingBloc>()),
        BlocProvider(create: (_) => di.sl<BookingsBloc>()),
        BlocProvider(create: (_) => di.sl<CallBloc>()),
        BlocProvider(create: (_) => di.sl<ChatBloc>()),
      ],
      child: MaterialApp(

        title: 'GoRide App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: IncomingCallOverlay(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated || 
                  state is AuthMfaStatus || 
                  (state is AuthLoading && state.user != null) ||
                  (state is AuthError && state.user != null)) {
                return const HomePage();
              } else if (state is AuthMfaRequired) {
                return MfaPage(factorId: state.factorId, challengeId: state.challengeId);
              } else if (state is AuthMfaSetupRequired) {
                return MfaSetupPage(
                  qrCode: state.qrCode,
                  secret: state.secret,
                  factorId: state.factorId,
                  challengeId: state.challengeId,
                );
              }
              return const SplashPage();
            },
          ),
        ),
      ),
    );
  }
}
