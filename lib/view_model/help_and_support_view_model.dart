import 'package:flutter/foundation.dart';
import 'package:yoyomiles/model/help_and_support_model.dart';
import 'package:yoyomiles/repo/help_support_repo.dart';

class HelpAndSupportViewModel with ChangeNotifier {
  final _helpSupportRepo = HelpSupportRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  HelpAndSupportModel? _helpAndSupportModel;
  HelpAndSupportModel? get helpAndSupportModel => _helpAndSupportModel;

  setModelData(HelpAndSupportModel value) {
    _helpAndSupportModel = value;
    notifyListeners();
  }
  Future<void> helpSupportApi() async {
    setLoading(true);
    try {
      final response = await _helpSupportRepo.helpSupportApi();
      if (response.status == 200) {
        setModelData(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in profileApi: $e');
      }
    } finally {
      setLoading(false);
    }
  }
}

