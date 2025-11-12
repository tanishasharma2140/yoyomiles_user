import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/base_api_services.dart';
import 'package:port_karo/helper/helper/network/network_api_services.dart';
import 'package:port_karo/model/goods_type_model.dart';
import 'package:port_karo/res/api_url.dart';

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
