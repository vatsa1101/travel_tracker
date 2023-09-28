import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/home/trip.dart';

import '../../domain/home/loc.dart';

import '../../domain/utils/logger.dart';

class ApiRepository {
  const ApiRepository();

  Future<List<Trip>> getTravelLogs() async {
    try {
      logger.i("Making request to get travel logs");
      final query = await FirebaseFirestore.instance
          .collection("trips")
          .where("uid", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .orderBy("startTime", descending: true)
          .get();
      final trips = query.docs.map((e) => Trip.fromJson(e.data())).toList();
      logger.i(query.docs.map((e) => e.data()).toList());
      return trips;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getAddress(Loc location) async {
    try {
      logger.i("Making request to get distance between two locations");
      final response = await Dio().get(
        "https://maps.googleapis.com/maps/api/geocode/json",
        queryParameters: {
          "latlng": "${location.latitude},${location.longitude}",
          "language": "en",
          "key": dotenv.env["MAPS_KEY"],
        },
      );
      logger.i(response.data["results"][0]["formatted_address"]);
      return response.data["results"][0]["formatted_address"].toString();
    } catch (e) {
      rethrow;
    }
  }

  Future<(String, String)> getDistance({
    required Loc start,
    required Loc destination,
  }) async {
    try {
      logger.i("Making request to get distance between two locations");
      final response = await Dio().get(
        "https://maps.googleapis.com/maps/api/distancematrix/json",
        queryParameters: {
          "origins": "${start.latitude},${start.longitude}",
          "destinations": "${destination.latitude},${destination.longitude}",
          "key": dotenv.env["MAPS_KEY"],
        },
      );
      logger.i(response.data);
      return (
        response.data["rows"][0]["elements"][0]["distance"]["text"].toString(),
        response.data["destination_addresses"][0].toString()
      );
    } catch (e) {
      rethrow;
    }
  }

  Future saveTrip(Trip trip) async {
    try {
      logger.i("Making request to save trip");
      await FirebaseFirestore.instance.collection("trips").add({
        ...trip.toJson(),
        "uid": FirebaseAuth.instance.currentUser?.uid,
      });
      return;
    } catch (e) {
      rethrow;
    }
  }
}
