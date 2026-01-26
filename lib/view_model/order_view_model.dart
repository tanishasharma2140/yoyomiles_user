import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles/repo/order_repo.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view/driver_searching/driver_searching_screen.dart';
import 'package:yoyomiles/view_model/user_view_model.dart';

class OrderViewModel with ChangeNotifier {
  final _orderRepo = OrderRepository();
  bool _loading = false;
  bool get loading => _loading;

  int? _locationType;
  int? get locationType => _locationType;

  dynamic _pickupData;
  dynamic _dropData;
  dynamic get pickupData => _pickupData;
  dynamic get dropData => _dropData;

  List<Map<String, dynamic>>? selectedGoodsType;

  Map<String, dynamic>? _currentOrderData;
  Map<String, dynamic>? get currentOrderData => _currentOrderData;

  void clearPickup() {
    _pickupData = null;
    notifyListeners();
  }

  void clearDrop() {
    _dropData = null;
    notifyListeners();
  }


  setLocationType(int value) {
    _locationType = value;
    notifyListeners();
  }

  setLocationData(dynamic data) {
    if (_locationType == 0) {
      _pickupData = data;
    } else {
      _dropData = data;
    }
    notifyListeners();
  }

  void setCurrentOrderData(Map<String, dynamic> data) {
    _currentOrderData = data;
    notifyListeners();
  }

  Future<void> orderApi(
      dynamic vehicle,
      dynamic pickupAddress,
      dynamic dropAddress,
      dynamic dropLatitude,
      dynamic dropLongitude,
      dynamic pickupLatitude,
      dynamic pickupLongitude,
      dynamic senderName,
      dynamic senderPhone,
      dynamic receiverName,
      dynamic receiverPhone,
      dynamic amount,
      dynamic distance,
      dynamic payMode,
      List<Map<String, dynamic>>? goodType,
      dynamic orderType,
      dynamic orderTime,
      dynamic pickUpSaveAs,
      dynamic dropSaveAs,
      dynamic vehicleBodyDetailType,
      dynamic vehicleBodyType,
      BuildContext context,
      ) async {
    print("🚀 [OrderViewModel] orderApi() called");

    UserViewModel userViewModel = UserViewModel();
    String? userId = await userViewModel.getUser();
    setLoading(true);

    Map<String, dynamic> data = {
      "userid": userId,
      "vehicle_type": vehicle,
      "pickup_address": pickupAddress.toString(),
      "drop_address": dropAddress.toString(),
      "drop_latitute": dropLatitude.toString(),
      "drop_logitute": dropLongitude.toString(),
      "pickup_latitute": pickupLatitude.toString(),
      "pickup_logitute": pickupLongitude.toString(),
      "sender_name": senderName,
      "sender_phone": senderPhone,
      "reciver_name": receiverName,
      "reciver_phone": receiverPhone,
      "amount": amount,
      "distance": distance,
      "paymode": payMode,
      "goods_type": goodType ?? [],
      "order_type": orderType,
      "order_time": orderTime,
      "pickup_save_as": pickUpSaveAs,
      "drop_save_as": dropSaveAs,
      "vehicle_body_details_type": vehicleBodyDetailType,
      "vehicle_body_type": vehicleBodyType
    };

    setCurrentOrderData(data);
    print("📦 ---------------- ORDER DATA START ----------------");
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    print(encoder.convert(data));
    print("📦 ---------------- ORDER DATA END ----------------");
    try {
      final response = await _orderRepo.orderApi(data);
      setLoading(false);

      if (response["status"] == 200) {


        final documentId = response["documentId"] ?? response["id"] ?? "";
        final orderTypeFromApi = response["order_type"] ?? "";

        print("📄 Order Document ID: $documentId");
        print("🟡 Order Type from API: $orderTypeFromApi");

        final updatedOrderData = {
          ...?_currentOrderData,
          "document_id": documentId,
          "order_type": orderTypeFromApi,
        };

        await FirebaseFirestore.instance
            .collection('order')
            .doc(documentId.toString())
            .update({
          'accepted_driver_id': null,
          'ride_started': false,
        });

        Utils.showSuccessMessage(context, response['message']);
        print("oiuioiu{$response['message']}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverSearchingScreen(
              orderData: updatedOrderData,
            ),
          ),
        );
      } else {
        Utils.showErrorMessage(context, response["message"]);
      }
    } catch (error) {
      setLoading(false);
      Utils.showErrorMessage(context, 'An error occurred: $error');
      if (kDebugMode) {
        Utils.showErrorMessage(context, 'An error occurred: $error');
        print('Error: $error');
      }
    }
  }

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // Future<void> launchURL(String url) async {
  //   final Uri uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }
}
