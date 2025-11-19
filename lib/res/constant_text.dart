import 'package:flutter/material.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';

class TextConst extends StatelessWidget {
  final String title;
  final double? size;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final String? fontFamily;
  final Color? color;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  const TextConst({
    super.key,
    required this.title,
    this.size,
    this.fontWeight,
    this.color,
    this.fontFamily,
    this.fontStyle,
    this.maxLines,
    this.textAlign,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: maxLines,
      overflow: overflow,
      // overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: textAlign ?? TextAlign.start,
      style: TextStyle(
        fontFamily: fontFamily ?? AppFonts.robotoReg,
        color: color ?? PortColor.black,
        fontSize: size ?? kDefaultFontSize,
        fontWeight: fontWeight ?? FontWeight.normal,
        fontStyle: fontStyle ?? FontStyle.normal,
      ),
    );
  }
}
