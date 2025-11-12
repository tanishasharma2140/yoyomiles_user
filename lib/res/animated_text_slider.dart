import 'package:flutter/material.dart';
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';

class AnimatedTextSlider extends StatefulWidget {
  const AnimatedTextSlider({super.key});

  @override
  State<AnimatedTextSlider> createState() => _AnimatedTextSliderState();
}

class _AnimatedTextSliderState extends State<AnimatedTextSlider> {
  final PageController _controller = PageController();
  final List<String> _texts = [
    "Introducing Yoyomiles Enterprise",
    "Safety ki shart Lagi!",
    "Introducing Loading unloading",
  ];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // 🔹 Auto-slide every 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), _autoSlide);
  }

  void _autoSlide() {
    if (!mounted) return;

    setState(() {
      _currentPage = (_currentPage + 1) % _texts.length;
    });


    _controller.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    // Repeat after 3 seconds
    Future.delayed(const Duration(seconds: 3), _autoSlide);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🔹 Text Slider
        SizedBox(
          height: 25,
          child: PageView.builder(
            controller: _controller,
            itemCount: _texts.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Center(
                child: AnimatedOpacity(
                  opacity: _currentPage == index ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: TextConst(
                    title: _texts[index],
                    fontFamily: AppFonts.kanitReg,
                    color: PortColor.blackLight,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 5),

        // 🔹 Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_texts.length, (index) {
            bool isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? PortColor.blackLight : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
