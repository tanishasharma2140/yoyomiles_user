import 'package:flutter/material.dart';
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/view_model/on_boarding_view_model.dart';
import 'package:provider/provider.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // final List<Map<String, String>> onboardingData = [
  //   {
  //     "image": Assets.assetsPortpro,
  //     "title": "Pickup & drop anywhere",
  //     "desc": "Choose your pickup & drop location from within the area which you require"
  //   },
  //   {
  //     "image": Assets.assetsPortpro,
  //     "title": "Fast & Secure",
  //     "desc": "Get your packages delivered quickly and safely at your doorstep."
  //   },
  //   {
  //     "image": Assets.assetsPortpro,
  //     "title": "24/7 Support",
  //     "desc": "We are here to help you anytime, anywhere with our service."
  //   },
  // ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onBoardingVm = Provider.of<OnBoardingViewModel>(context, listen: false);
      onBoardingVm.onBoardingApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final onBoarding = Provider.of<OnBoardingViewModel>(context);
    return Scaffold(
      backgroundColor: PortColor.bg,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: onBoarding.onBoardingModel?.data?.length,
              itemBuilder: (context, index) {
                final portOnBoarding = onBoarding.onBoardingModel?.data?[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      portOnBoarding?.imageUrl??"",
                      height: 250,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      textAlign: TextAlign.center,
                      portOnBoarding?.heading??"",
                      style:  TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.kanitReg,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        portOnBoarding?.subHeading??"",
                        textAlign: TextAlign.center,
                        style:  TextStyle(
                          fontSize: 11,
                          fontFamily: AppFonts.poppinsReg,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onBoarding.onBoardingModel?.data?.length ?? 0,
                  (index) => Container(
                margin: const EdgeInsets.all(4),
                width: _currentPage == index ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Continue with Phone action
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text("Continue with Phone"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.black12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    // Continue with Guest action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Continue with Guest"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
