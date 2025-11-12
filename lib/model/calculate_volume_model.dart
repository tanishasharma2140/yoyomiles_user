class CalculateVolumeModel {
  bool? status;
  String? message;
  double? totalVolumeFt3; // Change to double
  String? vehicleVolumeFt3;
  double? distance; // Change to double
  double? amountPerKm; // Change to double
  int? totalFloors;
  double? liftChargePerFloor;
  double? liftChargeAmount; // Change to double
  List<Data>? data;

  CalculateVolumeModel(
      {this.status,
        this.message,
        this.totalVolumeFt3,
        this.vehicleVolumeFt3,
        this.distance,
        this.amountPerKm,
        this.totalFloors,
        this.liftChargePerFloor,
        this.liftChargeAmount,
        this.data});

  CalculateVolumeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];

    // Convert to double safely
    totalVolumeFt3 = _toDouble(json['total_volume_ft3']);
    vehicleVolumeFt3 = json['vehicle_volume_ft3']?.toString();
    distance = _toDouble(json['distance']);
    amountPerKm = _toDouble(json['amount_per_km']);
    totalFloors = _toInt(json['total_floors']);
    liftChargePerFloor = _toDouble(json['lift_charge_per_floor']);
    liftChargeAmount = _toDouble(json['lift_charge_amount']);

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
    data['total_volume_ft3'] = totalVolumeFt3;
    data['vehicle_volume_ft3'] = vehicleVolumeFt3;
    data['distance'] = distance;
    data['amount_per_km'] = amountPerKm;
    data['total_floors'] = totalFloors;
    data['lift_charge_per_floor'] = liftChargePerFloor;
    data['lift_charge_amount'] = liftChargeAmount;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  // Helper method to convert to double
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Helper method to convert to int
  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class Data {
  int? numberOfVehicle;
  double? amount; // Change to double
  List<SubItems>? subItems;

  Data({this.numberOfVehicle, this.amount, this.subItems});

  Data.fromJson(Map<String, dynamic> json) {
    numberOfVehicle = _toInt(json['number_of_vehicle']);
    amount = _toDouble(json['amount']); // Convert to double
    if (json['sub_items'] != null) {
      subItems = <SubItems>[];
      json['sub_items'].forEach((v) {
        subItems!.add(SubItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number_of_vehicle'] = numberOfVehicle;
    data['amount'] = amount;
    if (subItems != null) {
      data['sub_items'] = subItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  // Helper methods
  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class SubItems {
  int? vehicleTypeId;
  int? vehicleBodyTypes;
  int? vehicleBodyDetailId;
  String? vehicleName;
  String? bodyDetail;
  String? bodyType;
  String? imageForOrderTime;

  SubItems(
      {this.vehicleTypeId,
        this.vehicleBodyTypes,
        this.vehicleBodyDetailId,
        this.vehicleName,
        this.bodyDetail,
        this.bodyType,
        this.imageForOrderTime});

  SubItems.fromJson(Map<String, dynamic> json) {
    vehicleTypeId = _toInt(json['vehicle_type_id']);
    vehicleBodyTypes = _toInt(json['vehicle_body_types']);
    vehicleBodyDetailId = _toInt(json['vehicle_body_detail_id']);
    vehicleName = json['vehicle_name'];
    bodyDetail = json['body_detail'];
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
    data['body_type'] = bodyType;
    data['image_for_order_time'] = imageForOrderTime;
    return data;
  }

  // Helper method
  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}