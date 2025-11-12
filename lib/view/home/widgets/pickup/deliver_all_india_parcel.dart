import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:port_karo/main.dart';
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
import 'package:port_karo/view/home/widgets/pickup/all_india_pick_up.dart' hide TextConst;

class DeliverAllIndiaParcel extends StatefulWidget {
  const DeliverAllIndiaParcel({super.key});

  @override
  State<DeliverAllIndiaParcel> createState() => _DeliverAllIndiaParcelState();
}
class _DeliverAllIndiaParcelState extends State<DeliverAllIndiaParcel> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.grey,
        body: Column(
          children: [
            SizedBox(height: topPadding,),
            Container(
              height: screenHeight * 0.17,
              width: screenWidth,
              decoration: BoxDecoration(
                  color: PortColor.white,
                  border: Border(
                    bottom: BorderSide(
                        color: PortColor.gray.withOpacity(0.4),
                        width: screenWidth * 0.002),
                  )),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back)),
                      TextConst(title: "Send Package", color: PortColor.black),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.015,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StepWidget(
                        icon: Icons.location_on,
                        TextConst: 'Address',
                        isActive: true,
                      ),
                      DottedLine(),
                      StepWidget(
                        icon: Icons.inventory,
                        TextConst: 'Package',
                        isActive: false,
                      ),
                      DottedLine(),
                      StepWidget(
                        icon: Icons.add_box,
                        TextConst: 'Estimate',
                        isActive: false,
                      ),
                      DottedLine(),
                      StepWidget(
                        icon: Icons.receipt,
                        TextConst: 'Review',
                        isActive: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.035),
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[800],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: PortColor.white,
                          size: screenHeight * 0.02,
                        ),
                      ),
                      Column(
                        children: List.generate(
                          8,
                          (index) => Container(
                            width: screenWidth * 0.005,
                            height: screenHeight * 0.0025,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            color: PortColor.gray,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: const BoxDecoration(
                          color: PortColor.gray,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          color: PortColor.white,
                          size: screenHeight * 0.02,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Container(
                    width: screenWidth*0.84,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => const AllIndiaPickUp(),
                                ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                              vertical: screenHeight * 0.015,
                            ),
                            height: screenHeight * 0.06,
                            width: screenWidth * 0.9,
                            decoration: BoxDecoration(
                              color: PortColor.gold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                TextConst(title: "Add Pick up Detail",color: PortColor.black,fontFamily: AppFonts.kanitReg,),
                                const Spacer(),
                                GestureDetector(
                                  onTap: (){

                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: PortColor.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: PortColor.blue,
                                      size: screenHeight * 0.02,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenHeight * 0.015,
                          ),
                          height: screenHeight * 0.058,
                          width: screenWidth * 0.9,
                          decoration: BoxDecoration(
                            color: PortColor.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextConst(
                              title: "Add drop details", color: PortColor.black,fontFamily: AppFonts.kanitReg,),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StepWidget extends StatelessWidget {
  final IconData icon;
  final String TextConst;
  final bool isActive;

  StepWidget({
    required this.icon,
    required this.TextConst,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? PortColor.button : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey,
            size: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          TextConst,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class DottedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(10, (index) {
        return Container(
          width: 1,
          height: 1,
          color: PortColor.black,
          margin: const EdgeInsets.symmetric(horizontal: 2),
        );
      }),
    );
  }
}
