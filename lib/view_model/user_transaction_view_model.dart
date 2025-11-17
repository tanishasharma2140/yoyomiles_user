import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:port_karo/model/user_transaction_model.dart';
import 'package:port_karo/repo/user_transaction_repo.dart';
import 'package:port_karo/view_model/user_view_model.dart';

class UserTransactionViewModel with ChangeNotifier {
  final _userTransactionRepo = UserTransactionRepo();

  UserTransactionModel? _userTransactionModel;
  UserTransactionModel? get userTransactionModel => _userTransactionModel;

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setTransactionData(UserTransactionModel value) {
    _userTransactionModel = value;
    notifyListeners();
  }

  Future<void> userTransactionApi(BuildContext context) async {
    try {
      setLoading(true);

      UserViewModel userViewModel = UserViewModel();
      String? userId = await userViewModel.getUser();

      Map data = {"type": "5", "user_id": userId};

      final value = await _userTransactionRepo.userTransactionApi(data);

      if (value.status == true) {
        setTransactionData(value);
      } else {
        if (kDebugMode) {
          print('API returned false: ${value.message}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in transactionApi: $error');
      }
    } finally {
      setLoading(false);
    }
  }
}
