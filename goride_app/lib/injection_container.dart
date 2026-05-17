import 'package:get_it/get_it.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/socket_service.dart';
import 'core/services/api_service.dart';
import 'core/services/notification_service.dart';
import 'features/splash/presentation/bloc/splash_bloc.dart';
import 'features/explore/presentation/bloc/explore_bloc.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'features/explore/presentation/ride_tracking/bloc/ride_tracking_bloc.dart';
import 'core/services/webrtc_service.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/call/presentation/bloc/call_bloc.dart';
import 'features/bookings/presentation/bloc/bookings_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());

  sl.registerLazySingleton(() => ApiService(client: sl(), prefs: sl()));
  sl.registerLazySingleton(() => NotificationService(sl()));

  final socketService = SocketService();
  socketService.connect('http://192.168.100.168:3000');
  sl.registerLazySingleton(() => socketService);

  sl.registerSingleton<WebRTCService>(WebRTCService(socketService: sl()));


  sl.registerFactory(() => SplashBloc());

  sl.registerLazySingleton(() => AuthBloc(
        apiService: sl(),
        prefs: sl(),
        socketService: sl(),
        notificationService: sl(),
      ));

  sl.registerFactory(
    () => ExploreBloc(apiService: sl(), socketService: sl(), authBloc: sl()),
  );
  sl.registerFactory(() => WalletBloc());
  sl.registerFactory(() => RideTrackingBloc(socketService: sl()));
  sl.registerFactory(() => ChatBloc(socketService: sl(), apiService: sl()));
  sl.registerSingleton<CallBloc>(CallBloc(webrtcService: sl()));
  sl.registerFactory(() => BookingsBloc(apiService: sl(), authBloc: sl()));
}
