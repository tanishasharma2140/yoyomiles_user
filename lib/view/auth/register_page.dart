import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_btn.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view/auth/login_page.dart';
import 'package:yoyomiles/view_model/register_view_model.dart';
import 'package:yoyomiles/view_model/requirement_view_model.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
 final  String? mobile;
 final String? referralCode;
  const RegisterPage({super.key,  this.mobile, this.referralCode});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController refer = TextEditingController();

  bool isSelected = false;
  dynamic selectedRadioValue;
  String? selectedBusinessUsage; // For dropdown value

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final requirementVm = Provider.of<RequirementViewModel>(context, listen: false);
      requirementVm.requirementApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("njhjbh");
    print(widget.mobile);
    final registerViewModel = Provider.of<RegisterViewModel>(context);
    final requirementVm = Provider.of<RequirementViewModel>(context);


    return Scaffold(
      backgroundColor: PortColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.06,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: screenHeight * 0.11,
                  width: screenWidth * 0.6,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Assets.assetsYoyoMilesRemoveBg),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.018),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: const AssetImage(Assets.assetsIndiaflagsquare),
                    height: screenHeight * 0.023,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  TextConst(
                    title: widget.mobile??"",
                    color: PortColor.black,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: TextConst(
                      title: "CHANGE",
                      color: PortColor.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      cursorColor: PortColor.portKaro,
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "First Name",
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: PortColor.gray,
                          fontFamily: AppFonts.kanitReg,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: PortColor.gray),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: PortColor.gray),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.06),
                  Expanded(
                    child: TextFormField(
                      cursorColor: PortColor.portKaro,
                      controller: lastnameController,
                      decoration: const InputDecoration(
                        hintText: "Last Name",
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: PortColor.gray,
                          fontFamily: AppFonts.kanitReg,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: PortColor.gray),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: PortColor.gray),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              TextFormField(
                cursorColor: PortColor.portKaro,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Email Id",
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: PortColor.gray,
                    fontFamily: AppFonts.kanitReg,
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: PortColor.gray),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: PortColor.gray),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  // Simple email regex
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),

              SizedBox(height: screenHeight * 0.035),

              // 🔹 Business Usage Dropdown - Added this section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextConst(
                    title: "Requirement",
                    size: 14,
                    color: PortColor.gray,
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFonts.kanitReg,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: PortColor.gray, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child:DropdownButton<String>(
                        value: selectedBusinessUsage,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        hint: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                          ),
                          child: TextConst(
                            title: "Select Business Usage",
                            color: PortColor.gray,
                            size: 14,
                            fontFamily: AppFonts.poppinsReg,
                          ),
                        ),
                        items: requirementVm.requirementModel?.data?.map((option) {
                          return DropdownMenuItem<String>(
                            value: option.id.toString(),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextConst(
                                    title: option.heading ?? "",
                                    color: PortColor.black,
                                    size: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppFonts.poppinsReg,
                                  ),
                                  TextConst(
                                    title: option.subheading ?? "",
                                    color: PortColor.gray,
                                    fontFamily: AppFonts.poppinsReg,
                                    size: 10,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList() ?? [],
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBusinessUsage = newValue;
                            selectedRadioValue = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),

              TextFormField(
                cursorColor: PortColor.portKaro,
                controller: refer,
                decoration: const InputDecoration(
                  hintText: "Referral Code(Optional)",
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: PortColor.gray,
                    fontFamily: AppFonts.kanitReg,
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: PortColor.gray),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: PortColor.gray),
                  ),
                ),
                // inputFormatters: [
                //   FilteringTextInputFormatter.allow(
                //     RegExp(r'[a-zA-Z\s]'),
                //   ),
                // ],
              ),
              // SizedBox(height: screenHeight * 0.03),
              //
              // Center(
              //   child: TextConst(
              //     title: "Have referral code?",
              //     color: PortColor.gold,
              //     size: 15,
              //     fontWeight: FontWeight.w600,
              //     fontFamily: AppFonts.poppinsReg,
              //   ),
              // ),
              SizedBox(height: screenHeight * 0.05),
        AppBtn(title: "Register",
            loading: registerViewModel.loading,
            onTap: (){
          if (nameController.text.isEmpty) {
            Utils.showErrorMessage(context, "Please enter First Name");
          } else if (lastnameController.text.isEmpty) {
            Utils.showErrorMessage(context, "Please enter Last Name");
          } else if (emailController.text.isEmpty) {
            Utils.showErrorMessage(
              context,
              "Please enter Email Address",
            );
          } else if (selectedBusinessUsage == null) {
            Utils.showErrorMessage(
              context,
              "Please select Business Usage",
            );
          } else {
            registerViewModel.registerApi(
              nameController.text,
              lastnameController.text,
              emailController.text,
              widget.mobile,
              selectedBusinessUsage!,
              "111adf",
              fcmToken.toString(),
              refer.text,
              context,
            );
          }
        }),

              SizedBox(height: 30,),

              // 🔹 OTP Message
              TextConst(
                title:
                    "A one time password (OTP) will be sent to this number for verification.",
                color: PortColor.gray,
                size: 12,
                textAlign: TextAlign.center,
                fontFamily: AppFonts.kanitReg,
              ),

              // 🔹 Register Button

            ],
          ),
        ),
      ),
    );
  }

  Widget buildOption(String title, String subtitle, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: screenHeight * 0.08,
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        border: Border.all(color: PortColor.gray, width: screenWidth * 0.002),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Radio(
            value: value,
            groupValue: selectedRadioValue,
            onChanged: (newValue) {
              setState(() {
                selectedRadioValue = newValue;
                selectedBusinessUsage = newValue
                    .toString(); // Sync with dropdown
              });
            },
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextConst(
                title: title,
                color: PortColor.black,
                size: 12,
                fontWeight: FontWeight.w500,
              ),
              TextConst(title: subtitle, color: PortColor.gray, size: 10),
            ],
          ),
        ],
      ),
    );
  }
}
