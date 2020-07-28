import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/Category.dart';
import 'package:martivi/Models/Product.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:martivi/Widgets/FadeInWidget.dart';
import 'package:martivi/Widgets/Widgets.dart';
import 'package:path/path.dart' as ppp;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          return user.role == UserType.admin
                              ? Container()
                              : ListView.builder(
                                  itemCount: snapshot.data.documents.length,
                                  itemBuilder: (context, index) {
                                    var p = ProductForm.fromJson(
                                        snapshot.data.documents[index].data);
                                    return Stack(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Image.network(
                                                p.images.first.downloadUrl),
                                            Text(p.localizedName[
                                                AppLocalizations.of(context)
                                                    .locale
                                                    .languageCode]),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                        },
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
                      builder: (context) {
                        return AddProductWidget(
                          onAddClicked: (p) {},
                        );
                      });
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

class AddProductWidget extends StatefulWidget {
  final Function(Category) onAddClicked;
  AddProductWidget({this.onAddClicked});

  @override
  _AddProductWidgetState createState() => _AddProductWidgetState();
}

class _AddProductWidgetState extends State<AddProductWidget> {
  ProductForm selectedProduct;
  TextEditingController productTextController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productFormNameController = TextEditingController();
  TextEditingController productFormDescrController = TextEditingController();
  TextEditingController productFormPriceController = TextEditingController();
  TextEditingController productFormquantityInSupplyController =
      TextEditingController();
  TextEditingController productFormWeightController = TextEditingController();
  String selectedLocal = AppLocalizations.supportedLocales.first;
  ValueNotifier<bool> isUploading = ValueNotifier<bool>(false);
  Product pc = Product();
  bool addClicked = false;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
//    try {
//      if (!addClicked && (category.image.refPath?.length ?? 0) > 0) {
//        FirebaseStorage.instance
//            .ref()
//            .child(category.image.refPath)
//            .delete()
//            .whenComplete(() {
//          category.image.refPath = null;
//        });
//      }
//    } catch (e) {}
  }

  void setTextControllers() {
    if (selectedProduct != null) {
      productFormNameController.text =
          selectedProduct.localizedName[selectedLocal] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16),
      height: double.infinity,
      child: SingleChildScrollView(
        child: Container(
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
                                    setTextControllers();
                                    pc.localizedDescription ??= {};
                                    productDescriptionController.text =
                                        pc.localizedDescription[
                                                selectedLocal] ??
                                            '';

                                    pc.localizedName ??= {};

                                    productTextController.text =
                                        pc.localizedName[selectedLocal] ?? '';
                                  });
                                },
                                padding: EdgeInsets.all(0),
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    color:
                                        e == selectedLocal ? kIcons : kPrimary,
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
                controller: productTextController,
                onChanged: (value) {
                  pc.localizedName ??= {};
                  pc.localizedName[selectedLocal] = value;
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
                        AppLocalizations.of(context).translate("Product Name")),
              ),
              TextField(
                maxLines: null,
                controller: productDescriptionController,
                onChanged: (value) {
                  pc.localizedDescription ??= {};
                  pc.localizedDescription[selectedLocal] = value;
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
                    hintText: AppLocalizations.of(context)
                        .translate("Product Description")),
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context).translate('Product forms'),
                  ),
                  Wrap(
                    children: <Widget>[
                      ...?pc.productsForms?.map(
                        (e) => FadeInWidget(
                          child: Stack(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, right: 15, left: 8, bottom: 8),
                                child: Material(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  elevation: 2,
                                  child: AnimatedContainer(
                                    height: 40,
                                    duration: Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                        color: selectedProduct == e
                                            ? kPrimary
                                            : kIcons,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: RawMaterialButton(
                                      constraints: BoxConstraints(minHeight: 0),
                                      splashColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      onPressed: () {
                                        setState(() {
                                          selectedProduct = e;
                                          setTextControllers();
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        child: Text(
                                          e.localizedName[
                                              AppLocalizations.of(context)
                                                  .locale
                                                  .languageCode],
                                          style: TextStyle(
                                              color: e == selectedProduct
                                                  ? Colors.white
                                                  : Colors.black87),
                                          maxLines: null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: ButtonTheme(
                                  padding: EdgeInsets.all(0),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashColor: kPrimary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        setState(() {
                                          if (selectedProduct == e)
                                            selectedProduct = null;
                                          pc.productsForms.remove(e);
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 22,
                                        color: Colors.red.withOpacity(.5),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.add,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              pc.productsForms ??= [];
                              pc.productsForms.add(ProductForm(localizedName: {
                                AppLocalizations.of(context)
                                        .locale
                                        .languageCode:
                                    AppLocalizations.of(context)
                                        .translate('Product')
                              }));
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (selectedProduct != null)
                Column(
                  children: <Widget>[
                    TextField(
                      maxLines: null,
                      controller: productFormNameController,
                      onChanged: (value) {
                        setState(() {
                          selectedProduct.localizedName ??= {};
                          selectedProduct.localizedName[selectedLocal] = value;
                        });
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
                          hintText: AppLocalizations.of(context)
                              .translate("Product form name")),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}

class EditProductWidget extends StatefulWidget {
  final Category category;
  final Function(Category) onEditClicked;
  EditProductWidget({@required this.onEditClicked, @required this.category});

  @override
  _EditProductWidgetState createState() => _EditProductWidgetState();
}

class _EditProductWidgetState extends State<EditProductWidget> {
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
