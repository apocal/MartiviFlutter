import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/Category.dart';
import 'package:martivi/Models/FirestoreImage.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:martivi/Widgets/Widgets.dart';
import 'package:path/path.dart' as ppp;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'MainDrawer.dart';

class CategoryPage extends StatelessWidget {
  static String id = 'CategoryPage';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('Categories')),
      ),
      drawer: MainDrawer(),
      body: SafeArea(
        child: Container(
          child: Consumer<MainViewModel>(
            builder: (context, viewModel, child) {
              return ValueListenableBuilder<User>(
                valueListenable: viewModel.databaseUser,
                builder: (_, databaseUser, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: Firestore.instance
                              .collection('/categories')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                  itemCount: snapshot.data.documents.length,
                                  itemBuilder: (context, index) {
                                    var c = Category.fromJson(
                                        snapshot.data.documents[index].data);
                                    return CategoryItemWidget(
                                      category: c,
                                    );
                                  });
                            } else
                              return Container();
                          },
                        ),
                      ),
                      if (databaseUser?.role == UserType.admin) child
                    ],
                  );
                },
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class CategoryItemWidget extends StatelessWidget {
  final Category category;
  const CategoryItemWidget({this.category});

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context).locale;
    print(locale.languageCode);
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Image(
          image: NetworkImage(category.image.downloadUrl),
          height: 200,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
        Text(
          category.localizedName[
                  AppLocalizations.of(context).locale.languageCode] ??
              category.localizedName[AppLocalizations.supportedLocales.first] ??
              '',
          style: TextStyle(
              color: kIcons, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class AddCategoryWidget extends StatefulWidget {
  final Function(Category) onAddClicked;
  AddCategoryWidget({this.onAddClicked});

  @override
  _AddCategoryWidgetState createState() => _AddCategoryWidgetState();
}

class _AddCategoryWidgetState extends State<AddCategoryWidget> {
  TextEditingController categoryController = TextEditingController();
  String selectedLocal = AppLocalizations.supportedLocales.first;
  ValueNotifier<bool> isUploading = ValueNotifier<bool>(false);
  Category category = Category(image: FirestoreImage(), localizedName: {});
  bool addClicked = false;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    try {
      if (!addClicked && (category.image.refPath?.length ?? 0) > 0) {
        FirebaseStorage.instance
            .ref()
            .child(category.image.refPath)
            .delete()
            .whenComplete(() {
          category.image.refPath = null;
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ...AppLocalizations.supportedLocales.map((e) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: CircleBorder(),
                        elevation: 4,
                        child: AnimatedContainer(
                          padding: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: e == selectedLocal ? kPrimary : kIcons,
                          ),
                          duration: Duration(milliseconds: 200),
                          child: RawMaterialButton(
                            constraints:
                                BoxConstraints(minWidth: 50, minHeight: 50),
                            shape: CircleBorder(),
                            onPressed: () {
                              setState(() {
                                selectedLocal = e;
                                categoryController.text =
                                    category.localizedName[selectedLocal];
                              });
                            },
                            padding: EdgeInsets.all(0),
                            child: Text(
                              e,
                              style: TextStyle(
                                color: e == selectedLocal ? kIcons : kPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          TextField(
            controller: categoryController,
            onChanged: (value) {
              category.localizedName[selectedLocal] = value;
            },
            style: TextStyle(),
            cursorColor: kPrimary,
            decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kPrimary),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kPrimary),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: kPrimary),
                ),
                hintStyle: TextStyle(),
                hintText:
                    AppLocalizations.of(context).translate("Category Name")),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 8),
              child: Column(
                children: <Widget>[
                  Text(
                      AppLocalizations.of(context).translate('Category image')),
                  Expanded(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isUploading,
                      builder: (context, value, child) {
                        return value
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(kPrimary),
                                ),
                              )
                            : child;
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: (category.image.downloadUrl?.length ?? 0) > 0
                            ? Stack(
                                children: <Widget>[
                                  Center(
                                    child: Image(
                                      image: NetworkImage(
                                          category.image.downloadUrl),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: RawMaterialButton(
                                        shape: CircleBorder(),
                                        onPressed: () {
                                          try {
                                            if ((category.image.refPath
                                                        ?.length ??
                                                    0) >
                                                0) {
                                              FirebaseStorage.instance
                                                  .ref()
                                                  .child(category.image.refPath)
                                                  .delete()
                                                  .whenComplete(() {
                                                category.image.refPath = null;
                                              });
                                            }
                                          } catch (e) {}

                                          setState(() {
                                            category.image.downloadUrl = null;
                                          });
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : IconButton(
                                onPressed: () async {
                                  try {
                                    var pickedImage = await ImagePicker()
                                        .getImage(source: ImageSource.gallery);
                                    if (pickedImage != null) {
                                      File file = File(pickedImage.path);
                                      String filename =
                                          '${Uuid().v4()}${ppp.basename(file.path)}';
                                      isUploading.value = true;
                                      var imageRef = FirebaseStorage.instance
                                          .ref()
                                          .child('images')
                                          .child(filename);
                                      var uploadTask = imageRef
                                          .putFile(File(pickedImage.path));
                                      category.image.refPath = imageRef.path;
                                      var res = await uploadTask.onComplete;
                                      if (!uploadTask.isSuccessful)
                                        throw Exception(AppLocalizations.of(
                                                context)
                                            .translate('File upload failed'));
                                      String url =
                                          await res.ref.getDownloadURL();
                                      String refPath = imageRef.path;
                                      if (!((url?.length ?? 0) > 0)) {
                                        throw Exception(AppLocalizations.of(
                                                context)
                                            .translate('File upload failed'));
                                      }
                                      setState(() {
                                        category.image.downloadUrl = url;
                                      });
                                    }
                                  } catch (e) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return OkDialog(
                                              title:
                                                  AppLocalizations.of(context)
                                                      .translate('Error'),
                                              content: e.message);
                                        });
                                  } finally {
                                    isUploading.value = false;
                                  }
                                },
                                icon: Icon(Icons.add),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          FlatButton(
            color: kPrimary,
            onPressed: () {
              if (!((category.image.downloadUrl?.length ?? 0) > 0 ||
                  (category.image.refPath?.length ?? 0) > 0)) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return OkDialog(
                          title:
                              AppLocalizations.of(context).translate('Error'),
                          content: AppLocalizations.of(context)
                              .translate('Please pick an image'));
                    });
                return;
              }
              if (!((category
                          .localizedName[
                              AppLocalizations.of(context).locale.languageCode]
                          ?.length ??
                      0) >
                  0)) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return OkDialog(
                          title:
                              AppLocalizations.of(context).translate('Error'),
                          content: AppLocalizations.of(context).translate(
                              'Please enter a category name in primary language'));
                    });
                return;
              }
              widget.onAddClicked(category);
              addClicked = true;
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context).translate('Add'),
              style: TextStyle(color: kIcons),
            ),
          ),
        ],
      ),
    );
  }
}
