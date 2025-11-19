import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles/model/goods_type_model.dart';
import 'package:yoyomiles/res/api_url.dart';

class GoodsTypeRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<GoodsTypeModel> goodsTypeApi() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        ApiUrl.goodsTypeUrl,
      );
      return GoodsTypeModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during goodsTypeApi: $e');
      }
      rethrow;
    }
  }
}
