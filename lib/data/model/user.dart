class User {
  final String uid;
  final String email;
  final bool isAdmin;
  final String name;
  final String phone;
  final String? deviceId;
  final String? logoutAt;
  final String? createdAt;
  //final String lastLoggedIn;

  User({
    required this.uid,
    required this.email,
    required this.isAdmin,
    required this.name,
    required this.phone,
    this.deviceId,
    this.logoutAt,
    this.createdAt,
    //required this.lastLoggedIn,
  });

  factory User.fromMap(Map<String, dynamic> map, String uid) {
    return User(
      uid: uid,
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      deviceId: map['deviceId'],
      logoutAt: map['logoutAt'],
      createdAt: map['createdAt'],
      //lastLoggedIn: map['lastLoggedIn'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'isAdmin': isAdmin,
      'name': name,
      'phone': phone,
      'deviceId': deviceId,
      'logoutAt': logoutAt,
      'createdAt': createdAt,
      //'lastLoggedIn': lastLoggedIn,
    };
  }
}
