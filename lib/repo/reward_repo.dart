import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles/model/reward_model.dart';
import 'package:yoyomiles/res/api_url.dart';
import '../helper/helper/network/base_api_services.dart';

class RewardRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<RewardModel> rewardApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getPostApiResponse(ApiUrl.referralRewardHistoryUrl , data);
      return RewardModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during rewardApi: $e');
      }
      rethrow;
    }
  }
}
