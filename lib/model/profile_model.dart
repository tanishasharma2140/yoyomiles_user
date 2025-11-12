class ProfileModel {
  Data? data;
  bool? success;
  String? message;
  int? status;

  ProfileModel({this.data, this.success, this.message, this.status});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    success = json['success'];
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['success'] = success;
    data['message'] = message;
    data['status'] = status;
    return data;
  }
}

class Data {
  int? id;
  String? deviceId;
  String? firstName;
  String? lastName;
  String? email;
  String? type;
  int? phone;
  int? status;
  dynamic wallet;
  String? fcm;
  String? createdAt;
  String? updatedAt;
  String? gstNumber;
  String? gstAddress;

  Data(
      {this.id,
        this.deviceId,
        this.firstName,
        this.lastName,
        this.email,
        this.type,
        this.phone,
        this.status,
        this.wallet,
        this.fcm,
        this.createdAt,
        this.updatedAt,
        this.gstNumber,
        this.gstAddress});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deviceId = json['device_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    type = json['type'];
    phone = json['phone'];
    status = json['status'];
    wallet = json['wallet'];
    fcm = json['fcm'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    gstNumber = json['gst_number'];
    gstAddress = json['gst_address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['device_id'] = deviceId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['type'] = type;
    data['phone'] = phone;
    data['status'] = status;
    data['wallet'] = wallet;
    data['fcm'] = fcm;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['gst_number'] = gstNumber;
    data['gst_address'] = gstAddress;
    return data;
  }
}
