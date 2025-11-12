import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/base_api_services.dart';
import 'package:port_karo/helper/helper/network/network_api_services.dart';
import 'package:port_karo/model/AddressShowModel.dart';
import 'package:port_karo/res/api_url.dart';
class AddressShowRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<AddressShowModel> addressShowApi(userid) async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.addressShowUrl+userid);
      return AddressShowModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during loginApi: $e');
      }
      rethrow;
    }
  }
}