import 'package:flutter/material.dart';
import 'package:yoyomiles/model/reward_model.dart';
import 'package:yoyomiles/repo/reward_repo.dart';
import 'package:yoyomiles/view_model/user_view_model.dart';

class RewardViewModel with ChangeNotifier {
  final _rewardRepo = RewardRepo();

  bool _loading = false;
  bool get loading => _loading;

  /// MASTER MERGED MODEL
  RewardModel? _rewardModel;
  RewardModel? get rewardModel => _rewardModel;

  /// TYPE BASE LISTS
  List<Data> _referralList = [];
  List<Data> get referralList => _referralList;

  List<Data> _scratchList = [];
  List<Data> get scratchList => _scratchList;

  /// TOTALS
  num totalReferralReward = 0;
  num totalScratchReward = 0;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// 🚀 Call BOTH type-1 & type-2 in one go
  Future<void> loadAllRewards(BuildContext context) async {
    setLoading(true);

    await Future.wait([
      _fetchRewards(1, context),
      _fetchRewards(2, context),
    ]);

    /// BUILD MERGED MODEL FOR UI
    _rewardModel = RewardModel(
      status: 200,
      totalReward: totalReward.toInt(),
      message: "Combined reward",
      data: [..._referralList, ..._scratchList],
    );

    setLoading(false);
    notifyListeners();
  }

  /// 🔒 internal fetch for both
  Future<void> _fetchRewards(int rewardType, BuildContext context) async {
    try {
      UserViewModel userViewModel = UserViewModel();
      String? userId = await userViewModel.getUser();

      Map data = {
        "user_id": userId,
        "reward_type": rewardType
      };

      final value = await _rewardRepo.rewardApi(data);

      if (value.status == 200) {
        if (rewardType == 1) {
          _referralList = value.data ?? [];
          totalReferralReward = value.totalReward ?? 0;
        }
        if (rewardType == 2) {
          _scratchList = value.data ?? [];
          totalScratchReward = value.totalReward ?? 0;
        }
      }
    } catch (e) {
      debugPrint("Reward API Exception: $e");
    }
  }

  /// 🧮 FINAL TOTAL
  num get totalReward => totalReferralReward + totalScratchReward;
}
