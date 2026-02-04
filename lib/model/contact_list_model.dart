class ContactListModel {
  bool? status;
  String? message;
  String? email;
  String? sosNumber;
  String? sosMessage;
  List<Data>? data;

  ContactListModel(
      {this.status,
        this.message,
        this.email,
        this.sosNumber,
        this.sosMessage,
        this.data});

  ContactListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    email = json['email'];
    sosNumber = json['sos_number'];
    sosMessage = json['sos_message'];
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
    data['email'] = email;
    data['sos_number'] = sosNumber;
    data['sos_message'] = sosMessage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  dynamic id;
  dynamic name;
  dynamic icon;
  dynamic phone;

  Data({this.id, this.name, this.icon, this.phone});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['icon'] = icon;
    data['phone'] = phone;
    return data;
  }
}
