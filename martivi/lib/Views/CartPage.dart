import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/CartItem.dart';
import 'package:martivi/Models/Product.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (context, viewModel, child) {
        return ValueListenableBuilder<List<CartItem>>(
          valueListenable: viewModel.cart,
          builder: (context, value, child) {
            var pForms = value.expand<ProductForm>((element) => element
                .product.productsForms
                .where((element) => element.quantity > 0));
            return Column(
              children: [
                Theme(
                  data: ThemeData(
                      accentColor: kPrimary,
                      textTheme: Theme.of(context).textTheme.copyWith(
                          subtitle1:
                              TextStyle(color: Colors.black.withOpacity(.7)))),
                  child: ExpansionTile(
                    leading: Text(
                      AppLocalizations.of(context).translate('Cart'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            '${pForms.length.toString()} ${AppLocalizations.of(context).translate('Product')} | '),
                        Text(
                          '₾${pForms.fold<double>(0, (previousValue, element) => previousValue + element.quantity * element.price).toString()}',
                        )
                      ],
                    ),
                    children: [
                      ...viewModel.cart.value
                          .map((e) => CartItemWidget(
                                p: e,
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class CartItemWidget extends StatefulWidget {
  const CartItemWidget({
    @required this.p,
  });

  final CartItem p;

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (context, viewModel, child) {
        return Container(
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 140,
                width: 160,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget
                              .p
                              ?.product
                              .productsForms[widget.p.product.selectedIndex]
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
                            widget.p.product.localizedName[
                                AppLocalizations.of(context)
                                    .locale
                                    .languageCode],
                            style: TextStyle(
                                fontFamily: "Sans",
                                color: Colors.black87,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            widget.p.product.localizedDescription[
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
                            '₾${widget.p.product.productsForms[widget.p.product.selectedIndex].price.toString()}',
                            style: TextStyle(),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: <Widget>[
                                ...widget.p.product.productsForms.map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, right: 5, left: 8, bottom: 8),
                                    child: Material(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      elevation: 2,
                                      child: AnimatedContainer(
                                        height: 40,
                                        duration: Duration(milliseconds: 200),
                                        decoration: BoxDecoration(
                                            color: widget.p.product
                                                            .productsForms[
                                                        widget.p.product
                                                            .selectedIndex] ==
                                                    e
                                                ? kPrimary
                                                : kIcons,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: RawMaterialButton(
                                          constraints:
                                              BoxConstraints(minHeight: 0),
                                          splashColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          onPressed: () {
                                            setState(() {
                                              widget.p.product.selectedIndex =
                                                  widget.p.product.productsForms
                                                      .indexOf(e);
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
                                                  color: e ==
                                                          widget.p.product
                                                                  .productsForms[
                                                              widget.p.product
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
                      child: Container(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white70,
                              border: Border.all(
                                  color: Colors.black12.withOpacity(0.1))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Material(
                                child: InkWell(
                                  onTap: () {
                                    try {
                                      widget
                                          .p
                                          .product
                                          .productsForms[
                                              widget.p.product.selectedIndex]
                                          .quantity ??= 0;
                                      if (widget
                                              .p
                                              .product
                                              .productsForms[widget
                                                  .p.product.selectedIndex]
                                              .quantity ==
                                          0) {
                                        return;
                                      }
                                      widget
                                          .p
                                          .product
                                          .productsForms[
                                              widget.p.product.selectedIndex]
                                          .quantity--;
                                      if (!widget.p.product.productsForms.any(
                                          (element) => element.quantity > 0)) {
                                        Firestore.instance
                                            .collection('/cart')
                                            .document(widget.p.documentId)
                                            .delete();
                                        return;
                                      }
                                      Firestore.instance
                                          .collection('/cart')
                                          .document(widget.p.documentId)
                                          .setData(widget.p.toJson(),
                                              merge: true);
                                    } catch (e) {}
                                  },
                                  child: Container(
                                    height: 30.0,
                                    width: 30.0,
                                    decoration: BoxDecoration(
                                        border: Border(
                                            right: BorderSide(
                                                color: Colors.black12
                                                    .withOpacity(0.1)))),
                                    child: Center(child: Text("-")),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0),
                                child: Text(widget
                                        .p
                                        .product
                                        .productsForms[
                                            widget.p.product.selectedIndex]
                                        .quantity
                                        ?.toString() ??
                                    '0'),
                              ),
                              Material(
                                child: InkWell(
                                  onTap: () {
                                    try {
                                      widget
                                          .p
                                          .product
                                          .productsForms[
                                              widget.p.product.selectedIndex]
                                          .quantity ??= 0;
                                      widget
                                          .p
                                          .product
                                          .productsForms[
                                              widget.p.product.selectedIndex]
                                          .quantity++;
                                      Firestore.instance
                                          .collection('/cart')
                                          .document(widget.p.documentId)
                                          .setData(widget.p.toJson(),
                                              merge: true);
                                    } catch (e) {}
                                  },
                                  child: Container(
                                    height: 30.0,
                                    width: 28.0,
                                    decoration: BoxDecoration(
                                        border: Border(
                                            left: BorderSide(
                                                color: Colors.black12
                                                    .withOpacity(0.1)))),
                                    child: Center(child: Text("+")),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ), //
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
