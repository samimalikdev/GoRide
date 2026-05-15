import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goride_driver_app/features/auth/presentation/pages/mfa_page.dart';
import 'package:goride_driver_app/features/auth/presentation/pages/mfa_setup_page.dart';
import 'package:goride_driver_app/features/documents/presentation/pages/document_submission_page.dart';
import 'package:goride_driver_app/features/auth/presentation/widgets/driver_status_wrapper.dart';
import 'package:goride_driver_app/features/home/presentation/pages/home_page.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/presentation/bloc/home_event.dart';
import 'features/home/presentation/bloc/home_state.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'features/call/presentation/bloc/call_bloc.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'firebase_options.dart';
import 'features/home/presentation/bloc/ride_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:goride_driver_app/core/services/notification_service.dart';

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
        BlocProvider(create: (_) => di.sl<HomeBloc>()),
        BlocProvider(create: (_) => di.sl<WalletBloc>()),
        BlocProvider(create: (_) => di.sl<CallBloc>()),
        BlocProvider(create: (_) => di.sl<ChatBloc>()),
        BlocProvider(create: (_) => di.sl<RideBloc>()),
      ],
      child: MaterialApp(
        title: 'GoRide Driver',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated || 
                state is AuthMfaStatus || 
                (state is AuthLoading && state.user != null) ||
                (state is AuthError && state.user != null)) {
              return const DriverStatusWrapper();
            } else if (state is AuthMfaRequired) {
              return MfaPage(factorId: state.factorId, challengeId: state.challengeId);
            } else if (state is AuthMfaSetupRequired) {
              return MfaSetupPage(
                qrCode: state.qrCode,
                secret: state.secret,
                factorId: state.factorId,
                challengeId: state.challengeId,
              );
            } else if (state is AuthInitial) {
              return Container(color: Colors.black);
            }
            
            return const SplashPage();
          },
        ),
      ),
    );
  }
}
