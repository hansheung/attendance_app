import 'package:attendance_app/data/model/attendance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class AttendanceRepo {
  final FirebaseFirestore _firestore;

  AttendanceRepo({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final _collection = 'attendance';

  Future<void> saveAttendance({
    required String user,
    required String sitename,
    required LatLng location,
  }) async {
    final expectedSite = LatLng(6.419910, 100.312764);
    final distance = const Distance().as(
      LengthUnit.Meter,
      expectedSite,
      location,
    );

    final status = distance <= 50 ? 'Ok' : 'Fail';

    final attendance = Attendance(
      user: user,
      sitename: sitename,
      latitude: location.latitude,
      longitude: location.longitude,
      timestamp: DateTime.now().toUtc().toIso8601String(),
      status: status,
    );

    await _firestore.collection(_collection).add(attendance.toMap());
    print("Attendance saved with status: $status");
  }

  Future<List<Attendance>> getUserAttendance(String userId) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('user', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Attendance.fromMap(doc.data()))
        .toList();
  }
}
