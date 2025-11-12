import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/base_api_services.dart';
import 'package:port_karo/helper/helper/network/network_api_services.dart';
import 'package:port_karo/model/packer_mover_terms_model.dart';
import 'package:port_karo/res/api_url.dart';
class PackerMoverTermsConditionRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<PackerMoverTermsModel> packerTermsConditionApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.packerMoversTermsUrl+ data);
      return PackerMoverTermsModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during packerMoverTermsApi: $e');
      }
      rethrow;
    }
  }
}