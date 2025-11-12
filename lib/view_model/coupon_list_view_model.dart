import 'package:flutter/foundation.dart';
import 'package:port_karo/model/coupon_list_model.dart';
import 'package:port_karo/repo/coupon_list_repo.dart';

class CouponListViewModel with ChangeNotifier {
  final _couponListRepo = CouponListRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  CouponListModel? _couponListModel;
  CouponListModel? get couponListModel => _couponListModel;

  setModelData(CouponListModel value) {
    _couponListModel = value;
    notifyListeners();
  }

  Future<void> couponListApi(String userId, String vehicleType) async {
    setLoading(true);
    try {
      final response = await _couponListRepo.couponListApi(userId, vehicleType);
      if (response.status == 200) {
        setModelData(response);
      } else {
        setModelData(response);
        debugPrint('Error: ${response.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in loanRequestApi: $e');
      }
    } finally {
      setLoading(false);
    }
  }
}
