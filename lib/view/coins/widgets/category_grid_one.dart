import 'package:flutter/material.dart';
import 'package:port_karo/generated/assets.dart';
import 'package:port_karo/main.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
class CategoryGridOne extends StatelessWidget {
  const CategoryGridOne({super.key});

  @override
  Widget build(BuildContext context) {
    List<GridTile> porterList = [
      GridTile(
        title: "Transfer into",
        subtitle: "Courier Credit",
        img: Assets.assetsPurse,

      ),
      GridTile(
        title: "Transfer into",
        subtitle: "Bank Account",
        img: Assets.assetsBankaccount,
      ),
    ];
    return GridView.builder(
        padding:  EdgeInsets.symmetric(horizontal: screenWidth * 0.05)
        ,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: screenWidth * 0.05,
          mainAxisSpacing: screenHeight * 0.02,
        ),
        itemCount: porterList.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: PortColor.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                )
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: screenHeight * 0.12,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    color: PortColor.gradientLightPurple.withOpacity(0.5),
                  ),
                  child: Image.asset(porterList[index].img, width: 50),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.014),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TextConst(title: porterList[index].title, color: PortColor.blue),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward,
                            color: PortColor.blue,
                            size: screenHeight * 0.02,
                          ),
                        ],
                      ),
                      TextConst(title: porterList[index].subtitle, color: PortColor.blue),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class GridTile {
  final String title;
  final String subtitle;
  final String img;
  GridTile( {required this.title, required this.img ,required this.subtitle,});
}