import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/CartItem.dart';
import 'package:martivi/Models/Product.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:martivi/Views/CartPage.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product p;
  ProductDetailPage({this.p});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: Text(widget.p
              .localizedName[AppLocalizations.of(context).locale.languageCode]),
          actions: [
            ValueListenableBuilder<List<CartItem>>(
              valueListenable: viewModel.cart,
              builder: (context, cart, child) {
                return Stack(
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
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 12,
                                      minHeight: 12,
                                    ),
                                    child: new Text(
                                      viewModel.cart.value.length.toString(),
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
                );
              },
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return Scaffold(
                          appBar: AppBar(
                            title: Text(
                                AppLocalizations.of(context).translate('Cart')),
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
        body: Padding(
          padding: EdgeInsets.only(left: 8, right: 8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
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
                                              height: 40,
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
                                                      BorderRadius.circular(8)),
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
                                      CartItem inCartProduct = value.firstWhere(
                                          (element) =>
                                              element
                                                  .product.productDocumentId ==
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
                                                    .productsForms[
                                                        widget.p.selectedIndex]
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
                                                            .withOpacity(0.1))),
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
                                                                        widget.p
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
                                                              Firestore.instance
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
                                                                          .withOpacity(
                                                                              0.1)))),
                                                          child: Center(
                                                              child: Text("-")),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 18.0),
                                                      child: Text(inCartProduct
                                                              .product
                                                              .productsForms[widget
                                                                  .p
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
                                                                          .withOpacity(
                                                                              0.1)))),
                                                          child: Center(
                                                              child: Text("+")),
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
                Divider(),
                Row(
                  children: [
                    Text(
                      "Photo",
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.justify,
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.of(context).push(PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) {
                              return PageView(
                                controller: PageController(
                                  initialPage: 0,
                                ),
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                pageSnapping: true,
                                children: <Widget>[
                                  ...?widget
                                      .p
                                      .productsForms[widget.p.selectedIndex]
                                      .images
                                      .map((e) => Scaffold(
                                            appBar: AppBar(
                                              title: Text(widget
                                                      .p.localizedName[
                                                  AppLocalizations.of(context)
                                                      .locale
                                                      .languageCode]),
                                            ),
                                            body: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                  bottom: 5.0,
                                                  left: 5.0,
                                                  right: 5.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          e.downloadUrl),
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                            ),
                                          ))
                                      .toList()
                                ],
                              );
                            },
                          ));
                        },
                        child: Text("See All",
                            style: TextStyle(
                                fontFamily: "Sofia",
                                fontSize: 15.0,
                                fontWeight: FontWeight.w300)))
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                Container(
                  height: 140,
                  child: ListView(
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      ...?widget.p.productsForms[widget.p.selectedIndex].images
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Material(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    child: InkWell(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      onTap: () {
                                        Navigator.of(context).push(
                                            PageRouteBuilder(
                                                opaque: false,
                                                pageBuilder:
                                                    (BuildContext context, _,
                                                        __) {
                                                  return new Material(
                                                    color: Colors.black54,
                                                    child: Container(
                                                      padding: EdgeInsets.only(
                                                          left: 5.0,
                                                          right: 5.0,
                                                          top: 0.0,
                                                          bottom: 0.0),
                                                      child: InkWell(
                                                        child: Hero(
                                                            tag:
                                                                "hero-grid-${e.refPath}",
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 5.0,
                                                                      right:
                                                                          5.0,
                                                                      top:
                                                                          160.0,
                                                                      bottom:
                                                                          160.0),
                                                              child: Container(
                                                                height: 500.0,
                                                                width: double
                                                                    .infinity,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.all(Radius.circular(
                                                                            10.0)),
                                                                    image: DecorationImage(
                                                                        image: NetworkImage(e
                                                                            .downloadUrl),
                                                                        fit: BoxFit
                                                                            .cover)),
                                                              ),
                                                            )),
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                                transitionDuration: Duration(
                                                    milliseconds: 500)));
                                      },
                                      child: Hero(
                                        tag: "hero-grid-${e.refPath}",
                                        child: Container(
                                          height: 110.0,
                                          width: 140.0,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      e.downloadUrl),
                                                  fit: BoxFit.cover),
                                              color: Colors.black12,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              boxShadow: [
                                                BoxShadow(
                                                    blurRadius: 5.0,
                                                    color: Colors.black12
                                                        .withOpacity(0.1),
                                                    spreadRadius: 2.0)
                                              ]),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ],
                    scrollDirection: Axis.horizontal,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 30.0, left: 20.0, right: 20.0, bottom: 50.0),
                  child: Text(
                    widget.p.productsForms[widget.p.selectedIndex]
                            .localizedFormDescription[
                        AppLocalizations.of(context).locale.languageCode],
                    style: TextStyle(
                        fontFamily: "Sofia",
                        color: Colors.black54,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
