import 'package:flutter/foundation.dart';
import 'package:port_karo/model/on_boarding_model.dart';
import 'package:port_karo/repo/on_boarding_repo.dart';

class OnBoardingViewModel with ChangeNotifier {
  final _onBoardingRepo = OnBoardingRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  OnBoardingModel? _onBoardingModel;
  OnBoardingModel? get onBoardingModel => _onBoardingModel;

  setModelData(OnBoardingModel value) {
    _onBoardingModel = value;
    notifyListeners();
  }

  Future<void> onBoardingApi() async {
    setLoading(true);

    _onBoardingRepo
        .onBoardingApi()
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
