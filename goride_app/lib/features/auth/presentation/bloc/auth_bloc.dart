import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goride_app/core/models/user_model.dart';
import 'package:goride_app/core/services/api_service.dart';
import 'package:goride_app/core/services/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goride_app/core/services/notification_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;
  final SharedPreferences prefs;
  final SocketService socketService;
  final NotificationService notificationService;
  static const String cachedUserKey = 'CACHED_USER';
  static const String authTokenKey = 'auth_token';

  AuthBloc({
    required this.apiService,
    required this.prefs,
    required this.socketService,
    required this.notificationService,
  }) : super(AuthInitial()) {


    on<CheckAuthSession>((event, emit) async {
      print('BLOC: Checking Auth Session');

      final jsonString = prefs.getString(cachedUserKey);
      if (jsonString != null) {
        final user = UserModel.fromJson(jsonDecode(jsonString));

        if (!user.isMfaVerified) {
          print('BLOC: Session found but MFA not verified, clearing...');
          await prefs.remove(cachedUserKey);
          await prefs.remove(authTokenKey);
          emit(AuthUnauthenticated());
        
        } else {
          print('BLOC: Session found for ${user.email}');
          if (user.token != null) {
            await prefs.setString(authTokenKey, user.token!);
          }
          socketService.registerUser(user.id);
          notificationService.updateTokenOnServer(user.id);
          emit(AuthAuthenticated(user: user));
        }
      } else {
        print('BLOC: No session found');
        emit(AuthUnauthenticated());
      }
    });


    on<LoginEvent>((event, emit) async {
      print('BLOC: LoginEvent ${event.email}');
      emit(AuthLoading());
      try {
        final data = await apiService.post('/auth/login', {
          'email': event.email,
          'password': event.password,
          'userType': 'rider',
        });

        if (data['data']['mfaRequired'] == true) {
          final mfaData = data['data'];
          print('BLOC: MFA required for ${event.email}');
          
          final token = mfaData['session']?['access_token'] ?? mfaData['token'];
          if (token != null) {
            await prefs.setString(authTokenKey, token);
          }
          
          final challengeData = await apiService.post('/auth/mfa/challenge', {
            'factorId': mfaData['factorId'],
          });

          emit(AuthMfaRequired(
            factorId: mfaData['factorId'],
            challengeId: challengeData['id']?.toString() ?? '',
            user: UserModel.fromJson(mfaData['user'] ?? mfaData),
          ));
        } else {
          final user = UserModel.fromJson(data['data']['user']);
          final token = data['data']['session']?['access_token'] ?? data['data']['token'];
          print('BLOC: Login successful for ${user.email}');
          
          if (token != null) {
            await prefs.setString(authTokenKey, token);
          }
          await prefs.setString(cachedUserKey, jsonEncode(user.toJson()));
          socketService.registerUser(user.id);
          notificationService.updateTokenOnServer(user.id);
          emit(AuthAuthenticated(user: user));
        }
      } catch (e) {
        emit(AuthError(message: 'Login Error: $e'));
      }
    });

    on<SignUpEvent>((event, emit) async {
      print('BLOC: SignUpEvent for ${event.email}');
      emit(AuthLoading());
      try {
        final response = await apiService.post('/auth/signup', {
          'email': event.email,
          'password': event.password,
          'fullName': event.fullName,
          'userType': 'rider',
        });

        final user = UserModel.fromJson(response['data']?['user'] ?? response['data']);
        final token = response['data']?['session']?['access_token'] ?? response['token'];
        
        if (token != null) {
          await prefs.setString(authTokenKey, token);
        }
        await prefs.setString(cachedUserKey, jsonEncode(user.toJson()));
        socketService.registerUser(user.id);
        notificationService.updateTokenOnServer(user.id);
        emit(AuthAuthenticated(user: user));
      } catch (e) {
        emit(AuthError(message: 'Signup Error: $e'));
      }
    });

    on<VerifyMfaEvent>((event, emit) async {
      print('BLOC: VerifyMfaEvent');
      final user = state.currentUser;
      emit(AuthLoading(user: user));
      
      try {
        final response = await apiService.post('/auth/mfa/verify', {
          'factorId': event.factorId,
          'challengeId': event.challengeId,
          'code': event.code,
        });

        final userResponse = response['user'] ?? response;
        final verifiedUser = UserModel.fromJson(userResponse);
        final token = response['session']?['access_token'] ?? response['token'];
        
        if (token != null) {
           await prefs.setString(authTokenKey, token);
        }
        await prefs.setString(cachedUserKey, jsonEncode(verifiedUser.toJson()));
        socketService.registerUser(verifiedUser.id);
        notificationService.updateTokenOnServer(verifiedUser.id);
        emit(AuthAuthenticated(user: verifiedUser));
      } catch (e) {
        emit(AuthError(message: 'Verification Error: $e', user: user));
      }
    });

    on<LogoutEvent>((event, emit) async {
      final user = state.currentUser;
      emit(AuthLoading());
      try {
        if (user != null) {
          await apiService.post('/auth/logout', {
            'userId': user.id,
          });
        }
      } catch (e) {
        print('BLOC: Logout error (ignoring): $e');
      }
      await prefs.remove(cachedUserKey);
      await prefs.remove(authTokenKey);
      emit(AuthUnauthenticated());
    });

    on<EnrollMfaEvent>((event, emit) async {
      final user = state.currentUser;
      if (user == null) return;
      emit(AuthLoading(user: user));
      try {
        final enrollData = await apiService.post('/auth/mfa/enroll', {});
        final mfaRoot = enrollData['data'] ?? enrollData;
        final factorId = mfaRoot['id']?.toString() ?? '';
        
        final challengeData = await apiService.post('/auth/mfa/challenge', {
          'factorId': factorId,
        });
        
        final challengeRoot = challengeData['data'] ?? challengeData;

        emit(AuthMfaSetupRequired(
          user: user,
          qrCode: mfaRoot['totp']?['uri'] ?? '',
          secret: mfaRoot['totp']?['secret'] ?? '',
          factorId: factorId,
          challengeId: challengeRoot['id']?.toString() ?? '',
        ));
      } catch (e) {
        emit(AuthError(message: 'Enrollment Error: $e', user: user));
        print('BLOC: Enrollment Error: $e');
      }
    });

    on<GetMfaStatusEvent>((event, emit) async {
      final user = state.currentUser;
      if (user == null) return;
      try {
        final data = await apiService.get('/auth/mfa/factors');
        final factors = data['all'] ?? [];
        final isEnabled = factors.any((f) => f['status'] == 'verified');
        emit(AuthMfaStatus(user: user, factors: factors, isEnabled: isEnabled));
      } catch (e) {
        emit(AuthError(message: 'Status Error: $e', user: user));
      }
    });

    on<UnenrollMfaEvent>((event, emit) async {
      final user = state.currentUser;
      if (user == null) return;
      emit(AuthLoading(user: user));
      try {
        await apiService.delete('/auth/mfa/factors/${event.factorId}');
        add(GetMfaStatusEvent());
      } catch (e) {
        emit(AuthError(message: 'Disable Error: $e', user: user));
      }
    });

    on<ChallengeMfaEvent>((event, emit) async {
      emit(AuthLoading(user: event.user));
      try {
        final challengeData = await apiService.post('/auth/mfa/challenge', {
          'factorId': event.factorId,
        });
        final challengeRoot = challengeData['data'] ?? challengeData;
        emit(AuthMfaRequired(
          factorId: event.factorId,
          challengeId: challengeRoot['id']?.toString() ?? '',
          user: event.user,
        ));
      } catch (e) {
        emit(AuthError(message: 'Challenge Error: $e', user: event.user));
      }
    });

    on<UpdateProfileEvent>((event, emit) async {
      final user = state.currentUser;
      if (user == null) return;
      emit(AuthLoading(user: user));
      try {
        final response = await apiService.post('/auth/update-profile', {
          'fullName': event.fullName,
          if (event.profilePicBase64 != null) 'profilePicBase64': event.profilePicBase64,
        });

        final updatedUserData = response['data']?['user'] ?? response['data'] ?? response;
        final tempUser = UserModel.fromJson(updatedUserData);
        final updatedUser = tempUser.copyWith(
          id: tempUser.id.isEmpty ? user.id : tempUser.id,
          email: tempUser.email.isEmpty ? user.email : tempUser.email,
          token: user.token,
          isMfaVerified: user.isMfaVerified,
        );
        
        await prefs.setString(cachedUserKey, jsonEncode(updatedUser.toJson()));
        emit(AuthAuthenticated(user: updatedUser));
      } catch (e) {
        emit(AuthError(message: 'Profile Update Error: $e', user: user));
      }
    });
  }
}

