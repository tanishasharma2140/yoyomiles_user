import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles/repo/change_pay_mode_repo.dart';
import 'package:yoyomiles/repo/claim_reward_repo.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view_model/reward_view_model.dart';
import 'package:yoyomiles/view_model/user_view_model.dart';

class ClaimRewardViewModel with ChangeNotifier {
  final _claimRewardRepo = ClaimRewardRepo();
  bool _loading = false;

  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> claimRewardApi({
    required BuildContext context,
    required dynamic rewardId,
  }) async {
    setLoading(true);

    UserViewModel userViewModel = UserViewModel();
    String? userId = await userViewModel.getUser();

    final Map<String, dynamic> data = {
      "user_id": userId,
      "reward_id": rewardId,
    };

    final response = await _claimRewardRepo.claimRewardApi(data);
    setLoading(false);

    if (response == null) {
      Utils.showErrorMessage(context, "Something went wrong");
      return;
    }

    if (response['status'] == 200) {
      /// SUCCESS HANDLING
      Utils.showSuccessMessage(context, response['message'] ?? "Claimed Successfully");
      Navigator.pop(context);  // close popup/bottomsheet/dialog
      notifyListeners();
      final rewardVm = Provider.of<RewardViewModel>(context, listen: false);
      rewardVm.loadAllRewards;
    }
    else if (response['status'] == 400) {
      /// SPECIFIC ERROR FROM BACKEND
      Utils.showErrorMessage(context, response['message'] ?? "Invalid Request");
    }
    else {
      /// DEFAULT CATCH
      Utils.showErrorMessage(context, "Failed to claim reward");
    }
  }



}
