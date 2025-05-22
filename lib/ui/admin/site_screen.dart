import 'package:attendance_app/data/repo/attendance_repo.dart';
import 'package:attendance_app/data/repo/auth_repo.dart';
import 'package:flutter/material.dart';

class SiteScreen extends StatefulWidget {
  const SiteScreen({super.key});

  @override
  State<SiteScreen> createState() => _SiteScreenState();
}

class _SiteScreenState extends State<SiteScreen> {
  final repo = AttendanceRepo();
  final authRepo = AuthRepo();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}