import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles/model/service_type_model.dart';
import 'package:yoyomiles/res/api_url.dart';
class ServiceTypeRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<ServiceTypeModel> serviceTypeApi() async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.serviceTypeUrl);
      return ServiceTypeModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during loginApi: $e');
      }
      rethrow;
    }
  }
}