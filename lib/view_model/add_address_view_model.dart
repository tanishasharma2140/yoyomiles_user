import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:port_karo/repo/add_address_repo.dart';
import 'package:port_karo/utils/utils.dart';
import 'package:port_karo/view_model/address_show_view_model.dart';
import 'package:port_karo/view_model/user_view_model.dart';
import 'package:provider/provider.dart';


class AddAddressViewModel with ChangeNotifier {
  final _addAddressRepo = AddAddressRepo();
  bool _loading = false;

  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> addAddressApi({
    required dynamic name,
    required dynamic latitude,
    required dynamic longitude,
    required dynamic address,
    required dynamic addressType,
    required dynamic houseArea,
    required dynamic pinCode,
    required dynamic phone,
    required BuildContext context,
  }) async {
    setLoading(true);
    UserViewModel userViewModel = UserViewModel();
    String? userId = await userViewModel.getUser();
    Map<String, dynamic> data =
    {
      "userid": userId,
      "name": name,
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
      "address_type": addressType,
      "house_area": houseArea,
      "pincode": pinCode,
      "contact_no": phone
    }
    ;

    print("addedede${data}");

    try {

      print(userId);
      final response = await _addAddressRepo.addAddressApi(data);
      setLoading(false);

      if (response.status == 200) {
        print("Address added successfully: ${response.message}");
         Utils.showSuccessMessage(context, "Address added successfully!");
         Navigator.pop(context);
         Navigator.pop(context);
        final addressShowViewModel =
        Provider.of<AddressShowViewModel>(context, listen: false);
        addressShowViewModel.addressShowApi();

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add address: ${response.message}')),
        );
      }
    } catch (e) {
      setLoading(false);
      if (kDebugMode) {
        print('Error: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}
