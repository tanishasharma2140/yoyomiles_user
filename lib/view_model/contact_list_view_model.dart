import 'package:flutter/foundation.dart';
import 'package:yoyomiles/model/contact_list_model.dart';
import 'package:yoyomiles/repo/contact_list_repo.dart';

class ContactListViewModel with ChangeNotifier {
  final _contactListRepo = ContactListRepo();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  ContactListModel? _contactListModel;
  ContactListModel? get contactListModel => _contactListModel;

  setContactListData(ContactListModel value) {
    _contactListModel = value;
    notifyListeners();
  }

  Future<void> contactListApi() async {
    setLoading(true);

    _contactListRepo.contactListApi().then((value) {
      debugPrint('value:$value');
      if (value.status == true) {
        setContactListData(value);
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
