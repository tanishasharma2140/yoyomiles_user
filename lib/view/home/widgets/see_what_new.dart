import 'package:flutter/material.dart';
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view/home/widgets/registration.dart';
import 'package:yoyomiles/view/home/widgets/packer_mover.dart';

class SeeWhatNew extends StatefulWidget {
  const SeeWhatNew({super.key});

  @override
  State<SeeWhatNew> createState() => _SeeWhatNewState();
}

class _SeeWhatNewState extends State<SeeWhatNew> {
  final List<Map<String, String>> items = [
    {
      'image': Assets.assetsDrivebusiness,
      'title': "Introducing Porter Enterprises",
      'description':
      "An end-to-end, agile logistics solution for business\nenterprises",
    },
    {
      'image': Assets.assetsPakingmoving,
      'title': "Packer and Movers",
      'description': "Packers & movers starting from ₹1200",
    },
    {
      'image': Assets.assetsPorterinstagram,
      'title': "Connect with Porter to get updates",
      'description': "Follow for speedier Updates",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.bg,
        body: Column(
          children: [
            SizedBox(height: topPadding,),
            Container(
              alignment: Alignment.center,
              height: screenHeight * 0.08,
              width: screenWidth,
              decoration: BoxDecoration(
                color: PortColor.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: screenWidth * 0.04),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: PortColor.black,
                      size: screenHeight * 0.027,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.25),
                  TextConst(title: "See What's New", color: PortColor.black),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.009,
                    ),
                    child: Container(
                      // height: screenHeight * 0.5,
                      decoration: BoxDecoration(
                        color: PortColor.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                          vertical: screenHeight * 0.01,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (index == 0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Registration(),
                                    ),
                                  );
                                } else if (index == 1) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PackerMover(),
                                    ),
                                  );
                                }
                              },
                              child: Image(
                                image: AssetImage(item['image']!),
                                height: screenHeight * 0.4,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            TextConst(
                              title: item['title']!,
                              color: PortColor.black,
                            ),
                            SizedBox(height: screenHeight * 0.002),
                            TextConst(
                              title: item['description']!,
                              color: PortColor.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
