import 'package:martivi/Models/FirestoreImage.dart';

class Product {
  Map<String, String> localizedName;
  List<FirestoreImage> images;
  String curencyMark;
  double price;
  Map<String, String> localizedWeight;
  int quantityInSupply;
  int quantity;
  Map<String, dynamic> toJson() => {
        'localizedName': localizedName,
        'quantityInSupply': quantityInSupply,
        'quantity': quantity,
        'images': images?.map((e) => e.toJson())?.toList(),
        'price': price,
        'localizedWeight': localizedWeight,
        'curencyMark': curencyMark
      };

  Product.fromJson(Map<String, dynamic> json) {
    localizedName = json['localizedName'];
    price = json['price'] as double;
    localizedWeight = json['localizedWeight'];
    curencyMark = json['curencyMark'] as String;
    quantityInSupply = json['quantityInSupply'] as int;
    quantity = json['quantity'] as int;
    images = (json['images'] as List<Map<String, dynamic>>)
        ?.map((e) => FirestoreImage.fromJson(e))
        ?.toList();
  }
}

class ProductCategory {
  Map<String, String> localizedName;
  Map<String, String> localizedDescription;
  List<Product> products;
  Map<String, dynamic> toJson() => {
        'localizedName': localizedName,
        'localizedDescription': localizedDescription,
        'products': products?.map((e) => e.toJson())
      };
  ProductCategory.fromJson(Map<String, dynamic> json) {
    localizedName = json['localizedName'];
    localizedDescription = json['localizedDescription'];
    products = (json['products'] as List<Map<String, dynamic>>)
        ?.map((e) => Product.fromJson(e))
        ?.toList();
  }
}
