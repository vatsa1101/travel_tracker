import 'loc.dart';

class Trip {
  final DateTime startTime;
  final Loc startLoc;
  final String startAddr;
  DateTime? endTime;
  Loc? destinationLoc;
  String? destAddr;
  String? distance;

  Trip({
    required this.startTime,
    required this.startLoc,
    required this.startAddr,
    this.destAddr,
    this.destinationLoc,
    this.distance,
    this.endTime,
  });

  factory Trip.fromJson(Map<dynamic, dynamic> json) {
    return Trip(
      startTime: DateTime.fromMillisecondsSinceEpoch(json["startTime"]),
      endTime: json["endTime"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["endTime"])
          : null,
      startAddr: json["startAddr"],
      destAddr: json["destAddr"],
      startLoc: Loc(
          latitude: double.parse(json["startLat"]),
          longitude: double.parse(json["startLong"])),
      destinationLoc: json["destLat"] != null && json["destLong"] != null
          ? Loc(
              latitude: double.parse(json["destLat"]),
              longitude: double.parse(json["destLong"]))
          : null,
      distance: json["distance"],
    );
  }

  bool get isActive => distance == null;

  Map<String, dynamic> toJson() => {
        "startTime": startTime.millisecondsSinceEpoch,
        "endTime": endTime?.millisecondsSinceEpoch,
        "startLat": startLoc.latitude.toString(),
        "startLong": startLoc.longitude.toString(),
        "destLat": destinationLoc?.latitude.toString(),
        "destLong": destinationLoc?.longitude.toString(),
        "distance": distance,
        "destAddr": destAddr,
        "startAddr": startAddr,
      };
}
