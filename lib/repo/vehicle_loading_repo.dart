import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles/model/vehicle_loading_model.dart';
import 'package:yoyomiles/res/api_url.dart';
import '../helper/helper/network/base_api_services.dart';

class VehicleLoadingRepo{
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<VehicleLoadingModel> vehicleLoadingApi(String vehicleType) async {
    String? url ="${ApiUrl.vehicleLoadingUrl}vehicle_type=$vehicleType";
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(url);
      return VehicleLoadingModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during vehicleLoadingApi: $e');
      }
      rethrow;
    }
  }
}