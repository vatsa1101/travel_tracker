part of 'home_bloc.dart';

abstract class HomeEvent extends Event {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchTravelLogsEvent extends HomeEvent {}

class StartTripPressedEvent extends HomeEvent {}

class CancelTripPressedEvent extends HomeEvent {}

class StopTripPressedEvent extends HomeEvent {
  final Trip trip;

  const StopTripPressedEvent({
    required this.trip,
  });

  @override
  List<Object> get props => [trip];
}

class ExportLogsPressedEvent extends HomeEvent {
  final List<Trip> trips;

  const ExportLogsPressedEvent({
    required this.trips,
  });

  @override
  List<Object> get props => [trips];
}
