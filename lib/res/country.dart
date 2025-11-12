import 'package:flutter/material.dart';
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/constant_color.dart';

import 'constant_text.dart';

class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flagAsset;

  Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flagAsset,
  });
}

class CountrySelectionDialog extends StatelessWidget {
  final List<Country> countries;
  final Function(Country) onCountrySelected;

  const CountrySelectionDialog({
    super.key,
    required this.countries,
    required this.onCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextConst(
                  title:
                  "Select Country / Region",
                   color: PortColor.black,
                  fontFamily: AppFonts.kanitReg,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero, // Remove list padding
                  shrinkWrap: true,
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    final country = countries[index];
                    return Container(
                      // Reduce height constraint if needed
                      constraints: BoxConstraints(
                        minHeight: 48, // Reduced minimum height
                      ),
                      child: ListTile(
                        dense: true, // Reduce tile density (less padding)
                        visualDensity: VisualDensity.compact, // Compact visual density
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Reduced padding
                        leading: Image.asset(
                          country.flagAsset,
                          width: 24,
                          height: 24,
                        ),
                        title: TextConst(
                          title:
                          country.name,
                           fontFamily: AppFonts.kanitReg,
                          color: PortColor.blackLight,
                        ),
                        subtitle: TextConst(
                          title:
                          country.dialCode,
                         fontFamily: AppFonts.poppinsReg,
                            color: Colors.grey[600],
                            size: 12, // Slightly smaller font

                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          onCountrySelected(country);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}