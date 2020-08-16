import 'package:martivi/Models/FirestoreImage.dart';

class Product {
  int selectedIndex;
  String documentId;
  String productDocumentId;
  Map<String, String> localizedName;
  Map<String, String> localizedDescription;
  List<ProductForm> productsForms;
  Map<String, dynamic> toJson() => {
        'productDocumentId': productDocumentId,
        'selectedIndex': selectedIndex,
        'documentId': documentId,
        'localizedName': localizedName,
        'localizedDescription': localizedDescription,
        'productsForms': productsForms?.map((e) => e.toJson())?.toList()
      };
  Product.fromJson(Map<String, dynamic> json) {
    selectedIndex = json['selectedIndex'] as int ?? 0;
    documentId = json['documentId'];
    productDocumentId = json['productDocumentId'];
    localizedName = Map<String, String>.from(json['localizedName']);
    localizedDescription =
        Map<String, String>.from(json['localizedDescription']);

    var ff = (json['productsForms'] as List<dynamic>);
    productsForms = (json['productsForms'] as List<dynamic>)
        ?.map((e) => ProductForm.fromJson(e))
        ?.toList();
  }
  Product();
}

class ProductForm {
  Map<String, String> localizedFormName;
  Map<String, String> localizedFormDescription;
  List<FirestoreImage> images;
  double price;
  Map<String, String> localizedWeight;
  int quantity;
  Map<String, dynamic> toJson() => {
        'localizedFormName': localizedFormName,
        'localizedFormDescription': localizedFormDescription,
        'quantity': quantity,
        'images': images?.map((e) => e.toJson())?.toList(),
        'price': price,
        'localizedWeight': localizedWeight,
      };
  ProductForm({this.localizedFormName, this.localizedFormDescription});
  ProductForm.fromJson(Map<String, dynamic> json) {
    localizedFormName = Map<String, String>.from(json['localizedFormName']);
    localizedFormDescription =
        Map<String, String>.from(json['localizedFormDescription'] ?? {});
    price = (json['price'] as num).toDouble();
    localizedWeight = json['localizedWeight'];
    quantity = (json['quantity'] as num)?.toInt();
    images = (json['images'] as List<dynamic>)
        ?.map((e) => FirestoreImage.fromJson(e))
        ?.toList();
//    List m = json['images'];
  }
}
