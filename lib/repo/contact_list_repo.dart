import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles/model/contact_list_model.dart';
import 'package:yoyomiles/res/api_url.dart';

class ContactListRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<ContactListModel> contactListApi() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        ApiUrl.contactListUrl,
      );
      return ContactListModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during contactListApi: $e');
      }
      rethrow;
    }
  }
}
