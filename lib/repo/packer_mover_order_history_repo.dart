import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/base_api_services.dart';
import 'package:port_karo/helper/helper/network/network_api_services.dart';
import 'package:port_karo/model/packer_mover_order_history_model.dart';
import 'package:port_karo/res/api_url.dart';

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