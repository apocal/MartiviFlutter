import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image/image.dart' as Img;
import 'package:image_picker/image_picker.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/Category.dart';
import 'package:martivi/Models/FirestoreImage.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:martivi/Views/ProductPage.dart';
import 'package:martivi/Widgets/CategoryItemWidget.dart';
import 'package:martivi/Widgets/FadeInWidget.dart';
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
        return ValueListenableBuilder<User>(
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
                              itemCount: viewModel.categories.value.length,
                              itemBuilder: (context, index) {
                                return Slidable(
                                  key: Key(viewModel.categories.value[index]
                                          .localizedName[
                                      AppLocalizations
                                          .supportedLocales.first]),
                                  actionPane: SlidableDrawerActionPane(),
                                  actions: <Widget>[
                                    SlideAction(
                                      onTap: () {
                                        var cat = Category.fromJson(viewModel
                                            .categories.value[index]
                                            .toJson());
                                        showModalBottomSheet(
                                            context: context,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
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
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0))),
                                          child: Material(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.all(
                                                        Radius.circular(15))),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.all(
                                                        Radius.circular(
                                                            15.0)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(0xFFABABAB)
                                                        .withOpacity(0.7),
                                                    blurRadius: 4.0,
                                                    spreadRadius: 3.0,
                                                  ),
                                                ],
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              15.0)),
                                                  color: Colors.black12
                                                      .withOpacity(0.1),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(
                                                          8.0),
                                                  child: Container(
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.edit,
                                                            color: kIcons,
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'Edit'),
                                                            style: TextStyle(
                                                                color:
                                                                    kIcons),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                height: double.infinity,
                                              ),
                                            ),
                                          ),
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
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0))),
                                          child: Material(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.all(
                                                        Radius.circular(15))),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.all(
                                                        Radius.circular(
                                                            15.0)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(0xFFABABAB)
                                                        .withOpacity(0.7),
                                                    blurRadius: 4.0,
                                                    spreadRadius: 3.0,
                                                  ),
                                                ],
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              15.0)),
                                                  color: Colors.black12
                                                      .withOpacity(0.1),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(
                                                          8.0),
                                                  child: Container(
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.delete,
                                                            color: kIcons,
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'Delete'),
                                                            style: TextStyle(
                                                                color:
                                                                    kIcons),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                height: double.infinity,
                                              ),
                                            ),
                                          ),
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
                                            viewModel.categories.value[index]
                                        ? () {
                                            viewModel.switchCategoriesOrders(
                                                viewModel
                                                    .categories.value[index],
                                                viewModel.categories
                                                    .value[index + 1]);
                                          }
                                        : null,
                                    onUpPress: categories.first !=
                                            viewModel.categories.value[index]
                                        ? () {
                                            viewModel.switchCategoriesOrders(
                                                viewModel
                                                    .categories.value[index],
                                                viewModel.categories
                                                    .value[index - 1]);
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
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (c) => ProductPage(
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
    );
  }
}

class CategoryItemWidget extends StatelessWidget {
  final Function onUpPress;
  final Function onDownPress;
  final Category category;
  const CategoryItemWidget({this.category, this.onDownPress, this.onUpPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Stack(
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
                category
                    .localizedName[AppLocalizations.supportedLocales.first] ??
                '',
            style: TextStyle(
                color: kIcons, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Positioned.fill(
              child: RawMaterialButton(
            onPressed: () {},
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (onUpPress != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: RawMaterialButton(
                      onPressed: onUpPress,
                      splashColor: kPrimary.withOpacity(0.3),
                      shape: CircleBorder(),
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: kPrimary.withOpacity(0.3),
                      ),
                    ),
                  ),
                if (onDownPress != null)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: RawMaterialButton(
                      onPressed: onDownPress,
                      splashColor: kPrimary.withOpacity(0.3),
                      shape: CircleBorder(),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: kPrimary.withOpacity(0.3),
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
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
                                    category.localizedName[selectedLocal] ?? '';
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
                                      Img.Image image_temp = Img.decodeImage(
                                          file.readAsBytesSync());
                                      Img.Image resized_img = Img.copyResize(
                                          image_temp,
                                          width: 800,
                                          height: image_temp.height ~/
                                              (image_temp.width / 800));
                                      var data = Img.encodeJpg(resized_img,
                                          quality: 60);

                                      String filename =
                                          '${Uuid().v4()}${ppp.basename(file.path)}';
                                      isUploading.value = true;
                                      var imageRef = FirebaseStorage.instance
                                          .ref()
                                          .child('images')
                                          .child(filename);
                                      var uploadTask = imageRef.putData(data);
//                                      var uploadTask = imageRef
//                                          .putFile(File(pickedImage.path));
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

class EditCategoryWidget extends StatefulWidget {
  final Category category;
  final Function(Category) onEditClicked;
  EditCategoryWidget({@required this.onEditClicked, @required this.category});

  @override
  _EditCategoryWidgetState createState() => _EditCategoryWidgetState();
}

class _EditCategoryWidgetState extends State<EditCategoryWidget> {
  String selectedLocal = AppLocalizations.supportedLocales.first;
  TextEditingController categoryController;
  ValueNotifier<bool> isUploading = ValueNotifier<bool>(false);
  @override
  void initState() {
    super.initState();
    categoryController = TextEditingController(
        text: widget.category.localizedName[selectedLocal]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.category.localizedName);
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
                                categoryController.text = widget.category
                                        .localizedName[selectedLocal] ??
                                    '';
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
              widget.category.localizedName[selectedLocal] = value;
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
                        child: (widget.category.image.downloadUrl?.length ??
                                    0) >
                                0
                            ? Stack(
                                children: <Widget>[
                                  Center(
                                    child: Image(
                                      image: NetworkImage(
                                          widget.category.image.downloadUrl),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: RawMaterialButton(
                                        shape: CircleBorder(),
                                        onPressed: () {
                                          setState(() {
                                            widget.category.image.refPath =
                                                null;
                                            widget.category.image.downloadUrl =
                                                null;
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
                                      widget.category.image.refPath =
                                          imageRef.path;
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
                                        widget.category.image.downloadUrl = url;
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
              if (!((widget.category.image.downloadUrl?.length ?? 0) > 0 ||
                  (widget.category.image.refPath?.length ?? 0) > 0)) {
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
              if (!((widget
                          .category
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
              widget.onEditClicked(widget.category);
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context).translate('Add changes'),
              style: TextStyle(color: kIcons),
            ),
          ),
        ],
      ),
    );
  }
}
