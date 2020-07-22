import 'package:martivi/Models/Product.dart';

import 'FirestoreImage.dart';

class Category {
  Map<String, String> localizedName = {};
  FirestoreImage image;
  List<ProductCategory> productsCategories;
  Map<String, dynamic> toJson() => {
        'localizedName': localizedName,
        'image': image?.toJson(),
        'products': productsCategories?.map((e) => e.toJson())?.toList(),
      };
  Category({this.image, this.productsCategories, this.localizedName});
  Category.fromJson(Map<String, dynamic> json) {
    localizedName = Map<String, String>.from(json['localizedName']);
    image = FirestoreImage.fromJson(json['image']);
    productsCategories = (json['productsCategories'] as List)
        ?.map((e) => ProductCategory.fromJson(e))
        ?.toList();
  }
}
