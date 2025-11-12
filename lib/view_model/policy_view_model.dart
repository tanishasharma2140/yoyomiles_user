import 'package:flutter/foundation.dart';
import 'package:port_karo/model/policy_model.dart';
import 'package:port_karo/repo/policy_repo.dart';

class PolicyViewModel with ChangeNotifier {
  final _policyRepo = PolicyRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  PolicyModel? _policyModel;
  PolicyModel? get policyModel => _policyModel;

  setModelData(PolicyModel value) {
    _policyModel = value;
    notifyListeners();
  }

  Future<void> policyApi(context) async {
    setLoading(true);

    _policyRepo.policyApi(context).then((value) {
      debugPrint('value:$value');
      if (value.success == true) {
        setModelData(value);
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
