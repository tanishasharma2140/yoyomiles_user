import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:port_karo/main.dart';
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
import 'package:port_karo/view_model/policy_view_model.dart';
import 'package:provider/provider.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}
class _PrivacyPolicyState extends State<PrivacyPolicy> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final policyVm =
      Provider.of<PolicyViewModel>(context, listen: false);
      policyVm.policyApi("1");
      print("I am the....don");
    });
  }
  @override
  Widget build(BuildContext context) {
    final privacyPolicy = Provider.of<PolicyViewModel>(context);
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.bg,
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 17),
              height: screenHeight * 0.085,
              width: screenWidth,
              decoration: BoxDecoration(
                color: PortColor.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: screenWidth * 0.06,
                  ),

                  SizedBox(
                    width: screenWidth * 0.24,
                  ),
                  TextConst(
                    title: "Privacy and Policy",
                    color: PortColor.black,
                  ),
                  SizedBox(
                    width: screenWidth * 0.22,
                  ),
                  InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.dangerous_outlined))
                ],
              ),
            ),
            SizedBox(height: 30,),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: privacyPolicy.loading
                    ? const Center(
                  child: Center(child: CircularProgressIndicator(color: PortColor.gold
                    ,),),
                )
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: HtmlWidget(
                    privacyPolicy.policyModel?.data?.description ?? "",
                    textStyle: TextStyle(
                      fontFamily: AppFonts.poppinsReg,
                      fontSize: 14,
                      color: PortColor.blackLight,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
