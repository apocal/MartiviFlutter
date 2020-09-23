import 'dart:convert';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' as fundation;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/Category.dart';
import 'package:martivi/Models/FirestoreImage.dart';
import 'package:martivi/Models/Product.dart';
import 'package:martivi/Models/Settings.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:martivi/Views/ProductPage.dart';
import 'package:martivi/Widgets/CategoryItemWidget.dart';
import 'package:martivi/Widgets/Widgets.dart';
import 'package:path/path.dart' as ppp;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  int categoryPagesIndex = 0;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (context, viewModel, child) {
        return ValueListenableBuilder<DatabaseUser>(
          valueListenable: viewModel.databaseUser,
          builder: (context, databaseUser, child) {
            return ValueListenableBuilder<AppSettings>(
              valueListenable: viewModel.settings,
              builder: (context, value, child) => Stack(
                children: [
                  child,
                  if ((value?.stopOrdering ?? false) &&
                      databaseUser?.role != UserType.admin)
                    Positioned.fill(
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                          child: Container(
                            color: Colors.transparent,
                            child: Center(
                                child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning,
                                  size: 150,
                                  color: Colors.red,
                                ),
                                Text(
                                  AppLocalizations.of(context).translate(
                                      'The service is temporarily unavailable'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    shadows: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.7),
                                          blurRadius: 10.0,
                                          spreadRadius: 2.0)
                                    ],
                                    color: Colors.red,
                                    fontFamily: "Sofia",
                                    fontWeight: FontWeight.w800,
                                    fontSize: 39.0,
                                  ),
                                ),
                              ],
                            )),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              child: ValueListenableBuilder<DatabaseUser>(
                valueListenable: viewModel.databaseUser,
                builder: (_, databaseUser, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: ValueListenableBuilder<List<Category>>(
                          valueListenable: viewModel.categories,
                          builder: (_, categories, child) {
                            return databaseUser?.role == UserType.admin
                                ? ListView.builder(
                                    itemCount:
                                        viewModel.categories.value.length,
                                    itemBuilder: (context, index) {
                                      return Slidable(
                                        key: Key(viewModel.categories
                                                .value[index].localizedName[
                                            AppLocalizations
                                                .supportedLocales.first]),
                                        actionPane: SlidableDrawerActionPane(),
                                        actions: <Widget>[
                                          SlideAction(
                                            onTap: () {
                                              var cat = Category.fromJson(
                                                  viewModel
                                                      .categories.value[index]
                                                      .toJson());
                                              showModalBottomSheet(
                                                  context: context,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(20),
                                                      topRight:
                                                          Radius.circular(20),
                                                    ),
                                                  ),
                                                  builder: (c) {
                                                    return EditCategoryWidget(
                                                      category: cat,
                                                      onEditClicked: (c) {
                                                        viewModel.updateCategory(
                                                            viewModel.categories
                                                                .value[index],
                                                            c);
                                                      },
                                                    );
                                                  });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SlideActionElement(
                                                iconData: Icons.edit,
                                                color: Colors.blue,
                                                text:
                                                    AppLocalizations.of(context)
                                                        .translate('Edit'),
                                              ),
                                            ),
                                          ),
                                        ],
                                        secondaryActions: <Widget>[
                                          SlideAction(
                                            onTap: () {
                                              viewModel.deleteCategory(viewModel
                                                  .categories.value[index]);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SlideActionElement(
                                                iconData: Icons.delete,
                                                text:
                                                    AppLocalizations.of(context)
                                                        .translate('Delete'),
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                        child: itemCard(
                                          onCategoryPress: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder: (c) => ProductPage(
                                                          category: viewModel
                                                              .categories
                                                              .value[index],
                                                        )));
                                          },
                                          onDownPress: categories.last !=
                                                  viewModel
                                                      .categories.value[index]
                                              ? () {
                                                  viewModel
                                                      .switchCategoriesOrders(
                                                          viewModel.categories
                                                              .value[index],
                                                          viewModel.categories
                                                                  .value[
                                                              index + 1]);
                                                }
                                              : null,
                                          onUpPress: categories.first !=
                                                  viewModel
                                                      .categories.value[index]
                                              ? () {
                                                  viewModel
                                                      .switchCategoriesOrders(
                                                          viewModel.categories
                                                              .value[index],
                                                          viewModel.categories
                                                                  .value[
                                                              index - 1]);
                                                }
                                              : null,
                                          category:
                                              viewModel.categories.value[index],
                                        ),
                                      );
                                    })
                                : ListView(
                                    children: <Widget>[
                                      ...(categories.map((e) => itemCard(
                                            onCategoryPress: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (c) =>
                                                          ProductPage(
                                                            category: e,
                                                          )));
                                            },
                                            category: e,
                                          )))
                                    ],
                                  );
                          },
                        ),
                      ),
                      if (databaseUser?.role == UserType.admin &&
                          fundation.kDebugMode)
                        FlatButton(
                          onPressed: () async {
                            var response = await http.get(
                                'http://martivi.net/api/Categories/GetFilteredCategories');
                            var encoded =
                                List.castFrom<dynamic, Map<String, dynamic>>(
                                    jsonDecode(response.body) as List<dynamic>);
                            await Future.forEach(encoded, (element) async {
                              var res =
                                  await http.get(element['image'] as String);
                              var byteRes = res.bodyBytes;
                              Category c = Category(
                                  image: FirestoreImage(),
                                  localizedName:
                                      Map<String, String>.fromIterable(
                                          AppLocalizations.supportedLocales,
                                          key: (e) =>
                                              (e as Locale).languageCode,
                                          value: (e) =>
                                              element['name'] as String));
                              String filename =
                                  '${Uuid().v4()}${ppp.basename(element['name'] as String)}';

                              var imageRef = FirebaseStorage.instance
                                  .ref()
                                  .child('images')
                                  .child(filename);
                              var uploadTask = imageRef.putData(byteRes);
                              c.image.refPath = imageRef.path;
                              var uploadRes = await uploadTask.onComplete;
                              c.image.downloadUrl =
                                  await uploadRes.ref.getDownloadURL();
                              var products =
                                  element['products'] as List<dynamic>;
                              var catRef = await viewModel.storeCategory(c);
                              int counter = 0;
                              await Future.forEach(products, (element) async {
                                counter++;
                                Product pf = Product(order: counter);
                                pf.documentId = catRef.id;
                                pf.localizedName =
                                    Map<String, String>.fromIterable(
                                        AppLocalizations.supportedLocales,
                                        key: (e) => (e as Locale).languageCode,
                                        value: (e) =>
                                            element['name'] as String);
                                pf.localizedDescription =
                                    Map<String, String>.fromIterable(
                                        AppLocalizations.supportedLocales,
                                        key: (e) => (e as Locale).languageCode,
                                        value: (e) =>
                                            element['description'] as String);

                                FirestoreImage pfImage = FirestoreImage();
                                pf.images = [pfImage];
                                pf.quantityInSupply =
                                    element['quantityInSupply'];

                                pf.localizedName =
                                    Map<String, String>.fromIterable(
                                        AppLocalizations.supportedLocales,
                                        key: (e) => (e as Locale).languageCode,
                                        value: (e) =>
                                            element['name'] as String);
                                pf.localizedDescription =
                                    Map<String, String>.fromIterable(
                                        AppLocalizations.supportedLocales,
                                        key: (e) => (e as Locale).languageCode,
                                        value: (e) =>
                                            element['description'] as String);
                                pf.basePrice = double.parse(
                                    (element['price'] as num)
                                        .toStringAsFixed(2));
                                pf.addonDescriptions = [
                                  AddonDescription(
                                      localizedAddonDescription:
                                          Map<String, String>.fromIterable(
                                              AppLocalizations.supportedLocales,
                                              key: (e) =>
                                                  (e as Locale).languageCode,
                                              value: (e) =>
                                                  element['weight'] as String),
                                      localizedAddonDescriptionName:
                                          Map<String, String>.fromIterable(
                                              AppLocalizations.supportedLocales,
                                              key: (e) =>
                                                  (e as Locale).languageCode,
                                              value: (e) =>
                                                  AppLocalizations.of(context)
                                                      .translate('Weight'))),
                                ];

                                var res =
                                    await http.get(element['image'] as String);
                                var byteRes = res.bodyBytes;

                                String filename =
                                    '${Uuid().v4()}${ppp.basename(element['name'] as String)}';

                                var imageRef = FirebaseStorage.instance
                                    .ref()
                                    .child('images')
                                    .child(filename);
                                var uploadTask = imageRef.putData(byteRes);
                                pfImage.refPath = imageRef.path;
                                var uploadRes = await uploadTask.onComplete;
                                pfImage.downloadUrl =
                                    await uploadRes.ref.getDownloadURL();
                                viewModel.storeProduct(pf);
                              });
                            });

                            print(response.body);
                          },
                          child: Text('Import'),
                        ),
                      if (databaseUser?.role == UserType.admin) child
                    ],
                  );
                },
                child: FlatButton(
                  color: kPrimary,
                  onPressed: () {
                    showBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return AddCategoryWidget(
                            onAddClicked: (c) {
                              viewModel.storeCategory(c);
                            },
                          );
                        });
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('Add Category'),
                    style: TextStyle(color: kIcons),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
