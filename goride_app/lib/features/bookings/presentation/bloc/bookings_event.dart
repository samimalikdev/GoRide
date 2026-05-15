import 'package:equatable/equatable.dart';

abstract class BookingsEvent extends Equatable {
  const BookingsEvent();

  @override
  List<Object> get props => [];
}

class FetchBookingsEvent extends BookingsEvent {}

class ChangeBookingTabEvent extends BookingsEvent {
  final String tab;
  const ChangeBookingTabEvent(this.tab);

  @override
  List<Object> get props => [tab];
}
