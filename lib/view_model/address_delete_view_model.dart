import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles/repo/address_delete_repo.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view_model/address_show_view_model.dart';
import 'package:yoyomiles/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class AddressDeleteViewModel with ChangeNotifier {
  final AddressDeleteRepo _addressDeleteRepo = AddressDeleteRepo();
  bool _loading = false;

  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> deleteAddressApi({
    dynamic  userid,
    required  addressId,
    required BuildContext context,
  }) async {
    setLoading(true);

    UserViewModel userViewModel = UserViewModel();
    String? userId = await userViewModel.getUser();

    Map  data = {
      "userid": userId,
      "address_id": addressId,
    };

    if (kDebugMode) {
      print("Request Data: $data");
    }

    try {
      final response = await _addressDeleteRepo.addressDeleteApi(data);


      if (response["status"] == true) {

        Provider.of<AddressShowViewModel>(context, listen: false).addressShowApi();
        Utils.showSuccessMessage(context, "Address deleted successfully");

        if (kDebugMode) {
          print("Address deleted successfully: ${response.message}");
        }
        Utils.showSuccessMessage(context, "Address deleted successfully!");
      } else {
        if (kDebugMode) {
          print("Failed to delete address: ${response.message}");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete address: ${response.message}')),
        );
      }
    } catch (e) {
      setLoading(false);
      if (kDebugMode) {
        print('Error occurred during address deletion: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}
