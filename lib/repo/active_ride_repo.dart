import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/base_api_services.dart';
import 'package:port_karo/model/active_ride_model.dart';
import 'package:port_karo/res/api_url.dart';

import '../helper/helper/network/network_api_services.dart';

class ActiveRideRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<ActiveRideModel> activeRideApi(String userId) async {
    String? url = "${ApiUrl.activeRideUrl}user_id=$userId";
    try {
      dynamic response = await _apiServices.getGetApiResponse(url);
      return ActiveRideModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during ActiveBodyTypeUrl: $e');
      }
      rethrow;
    }
  }
}
