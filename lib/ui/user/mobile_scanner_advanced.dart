import 'package:attendance_app/data/repo/attendance_repo.dart';
import 'package:attendance_app/data/repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScannerAdvanced extends StatefulWidget {
  const MobileScannerAdvanced({super.key});

  @override
  State<MobileScannerAdvanced> createState() => _MobileScannerAdvancedState();
}

class _MobileScannerAdvancedState extends State<MobileScannerAdvanced> {
  final MobileScannerController controller = MobileScannerController();
  final repo = AttendanceRepo();
  final auth = AuthRepo();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    final barcode = capture.barcodes.first;
    debugPrint('Scanned: ${barcode.rawValue}');
    // You can also pause/resume the scanner here if needed:
    controller.stop();

    final sitename = barcode.rawValue ?? 'Unknown';
    final location = await Geolocator.getCurrentPosition();
    final user = await auth.getCurrentUser();
  
    await repo.saveAttendance(
      user: user!.uid,
      sitename: sitename,
      location: LatLng(location.latitude, location.longitude),
    );


    Navigator.pop(context, barcode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Scanner')),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.flash_on, color: Colors.white),
                    onPressed: () => controller.toggleTorch(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cameraswitch, color: Colors.white),
                    onPressed: () => controller.switchCamera(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
