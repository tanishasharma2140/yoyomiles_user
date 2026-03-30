import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:yoyomiles/model/settings_model.dart';
import 'package:yoyomiles/repo/setting_repo.dart';
class SettingsViewModel with ChangeNotifier {
  final _settingRepo = SettingRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  SettingsModel? _settingsModel;
  SettingsModel? get settingsModel => _settingsModel;

  setSettingModelData(SettingsModel value) {
    _settingsModel = value;
    notifyListeners();
  }
  Future<void> settingApi(BuildContext context, String type) async {
    setLoading(true);

    _settingRepo.settingApi(type).then((value) {
      print('value:$value');

      if (value.success == true) {
        setSettingModelData(value);
      }

      setLoading(false); // 👈 ye missing tha (important)
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }
}

