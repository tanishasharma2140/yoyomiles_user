class HelpAndSupportModel {
  int? status;
  String? message;
  Data? data;

  HelpAndSupportModel({this.status, this.message, this.data});

  HelpAndSupportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? trucksTwoWheelers;
  int? packersMovers;
  int? allIndeeaParcel;
  int? anyOtherPhone;
  String? anyOtherEmail;

  Data(
      {this.trucksTwoWheelers,
        this.packersMovers,
        this.allIndeeaParcel,
        this.anyOtherPhone,
        this.anyOtherEmail});

  Data.fromJson(Map<String, dynamic> json) {
    trucksTwoWheelers = json['trucks_two_wheelers'];
    packersMovers = json['packers_movers'];
    allIndeeaParcel = json['all_indeea_parcel'];
    anyOtherPhone = json['any_other_phone'];
    anyOtherEmail = json['any_other_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['trucks_two_wheelers'] = trucksTwoWheelers;
    data['packers_movers'] = packersMovers;
    data['all_indeea_parcel'] = allIndeeaParcel;
    data['any_other_phone'] = anyOtherPhone;
    data['any_other_email'] = anyOtherEmail;
    return data;
  }
}
