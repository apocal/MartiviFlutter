import 'package:flutter/material.dart';
import 'package:martivi/Localizations/app_localizations.dart';

import 'FirestoreImage.dart';

class Product {
  double get totalProductPrice =>
      this.basePrice +
      (selectableAddons?.where((element) => element.isSelected)?.fold<double>(
              0, (previousValue, element) => previousValue + element.price) ??
          0) +
      (checkableAddons?.where((element) => element.isSelected)?.fold(
              0, (previousValue, element) => previousValue + element.price) ??
          0);
  String documentId;
  String productDocumentId;
  Map<String, String> localizedName;
  Map<String, String> localizedDescription;
  List<AddonDescription> addonDescriptions;
  List<PaidAddon> selectableAddons;
  List<PaidAddon> checkableAddons;
  List<FirestoreImage> images;
  int quantityInSupply;
  double basePrice;
  int quantity;
  Product(
      {this.localizedDescription,
      this.localizedName,
      this.addonDescriptions,
      this.selectableAddons,
      this.checkableAddons,
      this.images});
  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'productDocumentId': productDocumentId,
      'localizedName': localizedName,
      'localizedDescription': localizedDescription,
      'addonDescriptions': addonDescriptions?.map((e) => e.toJson())?.toList(),
      'selectableAddons': selectableAddons?.map((e) => e.toJson())?.toList(),
      'checkableAddons': checkableAddons?.map((e) => e.toJson())?.toList(),
      'images': images?.map((e) => e.toJson())?.toList(),
      'quantityInSupply': quantityInSupply,
      'basePrice': basePrice,
      'quantity': quantity
    };
  }

  Map<String, dynamic> toCheckoutJson(BuildContext context) => {
        'Quantity': 1,
        'Price': totalProductPrice,
        'Name': localizedName[AppLocalizations.of(context).locale.languageCode],
        'Description':
            '${nullSafeMapValue(localizedDescription, AppLocalizations.of(context).locale.languageCode) ?? ''}, ${nullSafeMapValue(selectableAddons?.firstWhere((element) => element.isSelected, orElse: () => null)?.localizedName, AppLocalizations.of(context).locale.languageCode)}, ${checkableAddons?.where((element) => element.isSelected)?.fold('', (previousValue, element) => previousValue + nullSafeMapValue(element?.localizedName, AppLocalizations.of(context).locale.languageCode) ?? '')}',
      };
  V nullSafeMapValue<K, V>(Map<K, V> map, K key) {
    if (map?.containsKey(key) ?? false) return map[key];
    return null;
  }

  Product.fromJson(Map<String, dynamic> json) {
    productDocumentId = json['productDocumentId'] as String;
    quantityInSupply = (json['quantityInSupply'] as num)?.toInt();
    basePrice = (json['basePrice'] as num)?.toDouble();
    quantity = (json['quantity'] as num)?.toInt();
    documentId = json['documentId'] as String;
    localizedName = Map<String, String>.from(json['localizedName']);
    localizedDescription =
        Map<String, String>.from(json['localizedDescription']);
    addonDescriptions = (json['addonDescriptions'] as List<dynamic>)
        ?.map((e) => AddonDescription.fromJson(e))
        ?.toList();

    selectableAddons = (json['selectableAddons'] as List<dynamic>)
        ?.map((e) => PaidAddon.fromJson(e))
        ?.toList();

    checkableAddons = (json['checkableAddons'] as List<dynamic>)
        ?.map((e) => PaidAddon.fromJson(e))
        ?.toList();

    images = (json['images'] as List<dynamic>)
        ?.map((e) => FirestoreImage.fromJson(e))
        ?.toList();
  }
}

class AddonDescription {
  Map<String, String> localizedAddonDescriptionName;
  Map<String, String> localizedAddonDescription;
  AddonDescription(
      {this.localizedAddonDescription, this.localizedAddonDescriptionName});
  Map<String, dynamic> toJson() {
    return {
      'localizedAddonDescriptionName': localizedAddonDescriptionName,
      'localizedAddonDescription': localizedAddonDescription,
    };
  }

