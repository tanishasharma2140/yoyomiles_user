// packer_mover_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:port_karo/model/packer_mover_model.dart';
import 'package:port_karo/repo/packer_mover_repo.dart';

class PackerMoverViewModel extends ChangeNotifier {
  PackerMoversModel? _packerMoversData;
  bool _loading = false;
  String? _error;

  PackerMoversModel? get packerMoversData => _packerMoversData;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> packerMoverApi() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService().getPackerMoverItems();

      if (response.status == 200) {
        _packerMoversData = response;
      } else {
        _error = response.message ?? 'Failed to load data';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}