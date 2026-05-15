import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goride_driver_app/core/services/socket_service.dart';
import 'package:goride_driver_app/core/services/api_service.dart';
import 'package:goride_driver_app/core/services/notification_service.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goride_driver_app/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/ride_bloc.dart';
import 'package:goride_driver_app/features/wallet/presentation/bloc/wallet_bloc.dart';

import 'package:goride_driver_app/core/services/webrtc_service.dart';
import 'package:goride_driver_app/features/call/presentation/bloc/call_bloc.dart';
import 'package:goride_driver_app/features/chat/presentation/bloc/chat_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());

  sl.registerLazySingleton(
    () => SocketService(baseUrl: 'http://192.168.100.168:3000'),
  );
  sl.registerLazySingleton(() => ApiService(client: sl(), prefs: sl()));
  sl.registerLazySingleton(() => NotificationService(sl()));
  sl.registerSingleton<WebRTCService>(WebRTCService(socketService: sl()));


  sl.registerLazySingleton(() => AuthBloc(apiService: sl(), prefs: sl(), socketService: sl(), notificationService: sl()));
  sl.registerLazySingleton(
    () => HomeBloc(apiService: sl(), authBloc: sl(), socketService: sl()),
  );
  sl.registerFactory(() => RideBloc(socketService: sl(), apiService: sl()));
  sl.registerFactory(() => WalletBloc());
  sl.registerFactory(() => SplashBloc());
  sl.registerSingleton<CallBloc>(CallBloc(webrtcService: sl()));
  sl.registerFactory(() => ChatBloc(socketService: sl(), apiService: sl()));
}
