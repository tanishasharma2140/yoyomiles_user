class RewardModel {
  int? status;
  int? totalReward;
  String? message;
  List<Data>? data;

  RewardModel({this.status, this.totalReward, this.message, this.data});

  RewardModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    totalReward = json['Total_Reward'];
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
    data['Total_Reward'] = totalReward;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  dynamic id;
  dynamic rewardAmount;
  dynamic status;
  dynamic rewardType;
  dynamic comment;
  dynamic updatedAt;

  Data(
      {this.id,
        this.rewardAmount,
        this.status,
        this.rewardType,
        this.comment,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    rewardAmount = json['reward_amount'];
    status = json['status'];
    rewardType = json['reward_type'];
    comment = json['comment'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['reward_amount'] = rewardAmount;
    data['status'] = status;
    data['reward_type'] = rewardType;
    data['comment'] = comment;
    data['updated_at'] = updatedAt;
    return data;
  }
}
