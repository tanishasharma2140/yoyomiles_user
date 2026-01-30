import 'package:flutter/foundation.dart';
import 'package:yoyomiles/model/gst_percentage_model.dart';
import 'package:yoyomiles/repo/gst_percentage_repo.dart';

class GstPercentageViewModel with ChangeNotifier {
  final _gstPercentageRepo = GstPercentageRepo();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  GstPercentageModel? _gstPercentageModel;
  GstPercentageModel? get gstPercentageModel => _gstPercentageModel;

  setGstModelData(GstPercentageModel value) {
    _gstPercentageModel = value;
    notifyListeners();
  }

  Future<void> gstPercentageApi() async {
    setLoading(true);

    _gstPercentageRepo.gstPercentageApi().then((value) {
      debugPrint('value:$value');
      if (value.success == true) {
        setGstModelData(value);
      }
      setLoading(false);
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }

}
