class OtpCountModel {
  bool? success;
  String? message;
  int? remainingOtp;
  int? totalOtp;

  OtpCountModel({this.success, this.message, this.remainingOtp, this.totalOtp});

  OtpCountModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    remainingOtp = json['remaining_otp'];
    totalOtp = json['total_otp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['remaining_otp'] = remainingOtp;
    data['total_otp'] = totalOtp;
    return data;
  }
}
