import 'package:flutter/foundation.dart';
import 'package:port_karo/model/port_banner_model.dart';
import 'package:port_karo/repo/port_banner_repo.dart';

class PortBannerViewModel with ChangeNotifier {
  final _portBannerRepo = PortBannerRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  PortBannerModel? _portBannerModel;
  PortBannerModel? get portBannerModel => _portBannerModel;

  setModelData(PortBannerModel value) {
    _portBannerModel = value;
    notifyListeners();
  }

  Future<void> portBannerApi() async {
    setLoading(true);

    _portBannerRepo
        .portBannerApi()
        .then((value) {
          debugPrint('value:$value');
          if (value.status == 200) {
            setModelData(value);
          }
        })
        .onError((error, stackTrace) {
          setLoading(false);
          if (kDebugMode) {
            print('error: $error');
          }
        });
  }
}
