import 'dart:io';
import 'package:attendance_app/data/model/attendance.dart';
import 'package:attendance_app/data/repo/attendance_repo.dart';
import 'package:attendance_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

class ExportAttendanceScreen extends StatefulWidget {
  const ExportAttendanceScreen({super.key});

  @override
  State<ExportAttendanceScreen> createState() => _ExportAttendanceScreenState();
}

class _ExportAttendanceScreenState extends State<ExportAttendanceScreen> {
  final repo = AttendanceRepo();
  List<Attendance> _all = [];
  List<Attendance> _filtered = [];
  String _selectedSite = 'Select Site';
  String _selectedUser = 'Select User';
  String _selectedStatus = 'All';

  List<String> _siteList = [];
  List<String> _userList = [];
  final _statusList = ['All', 'Ok', 'Fail'];


  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadAttendances();
  }

  Future<void> _loadAttendances() async {
    final data = await repo.getAttendances();
    setState(() {
      _all = data;
      _filtered = data;
      _siteList = [
        'Select Site',
        ...data.map((a) => a.sitename).toSet().toList(),
      ];
      _userList = ['Select User', ...data.map((a) => a.email).toSet().toList()];
    });
  }

  void _applyFilter() {
    setState(() { //Don't put complex logic in setState. setState we use to re-render.
      _filtered =
          _all.where((a) {
            final matchSite =
                _selectedSite == 'Select Site' || a.sitename == _selectedSite;
            final matchUser =
                _selectedUser == 'Select User' || a.email == _selectedUser;
            final matchStatus =
                _selectedStatus == 'All' || a.status == _selectedStatus;
                
            final aDate = DateTime.parse(a.timestamp);
            final matchStart =
                _startDate == null || !aDate.isBefore(_startDate!);
            final matchEnd = _endDate == null || !aDate.isAfter(_endDate!);
            return matchSite && matchUser && matchStatus && matchStart && matchEnd;
          }).toList();
    });
  }

  Future<void> _exportCSV() async {
    List<List<String>> rows = [
      [
        'User',
        'Email',
        'Sitename',
        'Latitude',
        'Longitude',
        'Timestamp',
        'Status',
      ],
    ];

    for (var a in _filtered) {
      rows.add([
        a.user,
        a.email,
        a.sitename,
        a.latitude.toString(),
        a.longitude.toString(),
        a.timestamp,
        a.status,
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/attendance_export.csv';
    final file = File(path);
    await file.writeAsString(csvData);

    Share.shareXFiles([XFile(file.path)], text: 'Exported Attendance CSV');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Attendance'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.lightGreenAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Dropdown filters
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: _selectedSite, //Initial value
                    items:
                        _siteList.map((site) {
                          return DropdownMenuItem(value: site, child: Text(site));
                        }).toList(),
                    onChanged: (value) {
                      _selectedSite = value!;
                      _applyFilter();
                    },
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: _selectedUser,
                    items:
                        _userList.map((user) {
                          return DropdownMenuItem(value: user, child: Text(user));
                        }).toList(),
                    onChanged: (value) {
                      _selectedUser = value!;
                      _applyFilter();
                    },
                  ),
                ],
              ),
              const SizedBox(width: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: _selectedStatus,
                    items:
                        _statusList.map((status) {
                          return DropdownMenuItem(value: status, child: Text(status));
                        }).toList(),
                    onChanged: (value) {
                      _selectedStatus = value!;
                      _applyFilter();
                    },
                  ),
                ],
              ),
              const SizedBox(width: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _startDate == null
                          ? "Start Date"
                          : "${_startDate!.day}-${_startDate!.month}-${_startDate!.year}",
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                        });
                        _applyFilter();
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _endDate == null
                          ? "End Date"
                          : "${_endDate!.day}-${_endDate!.month}-${_endDate!.year}",
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _endDate = picked;
                        });
                        _applyFilter();
                      }
                    },
                  ),
                ],
              ),
        
              const SizedBox(height: 16),
        
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text("Export CSV"),
                onPressed: _filtered.isEmpty ? null : _exportCSV,
              ),
        
              const SizedBox(height: 16),
        
              Expanded(
                child:
                    _filtered.isEmpty
                        ? const Center(child: Text("No data"))
                        : ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder:
                              (context, index) =>
                                  AttendanceItem(attendance: _filtered[index]),
                        ),
              ),
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
                Expanded(
                  child: Text(
                    attendance.email,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),

                Text(
                  attendance.status,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    attendance.sitename,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                Text(
                  utils.formatTimestamp(attendance.timestamp),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
