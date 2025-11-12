import 'package:flutter/material.dart';

class MovingDetailsViewModel with ChangeNotifier {
  Map<String, dynamic>? _movingDetails;
  Map<String, dynamic>? get movingDetails => _movingDetails;

  void setMovingDetails(Map<String, dynamic> details) {
    _movingDetails = details;
    notifyListeners();
  }

  void clear() {
    _movingDetails = null;
    notifyListeners();
  }
}
