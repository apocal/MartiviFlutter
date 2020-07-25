import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/Category.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainViewModel extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FirebaseUser user;
  final auth = FirebaseAuth.instance;
  AuthResult authResult;
  SharedPreferences prefs;
  bool isConnected = false;
  ValueNotifier<bool> isSigningSignUping = ValueNotifier<bool>(false);
  ValueNotifier<User> databaseUser = ValueNotifier<User>(null);
  ValueNotifier<List<Category>> categories = ValueNotifier<List<Category>>([]);
  MainViewModel() {
    init();
  }
  void signAnonymouslyifNotSigned() async {
    try {
      isSigningSignUping.value = true;
      if (await auth.currentUser() == null) {
        var res = await auth.signInAnonymously();
        if (res != null) {
          await storeNewUser(res.user, UserType.user);
        }
      }
    } catch (e) {
      print(e);
    } finally {
      isSigningSignUping.value = false;
    }
  }

  Future<bool> signInWithEmailAndPassword() async {
    try {
      isSigningSignUping.value = true;
      var authRes = await auth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      if (authRes != null) {
        return true;
      } else
        return false;
    } catch (e) {
      throw e;
    } finally {
      isSigningSignUping.value = false;
    }
  }

  Future signUpWithEmailAndPassword() async {
    try {
      isSigningSignUping.value = true;
      var authRes = await auth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      if (authRes != null) {
        await storeNewUser(authRes.user, UserType.user);
        return true;
      } else
        return false;
    } catch (e) {
      throw e;
    } finally {
      isSigningSignUping.value = false;
    }
  }

  StreamSubscription<QuerySnapshot> databaseUserListener;
  StreamSubscription<QuerySnapshot> categoryListener;
  Future init() async {
    auth.onAuthStateChanged.listen((event) {
      if (event != null) {
        user = event;

        categoryListener?.cancel();
        categoryListener = Firestore.instance
            .collection('/categories')
            .orderBy('order')
            .snapshots()
            .listen((event) {
          List<Category> cs = [];
          event.documents.forEach((element) {
            var c = Category.fromJson(element.data);
            cs.add(c);
          });
          categories.value = cs;
        });
        databaseUserListener?.cancel();
        databaseUserListener = Firestore.instance
            .collection('/users')
            .where('uid', isEqualTo: user.uid)
            .snapshots()
            .listen((event) {
          try {
            databaseUser.value = User.fromMap(event.documents
                .firstWhere((element) => element.documentID == user.uid)
                .data);
          } catch (e) {}
        });
      } else {
        databaseUser.value = null;
      }
    });
    signAnonymouslyifNotSigned();
    prefs = await SharedPreferences.getInstance();
    prefs.setString('ServerBaseAddress', 'http://martivi.net/');
    /*prefs.setString('ServerBaseAddress', 'http://192.168.100.11:44379/');*/
    prefs.setString('CheckoutBackLink',
        '${prefs.getString('ServerBaseAddress')}CheckoutResult');
  }

  Future storeCategory(Category c) async {
    c.order = categories.value.length > 0 ? categories.value.last.order + 1 : 1;

    await Firestore.instance
        .collection('/categories')
        .document(c.localizedName[AppLocalizations.supportedLocales.first])
        .setData(c.toJson(), merge: true);
  }

  Future switchCategoriesOrders(Category first, Category second) async {
    Firestore.instance
        .collection('/categories')
        .document(first.localizedName[AppLocalizations.supportedLocales.first])
        .updateData({'order': second.order});
    Firestore.instance
        .collection('/categories')
        .document(second.localizedName[AppLocalizations.supportedLocales.first])
        .updateData({'order': first.order});
  }

  Future storeNewUser(FirebaseUser user, UserType role) async {
    var u = User.fromFirebaseUser(user, role);
    await Firestore.instance
        .collection('/users')
        .document(user.uid)
        .setData(u.toMap(), merge: true);
  }

  Future deleteCategory(Category c) {
    Firestore.instance
        .collection('/categories')
        .document(c.localizedName[AppLocalizations.supportedLocales.first])
        .delete();
  }
}
