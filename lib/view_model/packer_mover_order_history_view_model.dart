import 'package:flutter/foundation.dart';
import 'package:yoyomiles/model/packer_mover_order_history_model.dart';
import 'package:yoyomiles/repo/packer_mover_order_history_repo.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view_model/user_view_model.dart';

class PackerMoverOrderHistoryViewModel with ChangeNotifier {
  final _packerMoverOrderHistoryRepo = PackerMoverOrderHistoryRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  PackerMoverOrderHistoryModel? _packerMoverOrderHistoryModel;
  PackerMoverOrderHistoryModel? get packerMoverOrderHistoryModel =>
      _packerMoverOrderHistoryModel;

  setPackerMoverOrderHistoryData(PackerMoverOrderHistoryModel value) {
    _packerMoverOrderHistoryModel = value;
    notifyListeners();
  }

  Future<void> packerMoverOrderHistoryApi(context) async {
    setLoading(true);
    UserViewModel userViewModel = UserViewModel();
    String? userId = await userViewModel.getUser();

    _packerMoverOrderHistoryRepo
        .packerMoverOrderHistoryApi(userId)
        .then((value) {

      setLoading(false);   // ✅ FIX HERE

      print('value:$value');

      if (value.status == 200) {
        setPackerMoverOrderHistoryData(value);
        Utils.showSuccessMessage(context, value.message.toString());
      } else {
        Utils.showErrorMessage(context, value.message.toString());
      }
    })
        .onError((error, stackTrace) {
      setLoading(false);   // already correct ✅
      if (kDebugMode) {
        print('error: $error');
        Utils.showErrorMessage(context, 'error: $error');
      }
    });
  }

}
