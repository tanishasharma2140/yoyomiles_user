import 'package:flutter/material.dart';
import 'package:port_karo/main.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
import 'package:port_karo/view/account/widgets/terms/privacy_policy.dart';

import 'terms/terms_and_condition.dart';
class TermsCondition extends StatefulWidget {
  const TermsCondition({super.key});

  @override
  State<TermsCondition> createState() => _TermsConditionState();
}

class _TermsConditionState extends State<TermsCondition> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.bg,
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 17),
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
                    width: screenWidth * 0.04,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: PortColor.black,
                      size: screenHeight * 0.025,
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.2,
                  ),
                  TextConst(
                    title: "Terms and Condition",
                    color: PortColor.black,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight*0.036,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth*0.04),
              // height: screenHeight*0.13,
              width: screenWidth,
              color: PortColor.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  GestureDetector(
                    onTap: (){
                      print("podpewdj");
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>TermsAndCondition()));
                    },
                    child: Container(
                      color: Colors.transparent,
                      height: 50,
                      child: Row(
                        children: [
                              TextConst(title: "Terms and Condition",color: PortColor.black),
                          Spacer(),
                          Icon(Icons.arrow_forward_ios_rounded,size: screenHeight*0.015,),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight*0.001,),
                  Divider(thickness: screenWidth*0.002,color: PortColor.grey,),
                  SizedBox(height: screenHeight*0.005,),

                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> PrivacyPolicy()));
                    },
                    child: Container(
                      color: Colors.transparent,
                      height: 50,
                      child: Row(
                        children: [
                    TextConst(title: "Privacy and policy",color: PortColor.black),
                          Spacer(),
                          Icon(Icons.arrow_forward_ios_rounded,size: screenHeight*0.015,),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      
      ),
    );
  }
}
