import 'package:attendance_app/data/repo/attendance_repo.dart';
import 'package:attendance_app/data/repo/auth_repo.dart';
import 'package:attendance_app/data/repo/site_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  final repoSite = SiteRepo();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (capture.barcodes.isEmpty) return;
    // Pause scanning while we process.
    controller.stop();

    try {
      final barcode = capture.barcodes.first;
      final sitename = barcode.rawValue?.trim();

      if (sitename == null || sitename.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid QR: empty value")),
        );
        await controller.start();
        return;
      }

      final user = await auth.getCurrentUser();
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Not logged in")));
        await controller.start();
        return;
      }

      final location = await _getLocationSafe();
      if (location == null) {
        await controller.start();
        return;
      }
      final deviceId = await auth.getDeviceId();

      final expectedSite = await repoSite.getSiteByName(sitename);

      if (expectedSite == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Site not found: $sitename")));
        Navigator.pop(context, "Site not found! $sitename");
        return;
      }

      final expectedSiteLatLong = LatLng(
        expectedSite.latitude,
        expectedSite.longitude,
      );

      final distance = const Distance().as(
        LengthUnit.Meter,
        expectedSiteLatLong,
        LatLng(location.latitude, location.longitude),
      );

      final status = distance <= expectedSite.distanceFromSite ? 'Ok' : 'Fail';

      await repo.saveAttendance(
        user: user.uid,
        email: user.email!,
        sitename: sitename,
        location: LatLng(location.latitude, location.longitude),
        status: status,
        deviceId: deviceId,
      );

      Navigator.pop(context, sitename);
    } catch (e, st) {
      debugPrint('Scan error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to record attendance: $e")),
      );
      await controller.start();
    }
  }

  Future<Position?> _getLocationSafe() async {
    final messenger = ScaffoldMessenger.of(context);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Location services are disabled.")),
      );
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Location permission is required.")),
      );
      return null;
    }

    return Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Scanner')),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),
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
