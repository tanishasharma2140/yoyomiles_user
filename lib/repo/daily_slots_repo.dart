import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles/model/daily_slot_model.dart';
import 'package:yoyomiles/res/api_url.dart';
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
