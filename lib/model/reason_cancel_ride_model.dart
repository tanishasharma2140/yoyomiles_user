class ReasonCancelRideModel {
  bool? status;
  String? message;
  List<Data>? data;

  ReasonCancelRideModel({this.status, this.message, this.data});

  ReasonCancelRideModel.fromJson(Map<String, dynamic> json) {
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
  int? id;
  String? reasonText;

  Data({this.id, this.reasonText});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reasonText = json['reason_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['reason_text'] = reasonText;
    return data;
  }
}
