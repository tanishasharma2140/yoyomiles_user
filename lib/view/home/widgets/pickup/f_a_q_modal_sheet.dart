import 'package:flutter/material.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';

class FAQModalSheet extends StatelessWidget {
  const FAQModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button floating
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Help',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ✅ Scrollable List of FAQs
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildSectionTitle('Service Overview'),
                _buildFAQItem(
                  'What is Packers and Movers?',
                  'Packers and Movers is a service that helps you relocate your belongings safely from one place to another. We handle packing, loading, transportation, unloading, and unpacking.',
                ),
                _buildFAQItem(
                  'What is the "Mini truck with 2 labor" option?',
                  'This option includes a mini truck for transportation and two laborers to help with loading and unloading your items. Perfect for small to medium moves.',
                ),
                _buildFAQItem(
                  'What makes Porter Packers and Movers different from others?',
                  'We offer transparent pricing, trained professionals, insurance coverage options, and a hassle-free moving experience with real-time tracking.',
                ),

                const SizedBox(height: 12),
                _buildSectionTitle('Inquiry and Pricing'),
                _buildFAQItem(
                  'How is the price calculated for my move?',
                  'Price is calculated based on distance, volume of items, additional services like packing and unpacking, and any special handling requirements.',
                ),
                _buildFAQItem(
                  'Do you offer house visits to provide estimates?',
                  'Yes, we offer free home visits to assess your moving needs and provide accurate estimates. You can also get instant quotes through our app.',
                ),

                const SizedBox(height: 12),
                _buildSectionTitle('Labor, Vehicle, and Packing Details'),
                _buildFAQItem(
                  'How many labourers are required for shifting?',
                  'The number of laborers depends on the volume of items. Typically, 2-3 laborers are sufficient for a 2BHK apartment. For larger homes, we recommend more help.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 12),
      child: TextConst(
        title:
        title,
         color: PortColor.button,
        fontFamily: AppFonts.kanitReg,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static Widget _buildFAQItem(String question, String answer) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
        title: TextConst(title:
          question,
            color: PortColor.gray,
          fontFamily: AppFonts.kanitReg,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
