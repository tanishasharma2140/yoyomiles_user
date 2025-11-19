import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yoyomiles/model/final_summary_model.dart';
import 'package:yoyomiles/repo/final_summary_repo.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view_model/user_view_model.dart';

class FinalSummaryViewModel with ChangeNotifier {
  final _finalSummaryRepo = FinalSummaryRepo();

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  FinalSummaryModel? _finalSummaryModel;
  FinalSummaryModel? get finalSummaryModel => _finalSummaryModel;

  void setFinalSummaryData(FinalSummaryModel value) {
    _finalSummaryModel = value;
    notifyListeners();
  }

  Future<void> finalSummaryApi(
      String? date,
      dynamic distance,
      dynamic pickupPoint,
      dynamic dropPoint,
      dynamic singleLayerCharges,
      dynamic multiLayerCharges,
      dynamic unpackingCharges,
      dynamic dismantleReassemblyCharges,
      BuildContext context,
      ) async {
    try {
      setLoading(true);

      UserViewModel userViewModel = UserViewModel();
      String? userId = await userViewModel.getUser();

      /// ✅ If date null → set current date
      String cleanDate = date?.toString().split('T').first ?? "";

      String finalDate = cleanDate.isEmpty
          ? DateFormat('yyyy-MM-dd').format(DateTime.now())
          : cleanDate;

      Map data = {
        "user_id": userId,
        "date": finalDate,
        "city_type": 1,
        "distance": distance,
        "pickup_point": pickupPoint,
        "drop_point": dropPoint,
        "single_layer_charges": singleLayerCharges,
        "multi_layer_charges": multiLayerCharges,
        "unpacking_charges": unpackingCharges,
        "dismantle_reassembly_charges": dismantleReassemblyCharges,
      };

      print("Final Summary API Body: $data");

      final response = await _finalSummaryRepo.finalSummaryApi(data);

      setLoading(false);

      if (response.success == true) {
        setFinalSummaryData(response);
      } else {
        Utils.showErrorMessage(context, response.message.toString());
      }
    } catch (e) {
      setLoading(false);
      Utils.showErrorMessage(context, "Error: $e");
      if (kDebugMode) print("Error FinalSummaryApi: $e");
    }
  }
}