  AddonDescription.fromJson(Map<String, dynamic> json) {
    localizedAddonDescriptionName =
        Map<String, String>.from(json['localizedAddonDescriptionName'] ?? {});
    localizedAddonDescription =
        Map<String, String>.from(json['localizedAddonDescription'] ?? {});
  }
}

class PaidAddon {
  PaidAddon({this.isSelected, this.price, this.localizedName});
  bool isSelected;
  Map<String, String> localizedName;
  double price;
  Map<String, dynamic> toJson() {
    return {
      'isSelected': isSelected,
      'localizedName': localizedName,
      'price': price,
    };
  }

  PaidAddon.fromJson(Map<String, dynamic> json) {
    isSelected = json['isSelected'] as bool;
    localizedName = Map<String, String>.from(json['localizedName']);
    price = (json['price'] as num)?.toDouble();
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:martivi/Localizations/app_localizations.dart';
// import 'package:martivi/Models/FirestoreImage.dart';
//
// class Product {
//   int selectedIndex;
//   String documentId;
//   String productDocumentId;
//   Map<String, String> localizedName;
//   Map<String, String> localizedDescription;
//   List<ProductForm> productsForms;
//   Map<String, dynamic> toJson() => {
//         'productDocumentId': productDocumentId,
//         'selectedIndex': selectedIndex,
//         'documentId': documentId,
//         'localizedName': localizedName,
//         'localizedDescription': localizedDescription,
//         'productsForms': productsForms?.map((e) => e.toJson())?.toList()
//       };
//   Product.fromJson(Map<String, dynamic> json) {
//     selectedIndex = json['selectedIndex'] as int ?? 0;
//     documentId = json['documentId'];
//     productDocumentId = json['productDocumentId'];
//     localizedName = Map<String, String>.from(json['localizedName']);
//     localizedDescription =
//         Map<String, String>.from(json['localizedDescription']);
//
//     var ff = (json['productsForms'] as List<dynamic>);
//     productsForms = (json['productsForms'] as List<dynamic>)
//         ?.map((e) => ProductForm.fromJson(e))
//         ?.where((element) => element.quantityInSupply != 0)
//         ?.toList();
//   }
//   Product();
// }
//
// class ProductForm {
//   Map<String, String> localizedFormName;
//   Map<String, String> localizedFormDescription;
//   List<FirestoreImage> images;
//   int quantityInSupply;
//   double price;
//   Map<String, String> localizedWeight;
//   int quantity;
//   Map<String, dynamic> toJson() => {
//         'quantityInSupply': quantityInSupply,
//         'localizedFormName': localizedFormName,
//         'localizedFormDescription': localizedFormDescription,
//         'quantity': quantity,
//         'images': images?.map((e) => e.toJson())?.toList(),
//         'price': price,
//         'localizedWeight': localizedWeight,
//       };
//   Map<String, dynamic> toCheckoutJson(BuildContext context) => {
//         'Quantity': quantity,
//         'Price': price,
//         'Name':
//             localizedFormName[AppLocalizations.of(context).locale.languageCode],
//         'Description': localizedFormDescription[
//             AppLocalizations.of(context).locale.languageCode],
//       };
//   ProductForm({this.localizedFormName, this.localizedFormDescription});
//   ProductForm.fromJson(Map<String, dynamic> json) {
//     quantityInSupply = (json['quantityInSupply'] as num)?.toInt();
//     localizedFormName = Map<String, String>.from(json['localizedFormName']);
//     localizedFormDescription =
//         Map<String, String>.from(json['localizedFormDescription'] ?? {});
//     price = (json['price'] as num)?.toDouble();
//     localizedWeight = Map<String, String>.from(json['localizedWeight'] ?? {});
//     quantity = (json['quantity'] as num)?.toInt();
//     images = (json['images'] as List<dynamic>)
//         ?.map((e) => FirestoreImage.fromJson(e))
//         ?.toList();
// //    List m = json['images'];
//   }
// }
