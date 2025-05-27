import 'package:attendance_app/data/model/attendance.dart';
import 'package:attendance_app/data/repo/attendance_repo.dart';
import 'package:attendance_app/data/repo/auth_repo.dart';
import 'package:attendance_app/nav/navigation.dart';
import 'package:attendance_app/ui/drawer/app_drawer.dart';
import 'package:attendance_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  List<Attendance> _attendances = [];
  final repo = AttendanceRepo();
  final authRepo = AuthRepo();

  String? uid;
  String? email;
  String? lastLoggedIn;

  final _status = ['All', 'Ok', 'Fail'];

  String _selectedStatus = 'All';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadAttendances();
  }

  Future<void> _loadAttendances() async {
    final attendances = await repo.getAttendances();

    List<Attendance> filtered = attendances;

    // Filter by status
    if (_selectedStatus != 'All') {
      filtered = filtered.where((a) => a.status == _selectedStatus).toList();
    }

    // Filter by date (by comparing just the date part)
    if (_selectedDate != null) {
      filtered =
          filtered.where((a) {
            final aDate = DateTime.parse(a.timestamp);
            return aDate.year == _selectedDate!.year &&
                aDate.month == _selectedDate!.month &&
                aDate.day == _selectedDate!.day;
          }).toList();
    }

    setState(() {
      _attendances = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendances',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.greenAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AttendanceSearchDelegate(_attendances),
              );
            },
          ),

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
      endDrawer: AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.lightGreenAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status dropdown
                  DropdownButton<String>(
                    value: _selectedStatus,
                    items:
                        _status.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                        });
                        _loadAttendances();
                      }
                    },
                  ),

                  const SizedBox(width: 16),

                  // Date picker
                  ElevatedButton.icon(
                    icon: Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _selectedDate == null
                          ? "Select Date"
                          : "${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}",
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                        _loadAttendances();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear Date Filter',
                    onPressed: () {
                      setState(() {
                        _selectedStatus = "All";
                        _selectedDate = null;
                      });
                      _loadAttendances();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child:
                    _attendances.isEmpty
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
                          itemCount: _attendances.length,
                          itemBuilder:
                              (context, index) => AttendanceItem(
                                attendance: _attendances[index],
                              ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceSearchDelegate extends SearchDelegate {
  final List<Attendance> attendances;

  AttendanceSearchDelegate(this.attendances);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredAttendances =
        attendances
            .where(
              (attendance) =>
                  attendance.email.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    return SizedBox.expand(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.lightGreenAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filteredAttendances.length,
            itemBuilder:
                (context, index) =>
                    AttendanceItem(attendance: filteredAttendances[index]),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.greenAccent, Colors.lightGreenAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
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
                const Icon(Icons.account_circle, color: Colors.black),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    attendance.email,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),

                attendance.status == "Ok"
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.cancel, color: Colors.red),

                const SizedBox(width: 8),
                Text(
                  attendance.status,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// Status
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

                const Icon(Icons.access_time, color: Colors.orange),
                const SizedBox(width: 8),
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
