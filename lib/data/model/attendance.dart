import 'package:latlong2/latlong.dart';

class Attendance {
  final String user; // new field
  final String sitename;
  final double latitude;
  final double longitude;
  final String timestamp;
  final String status;

  Attendance({
    required this.user,
    required this.sitename,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.status,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      user: map['user'] ?? '',
      sitename: map['sitename'] ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timestamp: map['timestamp'] ?? '',
      status: map['status'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'sitename': sitename,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'status': status,
    };
  }

}
