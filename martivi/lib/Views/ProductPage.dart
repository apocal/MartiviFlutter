import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image/image.dart' as Img;
import 'package:image_picker/image_picker.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/CartItem.dart';
import 'package:martivi/Models/Category.dart';
import 'package:martivi/Models/FirestoreImage.dart';
import 'package:martivi/Models/Product.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:martivi/Views/ProductDetailPage.dart';
import 'package:martivi/Widgets/FadeInWidget.dart';
import 'package:martivi/Widgets/Widgets.dart';
import 'package:path/path.dart' as ppp;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'CartPage.dart';

class ProductPage extends StatefulWidget {
  final Category category;
  static String id = 'ProductPage';
  ProductPage({this.category});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  MainViewModel vm;
  @override
  void didUpdateWidget(ProductPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    context.read<MainViewModel>().listenProductsOfCategory(widget.category);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    vm = context.read<MainViewModel>();
    vm.listenProductsOfCategory(widget.category);
  }

  @override
  void dispose() async {
    try {
      super.dispose();
    } catch (e) {
      print(e);
    } finally {
      vm.products.value?.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (BuildContext context, MainViewModel viewModel, Widget child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.category.localizedName[
                    AppLocalizations.of(context).locale.languageCode] ??
                widget.category
                    .localizedName[AppLocalizations.supportedLocales.first] ??
                ''),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate:
                          ProductsSearch(products: viewModel.products.value));
                },
              ),
              ValueListenableBuilder<List<CartItem>>(
                valueListenable: viewModel.cart,
                builder: (context, cart, child) {
                  return Padding(
                    padding: EdgeInsets.only(top: 4, right: 2),
                    child: Stack(
                      children: [
                        child,
                        if ((cart?.length ?? 0) > 0)
                          Positioned.fill(
                              child: Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 3, top: 3),
                                    child: Material(
                                      color: Colors.yellow,
                                      elevation: 2,
                                      borderRadius: BorderRadius.circular(6),
                                      child: new Container(
                                        padding: EdgeInsets.all(1),
                                        decoration: new BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        constraints: BoxConstraints(
                                          minWidth: 12,
                                          minHeight: 12,
                                        ),
                                        child: new Text(
                                          viewModel.cart.value.length
                                              .toString(),
                                          style: new TextStyle(
                                              color: kPrimary,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  )))
                      ],
                    ),
                  );
                },
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return Scaffold(
                            appBar: AppBar(
                              title: Text(AppLocalizations.of(context)
                                  .translate('Cart')),
                            ),
                            body: CartPage(),
                          );
                        },
                      ),
                    );
                  },
                  icon: Icon(Icons.shopping_cart),
                ),
              ),
            ],
          ),
          body: Builder(
            builder: (context) {
              return SafeArea(
                child: ValueListenableBuilder<User>(
                  builder: (BuildContext context, user, Widget child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: ValueListenableBuilder<List<Product>>(
                            valueListenable: viewModel.products,
                            builder: (context, value, child) {
                              return user?.role == UserType.admin
                                  ? ListView.builder(
                                      itemBuilder: (context, index) {
                                        return Slidable(
                                          key: Key(viewModel.products
                                              .value[index].productDocumentId),
                                          actionPane:
                                              SlidableDrawerActionPane(),
                                          actions: <Widget>[
                                            SlideAction(
                                              onTap: () {
                                                showModalBottomSheet(
                                                    context: context,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(20),
                                                      ),
                                                    ),
                                                    builder: (c) {
                                                      return AddProductWidget(
                                                        onAddClicked: (p) {
                                                          viewModel
                                                              .storeProduct(p)
                                                              .catchError(
                                                                  (error) {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                      OkDialog(
                                                                title: AppLocalizations.of(
                                                                        context)
                                                                    .translate(
                                                                        'Error'),
                                                                content: error
                                                                    .toString(),
                                                              ),
                                                            );
                                                          });
                                                        },
                                                        pc: viewModel.products
                                                            .value[index],

//
                                                      );
                                                    });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  15.0))),
                                                  child: Material(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    15))),
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    15.0)),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Color(
                                                                    0xFFABABAB)
                                                                .withOpacity(
                                                                    0.7),
                                                            blurRadius: 4.0,
                                                            spreadRadius: 3.0,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          15.0)),
                                                          color: Colors.black12
                                                              .withOpacity(0.1),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Icon(
                                                                    Icons.edit,
                                                                    color:
                                                                        kIcons,
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
                                                viewModel.deleteProduct(
                                                    viewModel
                                                        .products.value[index]);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  15.0))),
                                                  child: Material(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    15))),
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    15.0)),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Color(
                                                                    0xFFABABAB)
                                                                .withOpacity(
                                                                    0.7),
                                                            blurRadius: 4.0,
                                                            spreadRadius: 3.0,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          15.0)),
                                                          color: Colors.black12
                                                              .withOpacity(0.1),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color:
                                                                        kIcons,
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
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ProductItem(
                                                p: viewModel
                                                    .products.value[index]),
                                          ),
                                        );
                                      },
                                      itemCount:
                                          viewModel.products.value.length,
                                    )
                                  : ListView(
                                      children: <Widget>[
                                        ...value.map(
                                          (e) => Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ProductItem(p: e),
                                          ),
                                        ),
                                      ],
                                    );
                            },
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
                      showBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          builder: (context) {
                            return AddProductWidget(
                              onAddClicked: (p) {
                                p.documentId = widget.category.documentId;
                                viewModel.storeProduct(p).catchError((error) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => OkDialog(
                                      title: AppLocalizations.of(context)
                                          .translate('Error'),
                                      content: error.toString(),
                                    ),
                                  );
                                });
                              },
                            );
                          });
                    },
                    child: Text(
                      AppLocalizations.of(context).translate('Add Product'),
                      style: TextStyle(color: kIcons),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ProductItem extends StatefulWidget {
  const ProductItem({
    @required this.p,
  });

  final Product p;

  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (context, viewModel, child) {
        return Material(
          borderRadius: BorderRadius.circular(4),
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(
                      p: widget.p,
                    ),
                  ));
            },
            child: Container(
              margin: EdgeInsets.all(1),
              padding: EdgeInsets.only(top: 8, left: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.2),
                    blurRadius: 3.5,
                    spreadRadius: 0.4,
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 140,
                        width: 160,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(widget
                                      .p
                                      ?.productsForms[widget.p.selectedIndex]
                                      ?.images
                                      ?.first
                                      ?.downloadUrl ??
                                  ''),
                            )),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 12, top: 12),
                          child: ValueListenableBuilder<User>(
                            builder: (context, user, child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    widget.p.localizedName[
                                        AppLocalizations.of(context)
                                            .locale
                                            .languageCode],
                                    style: TextStyle(
                                        fontFamily: "Sans",
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    widget.p.localizedDescription[
                                        AppLocalizations.of(context)
                                            .locale
                                            .languageCode],
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  Text(
                                    '₾${widget.p.productsForms[widget.p.selectedIndex].price.toString()}',
                                    style: TextStyle(),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: <Widget>[
                                        ...widget.p.productsForms.map(
                                          (e) => Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5,
                                                right: 5,
                                                left: 8,
                                                bottom: 8),
                                            child: Material(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              elevation: 2,
                                              child: AnimatedContainer(
                                                constraints: BoxConstraints(
                                                    maxWidth: 110),
                                                duration:
                                                    Duration(milliseconds: 200),
                                                decoration: BoxDecoration(
                                                    color: widget.p.productsForms[
                                                                widget.p
                                                                    .selectedIndex] ==
                                                            e
                                                        ? kPrimary
                                                        : kIcons,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: RawMaterialButton(
                                                  constraints: BoxConstraints(
                                                      minHeight: 0),
                                                  splashColor: Colors.red,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  onPressed: () {
                                                    setState(() {
                                                      widget.p.selectedIndex =
                                                          widget.p.productsForms
                                                              .indexOf(e);
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(4),
                                                    child: Text(
                                                      e.localizedFormName[
                                                          AppLocalizations.of(
                                                                  context)
                                                              .locale
                                                              .languageCode],
                                                      style: TextStyle(
                                                          color: e ==
                                                                  widget.p.productsForms[
                                                                      widget.p
                                                                          .selectedIndex]
                                                              ? Colors.white
                                                              : Colors.black87),
                                                      maxLines: null,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (user?.role == UserType.user) child,
                                ],
                              );
                            },
                            valueListenable: viewModel.databaseUser,
                            child: Align(
                                alignment: Alignment.topRight,
                                child: ValueListenableBuilder<List<CartItem>>(
                                  builder: (context, value, child) {
                                    return Container(
                                      child: () {
                                        CartItem inCartProduct =
                                            value.firstWhere(
                                                (element) =>
                                                    element.product
                                                        .productDocumentId ==
                                                    widget.p.productDocumentId,
                                                orElse: () => null);
                                        return inCartProduct == null
                                            ? FlatButton(
                                                child: Text(
                                                  AppLocalizations.of(context)
                                                      .translate('Add to cart'),
                                                  style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(.8)),
                                                ),
                                                onPressed: () {
                                                  widget.p.productsForms
                                                      .forEach((element) {
                                                    element.quantity = 0;
                                                  });
                                                  widget
                                                      .p
                                                      .productsForms[widget
                                                          .p.selectedIndex]
                                                      .quantity = 1;
                                                  viewModel.storeCart(widget.p);
                                                },
                                              )
                                            : Container(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.white70,
                                                      border: Border.all(
                                                          color: Colors.black12
                                                              .withOpacity(
                                                                  0.1))),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      /// Decrease of value item
                                                      Material(
                                                        child: InkWell(
                                                          onTap: () {
                                                            try {
                                                              inCartProduct
                                                                  .product
                                                                  .productsForms[
                                                                      widget.p
                                                                          .selectedIndex]
                                                                  .quantity ??= 0;
                                                              if (inCartProduct
                                                                      .product
                                                                      .productsForms[
                                                                          widget
                                                                              .p
                                                                              .selectedIndex]
                                                                      .quantity ==
                                                                  0) {
                                                                return;
                                                              }
                                                              inCartProduct
                                                                  .product
                                                                  .productsForms[
                                                                      widget.p
                                                                          .selectedIndex]
                                                                  .quantity--;
                                                              if (!inCartProduct
                                                                  .product
                                                                  .productsForms
                                                                  .any((element) =>
                                                                      element
                                                                          .quantity >
                                                                      0)) {
                                                                Firestore
                                                                    .instance
                                                                    .collection(
                                                                        '/cart')
                                                                    .document(
                                                                        inCartProduct
                                                                            .documentId)
                                                                    .delete();
                                                                return;
                                                              }
                                                              Firestore.instance
                                                                  .collection(
                                                                      '/cart')
                                                                  .document(
                                                                      inCartProduct
                                                                          .documentId)
                                                                  .setData(
                                                                      inCartProduct
                                                                          .toJson(),
                                                                      merge:
                                                                          true);
                                                            } catch (e) {}
                                                          },
                                                          child: Container(
                                                            height: 30.0,
                                                            width: 30.0,
                                                            decoration: BoxDecoration(
                                                                border: Border(
                                                                    right: BorderSide(
                                                                        color: Colors
                                                                            .black12
                                                                            .withOpacity(0.1)))),
                                                            child: Center(
                                                                child:
                                                                    Text("-")),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    18.0),
                                                        child: Text(inCartProduct
                                                                .product
                                                                .productsForms[
                                                                    widget.p
                                                                        .selectedIndex]
                                                                .quantity
                                                                ?.toString() ??
                                                            '0'),
                                                      ),

                                                      /// Increasing value of item
                                                      Material(
                                                        child: InkWell(
                                                          onTap: () {
                                                            try {
                                                              inCartProduct
                                                                  .product
                                                                  .productsForms[
                                                                      widget.p
                                                                          .selectedIndex]
                                                                  .quantity ??= 0;

                                                              inCartProduct
                                                                  .product
                                                                  .productsForms[
                                                                      widget.p
                                                                          .selectedIndex]
                                                                  .quantity++;
                                                              Firestore.instance
                                                                  .collection(
                                                                      '/cart')
                                                                  .document(
                                                                      inCartProduct
                                                                          .documentId)
                                                                  .setData(
                                                                      inCartProduct
                                                                          .toJson(),
                                                                      merge:
                                                                          true);
                                                            } catch (e) {}
                                                          },
                                                          child: Container(
                                                            height: 30.0,
                                                            width: 28.0,
                                                            decoration: BoxDecoration(
                                                                border: Border(
                                                                    left: BorderSide(
                                                                        color: Colors
                                                                            .black12
                                                                            .withOpacity(0.1)))),
                                                            child: Center(
                                                                child:
                                                                    Text("+")),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
//                                              child: Text(inCartProduct
//                                                      .product
//                                                      .productsForms[widget
//                                                          .p.selectedIndex]
//                                                      .quantity
//                                                      ?.toString() ??
//                                                  '0'),
                                              );
                                        return Container();
                                      }(),
                                    );
                                  },
                                  valueListenable: viewModel.cart,
                                )),
                          ),
//
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AddProductWidget extends StatefulWidget {
  final Function(Product) onAddClicked;
  AddProductWidget({this.onAddClicked, this.pc});
  Product pc;
  @override
  _AddProductWidgetState createState() => _AddProductWidgetState();
}

class _AddProductWidgetState extends State<AddProductWidget> {
  TextEditingController productTextController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productFormNameController = TextEditingController();
  TextEditingController productFormDescriptionController =
      TextEditingController();
  TextEditingController productFormPriceController = TextEditingController();
  TextEditingController productFormWeightController = TextEditingController();
  String selectedLocal = AppLocalizations.supportedLocales.first;
  ValueNotifier<bool> isUploading = ValueNotifier<bool>(false);
  bool addClicked = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedLocal ?? AppLocalizations.supportedLocales.first;
    widget.pc ??= Product();
    localeSelected();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
//
  }

  void localeSelected() {
    setTextControllers();
    widget.pc.localizedDescription ??= {};
    productDescriptionController.text =
        widget.pc.localizedDescription[selectedLocal] ?? '';

    widget.pc.localizedName ??= {};

    productTextController.text = widget.pc.localizedName[selectedLocal] ?? '';
  }

  void setTextControllers() {
    if (widget.pc.selectedIndex != null) {
      productFormNameController.text = widget
              .pc
              .productsForms[widget.pc.selectedIndex]
              .localizedFormName[selectedLocal] ??
          '';
      productFormDescriptionController.text = widget
              .pc
              .productsForms[widget.pc.selectedIndex]
              .localizedFormDescription[selectedLocal] ??
          '';
      productFormPriceController.text =
          widget.pc.productsForms[widget.pc.selectedIndex].price?.toString() ??
              '';
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
                                    localeSelected();
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
                  widget.pc.localizedName ??= {};
                  widget.pc.localizedName[selectedLocal] = value;
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
                  widget.pc.localizedDescription ??= {};
                  widget.pc.localizedDescription[selectedLocal] = value;
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
                      ...?widget.pc?.productsForms?.map(
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
                                        color: widget.pc.selectedIndex == null
                                            ? null
                                            : widget.pc.productsForms
                                                        ?.elementAt(widget.pc
                                                            .selectedIndex) ==
                                                    e
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
                                          widget.pc.selectedIndex = widget
                                              .pc.productsForms
                                              .indexOf(e);
                                          setTextControllers();
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        child: Text(
                                          e.localizedFormName[
                                              AppLocalizations.of(context)
                                                  .locale
                                                  .languageCode],
                                          style: TextStyle(
                                              color: widget.pc.selectedIndex ==
                                                      null
                                                  ? null
                                                  : e ==
                                                          widget
                                                              .pc?.productsForms
                                                              ?.elementAt(widget
                                                                  .pc
                                                                  .selectedIndex)
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
                                          if (widget.pc.selectedIndex ==
                                              widget.pc.productsForms
                                                  .indexOf(e))
                                            try {
                                              widget
                                                  .pc
                                                  ?.productsForms[
                                                      widget.pc.selectedIndex]
                                                  ?.images
                                                  ?.forEach((element) {
                                                FirebaseStorage.instance
                                                    .ref()
                                                    .child(element.refPath)
                                                    .delete();
                                              });
                                            } catch (e) {}
                                          widget.pc.selectedIndex = null;
                                          widget.pc.productsForms.remove(e);
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
                              widget.pc.productsForms ??= [];
                              widget.pc.productsForms.add(ProductForm(
                                  localizedFormDescription:
                                      Map.of(widget.pc.localizedDescription),
                                  localizedFormName: {
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
                  if (widget.pc.selectedIndex != null) ...[
                    TextField(
                      maxLines: null,
                      controller: productFormNameController,
                      onChanged: (value) {
                        setState(() {
                          widget.pc.productsForms[widget.pc.selectedIndex]
                              .localizedFormName ??= {};
                          widget.pc.productsForms[widget.pc.selectedIndex]
                              .localizedFormName[selectedLocal] = value;
                        });
                      },
                      style: TextStyle(),
                      cursorColor: kPrimary,
                      decoration: kinputFiledDecoration.copyWith(
                          hintText: AppLocalizations.of(context)
                              .translate("Product form name")),
                    ),
                    TextField(
                      maxLines: null,
                      controller: productFormDescriptionController,
                      onChanged: (value) {
                        setState(() {
                          widget.pc.productsForms[widget.pc.selectedIndex]
                              .localizedFormDescription ??= {};
                          widget.pc.productsForms[widget.pc.selectedIndex]
                              .localizedFormDescription[selectedLocal] = value;
                        });
                      },
                      style: TextStyle(),
                      cursorColor: kPrimary,
                      decoration: kinputFiledDecoration.copyWith(
                          hintText: AppLocalizations.of(context)
                              .translate("Product form name description")),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      maxLines: null,
                      controller: productFormPriceController,
                      onChanged: (value) {
                        setState(() {
                          widget.pc.productsForms[widget.pc.selectedIndex]
                              .price = double.tryParse(value);
                        });
                      },
                      style: TextStyle(),
                      cursorColor: kPrimary,
                      decoration: kinputFiledDecoration.copyWith(
                          suffixText: curencyMark,
                          hintText: AppLocalizations.of(context)
                              .translate("Product form Price")),
                    ),
                    SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          ...?widget.pc.productsForms
                              ?.elementAt(widget.pc.selectedIndex)
                              ?.images
                              ?.map((e) => Stack(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InnerShadow(
                                          shadows: [
                                            BoxShadow(
                                                color: Colors.white
                                                    .withOpacity(.6),
                                                offset: Offset(1, 1),
                                                blurRadius: 2,
                                                spreadRadius: 2)
                                          ],
                                          child: Container(
                                            margin: EdgeInsets.all(4),
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(.3),
                                                      offset: Offset(2, 2),
                                                      blurRadius: 2,
                                                      spreadRadius: 1),
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(.4),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 2,
                                                      spreadRadius: .5)
                                                ],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                        e.downloadUrl))),
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
                                              splashColor:
                                                  kPrimary.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              onTap: () async {
                                                await FirebaseStorage.instance
                                                    .ref()
                                                    .child(e.refPath)
                                                    .delete();
                                                setState(() {
                                                  widget
                                                      .pc
                                                      .productsForms[widget
                                                          .pc.selectedIndex]
                                                      .images
                                                      .remove(e);
                                                });
                                              },
                                              child: Icon(
                                                Icons.close,
                                                size: 22,
                                                color:
                                                    Colors.red.withOpacity(.5),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                          IconButton(
                            onPressed: () async {
                              try {
                                FirestoreImage im = FirestoreImage();
                                var pickedImage = await ImagePicker()
                                    .getImage(source: ImageSource.gallery);

                                if (pickedImage != null) {
                                  File file = File(pickedImage.path);
                                  Img.Image image_temp =
                                      Img.decodeImage(file.readAsBytesSync());
                                  Img.Image resized_img = Img.copyResize(
                                      image_temp,
                                      width: 800,
                                      height: image_temp.height ~/
                                          (image_temp.width / 800));
                                  var data =
                                      Img.encodeJpg(resized_img, quality: 60);
                                  String filename =
                                      '${Uuid().v4()}${ppp.basename(file.path)}';
                                  isUploading.value = true;
                                  var imageRef = FirebaseStorage.instance
                                      .ref()
                                      .child('images')
                                      .child(filename);

                                  var uploadTask = imageRef.putData(
                                    data,
                                  );

//                                  var uploadTask =
//                                      imageRef.putFile(File(pickedImage.path));
                                  im.refPath = imageRef.path;
                                  var res = await uploadTask.onComplete;
                                  if (!uploadTask.isSuccessful)
                                    throw Exception(AppLocalizations.of(context)
                                        .translate('File upload failed'));
                                  String url = await res.ref.getDownloadURL();
                                  String refPath = imageRef.path;
                                  if (!((url?.length ?? 0) > 0)) {
                                    throw Exception(AppLocalizations.of(context)
                                        .translate('File upload failed'));
                                  }
                                  setState(() {
                                    im.downloadUrl = url;
                                    widget
                                        .pc
                                        .productsForms[widget.pc.selectedIndex]
                                        .images ??= [];
                                    widget
                                        .pc
                                        .productsForms[widget.pc.selectedIndex]
                                        .images
                                        .add(im);
                                  });
                                }
                              } catch (e) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return OkDialog(
                                          title: AppLocalizations.of(context)
                                              .translate('Error'),
                                          content: e.message);
                                    });
                              } finally {
                                isUploading.value = false;
                              }
                            },
                            icon: Icon(Icons.add),
                          )
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              FlatButton(
                color: kPrimary,
                onPressed: () {
                  widget.onAddClicked(widget.pc);
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context).translate('Add'),
                  style: TextStyle(color: kIcons),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductsSearch extends SearchDelegate<String> {
  final List<Product> products;
  ProductsSearch({this.products});
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
    final List<Product> suggestionList = query.isEmpty
        ? products.take(products.length > 10 ? 10 : products.length).toList()
        : products
            .where((element) => element
                .localizedName[AppLocalizations.of(context).locale.languageCode]
                ?.contains(query))
            .toList();

    return ListView(
      children: <Widget>[
        ...suggestionList.map(
          (e) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: ProductItem(p: e),
          ),
        ),
      ],
    );
  }
}
