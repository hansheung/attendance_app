import 'package:attendance_app/ui/user/mobile_scanner_advanced.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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

  @override
  void initState() {
    super.initState();
    _getLocation(); // fetch location on app start
  }

  Future<void> _getLocation() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    debugPrint("ServiceEnabled: $serviceEnabled");

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

          if (result is Barcode) {
            setState(() {
              scannedValue = result.rawValue ?? 'No value';
            });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workers Attendance Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
          
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
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
              SizedBox(height: 20),

              if (scannedValue != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Scanned Code: $scannedValue",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
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
}
