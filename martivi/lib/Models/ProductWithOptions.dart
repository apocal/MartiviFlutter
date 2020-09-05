import 'FirestoreImage.dart';

class ProductWithOptions {
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

  ProductWithOptions.fromJson(Map<String, dynamic> json) {
    quantityInSupply = (json['quantityInSupply'] as num)?.toInt();
    basePrice = (json['basePrice'] as num)?.toDouble();
    quantity = (json['quantity'] as num)?.toInt();

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

  Map<String, dynamic> toJson() {
    return {
      'localizedAddonDescriptionName': localizedAddonDescriptionName,
      'localizedAddonDescription': localizedAddonDescription,
    };
  }

  AddonDescription.fromJson(Map<String, dynamic> json) {
    localizedAddonDescriptionName =
        Map<String, String>.from(json['localizedAddonDescriptionName']);
    localizedAddonDescription =
        Map<String, String>.from(json['localizedAddonDescription']);
  }
}

class PaidAddon {
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
