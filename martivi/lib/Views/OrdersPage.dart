import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/Order.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:martivi/Views/OrderDetailPage.dart';
import 'package:martivi/Widgets/FadeInWidget.dart';
import 'package:provider/provider.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    return FadeInWidget(
        child: Consumer2<MainViewModel, FirebaseUser>(
      builder: (context, viewModel, user, child) => user == null
          ? Align(
              alignment: Alignment.center,
              child:
                  Text(AppLocalizations.of(context).translate('Unauthorized')),
            )
          : ValueListenableBuilder<User>(
              valueListenable: viewModel.databaseUser,
              builder: (context, databaseUser, child) => databaseUser != null
                  ? StreamBuilder<QuerySnapshot>(
                      stream: databaseUser.role == UserType.admin
                          ? Firestore.instance
                              .collection('orders')
                              .orderBy('serverTime', descending: true)
                              .snapshots()
                          : Firestore.instance
                              .collection('orders')
                              .where('uid', isEqualTo: user.uid)
                              .orderBy('serverTime', descending: true)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              var order = Order.fromJson(
                                  snapshot.data.documents[index].data);
                              order.documentId =
                                  snapshot.data.documents[index].documentID;
                              return OrderWidget(
                                showIsSeenIcon:
                                    databaseUser.role == UserType.admin
                                        ? true
                                        : false,
                                order: order,
                              );
                            },
                          );
                        } else
                          return Align(
                              alignment: Alignment.center,
                              child: Text('No Data'));
                      },
                    )
                  : Center(
                      child: Text(AppLocalizations.of(context)
                          .translate('Unauthorized')),
                    ),
            ),
    ));
  }
}

class OrderWidget extends StatelessWidget {
  final bool showIsSeenIcon;
  final Order order;
  OrderWidget({this.order, this.showIsSeenIcon = false});
  @override
  Widget build(BuildContext context) {
    print(order.isSeen);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 2,
          child: RawMaterialButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onPressed: () {
              if (showIsSeenIcon) {
                if (!order.isSeen)
                  Firestore.instance
                      .collection('/orders')
                      .document(order.documentId)
                      .updateData({'isSeen': true});
              }
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => OrderDetailPage(
                  orderR: order,
                ),
              ));
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(4),
                          topLeft: Radius.circular(4))),
                  elevation: 2,
                  color: kPrimary,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat.yMd().add_Hms().format(
                              (order.serverTime as Timestamp)?.toDate() ??
                                  DateTime(0000)),
                          style: TextStyle(
                              color: kIcons,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                        if (showIsSeenIcon && !order.isSeen)
                          Icon(
                            Icons.star,
                            color: kIcons,
                          ),
                        Text(
                          '${AppLocalizations.of(context).translate('Order id')}: ${order.orderId?.toString() ?? ''}',
                          style: TextStyle(color: kIcons),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${AppLocalizations.of(context).translate('Order price')}: ₾${(order.products.fold<double>(0, (previousValue, element) => previousValue + element.price * element.quantity))?.toString() ?? '0'}',
                          style: TextStyle(color: kPrimary),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Flexible(
                        child: Text(
                          '${AppLocalizations.of(context).translate('Delivery fee')}: ₾${order.deliveryFee?.toString() ?? '0'}',
                          style: TextStyle(color: kPrimary),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2)),
                          elevation: 4,
                          color: Colors.grey.shade300,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              children: [
                                Text(AppLocalizations.of(context)
                                    .translate('Order status')),
                                Text(AppLocalizations.of(context).translate(
                                    EnumToString.parse(order
                                        .deliveryStatusSteps.entries
                                        .firstWhere(
                                            (element) => element.value.isActive)
                                        .key))),
                              ],
                            ),
                          )),
                      Material(
                          color: Colors.grey.shade300,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2)),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              children: [
                                Text(AppLocalizations.of(context)
                                    .translate('Payment status')),
                                Text(AppLocalizations.of(context).translate(
                                    EnumToString.parse(order.paymentStatus))),
                              ],
                            ),
                          ))
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
