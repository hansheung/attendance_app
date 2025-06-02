class Attendance {
  final String user; 
  final String email;
  final String sitename;
  final double latitude;
  final double longitude;
  final String timestamp;
  final String status;

  Attendance({
    required this.user,
    required this.email,    
    required this.sitename,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.status,
  });

 
  factory Attendance.fromMap(Map<String, dynamic> map) {
  return Attendance(
    user: map['user'],
    email: map['email'],
    sitename: map['sitename'],
    latitude: map['latitude'],
    longitude: map['longitude'],
    timestamp: map['timestamp'],
    status: map['status'],
  );
}

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'email': email,
      'sitename': sitename,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'status': status,
    };
  }

}
