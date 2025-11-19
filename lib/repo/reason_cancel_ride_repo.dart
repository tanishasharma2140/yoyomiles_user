import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles/model/reason_cancel_ride_model.dart';
import 'package:yoyomiles/res/api_url.dart';
class ReasonCancelRideRepo {
  final BaseApiServices _apiServices = NetworkApiServices();
  Future<ReasonCancelRideModel> reasonCancelApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.walletHistoryUrl+ data);
      return ReasonCancelRideModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during reasonCancelRideApi: $e');
      }
      rethrow;
    }
  }
}