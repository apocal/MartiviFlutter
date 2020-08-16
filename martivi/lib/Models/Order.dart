import 'package:enum_to_string/enum_to_string.dart';
import 'package:martivi/Models/Address.dart';
import 'package:martivi/Models/Product.dart';
import 'package:martivi/Models/enums.dart';

class Order {
  int orderId;
  String documentId;
  String uid;
  List<ProductForm> products;
  PaymentMethods paymentMethod;
  PaymentStatus paymentStatus;
  double deliveryFee;
  UserAddress deliveryAddress;
  DeliveryStatus status;
  bool isSeen;
  dynamic serverTime;
  Order(
      {this.paymentMethod,
      this.orderId,
      this.paymentStatus = PaymentStatus.NotPaid,
      this.documentId,
      this.isSeen,
      this.serverTime,
      this.uid,
      this.products,
      this.deliveryAddress,
      this.deliveryFee,
      this.status});

  Order.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'] as int;
    paymentStatus = EnumToString.fromString(
        PaymentStatus.values, (json['paymentStatus'] as String) ?? 'UNKNOWN');
    isSeen = json['isSeen'] as bool;
    serverTime = json['serverTime'];
    status = EnumToString.fromString(
        DeliveryStatus.values, json['status'] as String ?? 'Unknown');
    uid = json['uid'] as String;
    products = (json['products'] as List<dynamic>)
        ?.map((e) => ProductForm.fromJson(e))
        ?.toList();
    paymentMethod = EnumToString.fromString(
        PaymentMethods.values, json['paymentMethod'] as String);
    deliveryFee = (json['deliveryFee'] as num)?.toDouble();
    deliveryAddress = UserAddress.fromJson(json['deliveryAddress']);
  }
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'paymentStatus': EnumToString.parse(paymentStatus),
      'isSeen': isSeen,
      'serverTime': serverTime,
      'status': EnumToString.parse(status),
      'uid': uid,
      'products': products?.map((e) => e.toJson())?.toList(),
      'paymentMethod': EnumToString.parse(paymentMethod),
      'deliveryFee': deliveryFee,
      'deliveryAddress': deliveryAddress?.toJson(),
    };
  }
}
