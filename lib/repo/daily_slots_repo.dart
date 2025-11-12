import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/base_api_services.dart';
import 'package:port_karo/model/daily_slot_model.dart';
import 'package:port_karo/res/api_url.dart';
import '../helper/helper/network/network_api_services.dart';

class DailySlotsRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<DailySlotModel> dailySlotApi(String date) async {
    String? url = "${ApiUrl.getDailySlotUrl}date=$date";
    try {
      dynamic response = await _apiServices.getGetApiResponse(url);
      return DailySlotModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during dailySlotApi: $e');
      }
      rethrow;
    }
  }
}
