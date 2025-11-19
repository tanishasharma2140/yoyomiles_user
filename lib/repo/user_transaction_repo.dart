import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles/model/user_transaction_model.dart';
import 'package:yoyomiles/res/api_url.dart';
import '../helper/helper/network/base_api_services.dart';

class UserTransactionRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<UserTransactionModel> userTransactionApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getPostApiResponse(ApiUrl.userTransactionUrl , data);
      return UserTransactionModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during profileApi: $e');
      }
      rethrow;
    }
  }
}
