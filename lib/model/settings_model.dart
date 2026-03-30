class SettingsModel {
  bool? success;
  Data? data;

  SettingsModel({this.success, this.data});

  SettingsModel.fromJson(Map<String, dynamic> json) {
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
  dynamic type;
  dynamic minBidLimit;
  dynamic userCanDiscount;

  Data({this.type, this.minBidLimit, this.userCanDiscount});

  Data.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    minBidLimit = json['min_bid_limit'];
    userCanDiscount = json['user_can_discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['min_bid_limit'] = minBidLimit;
    data['user_can_discount'] = userCanDiscount;
    return data;
  }
}
