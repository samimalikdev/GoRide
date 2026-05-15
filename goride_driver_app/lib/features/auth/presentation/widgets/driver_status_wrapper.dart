import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goride_driver_app/features/documents/presentation/pages/document_submission_page.dart';
import 'package:goride_driver_app/features/home/presentation/pages/main_navigation_page.dart';
import 'package:goride_driver_app/features/splash/presentation/pages/splash_page.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_event.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_state.dart';

class DriverStatusWrapper extends StatefulWidget {
  const DriverStatusWrapper({super.key});

  @override
  State<DriverStatusWrapper> createState() => _DriverStatusWrapperState();
}

class _DriverStatusWrapperState extends State<DriverStatusWrapper> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(FetchDriverStatusEvent());
  }

  String? _lastStatus;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeStatusUpdated) {
          _lastStatus = state.verificationStatus;
        }

        if (_lastStatus == 'approved') {
          return const MainNavigationPage();
        } else if (_lastStatus != null) {
          return const DocumentSubmissionPage();
        }

        if (state is HomeInitial || state is HomeLoading) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Color(0xff76eb07))),
          );
        }

        if (state is HomeError) {
          return const DocumentSubmissionPage();
        }

        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Color(0xff76eb07))),
        );
      },
    );
  }
}
