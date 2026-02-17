import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';

class AnimatedTextSlider extends StatefulWidget {
  const AnimatedTextSlider({super.key});

  @override
  State<AnimatedTextSlider> createState() => _AnimatedTextSliderState();
}

class _AnimatedTextSliderState extends State<AnimatedTextSlider> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Auto slide every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;

      setState(() {
        _currentPage++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final texts = [
      loc.introduce_yoyo,
      loc.safety_ki_shart,
      loc.introduce_load_unload,
    ];

    // Reset page if overflow
    if (_currentPage >= texts.length) {
      _currentPage = 0;
    }

    // Animate to page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// 🔹 Text Slider
        SizedBox(
          height: 25,
          child: PageView.builder(
            controller: _controller,
            itemCount: texts.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Center(
                child: AnimatedOpacity(
                  opacity: _currentPage == index ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: TextConst(
                    title: texts[index],
                    fontFamily: AppFonts.kanitReg,
                    color: PortColor.blackLight,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 6),

        /// 🔹 Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(texts.length, (index) {
            bool isActive = _currentPage == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 12 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? PortColor.blackLight
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }
}
