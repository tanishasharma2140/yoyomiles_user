import 'package:flutter/foundation.dart';
import 'package:port_karo/model/AddressShowModel.dart';
import 'package:port_karo/repo/address_show_repo.dart';
import 'package:port_karo/view_model/user_view_model.dart';

class AddressShowViewModel with ChangeNotifier {
  final _addressShowRepo = AddressShowRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  AddressShowModel? _addressShowModel;
  AddressShowModel? get addressShowModel => _addressShowModel;

  setModelData(AddressShowModel value) {
    _addressShowModel = value;
    notifyListeners();
  }
  Future<void> addressShowApi() async {
    setLoading(true);
    try {
      UserViewModel userViewModel = UserViewModel();
      String? userId = await userViewModel.getUser();
      print(userId);
      print("object");
      final response = await _addressShowRepo.addressShowApi(userId);
      if (response.status == 200) {
        setModelData(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in addressApi: $e');
      }
    } finally {
      setLoading(false);
    }
  }
}

