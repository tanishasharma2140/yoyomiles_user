class SelectVehicleModel {
  int? status;
  String? message;
  List<Data>? data;

  SelectVehicleModel({this.status, this.message, this.data});

  SelectVehicleModel.fromJson(Map<String, dynamic> json) {
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
  int? vehicleId;
  String? vehicleName;
  int? vehicleBodyTypesId;
  int? vehicleBodyDetailsId;
  String? bodyDetail;
  String? vehicleImage;
  String? measurementsImg;
  int? amount;
  int? selectedStatus;
  int? type;
  dynamic comment;

  Data(
      {this.vehicleId,
        this.vehicleName,
        this.vehicleBodyTypesId,
        this.vehicleBodyDetailsId,
        this.bodyDetail,
        this.vehicleImage,
        this.measurementsImg,
        this.amount,
        this.selectedStatus,
        this.type,
        this.comment});

  Data.fromJson(Map<String, dynamic> json) {
    vehicleId = json['vehicle_id'];
    vehicleName = json['vehicle_name'];
    vehicleBodyTypesId = json['vehicle_body_types_id'];
    vehicleBodyDetailsId = json['vehicle_body_details_id'];
    bodyDetail = json['body_detail'];
    vehicleImage = json['vehicle_image'];
    measurementsImg = json['measurements_img'];
    amount = json['amount'];
    selectedStatus = json['selected_status'];
    type = json['type'];
    comment = json['comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vehicle_id'] = vehicleId;
    data['vehicle_name'] = vehicleName;
    data['vehicle_body_types_id'] = vehicleBodyTypesId;
    data['vehicle_body_details_id'] = vehicleBodyDetailsId;
    data['body_detail'] = bodyDetail;
    data['vehicle_image'] = vehicleImage;
    data['measurements_img'] = measurementsImg;
    data['amount'] = amount;
    data['selected_status'] = selectedStatus;
    data['type'] = type;
    data['comment'] = comment;
    return data;
  }
}
