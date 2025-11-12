import 'package:flutter/foundation.dart';
import 'package:port_karo/model/goods_type_model.dart';
import 'package:port_karo/repo/goods_type_repo.dart';

class GoodsTypeViewModel with ChangeNotifier {
  final _goodsTypeRepo = GoodsTypeRepo();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  GoodsTypeModel? _goodsTypeModel;
  GoodsTypeModel? get goodsTypeModel => _goodsTypeModel;

  setModelData(GoodsTypeModel value) {
    _goodsTypeModel = value;
    notifyListeners();
  }

  Future<void> goodsTypeApi() async {
    setLoading(true);

    _goodsTypeRepo.goodsTypeApi().then((value) {
      debugPrint('value:$value');
      if (value.status == 200) {
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
