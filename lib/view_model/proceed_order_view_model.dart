import 'package:flutter/material.dart';
import 'package:yoyomiles/repo/proceed_order_repo.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view_model/packer_mover_payment_view_model.dart';
import 'package:yoyomiles/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class ProceedOrderViewModel with ChangeNotifier {
  final _proceedOrderRepo = ProceedOrderRepo();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> proceedOrderApi({
    required dynamic date,
    required dynamic cityType,
    required dynamic distance,
    required dynamic singleLayerCharges,
    required dynamic multiLayerCharges,
    required dynamic unpackingCharges,
    required dynamic dismantleReassemblyCharges,
    required dynamic pickupAddress,
    required dynamic pickupLatitude,
    required dynamic pickupLongitude,
    required dynamic dropAddress,
    required  dynamic dropLatitude,
    required dynamic dropLongitude,
    required dynamic senderName,
    required dynamic shiftingDate,
    required dynamic dailySlotId,
    required dynamic slotId,
    required dynamic paymentStatus,
    required dynamic pickupPointLiftInfo,
    required dynamic dropPointLiftInfo,
    required dynamic totalCharges,
      context,

  }) async {
    setLoading(true);
    UserViewModel userViewModel = UserViewModel();
    String? userId = await userViewModel.getUser();
    Map data =
    {
      "user_id": userId,
      "date": date,
      "city_type": cityType,
      "distance": distance,
      "single_layer_charges": singleLayerCharges,
      "multi_layer_charges": multiLayerCharges,
      "unpacking_charges": unpackingCharges,
      "dismantle_reassembly_charges": dismantleReassemblyCharges,
      "pickup_address": pickupAddress,
      "pickup_latitude": pickupLatitude,
      "pickup_longitude": pickupLongitude,
      "drop_address": dropAddress,
      "drop_latitude": dropLatitude,
      "drop_longitude": dropLongitude,
      "sender_name": senderName,
      "shifting_date": shiftingDate,
      "daily_slot_id": dailySlotId,
      "slot_id":slotId,
      "payment_status": paymentStatus,
      "pickup_point_lift_info": pickupPointLiftInfo,
      "drop_point_lift_info": dropPointLiftInfo,
      "total_charges": totalCharges,
    };

    print("proceedOrder🎉🥱🎁${data}");

    try {
      print(userId);
      final response = await _proceedOrderRepo.proceedOrderApi(data);
      setLoading(false);

      print("response 200: $response");

      if (response["status"] == 200) {
        print("Order success: ${response["message"]}");
        Utils.showSuccessMessage(context, response["message"]);
        // final packerPaymentVm = Provider.of<PackerMoverPaymentViewModel>(context,listen: false);
        // await packerPaymentVm.paymentApi(context, totalCharges, "");
      } else {
        Utils.showErrorMessage(context,  response["message"]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response["message"]}')),
        );
      }

    } catch (e) {
      setLoading(false);
      print('Error: $e');
      Utils.showErrorMessage(context, 'An error occurred: $e');
    }

  }
}
