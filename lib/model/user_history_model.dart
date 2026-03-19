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
        data!.add(new Data.fromJson(v));
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
  dynamic id;
  dynamic referralId;
  dynamic referralCode;
  dynamic deviceId;
  dynamic firstName;
  dynamic lastName;
  dynamic email;
  dynamic type;
  dynamic phone;
  dynamic status;
  dynamic wallet;
  dynamic fcm;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic gstNumber;
  dynamic gstAddress;
  dynamic coins;
  dynamic firstRideStatus;
  dynamic userid;
  dynamic rideStatus;
  dynamic amount;
  dynamic paymode;
  dynamic vehicleType;
  dynamic vehicleBodyDetailsType;
  dynamic vehicleBodyType;
  dynamic availableDriverId;
  dynamic driverId;
  dynamic pickupAddress;
  dynamic pickupLatitute;
  dynamic pickLongitude;
  dynamic dropAddress;
  dynamic dropLatitute;
  dynamic dropLogitute;
  dynamic senderName;
  dynamic senderPhone;
  dynamic reciverName;
  dynamic reciverPhone;
  dynamic paymentStatus;
  dynamic distance;
  dynamic pickupSaveAs;
  dynamic dropSaveAs;
  dynamic orderType;
  dynamic otp;
  dynamic goodsType;
  dynamic txnId;
  dynamic orderTime;
  dynamic datetime;
  dynamic couponId;
  dynamic ignoredDriverId;
  dynamic cancelByAdmin;
  dynamic extraCharges;
  dynamic walletApplied;
  dynamic amountWalletApplied;
  dynamic dbVehicleName;
  dynamic vehicleImage;
  dynamic vehicleName;
  dynamic userRating;
  dynamic ratingDate;
  dynamic invoiceLink;

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
        this.firstRideStatus,
        this.userid,
        this.rideStatus,
        this.amount,
        this.paymode,
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
        this.paymentStatus,
        this.distance,
        this.pickupSaveAs,
        this.dropSaveAs,
        this.orderType,
        this.otp,
        this.goodsType,
        this.txnId,
        this.orderTime,
        this.datetime,
        this.couponId,
        this.ignoredDriverId,
        this.cancelByAdmin,
        this.extraCharges,
        this.walletApplied,
        this.amountWalletApplied,
        this.dbVehicleName,
        this.vehicleImage,
        this.vehicleName,
        this.userRating,
        this.ratingDate,
        this.invoiceLink});

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
    firstRideStatus = json['first_ride_status'];
    userid = json['userid'];
    rideStatus = json['ride_status'];
    amount = json['amount'];
    paymode = json['paymode'];
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
    paymentStatus = json['payment_status'];
    distance = json['distance'];
    pickupSaveAs = json['pickup_save_as'];
    dropSaveAs = json['drop_save_as'];
    orderType = json['order_type'];
    otp = json['otp'];
    goodsType = json['goods_type'];
    txnId = json['txn_id'];
    orderTime = json['order_time'];
    datetime = json['datetime'];
    couponId = json['coupon_id'];
    ignoredDriverId = json['ignored_driver_id'];
    cancelByAdmin = json['cancel_by_admin'];
    extraCharges = json['extra_charges'];
    walletApplied = json['wallet_applied'];
    amountWalletApplied = json['amount_wallet_applied'];
    dbVehicleName = json['db_vehicle_name'];
    vehicleImage = json['vehicle_image'];
    vehicleName = json['vehicle_name'];
    userRating = json['user_rating'];
    ratingDate = json['rating_date'];
    invoiceLink = json['invoice_link'];
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
    data['first_ride_status'] = firstRideStatus;
    data['userid'] = userid;
    data['ride_status'] = rideStatus;
    data['amount'] = amount;
    data['paymode'] = paymode;
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
    data['payment_status'] = paymentStatus;
    data['distance'] = distance;
    data['pickup_save_as'] = pickupSaveAs;
    data['drop_save_as'] = dropSaveAs;
    data['order_type'] = orderType;
    data['otp'] = otp;
    data['goods_type'] = goodsType;
    data['txn_id'] = txnId;
    data['order_time'] = orderTime;
    data['datetime'] = datetime;
    data['coupon_id'] = couponId;
    data['ignored_driver_id'] = ignoredDriverId;
    data['cancel_by_admin'] = cancelByAdmin;
    data['extra_charges'] = extraCharges;
    data['wallet_applied'] = walletApplied;
    data['amount_wallet_applied'] = amountWalletApplied;
    data['db_vehicle_name'] = dbVehicleName;
    data['vehicle_image'] = vehicleImage;
    data['vehicle_name'] = vehicleName;
    data['user_rating'] = userRating;
    data['rating_date'] = ratingDate;
    data['invoice_link'] = invoiceLink;
    return data;
  }
}
