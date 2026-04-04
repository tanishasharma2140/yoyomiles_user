import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';


class StopSearchResult {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String fullAddress;

  StopSearchResult({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullAddress,
  });
}

class StopDetails {
  final String address;
  final double latitude;
  final double longitude;

  StopDetails({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}


class StopSearchPage extends StatefulWidget {
  final int stopNumber;

  const StopSearchPage({super.key, required this.stopNumber});

  @override
  State<StopSearchPage> createState() => _StopSearchPageState();
}

class _StopSearchPageState extends State<StopSearchPage> {
  static const String _apiKey = "AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM";

  final TextEditingController _searchController = TextEditingController();
  List<StopSearchResult> _suggestions = [];
  bool _isLoading = false;
  String _sessionToken = '';

  @override
  void initState() {
    super.initState();
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.length >= 2) {
      _fetchSuggestions(query);
    } else {
      setState(() => _suggestions = []);
    }
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(query)}'
          '&key=$_apiKey'
          '&sessiontoken=$_sessionToken'
          '&language=en'
          '&components=country:in',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          setState(() {
            _suggestions = predictions.map((p) {
              final structured = p['structured_formatting'];
              return StopSearchResult(
                placeId: p['place_id'],
                mainText: structured['main_text'] ?? '',
                secondaryText: structured['secondary_text'] ?? '',
                fullAddress: p['description'] ?? '',
              );
            }).toList();
          });
        } else {
          setState(() => _suggestions = []);
        }
      }
    } catch (e) {
      debugPrint('Autocomplete error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<StopDetails?> _fetchPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=geometry,formatted_address'
          '&key=$_apiKey'
          '&sessiontoken=$_sessionToken',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final address = data['result']['formatted_address'];
          return StopDetails(
            address: address,
            latitude: location['lat'],
            longitude: location['lng'],
          );
        }
      }
    } catch (e) {
      debugPrint('Place details error: $e');
    }
    return null;
  }

  // ── Location selected → fetch details → show Name/Phone bottom sheet ──
  Future<void> _onSuggestionTap(StopSearchResult result) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: PortColor.gold),
      ),
    );

    final details = await _fetchPlaceDetails(result.placeId);
    if (mounted) Navigator.pop(context); // close loader

    if (details == null || !mounted) return;

    // Show bottom sheet to collect Name + Phone
    _showContactBottomSheet(
      locationName: result.mainText,
      details: details,
    );
  }

  // ── Bottom Sheet: Name + Phone ─────────────────
  void _showContactBottomSheet({
    required String locationName,
    required StopDetails details,
  }) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final loc = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          // Push sheet up when keyboard appears
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration:  BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.025,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Handle bar ──
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // ── Title ──
                  Text(
                    'Stop ${widget.stopNumber} ${loc.detail}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppFonts.kanitReg,
                      color: PortColor.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),

                  // ── Selected location chip ──
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 16),
                      SizedBox(width: screenWidth * 0.015),
                      Expanded(
                        child: Text(
                          locationName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontFamily: AppFonts.poppinsReg,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.025),

                  // ── Name field ──
                  Text(
                    loc.receiver_name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.kanitReg,
                      color: PortColor.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      fontFamily: AppFonts.poppinsReg,
                      fontSize: 14,
                    ),
                    decoration: _inputDecoration(
                      hint: loc.enter_receiver_name,
                      icon: Icons.person_outline,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return loc.please_enter_name;
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: screenHeight * 0.018),

                  // ── Phone field ──
                  Text(
                    loc.receiver_mob_no,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.kanitReg,
                      color: PortColor.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: TextStyle(
                      fontFamily: AppFonts.poppinsReg,
                      fontSize: 14,
                    ),
                    decoration: _inputDecoration(
                      hint: loc.enter_ten_digit_mob,
                      icon: Icons.phone_outlined,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return loc.please_enter_valid;
                      }
                      if (v.trim().length != 10) {
                        return loc.phone_number_must_be;
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // ── Confirm button ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(ctx); // close bottom sheet
                          Navigator.pop(context, {
                            'address': details.address,
                            'latitude': details.latitude,
                            'longitude': details.longitude,
                            'name': nameController.text.trim(),
                            'phone': phoneController.text.trim(),
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PortColor.gold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.018,
                        ),
                      ),
                      child: Text(
                        loc.confirm_slot,
                        style: TextStyle(
                          color: PortColor.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.kanitReg,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontFamily: AppFonts.poppinsReg,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: PortColor.gold, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: PortColor.blue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  // ── Build ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.bg,
        body: Column(
          children: [
            // ── Top Bar ──
            Container(
              color: PortColor.white,
              padding: EdgeInsets.only(top: screenHeight * 0.055),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.008,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            '${loc.add_stops} ${widget.stopNumber}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.kanitReg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Search Field ──
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: TextStyle(
                          fontFamily: AppFonts.poppinsReg,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText:
                          '${loc.search_location_for_stop} ${widget.stopNumber}...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontFamily: AppFonts.poppinsReg,
                            fontSize: 13,
                          ),
                          prefixIcon:
                          const Icon(Icons.search, color: PortColor.gold),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _suggestions = []);
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                ],
              ),
            ),

            // ── Results List ──
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: PortColor.blue),
              )
                  : _suggestions.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_searching_outlined,
                      size: 60,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      _searchController.text.isEmpty
                          ? loc.type_to_search
                          : loc.no_result_found,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontFamily: AppFonts.poppinsReg,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.01),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: screenWidth * 0.16,
                  color: Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final result = _suggestions[index];
                  return ListTile(
                    onTap: () => _onSuggestionTap(result),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: PortColor.gold.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on,
                          color: PortColor.gold, size: 20),
                    ),
                    title: Text(
                      result.mainText,
                      style: TextStyle(
                        fontFamily: AppFonts.kanitReg,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      result.secondaryText,
                      style: TextStyle(
                        fontFamily: AppFonts.poppinsReg,
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey.shade400,
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