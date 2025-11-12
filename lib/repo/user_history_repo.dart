import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/base_api_services.dart';
import 'package:port_karo/helper/helper/network/network_api_services.dart';
import 'package:port_karo/model/user_history_model.dart';
import 'package:port_karo/res/api_url.dart';
class UserHistoryRepo {
  final BaseApiServices _apiServices = NetworkApiServices();
  Future<UserHistoryModel> userHistoryApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.userHistoryUrl+ data);
      return UserHistoryModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during userHistoryApi: $e');
      }
      rethrow;
    }
  }
}