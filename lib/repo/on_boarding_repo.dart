import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles/model/on_boarding_model.dart';
import 'package:yoyomiles/res/api_url.dart';

class OnBoardingRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<OnBoardingModel> onBoardingApi() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        ApiUrl.onBoardingUrl,
      );
      return OnBoardingModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during onBoardingApi: $e');
      }
      rethrow;
    }
  }
}
