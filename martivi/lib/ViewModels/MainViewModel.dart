import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:martivi/Models/CartItem.dart';
import 'package:martivi/Models/Category.dart';
import 'package:martivi/Models/ChatMessage.dart';
import 'package:martivi/Models/Product.dart';
import 'package:martivi/Models/Settings.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainViewModel extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  int lastOrderId;
  FirebaseUser user;
  final auth = FirebaseAuth.instance;
  AuthResult authResult;
  SharedPreferences prefs;
  bool isConnected = false;
  ValueNotifier<bool> isSigningSignUping = ValueNotifier<bool>(false);
  ValueNotifier<User> databaseUser = ValueNotifier<User>(null);
  ValueNotifier<List<Category>> categories = ValueNotifier<List<Category>>([]);
  ValueNotifier<List<Product>> products = ValueNotifier<List<Product>>([]);
  ValueNotifier<List<CartItem>> cart = ValueNotifier<List<CartItem>>([]);
  ValueNotifier<bool> newMessages = ValueNotifier<bool>(false);
  ValueNotifier<bool> adminNewMessages = ValueNotifier<bool>(false);
  ValueNotifier<List<ChatMessage>> userMessages =
      ValueNotifier<List<ChatMessage>>([]);
  ValueNotifier<Settings> settings = ValueNotifier<Settings>(Settings());
  ValueNotifier<List<User>> users = ValueNotifier<List<User>>([]);
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
  StreamSubscription<QuerySnapshot> cartListener;
  StreamSubscription<QuerySnapshot> productListener;
  StreamSubscription<QuerySnapshot> chatListener;
  StreamSubscription<QuerySnapshot> usersListener;
  List<StreamSubscription<QuerySnapshot>> usersMessagesListener;
  List<StreamSubscription<DocumentSnapshot>> usersNewMessagesListener;
  StreamSubscription<DocumentSnapshot> newMessagesListener;
  StreamSubscription<DocumentSnapshot> settingsListener;
  StreamSubscription<DocumentSnapshot> ordersCounterListener;

  Future init() async {
    auth.onAuthStateChanged.listen((event) {
      if (event != null) {
        user = event;

        cartListener?.cancel();
        cartListener = Firestore.instance
            .collection('/cart')
            .where('userId', isEqualTo: user.uid)
            .snapshots()
            .listen((event) {
          try {
            List<CartItem> c = [];
            event.documents.forEach((element) {
              CartItem ci = CartItem.fromJson(element.data);
              ci.documentId = element.documentID;
              c.add(ci);
            });
            cart.value = c;
          } catch (e) {
            var exc = e;
          }
        });

        categoryListener?.cancel();
        categoryListener = Firestore.instance
            .collection('/categories')
            .orderBy('order')
            .snapshots()
            .listen((event) {
          List<Category> cs = [];
          event.documents.forEach((element) {
            var c = Category.fromJson(element.data);
            c.documentId = element.documentID;
            cs.add(c);
          });
          categories.value = cs;
        });
        databaseUserListener?.cancel();
        databaseUserListener = Firestore.instance
            .collection('/users')
            .where('uid', isEqualTo: user?.uid ?? '')
            .snapshots()
            .listen((event) {
          try {
            databaseUser.value = User.fromMap(event.documents
                .firstWhere((element) => element.documentID == user.uid)
                .data);

            usersListener?.cancel();
            chatListener?.cancel();
            usersNewMessagesListener?.forEach((element) {
              element?.cancel();
            });
            usersMessagesListener?.forEach((element) {
              element?.cancel();
            });

            newMessagesListener?.cancel();
            switch (databaseUser.value.role) {
              case UserType.user:
                {
                  newMessagesListener = Firestore.instance
                      .collection('/newmessages')
                      .document('to${databaseUser.value.uid}FromAdmin')
                      .snapshots()
                      .listen((event) {
                    if (event.data != null) {
                      try {
                        newMessages.value =
                            event.data['hasNewMessages'] as bool;
                      } catch (e) {}
                    }
                  });
                  chatListener = Firestore.instance
                      .collection('/messages')
                      .where(
                        'pair',
                        isEqualTo: 'admin${databaseUser.value.uid}',
                      )
                      .orderBy('serverTime', descending: false)
                      .snapshots()
                      .listen((event) {
                    userMessages.value = event.documents
                        .map((e) => ChatMessage.fromJson(e.data))
                        .toList();
                  });
                  break;
                }
              case UserType.admin:
                {
                  usersListener = Firestore.instance
                      .collection('/users')
                      .snapshots()
                      .listen((event) {
                    users.value = event.documents
                        .map((e) => User.fromMap(e.data))
                        .toList();

                    usersNewMessagesListener = users.value.map((e) {
                      return Firestore.instance
                          .collection('/newmessages')
                          .document('toAdminFrom${e.uid}')
                          .snapshots()
                          .listen((event) {
                        if (event.data != null) {
                          try {
                            e.hasNewMessages.value =
                                event.data['hasNewMessages'] as bool;
                            adminNewMessages.value = users.value
                                .any((element) => element.hasNewMessages.value);
                            print(adminNewMessages.value);
                          } catch (e) {}
                        }
                      });
                    }).toList();

                    usersMessagesListener = users.value.map((e) {
                      return Firestore.instance
                          .collection('/messages')
                          .where(
                            'pair',
                            isEqualTo: 'admin${e.uid}',
                          )
                          .orderBy('serverTime', descending: false)
                          .snapshots()
                          .listen((event) {
                        e.messages.value = event.documents
                            .map((e) => ChatMessage.fromJson(e.data))
                            .toList();
                      });
                    }).toList();
                  });
                  break;
                }
            }
          } catch (e) {}
        });
      } else {
        databaseUser.value = null;
      }
    });

    ordersCounterListener?.cancel();
    ordersCounterListener = Firestore.instance
        .collection('/settings')
        .document('ordersCounterDocument')
        .snapshots()
        .listen((event) {
      try {
        if (event?.data != null) {
          lastOrderId = event.data['ordersCounterField'] as int;
          print(lastOrderId);
        } else {
          lastOrderId = null;
        }
      } catch (e) {}
    });
    settingsListener?.cancel();
    settingsListener = Firestore.instance
        .collection('/settings')
        .document('settings')
        .snapshots()
        .listen((event) {
      try {
        if (event.data != null) {
          settings.value = Settings.fromJson(event.data);
        }
      } catch (e) {
        print(e);
      }
    });
    signAnonymouslyifNotSigned();
    prefs = await SharedPreferences.getInstance();
    prefs.setString('ServerBaseAddress', 'http://martivi.net/');
    /*prefs.setString('ServerBaseAddress', 'http://192.168.100.11:44379/');*/
    prefs.setString('CheckoutBackLink',
        '${prefs.getString('ServerBaseAddress')}CheckoutResult');
  }

  Future listenProductsOfCategory(Category c) async {
    productListener = Firestore.instance
        .collection('/products')
        .where('documentId', isEqualTo: c.documentId)
        .snapshots()
        .listen((event) {
      try {
        List<Product> tempProducts = [];
        event.documents?.forEach((element) {
          try {
            var p = Product.fromJson(element.data);
            p.productDocumentId = element.documentID;
            tempProducts.add(p);
          } catch (e) {
            print(e.toString());
          }
        });
        products.value = tempProducts;
      } catch (e) {}
    });
  }

  void cancellistenProductsOfCategory() {
    productListener?.cancel();
    products.value = [];
  }

  Future storeCategory(Category c) async {
    c.order = categories.value.length > 0 ? categories.value.last.order + 1 : 1;

    await Firestore.instance
        .collection('/categories')
        .document()
        .setData(c.toJson(), merge: true);
  }

  Future storeProduct(
    Product p,
  ) async {
    var json = p.toJson();
    await Firestore.instance
        .collection('/products')
        .document(p.productDocumentId)
        .setData(p.toJson(), merge: true);
  }

  Future storeCart(Product p) async {
    if (user == null) throw Exception('Unauthorized');
    CartItem c = CartItem(userId: user.uid, product: p);
    await Firestore.instance.collection('cart').document().setData(
          c.toJson(),
        );
  }

  Future switchCategoriesOrders(Category first, Category second) async {
    Firestore.instance
        .collection('/categories')
        .document(first.documentId)
        .updateData({'order': second.order});
    Firestore.instance
        .collection('/categories')
        .document(second.documentId)
        .updateData({'order': first.order});
  }

  Future updateCategory(Category oldCat, Category newCat) async {
    var js = newCat.toJson();
    Firestore.instance
        .collection('/categories')
        .document(oldCat.documentId)
        .updateData(newCat.toJson());
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
        .document(c.documentId)
        .delete();
    FirebaseStorage.instance.ref().child(c.image.refPath).delete();
  }

  Future deleteProduct(Product product) {
    Firestore.instance
        .collection('/products')
        .document(product.productDocumentId)
        .delete();
    product.productsForms.forEach((element) {
      element.images.forEach((element) {
        FirebaseStorage.instance.ref().child(element.refPath).delete();
      });
    });
  }
}
