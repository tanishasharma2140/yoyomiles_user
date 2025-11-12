class AddressShowModel {
  List<Data>? data;
  int? status;
  String? message;

  AddressShowModel({this.data, this.status, this.message});

  AddressShowModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Data {
  int? id;
  int? userid;
  dynamic name;
  dynamic contactNo;
  String? latitude;
  String? longitude;
  String? address;
  dynamic addressType;
  dynamic houseArea;
  dynamic pincode;
  String? datetime;

  Data(
      {this.id,
        this.userid,
        this.name,
        this.contactNo,
        this.latitude,
        this.longitude,
        this.address,
        this.addressType,
        this.houseArea,
        this.pincode,
        this.datetime});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userid = json['userid'];
    name = json['name'];
    contactNo = json['contact_no'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    addressType = json['address_type'];
    houseArea = json['house_area'];
    pincode = json['pincode'];
    datetime = json['datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['userid'] = userid;
    data['name'] = name;
    data['contact_no'] = contactNo;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address;
    data['address_type'] = addressType;
    data['house_area'] = houseArea;
    data['pincode'] = pincode;
    data['datetime'] = datetime;
    return data;
  }
}
