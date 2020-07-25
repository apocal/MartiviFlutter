import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:martivi/Views/ContactPage.dart';
import 'package:martivi/Views/OrdersPage.dart';
import 'package:martivi/Views/singup_loginPage.dart';
import 'package:provider/provider.dart';

import 'CartPage.dart';
import 'CategoryPage.dart';

class HomePage extends StatefulWidget {
  static String id = 'HomePage';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> pages = [
    CategoryPage(),
    OrdersPage(),
    CartPage(),
    ContactPage()
  ];
  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (_, mainvViewModel, child) {
        return Scaffold(
          bottomNavigationBar: pageIndex <= 2
              ? BottomNavigationBar(
                  unselectedItemColor: Colors.white54,
                  selectedItemColor: Colors.yellow,
                  backgroundColor: kPrimary,
                  currentIndex: pageIndex > 2 ? 0 : pageIndex,
                  onTap: (index) {
                    setState(() {
                      pageIndex = index;
                    });
                  },
                  items: [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.category),
                        title: Text(AppLocalizations.of(context)
                            .translate('Categories'))),
                    BottomNavigationBarItem(
                        icon: Icon(FontAwesome.list),
                        title: Text(
                            AppLocalizations.of(context).translate('Orders'))),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_cart),
                        title: Text(
                            AppLocalizations.of(context).translate('Cart'))),
                  ],
                )
              : null,
          appBar: () {
            switch (pageIndex) {
              case 0:
                {
                  return AppBar(
                    title: Text(
                        AppLocalizations.of(context).translate('Categories')),
                  );
                }
              case 1:
                {
                  return AppBar(
                    title:
                        Text(AppLocalizations.of(context).translate('Orders')),
                  );
                }
              case 2:
                {
                  return AppBar(
                    title: Text(AppLocalizations.of(context).translate('Cart')),
                  );
                }
              case 3:
                return AppBar(
                  title: Text(
                      AppLocalizations.of(context).translate('Contact us')),
                );
              default:
                {
                  return null;
                }
            }
          }(),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                Consumer<FirebaseUser>(
                  builder: (context, user, child) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: mainvViewModel.isSigningSignUping,
                      builder: (context, value, child) {
                        return DrawerHeader(
                          decoration: BoxDecoration(color: kPrimary),
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: Text(
                                  user == null
                                      ? AppLocalizations.of(context)
                                          .translate('Unauthorized')
                                      : user.isAnonymous
                                          ? AppLocalizations.of(context)
                                              .translate('Guest')
                                          : (user.displayName?.length ?? 0) > 0
                                              ? user.displayName
                                              : user.email,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                              ),
                              value
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  onTap: () {
                    setState(() {
                      pageIndex = 0;
                      Navigator.pop(context);
                    });
                  },
                  title: Text(AppLocalizations.of(context).translate('Home')),
                ),
                ListTile(
                  leading: Icon(Icons.chat_bubble),
                  onTap: () {
                    setState(() {
                      pageIndex = 3;
                      Navigator.pop(context);
                    });
                  },
                  title: Text(
                      AppLocalizations.of(context).translate('Contact us')),
                ),
                Consumer<FirebaseUser>(
                  builder: (context, user, child) {
                    if (user == null) {
                      return ListTile(
                        leading: Icon(FontAwesome.sign_out),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SingUpLoginPage(
                                login: true,
                              ),
                            ),
                          );
                        },
                        title: Text(
                            AppLocalizations.of(context).translate('Sign in')),
                      );
                    } else {
                      return ListTile(
                        leading: Icon(FontAwesome.sign_out),
                        onTap: () {
                          mainvViewModel.auth.signOut();
                        },
                        title: Text(
                            AppLocalizations.of(context).translate('Sign out')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          body: pages[pageIndex],
        );
      },
    );
  }
}
