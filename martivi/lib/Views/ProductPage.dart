import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/Category.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:provider/provider.dart';

class ProductPage extends StatelessWidget {
  final Category category;
  static String id = 'ProductPage';
  ProductPage({this.category});
  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (BuildContext context, MainViewModel viewModel, Widget child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(category.localizedName[
                    AppLocalizations.of(context).locale.languageCode] ??
                category
                    .localizedName[AppLocalizations.supportedLocales.first] ??
                ''),
          ),
          body: SafeArea(
            child: ValueListenableBuilder<User>(
              builder: (BuildContext context, user, Widget child) {
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {},
                        stream: Firestore.instance
                            .collection('/products')
                            .where('documentId', isEqualTo: category.documentId)
                            .snapshots(),
                      ),
                    ),
                    if (user?.role == UserType.admin) child,
                  ],
                );
              },
              valueListenable: viewModel.databaseUser,
              child: FlatButton(
                color: kPrimary,
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {});
                },
                child: Text(
                  AppLocalizations.of(context).translate('Add Product'),
                  style: TextStyle(color: kIcons),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
