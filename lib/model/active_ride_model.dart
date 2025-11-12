class ActiveRideModel {
  int? status;
  String? message;
  Data? data;

  ActiveRideModel({this.status, this.message, this.data});

  ActiveRideModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  int? userid;
  String? vehicleType;
  int? vehicleBodyDetailsType;
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
  int? driverId;
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
  String? updatedAt;
  dynamic txnId;
  String? createdAt;
  String? availableDriverId;

  Data(
      {this.id,
        this.userid,
        this.vehicleType,
        this.vehicleBodyDetailsType,
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
        this.driverId,
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
        this.updatedAt,
        this.txnId,
        this.createdAt,
        this.availableDriverId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userid = json['userid'];
    vehicleType = json['vehicle_type'];
    vehicleBodyDetailsType = json['vehicle_body_details_type'];
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
    driverId = json['driver_id'];
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
    updatedAt = json['updated_at'];
    txnId = json['txn_id'];
    createdAt = json['created_at'];
    availableDriverId = json['available_driver_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userid'] = userid;
    data['vehicle_type'] = vehicleType;
    data['vehicle_body_details_type'] = vehicleBodyDetailsType;
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
    data['driver_id'] = driverId;
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
    data['updated_at'] = updatedAt;
    data['txn_id'] = txnId;
    data['created_at'] = createdAt;
    data['available_driver_id'] = availableDriverId;
    return data;
  }
}
