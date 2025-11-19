import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view_model/policy_view_model.dart';
import 'package:provider/provider.dart';
class TermsAndCondition extends StatefulWidget {
  const TermsAndCondition({super.key});

  @override
  State<TermsAndCondition> createState() => _TermsAndConditionState();
}

class _TermsAndConditionState extends State<TermsAndCondition> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final termsPolicyVm =
      Provider.of<PolicyViewModel>(context, listen: false);
      termsPolicyVm.policyApi("2");
      print("I am the....");
    });
  }
  @override
  Widget build(BuildContext context) {
    final termsPolicyVm = Provider.of<PolicyViewModel>(context);
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
                  SizedBox(width: screenWidth * 0.06),
                  SizedBox(width: screenWidth * 0.24),
                  TextConst(
                    title: "Terms and Condition",
                    color: PortColor.black,
                  ),
                  SizedBox(width: screenWidth * 0.16),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.dangerous_outlined),
                  ),
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
                child: termsPolicyVm.loading
                    ? const Center(
                  child: Center(child: CircularProgressIndicator(color: PortColor.gold
                    ,),),
                )
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: HtmlWidget(
                    termsPolicyVm.policyModel?.data?.description ?? "",
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
