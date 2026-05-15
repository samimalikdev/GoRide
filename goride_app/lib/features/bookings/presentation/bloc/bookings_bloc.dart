import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/booking_model.dart';
import 'bookings_event.dart';
import 'bookings_state.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  final ApiService apiService;
  final AuthBloc authBloc;

  BookingsBloc({required this.apiService, required this.authBloc}) : super(BookingsInitial()) {
    on<FetchBookingsEvent>(_onFetchBookings);
    on<ChangeBookingTabEvent>(_onChangeTab);
  }

  Future<void> _onFetchBookings(FetchBookingsEvent event, Emitter<BookingsState> emit) async {
    final user = authBloc.state.currentUser;
    if (user == null) {
      emit(const BookingsError("User not logged in"));
      return;
    }

    emit(BookingsLoading());
    try {
      final response = await apiService.get('/rides/history', query: {'userId': user.id});
      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'] ?? [];
        final bookings = data.map((b) => BookingModel.fromJson(b)).toList();
        
        final filtered = _filterByTab(bookings, 'Active');
        
        emit(BookingsLoaded(
          allBookings: bookings,
          filteredBookings: filtered,
          activeTab: 'Active',
        ));
      } else {
        emit(BookingsError(response['message'] ?? "Failed to fetch bookings"));
      }
    } catch (e) {
      emit(BookingsError(e.toString()));
    }
  }

  void _onChangeTab(ChangeBookingTabEvent event, Emitter<BookingsState> emit) {
    if (state is BookingsLoaded) {
      final currentState = state as BookingsLoaded;
      final filtered = _filterByTab(currentState.allBookings, event.tab);
      
      emit(BookingsLoaded(
        allBookings: currentState.allBookings,
        filteredBookings: filtered,
        activeTab: event.tab,
      ));
    }
  }

  List<BookingModel> _filterByTab(List<BookingModel> all, String tab) {
    switch (tab) {
      case 'Active':
        return all.where((b) => ['pending', 'driver_assigned', 'accepted', 'driver_arrived', 'started'].contains(b.status)).toList();
      case 'Completed':
        return all.where((b) => b.status == 'completed').toList();
      case 'Cancelled':
        return all.where((b) => b.status == 'cancelled').toList();
      default:
        return all;
    }
  }
}
