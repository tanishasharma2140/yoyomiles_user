class UserHistoryModel {
  bool? success;
  String? message;
  List<Data>? data;

  UserHistoryModel({this.success, this.message, this.data});

  UserHistoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
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
  dynamic gstNumber;
  dynamic gstAddress;
  int? userid;
  String? vehicleType;
  int? vehicleBodyDetailsType;
  int? vehicleBodyType;
  String? availableDriverId;
  int? driverId;
  String? pickupAddress;
  String? pickupLatitute;
  String? pickLongitude;
  String? dropAddress;
  String? dropLatitute;
  String? dropLogitute;
  String? senderName;
  int? senderPhone;
  String? reciverName;
  int? reciverPhone;
  int? rideStatus;
  int? amount;
  int? paymode;
  int? paymentStatus;
  int? distance;
  String? pickupSaveAs;
  String? dropSaveAs;
  dynamic orderTime;
  int? orderType;
  int? otp;
  String? goodsType;
  String? datetime;
  dynamic txnId;
  String? dbVehicleName;
  String? vehicleImage;
  String? vehicleName;
  int? userRating;
  String? ratingDate;

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
        this.gstAddress,
        this.userid,
        this.vehicleType,
        this.vehicleBodyDetailsType,
        this.vehicleBodyType,
        this.availableDriverId,
        this.driverId,
        this.pickupAddress,
        this.pickupLatitute,
        this.pickLongitude,
        this.dropAddress,
        this.dropLatitute,
        this.dropLogitute,
        this.senderName,
        this.senderPhone,
        this.reciverName,
        this.reciverPhone,
        this.rideStatus,
        this.amount,
        this.paymode,
        this.paymentStatus,
        this.distance,
        this.pickupSaveAs,
        this.dropSaveAs,
        this.orderTime,
        this.orderType,
        this.otp,
        this.goodsType,
        this.datetime,
        this.txnId,
        this.dbVehicleName,
        this.vehicleImage,
        this.vehicleName,
        this.userRating,
        this.ratingDate});

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
    userid = json['userid'];
    vehicleType = json['vehicle_type'];
    vehicleBodyDetailsType = json['vehicle_body_details_type'];
    vehicleBodyType = json['vehicle_body_type'];
    availableDriverId = json['available_driver_id'];
    driverId = json['driver_id'];
    pickupAddress = json['pickup_address'];
    pickupLatitute = json['pickup_latitute'];
    pickLongitude = json['pick_longitude'];
    dropAddress = json['drop_address'];
    dropLatitute = json['drop_latitute'];
    dropLogitute = json['drop_logitute'];
    senderName = json['sender_name'];
    senderPhone = json['sender_phone'];
    reciverName = json['reciver_name'];
    reciverPhone = json['reciver_phone'];
    rideStatus = json['ride_status'];
    amount = json['amount'];
    paymode = json['paymode'];
    paymentStatus = json['payment_status'];
    distance = json['distance'];
    pickupSaveAs = json['pickup_save_as'];
    dropSaveAs = json['drop_save_as'];
    orderTime = json['order_time'];
    orderType = json['order_type'];
    otp = json['otp'];
    goodsType = json['goods_type'];
    datetime = json['datetime'];
    txnId = json['txn_id'];
    dbVehicleName = json['db_vehicle_name'];
    vehicleImage = json['vehicle_image'];
    vehicleName = json['vehicle_name'];
    userRating = json['user_rating'];
    ratingDate = json['rating_date'];
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
    data['userid'] = userid;
    data['vehicle_type'] = vehicleType;
    data['vehicle_body_details_type'] = vehicleBodyDetailsType;
    data['vehicle_body_type'] = vehicleBodyType;
    data['available_driver_id'] = availableDriverId;
    data['driver_id'] = driverId;
    data['pickup_address'] = pickupAddress;
    data['pickup_latitute'] = pickupLatitute;
    data['pick_longitude'] = pickLongitude;
    data['drop_address'] = dropAddress;
    data['drop_latitute'] = dropLatitute;
    data['drop_logitute'] = dropLogitute;
    data['sender_name'] = senderName;
    data['sender_phone'] = senderPhone;
    data['reciver_name'] = reciverName;
    data['reciver_phone'] = reciverPhone;
    data['ride_status'] = rideStatus;
    data['amount'] = amount;
    data['paymode'] = paymode;
    data['payment_status'] = paymentStatus;
    data['distance'] = distance;
    data['pickup_save_as'] = pickupSaveAs;
    data['drop_save_as'] = dropSaveAs;
    data['order_time'] = orderTime;
    data['order_type'] = orderType;
    data['otp'] = otp;
    data['goods_type'] = goodsType;
    data['datetime'] = datetime;
    data['txn_id'] = txnId;
    data['db_vehicle_name'] = dbVehicleName;
    data['vehicle_image'] = vehicleImage;
    data['vehicle_name'] = vehicleName;
    data['user_rating'] = userRating;
    data['rating_date'] = ratingDate;
    return data;
  }
}
