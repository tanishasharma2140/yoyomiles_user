import 'package:flutter/material.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';

class Frequently extends StatefulWidget {
  const Frequently({super.key});

  @override
  _FrequentlyState createState() => _FrequentlyState();
}

class _FrequentlyState extends State<Frequently> {
  final List<String> faqQuestions = [
    "Do Porter Coins Have Validity?",
    "What is the value of a Porter coin in Rupees?",
    "How can I use Porter Coin?",
    "Do Porter Coins Have Validity?",
    "Where are the Porter coins awarded?",
    "Will Porter Rewards be credited against a PEE\nBusiness wallet trip?"
  ];

  final List<String> faqAnswers = [
    "Porter coins have a validity of 1 year.",
    "1 Porter coin equals 1 Rupee.",
    "Porter coins can be used to avail discounts.",
    "Yes, they do have validity.",
    "Porter coins are awarded for every eligible trip.",
    "Rewards are not credited for PEE Business wallet trips."
  ];

  List<bool> expandedList = [];

  @override
  void initState() {
    super.initState();
    expandedList = List<bool>.filled(faqQuestions.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextConst(title: "Frequently asked questions", color: PortColor.black),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: faqQuestions.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextConst(
                          title: faqQuestions[index], color: PortColor.black),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          expandedList[index]
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: PortColor.gray,
                        ),
                        onPressed: () {
                          setState(() {
                            expandedList[index] = !expandedList[index];
                          });
                        },
                      ),
                    ],
                  ),
                  if (expandedList[index])
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.01),
                      child: Text(
                        faqAnswers[index],
                        style: TextStyle(color: PortColor.gray),
                      ),
                    ),
                  Divider(thickness: screenWidth * 0.001),
                  SizedBox(height: screenHeight * 0.018),
                ],
              );
            },
          ),
          SizedBox(height: screenHeight * 0.04),
          TextConst(title: "Terms & Condition", color: PortColor.black),
          SizedBox(height: screenHeight * 0.04),
        ],
      ),
    );
  }
}
