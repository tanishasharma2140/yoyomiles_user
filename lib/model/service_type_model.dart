class ServiceTypeModel {
  bool? success;
  int? status;
  String? message;
  List<ServiceCategory>? data;

  ServiceTypeModel({this.success, this.status, this.message, this.data});

  ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ServiceCategory>[];
      json['data'].forEach((v) {
        data!.add(ServiceCategory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceCategory {
  String? comment;
  List<VehicleData>? data;

  ServiceCategory({this.comment, this.data});

  ServiceCategory.fromJson(Map<String, dynamic> json) {
    comment = json['comment'];
    if (json['data'] != null) {
      data = <VehicleData>[];
      json['data'].forEach((v) {
        data!.add(VehicleData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['comment'] = comment;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VehicleData {
  int? id;
  String? name;
  int? status;
  int? type;
  String? images;

  VehicleData({this.id, this.name, this.status, this.images});

  VehicleData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    type = json['type'];
    images = json['images'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['status'] = status;
    data['type'] = this.type;
    data['images'] = images;
    return data;
  }
}