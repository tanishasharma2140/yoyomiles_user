import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/base_api_services.dart';
import 'package:port_karo/helper/helper/network/network_api_services.dart';
import 'package:port_karo/model/requirement_model.dart';
import 'package:port_karo/res/api_url.dart';

class RequirementRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<RequirementModel> requirementApi() async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.requirementUrl);
      return RequirementModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during requirementApi: $e');
      }
      rethrow;
    }
  }
}