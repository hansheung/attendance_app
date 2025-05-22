import 'package:attendance_app/data/model/attendance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class AttendanceRepo {
  final CollectionReference attendanceCollection =
      FirebaseFirestore.instance.collection('attendance');

  Future<void> saveAttendance({
    required String user,
    required String email,
    required String sitename,
    required LatLng location,
  }) async {
    final expectedSite = LatLng(1.414183, 100.337117);
    final distance = const Distance().as(
      LengthUnit.Meter,
      expectedSite,
      location,
    );

    final status = distance <= 50 ? 'Ok' : 'Fail';

    final attendance = Attendance(
      user: user,
      email: email,
      sitename: sitename,
      latitude: location.latitude,
      longitude: location.longitude,
      timestamp: DateTime.now().toLocal().toIso8601String(),
      status: status,
    );

    await attendanceCollection.add(attendance.toMap());
    print("Attendance saved with status: $status");
  }

  Future<List<Attendance>> getUserAttendance(String userId) async {
    final querySnapshot = await attendanceCollection
        .where('user', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Attendance.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Attendance>> getAttendances() async {
    final querySnapshot = await attendanceCollection
        .get();

    return querySnapshot.docs
        .map((doc) => Attendance.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
