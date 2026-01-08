class VehicleLoadingModel {
  bool? success;
  Data? data;

  VehicleLoadingModel({this.success, this.data});

  VehicleLoadingModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? vehicleType;
  int? loadingTimeMinute;
  int? unloadingTimeMinute;
  String? source;

  Data(
      {this.vehicleType,
        this.loadingTimeMinute,
        this.unloadingTimeMinute,
        this.source});

  Data.fromJson(Map<String, dynamic> json) {
    vehicleType = json['vehicle_type'];
    loadingTimeMinute = json['loading_time_minute'];
    unloadingTimeMinute = json['unloading_time_minute'];
    source = json['source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vehicle_type'] = vehicleType;
    data['loading_time_minute'] = loadingTimeMinute;
    data['unloading_time_minute'] = unloadingTimeMinute;
    data['source'] = source;
    return data;
  }
}
