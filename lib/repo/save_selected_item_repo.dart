import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/network_api_services.dart';
import 'package:port_karo/model/save_selected_item_model.dart';
import 'package:port_karo/res/api_url.dart';

import '../helper/helper/network/base_api_services.dart';

class SaveSelectedItemRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<SaveSelectedItemModel> saveSelectedItemsApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(
        ApiUrl.saveSelectedItemsUrl,
        data,
      );
      return SaveSelectedItemModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during saveSelectedApi : $e');
      }
      rethrow;
    }
  }
}
