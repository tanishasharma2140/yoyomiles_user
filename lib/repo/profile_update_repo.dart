import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/base_api_services.dart';
import 'package:port_karo/helper/helper/network/network_api_services.dart';
import 'package:port_karo/model/profile_model.dart';
import 'package:port_karo/res/api_url.dart';
class ProfileUpdateRepository {
  final BaseApiServices _apiServices = NetworkApiServices();
  Future<ProfileModel> profileUpdateApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getPostApiResponse(ApiUrl.profileUpdateUrl, data);
      return ProfileModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during loginApi: $e');
      }
      rethrow;
    }
  }
}
