import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/home/home_bloc.dart';
import './widgets/trip_widget.dart';
import './widgets/welcome_widget.dart';
import '../utils/size_helpers.dart';
import '../widgets/custom_toast.dart';
import '../../domain/home/trip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool isTripLoading = false;
  bool activeTrip = false;
  bool isError = false;
  String error = '';
  List<Trip> trips = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (context) =>
          HomeBloc(HomeInitialState())..add(FetchTravelLogsEvent()),
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeLoadingState) {
            isLoading = true;
            isError = false;
          }
          if (state is HomeErrorState) {
            error = state.error;
            isError = true;
            isLoading = false;
          }
          if (state is TravelLogsLoadedState) {
            trips = state.trips;
            activeTrip = state.activeOngoingTrip;
            isLoading = false;
            isError = false;
          }
          if (state is TripLoadingState) {
            isTripLoading = true;
          }
          if (state is TripErrorState) {
            isTripLoading = false;
            showErrorToast(context: context, error: state.error);
          }
          if (state is TripStartedState) {
            trips.insert(0, state.trip);
            activeTrip = true;
            isTripLoading = false;
            showToast(context: context, message: "Trip Started");
          }
          if (state is TripEndedState) {
            activeTrip = false;
            isTripLoading = false;
            showToast(context: context, message: "Trip Finished");
          }
          if (state is TripCanceledState) {
            activeTrip = false;
            trips.removeAt(0);
            showToast(context: context, message: "Trip Canceled");
          }
          if (state is LogsExportedState) {
            showToast(
                context: context, message: "Travel logs exported successfully");
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              surfaceTintColor: Colors.white,
              title: Row(
                children: [
                  Image.asset(
                    "assets/images/icon-fit.png",
                    height: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Flexible(
                    child: AutoSizeText(
                      "Travel Tracker",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                      minFontSize: 1,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              actions: trips.isNotEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 10,
                        ),
                        child: IconButton(
                          onPressed: () => context
                              .read<HomeBloc>()
                              .add(ExportLogsPressedEvent(trips: trips)),
                          icon: const Icon(
                            Icons.file_download,
                            color: Colors.orange,
                          ),
                        ),
                      )
                    ]
                  : null,
            ),
            body: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : isError
                    ? Center(
                        child: AutoSizeText(
                          error,
                          minFontSize: 1,
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: trips.isEmpty
                                ? const WelcomeWidget()
                                : Stack(
                                    children: [
                                      ListView.builder(
                                        itemCount: trips.length,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (_, i) => TripWidget(
                                          trip: trips[i],
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        child: Container(
                                          height: 30,
                                          width: context.width,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white,
                                                Colors.white.withOpacity(0),
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          if (activeTrip)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 10,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isTripLoading
                                      ? () {}
                                      : () => context
                                          .read<HomeBloc>()
                                          .add(CancelTripPressedEvent()),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const AutoSizeText(
                                    "Cancel Trip",
                                    minFontSize: 1,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 20,
                              top: 10,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isTripLoading
                                    ? () {}
                                    : () => activeTrip
                                        ? context.read<HomeBloc>().add(
                                            StopTripPressedEvent(
                                                trip: trips.first))
                                        : context
                                            .read<HomeBloc>()
                                            .add(StartTripPressedEvent()),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: isTripLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : AutoSizeText(
                                        activeTrip
                                            ? "Finish Trip"
                                            : "Start Trip",
                                        minFontSize: 1,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
          );
        },
      ),
    );
  }
}
