import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles/repo/add_wallet_repo.dart';
import 'package:yoyomiles/view/payment/widgets/payment_porter_credit.dart';
import 'package:yoyomiles/view_model/user_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AddWalletViewModel with ChangeNotifier {
  final _addWalletRepo = AddWalletRepository();
  bool _loading = false;
  bool get loading => _loading;
  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> addWalletApi(context, dynamic amount) async {
    setLoading(true);
    UserViewModel userViewModel = UserViewModel();
    String? userId = await userViewModel.getUser();
    Map data = {"userid": userId, "amount": amount};

    try {
      final response = await _addWalletRepo.addWalletApi(data);
      setLoading(false);
      if (response['success'] == true) {
        // print("tanuu");
        // print(jsonEncode(data));
        await launchURL(response["payment_link"]).then((_) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PaymentPorterCredit()));
        });
      } else {
        print("wrong");
      }
    } catch (error) {
      setLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
      if (kDebugMode) {
        print('Error: $error');      }
    }
  }
  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
