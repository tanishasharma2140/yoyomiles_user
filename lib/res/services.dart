import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:port_karo/utils/routes/routes.dart';
import 'package:port_karo/view/auth/intro_page.dart';
import 'package:port_karo/view_model/profile_view_model.dart';
import 'package:port_karo/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
class Services{
  Future<String?> getUserData() => UserViewModel().getUser();
  void checkAuthentication(context) async {
    // UserViewModel().remove();
    getUserData().then((value) async {
      if (kDebugMode) {
        print(value.toString());
        print('valueId');
      }
      if (value == null || value == '') {
        await Future.delayed(const Duration(seconds: 3));
        Navigator.pushNamed(context, RoutesName.login);
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>IntroPage()));
      } else {
        final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
        profileViewModel.profileApi(context);
        if(profileViewModel.profileModel?.data?.status==2){
          UserViewModel().remove();
          await Future.delayed(const Duration(seconds: 3));
          Navigator.pushNamed(context, RoutesName.login);
        }else{
          await Future.delayed(const Duration(seconds: 3));
          Navigator.pushNamed(context, RoutesName.bottomNavBar);
        }
      }
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }
}