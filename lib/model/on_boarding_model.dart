class OnBoardingModel {
  int? status;
  List<Data>? data;

  OnBoardingModel({this.status, this.data});

  OnBoardingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
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
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? imageUrl;
  String? heading;
  String? subHeading;

  Data({this.id, this.imageUrl, this.heading, this.subHeading});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imageUrl = json['image_url'];
    heading = json['heading'];
    subHeading = json['sub_heading'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image_url'] = imageUrl;
    data['heading'] = heading;
    data['sub_heading'] = subHeading;
    return data;
  }
}
