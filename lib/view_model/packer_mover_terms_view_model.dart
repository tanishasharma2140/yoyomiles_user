import 'package:flutter/foundation.dart';
import 'package:port_karo/model/packer_mover_terms_model.dart';
import 'package:port_karo/model/policy_model.dart';
import 'package:port_karo/repo/packer_mover_terms_condition_repo.dart';
import 'package:port_karo/repo/policy_repo.dart';

class PackerMoverTermsViewModel with ChangeNotifier {
  final _packerMoverTermsConditionRepo = PackerMoverTermsConditionRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  PackerMoverTermsModel? _packerMoverTermsModel;
  PackerMoverTermsModel? get packerMoverTermsModel => _packerMoverTermsModel;

  setPackerTermsData(PackerMoverTermsModel value) {
    _packerMoverTermsModel = value;
    notifyListeners();
  }

  Future<void> packerTermsConditionApi(context) async {
    setLoading(true);

    _packerMoverTermsConditionRepo.packerTermsConditionApi(context).then((value) {
      debugPrint('value:$value');
      if (value.success == true) {
        setPackerTermsData(value);
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
