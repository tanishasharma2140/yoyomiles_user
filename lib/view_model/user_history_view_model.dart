import 'package:flutter/foundation.dart';
import 'package:port_karo/model/user_history_model.dart';
import 'package:port_karo/repo/user_history_repo.dart';
import 'package:port_karo/view_model/user_view_model.dart';
class UserHistoryViewModel with ChangeNotifier {
  final _userHistoryRepo = UserHistoryRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  UserHistoryModel? _userHistoryModel;
  UserHistoryModel? get userHistoryModel => _userHistoryModel;

  setModelData(UserHistoryModel value) {
    _userHistoryModel = value;
    notifyListeners();
  }
  Future<void> userHistoryApi() async {
    setLoading(true);
    UserViewModel userViewModel = UserViewModel();
    String? userId = await userViewModel.getUser();
    _userHistoryRepo.userHistoryApi(userId).then((value){
      print('value:$value');
      if (value.success == true) {
        setModelData(value);
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }
}

