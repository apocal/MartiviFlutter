import 'package:martivi/Models/FirestoreImage.dart';

class ProductForm {
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
  ProductForm({this.localizedName});
  ProductForm.fromJson(Map<String, dynamic> json) {
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

class Product {
  String documentId;
  Map<String, String> localizedName;
  Map<String, String> localizedDescription;
  List<ProductForm> productsForms;
  Map<String, dynamic> toJson() => {
        'documentId': documentId,
        'localizedName': localizedName,
        'localizedDescription': localizedDescription,
        'productsForms': productsForms?.map((e) => e.toJson())
      };
  Product.fromJson(Map<String, dynamic> json) {
    documentId = json['documentId'];
    localizedName = json['localizedName'];
    localizedDescription = json['localizedDescription'];
    productsForms = (json['productsForms'] as List<Map<String, dynamic>>)
        ?.map((e) => ProductForm.fromJson(e))
        ?.toList();
  }
  Product();
}
