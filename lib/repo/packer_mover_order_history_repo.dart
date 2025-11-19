import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles/model/packer_mover_order_history_model.dart';
import 'package:yoyomiles/res/api_url.dart';

class PackerMoverOrderHistoryRepo {

  final BaseApiServices _apiServices = NetworkApiServices();
  Future<PackerMoverOrderHistoryModel> packerMoverOrderHistoryApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.moverHistoryUrl+ data);
      return PackerMoverOrderHistoryModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during packerMoverOrderHistoryApi: $e');
      }
      rethrow;
    }
  }
}