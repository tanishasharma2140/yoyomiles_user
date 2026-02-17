import 'package:flutter/material.dart';
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_constant.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/res/launcher.dart';
import 'package:yoyomiles/view/account/widgets/help_support.dart';
import 'package:yoyomiles/view/account/widgets/save_address_detail.dart';
import 'package:yoyomiles/view/account/widgets/terms_condition.dart';
import 'package:yoyomiles/view/coins/coins.dart';
import 'package:yoyomiles/view/home/change_language.dart';
import 'package:yoyomiles/view/order/packer_mover_order_history.dart';
import 'package:yoyomiles/view/splash_screen.dart';
import 'package:yoyomiles/view_model/user_view_model.dart';

class AccountDetail extends StatelessWidget {
  const AccountDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Expanded(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        children: [
          SizedBox(height: screenHeight * 0.03),
          Material(
              elevation: 3.0,
              borderRadius: BorderRadius.circular(10.0),
              shadowColor: PortColor.grey.withOpacity(0.5),
              color: PortColor.white,
              child: buttonLayoutUi(
                context,
                Icons.favorite_border,
                color: PortColor.rapidBlue,
                loc.saved_address,
                page: const SaveAddressDetail(),
              )),
          SizedBox(height: screenHeight * 0.02),
          TextConst(title: loc.order_history, color: PortColor.gray),
          SizedBox(height: screenHeight * 0.02),
          Material(
              elevation: 3.0,
              borderRadius: BorderRadius.circular(10.0),
              shadowColor: PortColor.grey.withOpacity(0.5),
              color: PortColor.white,
              child: buttonLayoutUi(
                context,
                Icons.history,
                color: PortColor.gold,
                loc.packer_mover_order,
                page: const PackerMoverOrderHistory(),
              )),
          SizedBox(height: screenHeight * 0.02),
          TextConst(title: loc.benefits, color: PortColor.gray),
          SizedBox(height: screenHeight * 0.02),
          Container(
            height: screenHeight * 0.19,
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.025, vertical: screenHeight * 0.02),
            decoration: BoxDecoration(
              color: PortColor.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: PortColor.grayLight.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                buttonLayoutUi(
                  page: CoinsPage(),
                  context,
                  color: PortColor.rapidPurple,
                  Icons.star_border_purple500_outlined,
                   loc.yoyomiles_rew,
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: PortColor.black,
                    size: screenHeight * 0.02,
                  ),
                ),
                buttonLayoutUi(
                  context,
                  Icons.share,
                  loc.refer_friend,   // label String
                  color: PortColor.portKaro,
                  trailing: GestureDetector(
                    onTap: () {
                      Launcher.shareApk(AppConstant.apkUrl, context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      height: screenHeight * 0.03,
                      // width: screenWidth * 0.16,
                      decoration: BoxDecoration(
                        color: PortColor.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share,
                            color: PortColor.blackList,
                            size: screenHeight * 0.02,
                          ),
                          const SizedBox(width: 4.0),
                          TextConst(
                            title: loc.invite,
                            color: PortColor.blackList,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          TextConst(title: loc.support_legal, color: PortColor.gray),
          SizedBox(height: screenHeight * 0.02),
          Container(
            height: screenHeight * 0.19,
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.025, vertical: screenHeight * 0.02),
            decoration: BoxDecoration(
              color: PortColor.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: PortColor.grayLight.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                buttonLayoutUi(context, Icons.help_outline,color: PortColor.rapidGreen ,loc.help_support,
                    page: const HelpSupport()),
                buttonLayoutUi(context, Icons.copy_all, color: PortColor.darkBlue,loc.terms_condition,
                    page: const TermsCondition())
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          TextConst(title: loc.setting, color: PortColor.gray),
          SizedBox(height: screenHeight * 0.02),
          Material(
              elevation: 3.0,
              borderRadius: BorderRadius.circular(10.0),
              shadowColor: PortColor.grey.withOpacity(0.5),
              color: PortColor.white,
              child: buttonLayoutUi(
                context,
                Icons.language,
                color: PortColor.yellowCoin,
                "Change Language",
                page: ChangeLanguage(),
              )),
          SizedBox(height: screenHeight * 0.02),
          Material(
            elevation: 3.0,
            borderRadius: BorderRadius.circular(10.0),
            shadowColor: PortColor.grey.withOpacity(0.5),
            child: ListTile(
              contentPadding:
              EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              leading: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: PortColor.rapidRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  color: PortColor.rapidRed,
                  size: screenHeight * 0.025,
                ),
              ),
              title: TextConst(title: loc.log_out, color: PortColor.black),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: PortColor.black,
                size: screenHeight * 0.02,
              ),
              onTap: () {
                showModalBottomSheet(
                  backgroundColor: PortColor.white,
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  builder: (BuildContext context) {
                    return logoutBottomSheet(context);
                  },
                );
              },
            ),
          ),
          SizedBox(height: screenHeight * 0.04),
          Center(
            child: TextConst(
                title: "${loc.app_version} ${AppConstant.appVersion}",
                color: PortColor.gray),
          ),
          SizedBox(height: screenHeight * 0.04),
        ],
      ),
    );
  }

  Widget logoutBottomSheet(context) {
    final loc = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: EdgeInsets.all(screenHeight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextConst(
                title: loc.are_you_want_to_log,
                color: PortColor.black),
            SizedBox(height: screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: screenHeight * 0.058,
                    width: screenWidth * 0.4,
                    decoration: BoxDecoration(
                      color: PortColor.white,
                      border: Border.all(
                          color: PortColor.blue.withOpacity(0.75), width: 2),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Center(
                      child: TextConst(
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.kanitReg,
                          title: loc.no, color: PortColor.blue),
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.02,
                ),
                InkWell(
                  onTap: () {
                    UserViewModel().remove();
                    // Navigator.pushReplacementNamed(context, RoutesName.splash);
                    // Navigator.pushNamedAndRemoveUntil(context, RoutesName.splash, (context)=>true);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SplashScreen()),
                            (context) => false);
                    //  Navigator.pushAndRemoveUntil(context, RoutesName.splash, (context)=>false);
                  },
                  child: Container(
                    height: screenHeight * 0.058,
                    width: screenWidth * 0.4,
                    decoration: BoxDecoration(
                      color: PortColor.gold,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Center(
                      child: TextConst(title: loc.yes, color: PortColor.white,fontFamily:AppFonts.kanitReg,fontWeight: FontWeight.w400,),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buttonLayoutUi(
      BuildContext context,
      IconData icon,
      String label, {
        Widget? page,
        Widget? trailing,
        Color? color, // 🔹 extra parameter
      }) {
    final Color effectiveColor = color ?? PortColor.blue;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, __, ___) =>  page,
              transitionsBuilder: (_, animation, __, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 1), // start from bottom
                  end: Offset.zero,          // end at normal position
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
        }
      },
      leading: Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: effectiveColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: effectiveColor,
          size: screenHeight * 0.025,
        ),
      ),
      title: TextConst(
        title: label,
        color: PortColor.black,
        size: 12,
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: PortColor.black,
            size: screenHeight * 0.02,
          ),
    );
  }

}
