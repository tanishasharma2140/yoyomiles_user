import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:port_karo/repo/driver_rating_repo.dart';
import 'package:port_karo/utils/utils.dart';
import 'package:port_karo/view_model/user_history_view_model.dart';
import 'package:port_karo/view_model/user_view_model.dart';
import 'package:provider/provider.dart';


class DriverRatingViewModel with ChangeNotifier {
  final _driverRatingRepo = DriverRatingRepo();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> driverRatingApi (context,String orderId, String driverId, String rating) async {
    setLoading(true);

    UserViewModel userViewModel = UserViewModel();
    String? userId = await userViewModel.getUser();

    Map data = {
      "user_id": userId,
      "order_id": orderId,
      "driver_id": driverId,
      "rating": rating
    };
    print("driverRating: ${data}");

    _driverRatingRepo.driverRatingApi(data).then((value) async {
      setLoading(false);
      if (value['status'] == 200) {
        Navigator.pop(context);
        Utils.showSuccessMessage(context, value['message']);
        final userHistoryViewModel =
        Provider.of<UserHistoryViewModel>(context, listen: false);
        userHistoryViewModel.userHistoryApi();
      } else {
        Utils.showErrorMessage(context, value["message"]);
        Navigator.pop(context);
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }
}
