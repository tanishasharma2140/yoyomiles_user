import 'package:flutter/foundation.dart';
import 'package:port_karo/model/requirement_model.dart';
import 'package:port_karo/repo/requirement_repo.dart';

class RequirementViewModel with ChangeNotifier {
  final _requirementRepo = RequirementRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  RequirementModel? _requirementModel;
  RequirementModel? get requirementModel => _requirementModel;

  setModelData(RequirementModel value) {
    _requirementModel = value;
    notifyListeners();
  }

  Future<void> requirementApi() async {
    setLoading(true);

    _requirementRepo
        .requirementApi()
        .then((value) {
          debugPrint('value:$value');
          if (value.status == 200) {
            setModelData(value);
          }
          setLoading(false);
        })
        .onError((error, stackTrace) {
          setLoading(false);
          if (kDebugMode) {
            print('error: $error');
          }
        });
  }
}
