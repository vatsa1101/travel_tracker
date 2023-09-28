import '../../domain/home/trip.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalDb {
  static Box? data;

  static Future init() async {
    await Hive.initFlutter();
    data = await Hive.openBox("data");
  }

  static Trip? get ongoingTrip {
    return data?.get("trip") != null ? Trip.fromJson(data!.get("trip")) : null;
  }

  static Future saveTrip(Trip trip) async {
    await data!.put('trip', trip.toJson());
  }

  static Future clearTrip() async {
    if (data != null) {
      await data!.delete("trip");
    }
  }
}
