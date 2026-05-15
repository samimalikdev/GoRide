import 'package:equatable/equatable.dart';
import '../../data/models/booking_model.dart';

abstract class BookingsState extends Equatable {
  const BookingsState();
  
  @override
  List<Object> get props => [];
}

class BookingsInitial extends BookingsState {}

class BookingsLoading extends BookingsState {}

class BookingsLoaded extends BookingsState {
  final List<BookingModel> allBookings;
  final List<BookingModel> filteredBookings;
  final String activeTab;

  const BookingsLoaded({
    required this.allBookings,
    required this.filteredBookings,
    this.activeTab = 'Active',
  });

  @override
  List<Object> get props => [allBookings, filteredBookings, activeTab];
}

class BookingsError extends BookingsState {
  final String message;
  const BookingsError(this.message);

  @override
  List<Object> get props => [message];
}
