import 'package:flutter/material.dart';
import 'package:port_karo/generated/assets.dart';
import 'package:port_karo/main.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
class CategoryGridTwo extends StatelessWidget {
  const CategoryGridTwo({super.key});

  @override
  Widget build(BuildContext context) {
    List<GridPaper> porterGrid=[
      GridPaper(title:"How do I earn \ncoins?",img:Assets.assetsHandcoinremove),
      GridPaper(title:"How do I use \ncoins?",img:Assets.assetsPursecoinremove),

    ];
    return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 2,
          childAspectRatio: 0.64,
          crossAxisSpacing: screenWidth * 0.05,
          mainAxisSpacing: screenHeight * 0.04,
        ),
        itemCount: porterGrid.length,
        itemBuilder: (context, index)

        {
          return  Container(
            decoration: BoxDecoration(
              color: PortColor.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    color: PortColor.gradientLightPurple.withOpacity(0.5),
                  ),
                  child: Image(
                    image: AssetImage(porterGrid[index].img),
                    height: screenHeight * 0.18,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03, vertical: screenHeight * 0.004),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextConst(title: porterGrid[index].title, color: PortColor.black),
                      SizedBox(height: screenHeight * 0.016),
                      Row(
                        children: [
                          TextConst(title: "Learn", color: PortColor.blue),
                          SizedBox(width: screenWidth * 0.02),
                          Icon(Icons.arrow_forward,
                              color: PortColor.blue, size: screenHeight * 0.02),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
class GridPaper {
  final String title;
  final String img;
  GridPaper( {required this.title, required this.img });
}