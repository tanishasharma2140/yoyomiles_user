class PackerMoverVehicleModel {
  bool? status;
  String? message;
  List<Data>? data;

  PackerMoverVehicleModel({this.status, this.message, this.data});

  PackerMoverVehicleModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
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
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? vehicleTypeId;
  int? vehicleBodyTypes;
  int? vehicleBodyDetailId;
  String? vehicleName;
  String? bodyDetail;
  int? startingAmount;
  String? bodyType;
  String? imageForOrderTime;

  Data(
      {this.vehicleTypeId,
        this.vehicleBodyTypes,
        this.vehicleBodyDetailId,
        this.vehicleName,
        this.bodyDetail,
        this.startingAmount,
        this.bodyType,
        this.imageForOrderTime});

  Data.fromJson(Map<String, dynamic> json) {
    vehicleTypeId = json['vehicle_type_id'];
    vehicleBodyTypes = json['vehicle_body_types'];
    vehicleBodyDetailId = json['vehicle_body_detail_id'];
    vehicleName = json['vehicle_name'];
    bodyDetail = json['body_detail'];
    startingAmount = json['starting_amount'];
    bodyType = json['body_type'];
    imageForOrderTime = json['image_for_order_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vehicle_type_id'] = vehicleTypeId;
    data['vehicle_body_types'] = vehicleBodyTypes;
    data['vehicle_body_detail_id'] = vehicleBodyDetailId;
    data['vehicle_name'] = vehicleName;
    data['body_detail'] = bodyDetail;
    data['starting_amount'] = startingAmount;
    data['body_type'] = bodyType;
    data['image_for_order_time'] = imageForOrderTime;
    return data;
  }
}
