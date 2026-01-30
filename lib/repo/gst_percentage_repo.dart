import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles/model/gst_percentage_model.dart';
import 'package:yoyomiles/res/api_url.dart';

class GstPercentageRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<GstPercentageModel> gstPercentageApi() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        ApiUrl.gstPercentageUrl,
      );
      return GstPercentageModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during gstPercentageApi: $e');
      }
      rethrow;
    }
  }
}
