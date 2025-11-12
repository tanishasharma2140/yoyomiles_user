import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:port_karo/model/profile_model.dart';
import 'package:port_karo/repo/profile_repo.dart';
import 'package:port_karo/utils/routes/routes.dart';
import 'package:port_karo/view_model/user_view_model.dart';
class ProfileViewModel with ChangeNotifier {
  final _profileRepo = ProfileRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  ProfileModel? _profileModel;
  ProfileModel? get profileModel => _profileModel;

  setModelData(ProfileModel value) {
    _profileModel = value;
    notifyListeners();
  }
  Future<void> profileApi(context) async {
    setLoading(true);
      UserViewModel userViewModel = UserViewModel();
      String? userId = await userViewModel.getUser();
       _profileRepo.profileApi(userId).then((value){
         print('value:$value');
         if (value.success == true) {
           setModelData(value);
           if (value.data!.status == 2) {
             userViewModel.remove();
             Navigator.pushNamedAndRemoveUntil(
                 context,
                 RoutesName.login,
             (route) => false,
             );
           }
         }
       }).onError((error, stackTrace) {
         setLoading(false);
         if (kDebugMode) {
           print('error: $error');
         }
       });
  }
}

