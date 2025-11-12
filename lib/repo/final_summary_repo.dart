import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/network_api_services.dart';
import 'package:port_karo/model/final_summary_model.dart';
import 'package:port_karo/res/api_url.dart';

import '../helper/helper/network/base_api_services.dart';

class FinalSummaryRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<FinalSummaryModel> finalSummaryApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(
        ApiUrl.finalSummaryUrl,
        data,
      );
      return FinalSummaryModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during finalSummaryApi : $e');
      }
      rethrow;
    }
  }
}
