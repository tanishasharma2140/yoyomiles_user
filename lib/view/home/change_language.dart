import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles/controller/language_controller.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({super.key});

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.white,

        /// 🔹 APP BAR
        appBar: AppBar(
          backgroundColor: PortColor.gold,
          automaticallyImplyLeading: false,
          elevation: 0,
          leading: GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back,color: Colors.black,)),
          title: Text(
            "Select Language",
            style:  TextStyle(
              fontSize: 16,
              fontFamily: AppFonts.kanitReg,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
        ),

        /// 🔹 BODY
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<LanguageController>(
            builder: (context, languageProvider, child) {
              return Column(
                children: [

                  const SizedBox(height: 20),

                  /// ENGLISH OPTION
                  _buildLanguageCard(
                    title: "English",
                    subTitle: "English (United Kingdom)",
                    value: "en",
                    groupValue: languageProvider.currentLanguageCode,
                    onTap: () {
                      languageProvider.changeLanguage(
                        const Locale('en'),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  /// HINDI OPTION
                  _buildLanguageCard(
                    title: "हिंदी",
                    subTitle: "Hindi (भारत)",
                    value: "hi",
                    groupValue: languageProvider.currentLanguageCode,
                    onTap: () {
                      languageProvider.changeLanguage(
                        const Locale('hi'),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required String title,
    required String subTitle,
    required String value,
    required String groupValue,
    required VoidCallback onTap,
  }) {
    bool isSelected = value == groupValue;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? PortColor.gold.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? PortColor.gold : Colors.grey.shade300,
            width: 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: PortColor.gold.withOpacity(0.2),
                blurRadius: 10,
              )
          ],
        ),
        child: Row(
          children: [
            /// TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: AppFonts.kanitReg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subTitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontFamily: AppFonts.poppinsReg,
                    ),
                  ),
                ],
              ),
            ),

            /// RADIO STYLE INDICATOR
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? PortColor.gold : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: PortColor.gold,
                  ),
                ),
              )
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
