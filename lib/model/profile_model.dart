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
  int? referralId;
  String? referralCode;
  String? deviceId;
  String? firstName;
  String? lastName;
  String? email;
  String? type;
  int? phone;
  int? status;
  int? wallet;
  String? fcm;
  String? createdAt;
  String? updatedAt;
  String? gstNumber;
  String? gstAddress;
  int? coins;
  String? referralLink;
  int? referralAmount;
  String? referralMessages;

  Data(
      {this.id,
        this.referralId,
        this.referralCode,
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
        this.gstAddress,
        this.coins,
        this.referralLink,
        this.referralAmount,
        this.referralMessages});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    referralId = json['referral_id'];
    referralCode = json['referral_code'];
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
    coins = json['coins'];
    referralLink = json['referral_link'];
    referralAmount = json['referral_amount'];
    referralMessages = json['referral_messages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['referral_id'] = referralId;
    data['referral_code'] = referralCode;
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
    data['coins'] = coins;
    data['referral_link'] = referralLink;
    data['referral_amount'] = referralAmount;
    data['referral_messages'] = referralMessages;
    return data;
  }
}
