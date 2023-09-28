part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitialState extends HomeState {}

class EmptyHomeState extends HomeState {}

class HomeLoadingState extends HomeState {}

class TripLoadingState extends HomeState {}

class HomeErrorState extends HomeState {
  final String error;

  const HomeErrorState({required this.error});

  @override
  List<Object> get props => [error];
}

class TripErrorState extends HomeState {
  final String error;

  const TripErrorState({required this.error});

  @override
  List<Object> get props => [error];
}

class TravelLogsLoadedState extends HomeState {
  final List<Trip> trips;
  final bool activeOngoingTrip;

  const TravelLogsLoadedState({
    required this.trips,
    required this.activeOngoingTrip,
  });

  @override
  List<Object> get props => [trips, activeOngoingTrip];
}

class TripStartedState extends HomeState {
  final Trip trip;

  const TripStartedState({
    required this.trip,
  });

  @override
  List<Object> get props => [trip];
}

class TripEndedState extends HomeState {
  final Trip trip;

  const TripEndedState({
    required this.trip,
  });

  @override
  List<Object> get props => [trip];
}

class TripCanceledState extends HomeState {}

class LogsExportedState extends HomeState {}
