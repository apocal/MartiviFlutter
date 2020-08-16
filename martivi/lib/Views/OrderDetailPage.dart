import 'package:flutter/material.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/Order.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;
  OrderDetailPage({this.order});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context).translate('Order id')}: ${order.orderId?.toString() ?? ''}',
          style: TextStyle(color: kIcons),
        ),
      ),
    );
  }
}
