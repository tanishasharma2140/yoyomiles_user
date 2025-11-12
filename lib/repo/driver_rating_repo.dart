import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/base_api_services.dart';
import 'package:port_karo/helper/helper/network/network_api_services.dart';
import 'package:port_karo/res/api_url.dart';

class DriverRatingRepo {
  final BaseApiServices _apiServices = NetworkApiServices();
  Future<dynamic> driverRatingApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(
        ApiUrl.driverRatingUrl,
        data,
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during driverRatingApi: $e');
      }
      rethrow;
    }
  }
}
