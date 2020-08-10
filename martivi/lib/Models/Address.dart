class Coordinates {
  String latitude;
  String longitude;
  Coordinates.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'] as String;
    longitude = json['longitude'] as String;
  }
  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}

class UserAddress {
  bool isPrimary;
  String uid;
  String name;
  Coordinates coordinates;
  String address;
  String mobileNumber;
  UserAddress.fromJson(Map<String, dynamic> json) {
    isPrimary = json['isPrimary'] as bool;
    uid = json['uid'] as String;
    coordinates = Coordinates.fromJson(json['coordinates']);
    address = json['address'] as String;
    mobileNumber = json['mobileNumber'] as String;
  }
  Map<String, dynamic> toJson() {
    return {
      'isPrimary': isPrimary,
      'uid': uid,
      'name': name,
      'coordinates': coordinates.toJson(),
      'address': address,
      'mobileNumber': mobileNumber,
    };
  }
}
