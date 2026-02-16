// lib/view/auth/login_page.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoyomiles/controller/language_controller.dart';
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_btn.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/const_loader.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/res/country.dart';
import 'package:yoyomiles/res/custom_text_field.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view/account/widgets/terms/privacy_policy.dart';
import 'package:yoyomiles/view/account/widgets/terms/terms_and_condition.dart';
import 'package:yoyomiles/view_model/login_view_model.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  final Country _selectedCountry = Country(
    name: "India",
    code: "IND",
    dialCode: "+91",
    flagAsset: Assets.assetsIndiaflag,
  );

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    // keep UI updated when text changes so button remains visible if text exists
    // loginViewModel.phoneController.addListener(() {
    //   setState(() {});
    // });
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<AuthViewModel>(context);
    final loc = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: screenHeight * 0.08),
                Container(
                  height: screenHeight * 0.12,
                  width: screenWidth * 0.6,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Assets.assetsYoyoMilesRemoveBg),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Image(image: AssetImage(Assets.assetsLoginDriver)),
              ],
            ),
            if (loginViewModel.loading) const Center(child: ConstLoader()),
            Positioned(
              top: screenHeight * 0.05,
              right: screenWidth * 0.05,
              child: Consumer<LanguageController>(
                builder: (context, languageProvider, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: languageProvider.currentLanguageCode,
                        dropdownColor: Colors.white, // ✅ Dropdown menu white
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: PortColor.portKaro,
                        ),
                        style: const TextStyle(
                          color: PortColor.portKaro,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text("English"),
                          ),
                          DropdownMenuItem(
                            value: 'hi',
                            child: Text("Hindi"),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == 'en') {
                            languageProvider.changeLanguage(const Locale('en'));
                          } else if (value == 'hi') {
                            languageProvider.changeLanguage(const Locale('hi'));
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),


          ],
        ),
        bottomSheet: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.037,
          ),
          decoration: BoxDecoration(
            color: PortColor.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  TextConst(
                    title: loc.welcome,
                    color: PortColor.portKaro,
                    fontFamily: AppFonts.kanitReg,
                    fontWeight: FontWeight.w400,
                    size: 16,
                  ),
                  SizedBox(width: screenWidth * 0.018),
                  Image(
                    image: const AssetImage(Assets.assetsHello),
                    height: screenHeight * 0.03,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.016),
              TextConst(
                title:
                    loc.valid_number,
                color: PortColor.gray,
                fontFamily: AppFonts.poppinsReg,
              ),
              SizedBox(height: screenHeight * 0.03),

              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: screenHeight * 0.05,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: screenWidth * 0.002,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            _selectedCountry.flagAsset,
                            width: 22,
                            height: 22,
                          ),
                          const SizedBox(width: 4),
                          TextConst(
                            title: _selectedCountry.dialCode,
                            color: PortColor.gray,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      controller: loginViewModel.phoneController,
                      height: screenHeight * 0.05,
                      hintText: loc.mobile_number,
                      fillColor: PortColor.white,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      cursorHeight: screenHeight * 0.025,
                      focusNode: _focusNode,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // ✅ only numbers
                      ],
                      // ensure Done button is handled
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        // hide keyboard but keep login button if number exists
                        FocusScope.of(context).unfocus();
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: bottomPadding),

              // show login button when field is focused OR when there's text in the field
              if (_isFocused || loginViewModel.phoneController.text.isNotEmpty) loginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginButton() {
    final loginViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(height: screenHeight * 0.03),
        AppBtn(
          title: loc.login,
          loading: loginViewModel.loading,
          onTap: () {
            if (loginViewModel.phoneController.text.length == 10 &&
                RegExp(r'^\d{10}$').hasMatch(loginViewModel.phoneController.text)) {
                 loginViewModel.otpSentApi(loginViewModel.phoneController.text, context);
              //   loginViewModel.phoneController.text,
              //   fcmToken.toString(),
              //   context,
              // );
            } else {
              Utils.showErrorMessage(
                context,
                loc.please_enter_mobile,
              );
            }
          },
        ),
        SizedBox(height: screenHeight * 0.02),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: loc.login_agree,
            style: const TextStyle(
              color: PortColor.gray,
              fontSize: 12,
              fontFamily: AppFonts.poppinsReg,
            ),
            children: [
              TextSpan(
                text: loc.terms_service,
                style: const TextStyle(
                  color: PortColor.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: AppFonts.poppinsReg,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 400),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const TermsAndCondition(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              final tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: Curves.easeInOut));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                      ),
                    );
                  },
              ),
               TextSpan(
                text: loc.and,
                style: TextStyle(
                  color: PortColor.gray,
                  fontSize: 12,
                  fontFamily: AppFonts.poppinsReg,
                ),
              ),
              TextSpan(
                text: loc.privacy_policy,
                style: const TextStyle(
                  color: PortColor.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: AppFonts.poppinsReg,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 400),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const PrivacyPolicy(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              final tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: Curves.easeInOut));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                      ),
                    );
                  },
              ),
            ],
          ),
        ),
        SizedBox(height: bottomPadding),
      ],
    );
  }
}
