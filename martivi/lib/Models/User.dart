import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:martivi/Models/enums.dart';

class User {
  String email;
  String uid;
  String displayName;
  String photoUrl;
  bool isAnonymous;
  UserType role;
  User({this.email, this.displayName, this.uid, this.role});
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'uid': uid,
      'displayName': displayName,
      'isAnonymous': isAnonymous,
      'role': EnumToString.parse(role)
    };
  }

  User.fromMap(Map<String, dynamic> map) {
    isAnonymous = map['isAnonymous'];
    displayName = map['displayName'];
    email = map['email'];
    uid = map['uid'];
    photoUrl = map['photoUrl'];
    role = EnumToString.fromString<UserType>(UserType.values, map['role']);
  }
  User.fromFirebaseUser(FirebaseUser user, UserType r) {
    isAnonymous = user.isAnonymous;
    displayName = user.displayName;
    email = user.email;
    uid = user.uid;
    photoUrl = user.photoUrl;
    role = r;
  }
}
