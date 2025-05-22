class User {
  final String uid;
  final String email;
  final bool isAdmin;
  //final String lastLoggedIn;

  User({
    required this.uid,
    required this.email,
    required this.isAdmin,
    //required this.lastLoggedIn,
  });

  factory User.fromMap(Map<String, dynamic> map, String uid) {
    return User(
      uid: uid,
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      //lastLoggedIn: map['lastLoggedIn'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'isAdmin': isAdmin,
      //'lastLoggedIn': lastLoggedIn,
    };
  }
}
