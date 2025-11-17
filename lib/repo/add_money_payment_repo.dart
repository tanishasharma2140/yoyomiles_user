import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/base_api_services.dart';
import 'package:port_karo/model/cash_free_gateway_model.dart';
import 'package:port_karo/res/api_url.dart';
import '../helper/helper/network/network_api_services.dart' show NetworkApiServices;


class AddMoneyPaymentRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<CashFreeGatewayModel> paymentApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getPostApiResponse(ApiUrl.paymentUrl, data);
      return CashFreeGatewayModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during paymentApi: $e');
      }
      rethrow;
    }
  }
}