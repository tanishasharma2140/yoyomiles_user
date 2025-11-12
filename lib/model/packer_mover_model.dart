class PackerMoversModel {
  int? status;
  String? message;
  List<Data>? data;

  PackerMoversModel({this.status, this.message, this.data});

  PackerMoversModel.fromJson(Map<String, dynamic> json) {
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
  int? packerType;
  List<Packers>? packers;

  Data({this.packerType, this.packers});

  Data.fromJson(Map<String, dynamic> json) {
    packerType = json['packer_type'];
    if (json['packers'] != null) {
      packers = <Packers>[];
      json['packers'].forEach((v) {
        packers!.add(Packers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['packer_type'] = packerType;
    if (packers != null) {
      data['packers'] = packers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Packers {
  int? packerMoverId;
  String? packerName;
  String? comment;
  String? imageIcon;
  List<SubItems>? subItems;

  Packers(
      {this.packerMoverId,
        this.packerName,
        this.comment,
        this.imageIcon,
        this.subItems});

  Packers.fromJson(Map<String, dynamic> json) {
    packerMoverId = json['packer_and_mover_id'];
    packerName = json['packer_name'];
    comment = json['comment'];
    imageIcon = json['image_icon'];
    if (json['sub_items'] != null) {
      subItems = <SubItems>[];
      json['sub_items'].forEach((v) {
        subItems!.add(SubItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['packer_and_mover_id'] = packerMoverId;
    data['packer_name'] = packerName;
    data['comment'] = comment;
    data['image_icon'] = imageIcon;
    if (subItems != null) {
      data['sub_items'] = subItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubItems {
  int? itemId;
  String? itemName;
  String? amount;
  String? comment;

  SubItems({this.itemId, this.itemName, this.amount, this.comment});

  SubItems.fromJson(Map<String, dynamic> json) {
    itemId = json['item_id'];
    itemName = json['item_name'];
    amount = json['amount'];
    comment = json['comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['item_id'] = itemId;
    data['item_name'] = itemName;
    data['amount'] = amount;
    data['comment'] = comment;
    return data;
  }
}
