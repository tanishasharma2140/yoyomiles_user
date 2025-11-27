// dart
// File: lib/view_model/select_vehicles_view_model.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles/model/select_vehicles_model.dart';
import 'package:yoyomiles/repo/select_vehicles_repo.dart';
import 'package:yoyomiles/res/app_btn.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view/bottom_nav_bar.dart';

class SelectVehiclesViewModel with ChangeNotifier {
  final _selectVehicleRepo = SelectVehiclesRepo();

  SelectVehicleModel? _selectVehicleModel;
  SelectVehicleModel? get selectVehicleModel => _selectVehicleModel;

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setVehicleData(SelectVehicleModel value) {
    _selectVehicleModel = value;
    notifyListeners();
  }

  Future<void> selectVehicleApi(
      dynamic vehicleId,
      dynamic range,
      dynamic type,
      dynamic pickupLatitude,
      dynamic pickupLongitude,
      dynamic dropLatitude,
      dynamic dropLongitude,
      BuildContext context,
      ) async {
    Map<String, dynamic> data = {
      "vehicle_id": vehicleId,
      "range": range,
      "type": type,
      "pickup_latitude": pickupLatitude,
      "pickup_longitude": pickupLongitude,
      "drop_latitude": dropLatitude,
      "drop_longitude": dropLongitude,
    };

    if (kDebugMode) {
      print("🚕 selectVehicleApi body: $data");
    }

    setLoading(true);

    _selectVehicleRepo.selectVehicleApi(data).then((value) {
      setLoading(false);

      if (kDebugMode) {
        print("✅ API status: ${value.status}, message: ${value.message}, sub_message: ${value.subMessage}");
      }

      if (value.status == 200) {
        // ✅ Success case
        setVehicleData(value);
      } else {
        // ❌ Non-200 but success callback (agar repo aise return kare)
        final String title = value.message?.toString() ?? "";
        final String subMessage = value.subMessage?.toString() ?? "";

        _showNotServiceableBottomSheet(
          context,
          title: title,
          message: subMessage,
        );
      }
    }).onError((error, stackTrace) {
      setLoading(false);

      // 👇 YAHAN tumhare log me aa raha hai:
      // Error occurred during selectVehicleApi: Invalid Request{"status":400,"message":"Pickup location is not serviceable","sub_message":"Sorry, this pickup location is not serviceable currently","data":[]}
      if (kDebugMode) {
        print("❌ onError raw: $error");
      }

      String title = "";
      String subMessage = "";

      try {
        final raw = error.toString(); // ensure String

        // "{...}" ka part nikaal lo
        final startIndex = raw.indexOf('{');
        if (startIndex != -1) {
          final jsonStr = raw.substring(startIndex); // {"status":400,...}
          final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

          title = decoded['message']?.toString() ?? "";
          subMessage = decoded['sub_message']?.toString() ?? "";

          if (kDebugMode) {
            print("📩 Parsed from error → title: $title");
            print("📩 Parsed from error → sub_message: $subMessage");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("JSON parse error in selectVehicleApi: $e");
        }
      }

      // Agar still kuch na mila, toast dikha ke return
      if (title.isEmpty && subMessage.isEmpty) {
        Utils.showErrorMessage(
          context,
          "Something went wrong. Please try again.",
        );
        return;
      }

      _showNotServiceableBottomSheet(
        context,
        title: title,        // "Pickup location is not serviceable"
        message: subMessage, // "Sorry, this pickup location is not serviceable currently"
      );
    });
  }

  // ----------------- UI Bottom Sheet -----------------

  void _showNotServiceableBottomSheet(
      BuildContext context, {
        required String title,
        required String message,
      }) {
    if (kDebugMode) {
      print("📢 Showing bottom sheet → $title | $message");
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final mq = MediaQuery.of(sheetContext);

        return Padding(
          padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 140,
                      width: 140,
                      child: Image.asset(
                        "assets/location_not_available.gif",
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title → API ka "message"
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Sub message → API ka "sub_message"
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    AppBtn(
                      title: "Change Address",
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const BottomNavigationPage(),
                          ),
                              (route) => false,
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
