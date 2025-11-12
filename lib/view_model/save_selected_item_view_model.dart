import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:port_karo/model/save_selected_item_model.dart';
import 'package:port_karo/repo/save_selected_item_repo.dart';
import 'package:port_karo/utils/utils.dart';
import 'package:port_karo/view/home/widgets/pickup/schedule_screen.dart';
import 'package:port_karo/view_model/final_summary_view_model.dart';
import 'package:port_karo/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class SaveSelectedItemViewModel with ChangeNotifier {
  final _saveSelectedItemRepo = SaveSelectedItemRepo();

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  SaveSelectedItemModel? _saveSelectedItemModel;
  SaveSelectedItemModel? get saveSelectedItemModel => _saveSelectedItemModel;

  void setSelectedItemData(SaveSelectedItemModel value) {
    _saveSelectedItemModel = value;
    notifyListeners();
  }

  Future<void> saveSelectedItemsApi(
    dynamic cityType,
    dynamic distance,
    dynamic pickupPoint,
    dynamic dropPoint,
      dynamic selectedItems,
    context,
      Map<String, dynamic> movingDetailsData,

  ) async {
    UserViewModel userViewModel = UserViewModel();
    String? userId = await userViewModel.getUser();
    setLoading(true);

    Map data = {
      "user_id": userId.toString(),
      "city_type": cityType,
      "distance": distance,
      "pickup_point": pickupPoint,
      "drop_point": dropPoint,
      "selected_items": selectedItems,
    };

    print("saveSelectedItem${data}");
    print("movingDetailsData${movingDetailsData}");

    _saveSelectedItemRepo
        .saveSelectedItemsApi(data)
        .then((value) {
          setLoading(false);
          if (value.status == true) {
            setSelectedItemData(value);
            final summaryVm = Provider.of<FinalSummaryViewModel>(context,listen: false);
            summaryVm.finalSummaryApi(null,distance, pickupPoint, dropPoint, 0, 0, 0, 0, context);

            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (_, __, ___) => ScheduleScreen(
                  data : movingDetailsData,
                ),
                transitionsBuilder: (_, animation, __, child) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ));

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );

          } else {
            if (kDebugMode) {
              print('value: ${value.message}');
            }
          }
        })
        .onError((error, stackTrace) {
          setLoading(false); // ✅ Stop loader on error
          if (kDebugMode) {
            print('error: $error');
            Utils.showErrorMessage(context, 'error: $error');
          }
        });
  }
}

// Navigator.push(
// context,
// PageRouteBuilder(
// transitionDuration: const Duration(milliseconds: 400),
// pageBuilder: (_, __, ___) => const ScheduleScreen(),
// transitionsBuilder: (_, animation, __, child) {
// final offsetAnimation = Tween<Offset>(
// begin: const Offset(0, 1),
// end: Offset.zero,
// ).animate(CurvedAnimation(
// parent: animation,
// curve: Curves.easeOutCubic,
// ));
//
// return SlideTransition(
// position: offsetAnimation,
// child: child,
// );
// },
// ),
// );
