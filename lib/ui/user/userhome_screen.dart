import 'package:attendance_app/data/model/attendance.dart';
import 'package:attendance_app/data/repo/attendance_repo.dart';
import 'package:attendance_app/data/repo/auth_repo.dart';
import 'package:attendance_app/nav/navigation.dart';
import 'package:attendance_app/ui/user/mobile_scanner_advanced.dart';
import 'package:attendance_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class UserhomeScreen extends StatefulWidget {
  const UserhomeScreen();

  @override
  State<UserhomeScreen> createState() => _UserhomeScreenState();
}

class _UserhomeScreenState extends State<UserhomeScreen> {
  String? scannedValue;
  LatLng? currentLatLng;

  final repo = AttendanceRepo();
  final authRepo = AuthRepo();

  String? uid;
  String? email;
  String? lastLoggedIn;

  List<Attendance> attendance = [];

  @override
  void initState() {
    super.initState();
    _getLocation(); // fetch location on app start
    _getLoggedInUser();
  }

  void _getLoggedInUser() async {
    final user = await authRepo.getCurrentUser();
    if (user != null) {
      setState(() {
        uid = user.uid;
        email = user.email;
        lastLoggedIn =
            user.metadata.lastSignInTime?.toLocal().toString().split('.')[0];
      });
      _loadAttendances();
    }
  }

  Future<void> _loadAttendances() async {
    final attendances = await repo.getUserAttendance(uid!);
    setState(() {
      attendance = attendances;
    });
  }

  void _logout() async {
    await authRepo.logout();
    if (mounted) {
      context.pushNamed(Screen.login.name); // or your login route
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Tracker',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.blueAccent),
                  ),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            SizedBox(height: 40),

            Icon(Icons.account_circle, size: 80, color: Colors.blueAccent),

            SizedBox(height: 10),

            Text(email ?? "No email", style: TextStyle(fontSize: 18)),

            SizedBox(height: 10),

            Text(
              "Last login: ${lastLoggedIn ?? 'N/A'}",
              style: TextStyle(color: Colors.grey),
            ),

            Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              SizedBox(height: 10),

              if (scannedValue != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Site: $scannedValue",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

              if (currentLatLng != null) ...[
                _buildItem(
                  context,
                  'Scan your attendance',
                  'On the next page, please scan in your attendance. '
                      'Place the camera over the QR Code',
                  const MobileScannerAdvanced(),
                  Icons.qr_code_scanner,
                  expectResult: true,
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    child: SizedBox(
                      height: 250,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: currentLatLng!,
                            initialZoom: 15,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: const ['a', 'b', 'c'],
                              userAgentPackageName: 'com.example.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  width: 50.0,
                                  height: 50.0,
                                  point: currentLatLng!,
                                  child: const Icon(
                                    Icons.location_pin,
                                    size: 40,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: Text(
                      "Attendance History",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(16.0),
                  child:
                      attendance.isEmpty
                          ? Center(
                            child: Text(
                              "No records",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                attendance.length > 7 ? 7 : attendance.length,
                            itemBuilder:
                                (context, index) => AttendanceItem(
                                  attendance: attendance[index],
                                ),
                          ),
                ),
              ] else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    String label,
    String subtitle,
    Widget page,
    IconData icon, {
    bool expectResult = false,
  }) {
    return GestureDetector(
      onTap: () async {
        if (expectResult) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );

          if (result is String) {
            setState(() {
              scannedValue = result; // sitename from MobileScannerAdvanced
            });
            _loadAttendances(); // reload the list
          }
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
        }
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blueAccent),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceItem extends StatelessWidget {
  AttendanceItem({super.key, required this.attendance});
  final Attendance attendance;
  final utils = Utils();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      //margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Sitename
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    attendance.sitename,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                attendance.status == "Ok"
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.cancel, color: Colors.red),

                const SizedBox(width: 8),
                Text(
                  attendance.status,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// Status
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  utils.formatTimestamp(attendance.timestamp),
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
