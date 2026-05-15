import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goride_app/core/models/user_model.dart';
import 'package:goride_app/core/services/api_service.dart';
import 'package:goride_app/core/services/notification_service.dart';
import 'package:goride_app/core/services/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:goride_app/features/profile/presentation/pages/profile_page.dart';

class FakeAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  FakeAuthBloc(super.initialState);

  @override
  ApiService get apiService => throw UnimplementedError();

  @override
  SharedPreferences get prefs => throw UnimplementedError();

  @override
  SocketService get socketService => throw UnimplementedError();

  @override
  NotificationService get notificationService => throw UnimplementedError();
}

void main() {
  testWidgets('ProfilePage does not contain hardcoded stats and Refer option', (WidgetTester tester) async {
    final fakeAuthBloc = FakeAuthBloc(
      AuthAuthenticated(
        user: const UserModel(
          id: 'usr_123456789',
          email: 'rider@goride.pk',
          fullName: 'Sami Malik',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: fakeAuthBloc,
          child: const ProfilePage(),
        ),
      ),
    );

    // Verify hardcoded elements are removed
    expect(find.text('124'), findsNothing);
    expect(find.text('Refer & Earn'), findsNothing);
  });

  testWidgets('Tapping Manage Profile opens dynamic bottom sheet', (WidgetTester tester) async {
    final fakeAuthBloc = FakeAuthBloc(
      AuthAuthenticated(
        user: const UserModel(
          id: 'usr_123456789',
          email: 'rider@goride.pk',
          fullName: 'Sami Malik',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: fakeAuthBloc,
          child: const ProfilePage(),
        ),
      ),
    );

    await tester.tap(find.text('Manage Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Account Details'), findsOneWidget);
    expect(find.text('Sami Malik'), findsWidgets);
    expect(find.text('rider@goride.pk'), findsWidgets);
  });

  testWidgets('Tapping Payment Methods opens dynamic payment options sheet', (WidgetTester tester) async {
    final fakeAuthBloc = FakeAuthBloc(
      AuthAuthenticated(
        user: const UserModel(
          id: 'usr_123456789',
          email: 'rider@goride.pk',
          fullName: 'Sami Malik',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: fakeAuthBloc,
          child: const ProfilePage(),
        ),
      ),
    );

    await tester.tap(find.text('Payment Methods'));
    await tester.pumpAndSettle();

    expect(find.text('Payment Options'), findsOneWidget);
    expect(find.text('GoRide Cash'), findsOneWidget);
    expect(find.text('Credit/Debit Card'), findsOneWidget);
  });

  testWidgets('Tapping Support & Help opens dynamic support options sheet', (WidgetTester tester) async {
    final fakeAuthBloc = FakeAuthBloc(
      AuthAuthenticated(
        user: const UserModel(
          id: 'usr_123456789',
          email: 'rider@goride.pk',
          fullName: 'Sami Malik',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: fakeAuthBloc,
          child: const ProfilePage(),
        ),
      ),
    );

    await tester.tap(find.text('Support & Help'));
    await tester.pumpAndSettle();

    expect(find.text('Support & Help Center'), findsOneWidget);
    expect(find.text('Live Chat Support'), findsOneWidget);
    expect(find.text('24/7 Helpline'), findsOneWidget);
  });
}
