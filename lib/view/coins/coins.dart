import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/widgets.dart';
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view_model/claim_reward_view_model.dart';
import 'package:yoyomiles/view_model/reward_view_model.dart';

class CoinsPage extends StatefulWidget {
  const CoinsPage({super.key});

  @override
  State<CoinsPage> createState() => _CoinsPageState();
}


class _CoinsPageState extends State<CoinsPage> {
  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rewardVm = Provider.of<RewardViewModel>(context, listen: false);
      rewardVm.loadAllRewards(context);
    });
  }



  void _openScratchPopup(BuildContext context, var vm) {
    bool revealed = false;

    final claimVm = Provider.of<ClaimRewardViewModel>(context, listen: false);
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 300,
                      width: 280,
                      padding: const EdgeInsets.all(12),
                      child: ClipRRect(   // ← Border radius apply here
                        borderRadius: BorderRadius.circular(15),
                        child: Scratcher(
                          brushSize: 50,
                          threshold: 60,
                          color: PortColor.containerBlue,
                          onThreshold: () async {
                            setState(() => revealed = true);
                            claimVm.claimRewardApi(
                              context: context,
                              rewardId: vm.id.toString(),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [  PortColor.containerBlue,
                                  PortColor.purple,
                                  PortColor.darkCoin,],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: !revealed
                                ?  Text(
                              loc.scratch,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "₹${vm.rewardAmount}",
                                  style: const TextStyle(
                                    fontSize: 28,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  vm.comment ?? "",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),


                    Positioned(
                      right: -10,
                      top: -10,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(2, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.close, size: 20, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reward = Provider.of<RewardViewModel>(context);
    final scratchList = reward.scratchList;
    final loc = AppLocalizations.of(context)!;


    return Scaffold(
      backgroundColor: PortColor.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: AppBar(
          backgroundColor: PortColor.white,
          elevation: 0,
          centerTitle: true,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.arrow_back, color: PortColor.black, size: 22),
            ),
          ),
          title:  Text(
            loc.yoyomiles_rew,
            style: TextStyle(
              color: Colors.black,
              fontFamily: AppFonts.kanitReg,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      body: reward.loading
          ? const Center(child: CircularProgressIndicator())
          : reward.rewardModel == null
          ?  Center(child: Text(loc.no_referal_yet))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ---------- TOP COIN SUMMARY ----------
                Container(
                  height: screenHeight * 0.25,
                  width: screenWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PortColor.gradientPurple,
                        PortColor.gradientLightPurple,
                        PortColor.white,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              PortColor.containerBlue,
                              PortColor.purple,
                              PortColor.darkCoin,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(
                     Radius.circular(10)
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextConst(
                                    title: loc.total_re,
                                    color: PortColor.gray,
                                  ),
                                  TextConst(
                                    title: "₹${reward.totalReward}",
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),

                                ],
                              ),
                            ),
                            const Spacer(),
                            Image(
                              image: const AssetImage(Assets.assetsCoinsbundle),
                              height: screenHeight * 0.18,
                              width: screenWidth * 0.43,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                 Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                  child: TextConst(
                    title:
                    loc.you_re_reward,
                    size: 16, fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.kanitReg,
                  ),
                ),
                Consumer<RewardViewModel>(
                  builder: (context, rewardVm, _) {

                    final referralList = rewardVm.referralList; // type 1 data

                    if (rewardVm.loading) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (referralList.isEmpty) {
                      return  Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Text(
                          loc.no_referal_yet,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: referralList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (_, index) {
                        var vm = referralList[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                  blurRadius: 4,
                                  color: Colors.black12,
                                  offset: Offset(0, 2)
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.currency_rupee, color: Colors.green),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextConst(
                                      title:
                                      "₹${vm.rewardAmount}",
                                        size: 15,
                                        fontWeight: FontWeight.bold,
                                      fontFamily: AppFonts.kanitReg,
                                    ),
                                    const SizedBox(height: 4),
                                    TextConst(
                                      title:
                                      vm.comment ?? "",
                                        size: 12, color: Colors.black54
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      vm.updatedAt.toString().substring(0, 10),
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),


                 Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                  child: TextConst(
                    title:
                    loc.you_rewards,
                      size: 16, fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.kanitReg,
                  ),
                ),


                /// ---------- GRID SECTION ----------
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: scratchList.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final vm = scratchList[index];

                      bool isClaimed = vm.status == 1;

                      return GestureDetector(
                        onTap: isClaimed ? null : () => _openScratchPopup(context, vm),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                PortColor.containerBlue,
                                PortColor.purple,
                                PortColor.darkCoin,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: isClaimed
                                ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "₹${vm.rewardAmount}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppFonts.kanitReg,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextConst(
                                  title: vm.comment,
                                  color: PortColor.white,
                                  size: 13,
                                  fontFamily: AppFonts.kanitReg,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child:  Text(
                                   loc.claimed,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )
                                :  Text(
                              loc.tap_to_open,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.kanitReg,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )


              ],
            ),
    );
  }
}

