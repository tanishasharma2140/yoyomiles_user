import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/network_api_services.dart';
import 'package:port_karo/model/coupon_list_model.dart';
import 'package:port_karo/res/api_url.dart';
import '../helper/helper/network/base_api_services.dart';

class CouponListRepo{
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<CouponListModel> couponListApi(String userId,String vehicleType) async {
    String? url ="${ApiUrl.couponListUrl}userid=$userId&vehicle_type=$vehicleType";
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(url);
      return CouponListModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during couponListApi: $e');
      }
      rethrow;
    }
  }
}