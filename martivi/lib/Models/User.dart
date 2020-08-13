import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:martivi/Models/ChatMessage.dart';
import 'package:martivi/Models/enums.dart';

class User {
  ValueNotifier<List<ChatMessage>> messages =
      ValueNotifier<List<ChatMessage>>([]);
  ValueNotifier<bool> hasNewMessages = ValueNotifier<bool>(false);
  String email;
  String uid;
  String displayName;
  String photoUrl;
  String phoneNumber;
  bool isAnonymous;
  UserType role;
  User({this.email, this.displayName, this.uid, this.role});
  Map<String, dynamic> toMap() {
    return {
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'email': email,
      'uid': uid,
      'displayName': displayName,
      'isAnonymous': isAnonymous,
      'role': EnumToString.parse(role)
    };
  }

  User.fromMap(Map<String, dynamic> map) {
    photoUrl = map['photoUrl'] as String;
    phoneNumber = map['phoneNumber'] as String;
    isAnonymous = map['isAnonymous'];
    displayName = map['displayName'];
    email = map['email'];
    uid = map['uid'];
    photoUrl = map['photoUrl'];
    role = EnumToString.fromString<UserType>(UserType.values, map['role']);
  }
  User.fromFirebaseUser(FirebaseUser user, UserType r) {
    photoUrl = user.photoUrl;
    phoneNumber = user.phoneNumber;
    isAnonymous = user.isAnonymous;
    displayName = user.displayName;
    email = user.email;
    uid = user.uid;
    photoUrl = user.photoUrl;
    role = r;
  }
}
