import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/Category.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:martivi/Views/ContactPage.dart';
import 'package:martivi/Views/OrdersPage.dart';
import 'package:martivi/Views/ProductPage.dart';
import 'package:martivi/Views/ProfilePage.dart';
import 'package:martivi/Views/UsersPage.dart';
import 'package:martivi/Views/singup_loginPage.dart';
import 'package:martivi/Widgets/CategoryItemWidget.dart';
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
  ];
  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (_, mainvViewModel, child) {
        return Scaffold(
          bottomNavigationBar: pageIndex <= 2
              ? ValueListenableBuilder(
                  valueListenable: mainvViewModel.databaseUser,
                  builder: (context, value, child) {
                    return BottomNavigationBar(
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
                            title: Text(AppLocalizations.of(context)
                                .translate('Orders'))),
                        BottomNavigationBarItem(
                            icon: ValueListenableBuilder(
                              valueListenable: mainvViewModel.cart,
                              builder: (context, value, child) {
                                return Container(
                                  width: double.infinity,
                                  child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        mainvViewModel.cart.value.length > 0
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 30, bottom: 10),
                                                child: Material(
                                                  color: Colors.yellow,
                                                  elevation: 2,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  child: new Container(
                                                    padding: EdgeInsets.all(1),
                                                    decoration:
                                                        new BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    constraints: BoxConstraints(
                                                      minWidth: 12,
                                                      minHeight: 12,
                                                    ),
                                                    child: new Text(
                                                      mainvViewModel
                                                          .cart.value.length
                                                          .toString(),
                                                      style: new TextStyle(
                                                          color: kPrimary,
                                                          fontSize: 8,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                        Icon(Icons.shopping_cart),
                                      ]),
                                );
                              },
                            ),
                            title: Text(AppLocalizations.of(context)
                                .translate('Cart'))),
                      ],
                    );
                  },
                )
              : null,
          appBar: () {
            switch (pageIndex) {
              case 0:
                {
                  return AppBar(
                    title: Text(
                        AppLocalizations.of(context).translate('Categories')),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          showSearch(
                              context: context,
                              delegate: CategorySearch(
                                  categories: mainvViewModel.categories.value));
                        },
                      )
                    ],
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
              default:
                {
                  return null;
                }
            }
          }(),
          drawer: Drawer(
            child: ValueListenableBuilder<User>(
              valueListenable: mainvViewModel.databaseUser,
              builder: (context, databaseUseruser, child) {
                return ListView(
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
                                              : (databaseUseruser.displayName
                                                              ?.length ??
                                                          0) >
                                                      0
                                                  ? databaseUseruser.displayName
                                                  : databaseUseruser.email,
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
                      title:
                          Text(AppLocalizations.of(context).translate('Home')),
                    ),
                    if (databaseUseruser?.role == UserType.user ||
                        databaseUseruser?.role == UserType.anonymous)
                      ListTile(
                        leading: Icon(Icons.chat_bubble),
                        onTap: () {
                          setState(() {
                            mainvViewModel.newMessages.value = false;
                            Firestore.instance
                                .collection('/newmessages')
                                .document(
                                    'to${mainvViewModel.databaseUser.value.uid}FromAdmin')
                                .setData({'hasNewMessages': false});

                            Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ContactPage(),
                            ));
                          });
                        },
                        title: ValueListenableBuilder<bool>(
                          valueListenable: mainvViewModel.newMessages,
                          builder: (context, value, child) {
                            return Stack(
                              children: <Widget>[
                                Text(AppLocalizations.of(context)
                                    .translate('Contact us')),
                                if (value) child
                              ],
                            );
                          },
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: kPrimary, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      ),
                    if (databaseUseruser?.role == UserType.admin)
                      ListTile(
                        leading: Icon(FontAwesome.users),
                        onTap: () {
                          setState(() {
                            mainvViewModel.newMessages.value = false;

                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UsersPage(),
                                ));
                          });
                        },
                        title: ValueListenableBuilder<bool>(
                          valueListenable: mainvViewModel.adminNewMessages,
                          builder: (context, value, child) {
                            return Stack(
                              children: <Widget>[
                                Text(AppLocalizations.of(context)
                                    .translate('Users')),
                                if (value) child
                              ],
                            );
                          },
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: kPrimary, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      ),
                    if (databaseUseruser?.role != null)
                      ListTile(
                        leading: Icon(FontAwesome.user),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ));
                        },
                        title: Text(
                            AppLocalizations.of(context).translate('Profile')),
                      ),
                    Consumer<FirebaseUser>(
                      builder: (context, user, child) {
                        if (user == null) {
                          return ListTile(
                            leading: Icon(FontAwesome.sign_in),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SingUpLoginPage(
                                    login: true,
                                  ),
                                ),
                              );
                            },
                            title: Text(AppLocalizations.of(context)
                                .translate('Sign in')),
                          );
                        } else {
                          return ListTile(
                            leading: Icon(FontAwesome.sign_out),
                            onTap: () {
                              mainvViewModel.auth.signOut();
                            },
                            title: Text(AppLocalizations.of(context)
                                .translate('Sign out')),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          body: pages[pageIndex],
        );
      },
    );
  }
}

class CategorySearch extends SearchDelegate<String> {
  final List<Category> categories;
  CategorySearch({this.categories});
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Category> suggestionList = query.isEmpty
        ? categories
            .take(categories.length > 10 ? 10 : categories.length)
            .toList()
        : categories
            .where((element) => element
                .localizedName[AppLocalizations.of(context).locale.languageCode]
                ?.contains(query))
            .toList();
    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          return itemCard(
            category: suggestionList[index],
            onCategoryPress: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return ProductPage(
                  category: suggestionList[index],
                );
              }));
            },
          );
        });
  }
}
