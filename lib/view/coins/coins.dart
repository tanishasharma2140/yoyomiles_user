import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view/coins/widgets/category_grid_one.dart';
import 'package:yoyomiles/view/coins/widgets/list/frequently.dart';

import 'widgets/category_grid_two.dart';

class CoinsPage extends StatefulWidget {
  const CoinsPage({super.key});

  @override
  State<CoinsPage> createState() => _CoinsPageState();
}

bool coin = false;

class _CoinsPageState extends State<CoinsPage> {
  @override
  void initState() {
    super.initState();
    closeCoin();
  }

  void closeCoin() {
    setState(() {
      coin = false;
    });
    print("tapped");
    Timer(const Duration(seconds: 1), () {
      setState(() {
        coin = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortColor.white,
      body:
      // coin == false
      //     ? const Center(
      //         child: Image(
      //         image: AssetImage(Assets.assetsCoinrewardremov),
      //         width: 500,
      //         height: 500,
      //       ))
      //     :
      SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: screenHeight * 0.365,
                    width: screenWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          PortColor.gradientPurple,
                          PortColor.gradientLightPurple,
                          PortColor.white
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                          vertical: screenHeight * 0.04),
                      child: Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  PortColor.containerBlue,
                                  PortColor.purple,
                                  PortColor.darkCoin
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.02,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextConst(title: " 0 "),
                                      TextConst(
                                          title: " Available Coins ",
                                          color: PortColor.gray),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Image(
                                  image: const AssetImage(
                                      Assets.assetsCoinsbundle),
                                  height: screenHeight * 0.2,
                                  width: screenWidth * 0.43,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: screenWidth * 0.9,
                            height: screenWidth * 0.1,
                            decoration: const BoxDecoration(
                                color: PortColor.white,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            child: Row(
                              children: [
                                SizedBox(width: screenWidth*0.02,),
                                TextConst(
                                    title: "Coin transaction History",
                                    color: PortColor.black),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_forward,
                                  size: screenHeight * 0.025,
                                  color: PortColor.gray,
                                ),
                                SizedBox(width: screenWidth*0.01,),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Row(
                      children: [
                        TextConst(title: "Use Coins", color: PortColor.black),
                        SizedBox(
                          width: screenWidth * 0.02,
                        ),
                        Container(
                          width: screenWidth * 0.2,
                          decoration: BoxDecoration(
                              color: PortColor.darkCoin,
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image(
                                image: const AssetImage(Assets.assetsCoin48),
                                height: screenHeight * 0.03,
                              ),
                              TextConst(title: "1 = ₹1 ")
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  const CategoryGridOne(),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: TextConst(
                        title: "More about coins", color: PortColor.black),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  const CategoryGridTwo(),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  const Frequently(),
                ],
              ),
            ),
    );
  }
}
