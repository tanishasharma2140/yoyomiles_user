// import 'package:flutter/foundation.dart';
// import 'package:yoyomiles/helper/helper/network/base_api_services.dart';
// import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
// import 'package:yoyomiles/res/api_url.dart';
// class ChangePayModeRepo{
//   final BaseApiServices _apiServices = NetworkApiServices();
//   Future<dynamic> changePayModeApi(dynamic data) async {
//     try {
//       dynamic response =
//       await _apiServices.getPostApiResponse(ApiUrl.changePaymentModeUrl, data);
//       return response;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error occurred during changePayModeApi: $e');
//       }
//       rethrow;
//     }
//   }
// }