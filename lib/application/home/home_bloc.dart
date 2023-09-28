import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/localDb/local_db.dart';
import '../../domain/home/loc.dart';
import '../../domain/home/trip.dart';
import '../../domain/utils/event.dart';
import '../../data/repository/api_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:csv/csv.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ApiRepository apiRepository = const ApiRepository();

  bool hasLocationPermission(LocationPermission permission) {
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  HomeBloc(HomeState homeInitial) : super(homeInitial) {
    on<FetchTravelLogsEvent>((event, emit) async {
      emit(HomeLoadingState());
      try {
        final trips = await apiRepository.getTravelLogs();
        bool activeTrip = false;
        if (LocalDb.ongoingTrip != null) {
          trips.insert(0, LocalDb.ongoingTrip!);
          activeTrip = true;
        }
        emit(TravelLogsLoadedState(
          trips: trips,
          activeOngoingTrip: activeTrip,
        ));
      } catch (e) {
        emit(HomeErrorState(error: e.toString()));
      }
    });
    on<StartTripPressedEvent>((event, emit) async {
      emit(TripLoadingState());
      HapticFeedback.heavyImpact();
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (!hasLocationPermission(permission)) {
          permission = await Geolocator.requestPermission();
          if (!hasLocationPermission(permission)) {
            emit(const TripErrorState(error: "Please grant location access"));
            return;
          }
        }
        final position = await Geolocator.getCurrentPosition();
        final currentLoc = Loc(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        final currentAddr = await apiRepository.getAddress(currentLoc);
        final trip = Trip(
          startTime: DateTime.now(),
          startLoc: currentLoc,
          startAddr: currentAddr,
        );
        emit(TripStartedState(
          trip: trip,
        ));
        await LocalDb.saveTrip(trip);
      } catch (e) {
        emit(TripErrorState(error: e.toString()));
      }
    });
    on<StopTripPressedEvent>((event, emit) async {
      emit(TripLoadingState());
      HapticFeedback.heavyImpact();
      try {
        final currentLoc = await Geolocator.getCurrentPosition();
        event.trip.endTime = DateTime.now();
        event.trip.destinationLoc = Loc(
          latitude: currentLoc.latitude,
          longitude: currentLoc.longitude,
        );
        (String, String) result = await apiRepository.getDistance(
          start: event.trip.startLoc,
          destination: event.trip.destinationLoc!,
        );
        event.trip.distance = result.$1;
        event.trip.destAddr = result.$2;
        emit(TripEndedState(
          trip: event.trip,
        ));
        await LocalDb.clearTrip();
        await apiRepository.saveTrip(event.trip);
      } catch (e) {
        emit(const TripErrorState(error: "Failed to calculate trip details"));
      }
    });
    on<CancelTripPressedEvent>((event, emit) async {
      emit(TripCanceledState());
      HapticFeedback.heavyImpact();
      try {
        await LocalDb.clearTrip();
      } catch (e) {
        emit(TripErrorState(error: e.toString()));
      }
    });
    on<ExportLogsPressedEvent>((event, emit) async {
      emit(EmptyHomeState());
      try {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        PermissionStatus status = androidInfo.version.sdkInt >= 33
            ? await Permission.manageExternalStorage.request()
            : await Permission.storage.request();
        if (status.isGranted) {
          List<List<dynamic>> rows = [];

          List<dynamic> row = [];
          row.add("Start Time");
          row.add("End Time");
          row.add("Origin Latitude");
          row.add("Origin Longitude");
          row.add("Origin Address");
          row.add("Destination Latitude");
          row.add("Destination Longitude");
          row.add("Destination Address");
          row.add("Distance");
          rows.add(row);

          for (int i = 0; i < event.trips.length; i++) {
            List<dynamic> row = [];
            row.add(event.trips[i].startTime.toString());
            row.add(event.trips[i].endTime?.toString());
            row.add(event.trips[i].startLoc.latitude);
            row.add(event.trips[i].startLoc.longitude);
            row.add(event.trips[i].startAddr);
            row.add(event.trips[i].destinationLoc?.latitude);
            row.add(event.trips[i].destinationLoc?.longitude);
            row.add(event.trips[i].destAddr);
            row.add(event.trips[i].distance);
            rows.add(row);
          }

          String csv = const ListToCsvConverter().convert(rows);
          String dir = await ExternalPath.getExternalStoragePublicDirectory(
              ExternalPath.DIRECTORY_DOWNLOADS);
          File file = File("$dir/travel_logs.csv");
          await file.writeAsString(csv);
          emit(LogsExportedState());
        }
      } catch (e) {
        emit(TripErrorState(error: e.toString()));
      }
    });
  }
}
