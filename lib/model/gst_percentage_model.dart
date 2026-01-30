class GstPercentageModel {
  bool? success;
  Data? data;

  GstPercentageModel({this.success, this.data});

  GstPercentageModel.fromJson(Map<String, dynamic> json) {
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
  String? gstPercentage;

  Data({this.gstPercentage});

  Data.fromJson(Map<String, dynamic> json) {
    gstPercentage = json['gst_percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['gst_percentage'] = gstPercentage;
    return data;
  }
}
