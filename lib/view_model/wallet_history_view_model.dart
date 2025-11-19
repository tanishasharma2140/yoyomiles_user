import 'package:flutter/foundation.dart';
import 'package:yoyomiles/model/wallet_history_model.dart';
import 'package:yoyomiles/repo/wallet_history_repo.dart';
import 'package:yoyomiles/view_model/user_view_model.dart';
class WalletHistoryViewModel with ChangeNotifier {
  final _walletHistoryRepo = WalletHistoryRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  WalletHistoryModel? _walletHistoryModel;
  WalletHistoryModel? get walletHistoryModel => _walletHistoryModel;

  setModelData(WalletHistoryModel value) {
    _walletHistoryModel = value;
    notifyListeners();
  }
  Future<void> walletHistoryApi() async {
    setLoading(true);
    try {
      UserViewModel userViewModel = UserViewModel();
      String? userId = await userViewModel.getUser();

      final value = await _walletHistoryRepo.walletHistoryApi(userId);

      if (value.success == true) {
        setModelData(value);
      }
    } catch (e) {
      if (kDebugMode) {
        print('error: $e');
      }
    } finally {
      setLoading(false); // 👈 hamesha chalega (success or error)
    }
  }

}

