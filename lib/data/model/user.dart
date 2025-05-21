class UserModel {
  final String uid;
  final String email;
  final bool isAdmin;
  //final String lastLoggedIn;

  UserModel({
    required this.uid,
    required this.email,
    required this.isAdmin,
    //required this.lastLoggedIn,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
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
