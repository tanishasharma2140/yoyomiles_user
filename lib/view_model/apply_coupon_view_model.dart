import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:port_karo/repo/apply_coupon_repo.dart';
import 'package:port_karo/res/coupon_sucess_popup.dart';
import 'package:port_karo/utils/utils.dart';
import 'package:port_karo/view_model/coupon_list_view_model.dart';
import 'package:port_karo/view_model/service_type_view_model.dart';
import 'package:port_karo/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class ApplyCouponViewModel with ChangeNotifier {
  final _applyCouponRepo = ApplyCouponRepo();

  bool _loading = false;
  bool get loading => _loading;

  double? _finalAmount;
  double? get finalAmount => _finalAmount;

  double? _discount;
  double? get discount => _discount;

  int? _applyStatus; // 🟢 New field
  int? get applyStatus => _applyStatus;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setFinalAmount(double value) {
    _finalAmount = value;
    notifyListeners();
  }

  void setDiscount(double value) {
    _discount = value;
    notifyListeners();
  }

  void setApplyStatus(int? status) {
    _applyStatus = status;
    notifyListeners();
  }

  Future<void> applyCouponApi(
      dynamic couponCode,
      dynamic amount,
      BuildContext context,
      ) async {
    UserViewModel userViewModel = UserViewModel();
    String? userId = await userViewModel.getUser();
    setLoading(true);

    Map data = {"user_id": userId, "coupon_code": couponCode, "amount": amount};
    debugPrint("Apply Coupon data: $data");

    _applyCouponRepo.applyCouponApi(data).then((value) async {
      setLoading(false);

      debugPrint("API Response: $value");

      if (value['status'] == 200) {
        debugPrint("Coupon Applied Successfully!!");

        // 🟢 Check and store apply_status
        if (value["data"] != null && value["data"]["apply_status"] != null) {
          setApplyStatus(int.tryParse(value["data"]["apply_status"].toString()));
          debugPrint("Apply Status: $_applyStatus");
        }

        // ✅ Set Final Amount
        if (value["data"] != null && value["data"]["final_amount"] != null) {
          setFinalAmount(double.tryParse(value["data"]["final_amount"].toString()) ?? 0.0);
          debugPrint("Final Amount Set: $_finalAmount");
        }

        // ✅ Set Discount
        if (value["data"] != null && value["data"]["discount"] != null) {
          setDiscount(double.tryParse(value["data"]["discount"].toString()) ?? 0.0);
          debugPrint("Discount Set: $_discount");
        }

        // Show success popup
        _showCouponSuccessPopup(context, value, couponCode, userId);
      } else {
        Utils.showErrorMessage(
          context,
          value["message"] ?? "Something went wrong",
        );
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('Error: $error');
      }
    });
  }

  void _showCouponSuccessPopup(
      BuildContext context,
      Map<String, dynamic> response,
      String couponCode,
      String? userId,
      ) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => CouponSuccessPopup(
        response: response,
        couponCode: couponCode,
        onContinue: () {
          final serviceTypeViewModel =
          Provider.of<ServiceTypeViewModel>(context, listen: false);
          final couponListVm =
          Provider.of<CouponListViewModel>(context, listen: false);
          couponListVm.couponListApi(
            userId.toString(),
            serviceTypeViewModel.selectedVehicleId!,
          );
        },
      ),
    );
  }
}
