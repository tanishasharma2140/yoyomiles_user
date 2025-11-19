import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/res/custom_text_field.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view/home/add_item_screen.dart';
import 'package:yoyomiles/view/home/widgets/city_toggle.dart';
import 'package:yoyomiles/view/home/widgets/pickup/f_a_q_modal_sheet.dart';
import 'package:provider/provider.dart';

class DeliverByPackerMover extends StatefulWidget {
  const DeliverByPackerMover({super.key});

  @override
  State<DeliverByPackerMover> createState() => _DeliverByPackerMoverState();
}

class _DeliverByPackerMoverState extends State<DeliverByPackerMover> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController pickupFloorController = TextEditingController();
  final TextEditingController dropFloorController = TextEditingController();
  final FocusNode pickupFocus = FocusNode();
  final FocusNode dropFocus = FocusNode();

  List<dynamic> searchResults = [];
  bool isPickupActive = false;

  // SEPARATE LOADING VARIABLES
  bool isLoading = false; // For place search
  bool isCheckPriceLoading = false; // For check price button

  String selectedCity = "";
  String selectedDay = "";

  // Switch states
  bool pickupLiftAvailable = false;
  bool dropLiftAvailable = false;
  bool _isScrolling = false;

  // Step management
  int currentStep = 0; // 0: Moving details, 1: Add items, 2: Schedule

  // City toggle state - WITHIN CITY SELECTED BY DEFAULT
  bool isWithinCitySelected = true;
  bool isCityValidationLoading = false;

  @override
  void initState() {
    super.initState();

    pickupFocus.addListener(() {
      setState(() {
        isPickupActive = pickupFocus.hasFocus;
        searchResults.clear();
      });
    });

    dropFocus.addListener(() {
      setState(() {
        isPickupActive = !dropFocus.hasFocus ? true : false;
        searchResults.clear();
      });
    });
  }

  Future<void> placeSearchApi(String searchCon) async {
    if (searchCon.isEmpty) return;

    setState(() => isLoading = true);

    Uri uri =
    Uri.https("maps.googleapis.com", 'maps/api/place/autocomplete/json', {
      "input": selectedCity.isNotEmpty
          ? "$searchCon, $selectedCity"
          : searchCon,
      "key": "AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA",
      "components": "country:in",
    });

    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body)['predictions'];
        if (mounted) {
          setState(() {
            searchResults = resData;
          });
        }
      }
    } catch (e) {
      print("Error fetching places: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<LatLng> fetchLatLng(String placeId) async {
    Uri uri = Uri.https("maps.googleapis.com", 'maps/api/place/details/json', {
      "place_id": placeId,
      "key": "AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA",
    });

    var response = await http.get(uri);
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final location = result['result']['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    } else {
      return const LatLng(0.0, 0.0);
    }
  }

  // 🔹 Function to get lat-long from address
  Future<LatLng> fetchLatLngFromAddress(String address) async {
    if (address.isEmpty) return const LatLng(0.0, 0.0);

    const apiKey = "AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA";
    final encodedAddress = Uri.encodeComponent(address);
    final url = "https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data["status"] == "OK") {
        final location = data["results"][0]["geometry"]["location"];
        return LatLng(location['lat'], location['lng']);
      }
    } catch (e) {
      print("Geocoding error: $e");
    }
    return const LatLng(0.0, 0.0);
  }

  // 🔹 Function to calculate distance between two points using Haversine formula
  Future<double> calculateDistance(LatLng pickup, LatLng drop) async {
    double calculateHaversineDistance() {
      const double earthRadius = 6371; // in kilometers

      double dLat = _toRadians(drop.latitude - pickup.latitude);
      double dLng = _toRadians(drop.longitude - pickup.longitude);

      double a = sin(dLat / 2) * sin(dLat / 2) +
          cos(_toRadians(pickup.latitude)) *
              cos(_toRadians(drop.latitude)) *
              sin(dLng / 2) *
              sin(dLng / 2);

      double c = 2 * atan2(sqrt(a), sqrt(1 - a));
      return earthRadius * c;
    }

    double distance = calculateHaversineDistance();

    // Print distance for verification
    print("Calculated Distance: ${distance.toStringAsFixed(2)} km");

    return double.parse(distance.toStringAsFixed(2));
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Future<void> pickDate() async {
    DateTime today = DateTime.now();
    DateTime lastDate = today.add(const Duration(days: 7));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: PortColor.button,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: PortColor.button),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
        selectedDay = "";
      });
    }
  }

  void selectDay(String day) {
    DateTime today = DateTime.now();
    if (day == "Today") {
      dateController.text = "${today.day}/${today.month}/${today.year}";
    } else if (day == "Tomorrow") {
      final tomorrow = today.add(const Duration(days: 1));
      dateController.text =
      "${tomorrow.day}/${tomorrow.month}/${tomorrow.year}";
    }
    setState(() {
      selectedDay = day;
    });
  }

  // 🔹 Function to fetch city name from Google Geocoding API
  Future<String> _getCityFromAddress(String address) async {
    if (address.isEmpty) return "";

    const apiKey = "AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA";
    final encodedAddress = Uri.encodeComponent(address);
    final url = "https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data["status"] == "OK") {
        final components = data["results"][0]["address_components"] as List<dynamic>;

        for (var comp in components) {
          if ((comp["types"] as List).contains("locality")) {
            return comp["long_name"];
          }
        }

        // If locality not found, try administrative_area_level_2
        for (var comp in components) {
          if ((comp["types"] as List).contains("administrative_area_level_2")) {
            return comp["long_name"];
          }
        }
      }
    } catch (e) {
      print("Geocoding error: $e");
    }
    return "";
  }

  // 🔹 Function to validate city selection - SIMPLIFIED VERSION
  Future<bool> _validateCitySelection() async {
    // Check if locations are filled
    if (pickupController.text.isEmpty || dropController.text.isEmpty) {
      Utils.showErrorMessage(context, "Please enter both pickup and drop locations first.");
      return false;
    }

    // Check floor numbers if lift is not available
    if (!pickupLiftAvailable && pickupFloorController.text.isEmpty) {
      Utils.showErrorMessage(context, "Please enter pickup floor number");
      return false;
    }
    if (!dropLiftAvailable && dropFloorController.text.isEmpty) {
      Utils.showErrorMessage(context, "Please enter drop floor number");
      return false;
    }

    setState(() => isCityValidationLoading = true);

    final pickupCity = await _getCityFromAddress(pickupController.text);
    final dropCity = await _getCityFromAddress(dropController.text);

    setState(() => isCityValidationLoading = false);

    if (pickupCity.isEmpty || dropCity.isEmpty) {
      Utils.showErrorMessage(context, "Could not fetch city details. Please check the addresses and try again.");
      return false;
    }

    // 🔹 VALIDATE IF WITHIN CITY SERVICE IS POSSIBLE
    if (isWithinCitySelected) {
      if (pickupCity != dropCity) {
        Utils.showErrorMessage(context ,"Within City service is not available for different cities");
        return false;
      } else {
        Utils.showSuccessMessage(context, "Within City service confirmed! Both locations are in $pickupCity");
        return true;
      }
    } else {
      // Between Cities validation
      if (pickupCity == dropCity) {
        Utils.showErrorMessage(context, " Between Cities service is not available for same city.");
        return false;
      } else {
        Utils.showSuccessMessage(context, "Between Cities service confirmed! From $pickupCity to $dropCity");
        return true;
      }
    }
  }

  void _navigateToAddItemsScreen() async {
    // USE SEPARATE LOADING VARIABLE FOR CHECK PRICE
    setState(() => isCheckPriceLoading = true);

    // Small delay to show loader (optional)
    await Future.delayed(Duration(milliseconds: 50));

    try {
      // Fast validations
      if (pickupController.text.isEmpty || dropController.text.isEmpty) {
        Utils.showErrorMessage(context, "Please fill all required fields");
        setState(() => isCheckPriceLoading = false);
        return;
      }

      if (!pickupLiftAvailable && pickupFloorController.text.isEmpty) {
        Utils.showErrorMessage(context, "Please enter pickup floor number");
        setState(() => isCheckPriceLoading = false);
        return;
      }
      if (!dropLiftAvailable && dropFloorController.text.isEmpty) {
        Utils.showErrorMessage(context, "Please enter drop floor number");
        setState(() => isCheckPriceLoading = false);
        return;
      }

      // Validate city selection
      final isValidCity = await _validateCitySelection();
      if (!isValidCity) {
        setState(() => isCheckPriceLoading = false);
        return;
      }

      // Parallel API calls for better performance
      final Future<LatLng> pickupFuture = fetchLatLngFromAddress(pickupController.text);
      final Future<LatLng> dropFuture = fetchLatLngFromAddress(dropController.text);

      final results = await Future.wait([pickupFuture, dropFuture]);
      final pickupLatLng = results[0];
      final dropLatLng = results[1];

      // Calculate distance
      final distance = await calculateDistance(pickupLatLng, dropLatLng);

      // Prepare data
      final Map<String, dynamic> movingDetailsData = {
        'distance': distance,
        'pickup_point': {
          'has_lift': pickupLiftAvailable ? 1 : 0,
          'floors': pickupFloorController.text.isNotEmpty ? int.tryParse(pickupFloorController.text) ?? 0 : 0,
        },
        'drop_point': {
          'has_lift': dropLiftAvailable ? 1 : 0,
          'floors': dropFloorController.text.isNotEmpty ? int.tryParse(dropFloorController.text) ?? 0 : 0,
        },
        'pickup_address': pickupController.text,
        'drop_address': dropController.text,
        'pickup_lat': pickupLatLng.latitude,
        'pickup_lng': pickupLatLng.longitude,
        'drop_lat': dropLatLng.latitude,
        'drop_lng': dropLatLng.longitude,
        'service_type': isWithinCitySelected ? 1 : 2,
        'shifting_date': dateController.text,
      };

      _printMovingDetailsData(movingDetailsData);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddItemsScreen(
              movingDetailsData: movingDetailsData,
            ),
          ),
        );
      }

    } catch (e) {
      print("Error in navigation: $e");
      if (mounted) {
        Utils.showErrorMessage(context, "Something went wrong. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() => isCheckPriceLoading = false);
      }
    }
  }

// 🔹 Helper function to print data with null safety
  void _printMovingDetailsData(Map<String, dynamic> data) {
    print("═══════════════════════════════════════");
    print("SENDING DATA TO ADD ITEMS SCREEN:");
    print("Distance: ${data['distance'] ?? 'N/A'} km");

    // Safe access for nested maps
    final pickupPoint = data['pickup_point'] as Map<String, dynamic>? ?? {};
    final dropPoint = data['drop_point'] as Map<String, dynamic>? ?? {};

    print("Pickup Point - Lift: ${pickupPoint['has_lift'] ?? 'N/A'}, Floors: ${pickupPoint['floors'] ?? 'N/A'}");
    print("Drop Point - Lift: ${dropPoint['has_lift'] ?? 'N/A'}, Floors: ${dropPoint['floors'] ?? 'N/A'}");
    print("Pickup Location: ${data['pickup_address'] ?? 'N/A'}");
    print("Drop Location: ${data['drop_address'] ?? 'N/A'}");
    print("Pickup LatLng: ${data['pickup_lat'] ?? 'N/A'}, ${data['pickup_lng'] ?? 'N/A'}");
    print("Drop LatLng: ${data['drop_lat'] ?? 'N/A'}, ${data['drop_lng'] ?? 'N/A'}");
    print("Service Type Sent: ${isWithinCitySelected ? 1 : 2}");
    print("Shifting Date: ${data['shifting_date'] ?? 'N/A'}");
    print("═══════════════════════════════════════");
  }

  void updateCitySelection(bool isWithinCity) {
    setState(() {
      isWithinCitySelected = isWithinCity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.grey,
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: topPadding,),
                // Header + Steps
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.02,
                  ),
                  height: screenHeight * 0.17,
                  decoration: BoxDecoration(
                    color: PortColor.white,
                    border: Border(
                      bottom: BorderSide(
                        color: PortColor.gray,
                        width: screenWidth * 0.002,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: PortColor.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 30,
                              width: 30,
                              color: Colors.transparent,
                              child: Icon(
                                Icons.arrow_back,
                                color: PortColor.black,
                                size: screenHeight * 0.026,
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          TextConst(
                            title: "Packer and Mover",
                            color: PortColor.black,
                            fontWeight: FontWeight.w600,
                            size: 16,
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: (){
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return const FAQModalSheet();
                                },
                              );
                            },
                            child: TextConst(
                              title: "FAQs",
                              color: PortColor.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StepWidget(
                            icon: currentStep > 0
                                ? Icons.check
                                : Icons.location_on,
                            text: 'Moving details',
                            isActive: true,
                            isCompleted: currentStep > 0,
                          ),
                          const DottedLine(),
                          StepWidget(
                            icon: Icons.inventory,
                            text: 'Add items',
                            isActive: currentStep >= 1,
                            isCompleted: currentStep > 1,
                          ),
                          const DottedLine(),
                          StepWidget(
                            icon: Icons.receipt,
                            text: 'Schedule',
                            isActive: currentStep >= 2,
                            isCompleted: currentStep > 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // City Toggle
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: CityToggle(
                    pickupLocation: pickupController.text,
                    dropLocation: dropController.text,
                    onSelectionChanged: updateCitySelection,
                    initialSelection: isWithinCitySelected,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Pickup Field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: pickupController,
                        focusNode: pickupFocus,
                        textStyle: TextStyle(
                          color: Colors.black54,
                          fontFamily: AppFonts.kanitReg,
                          fontSize: 13,
                        ),
                        onChanged: (val) => placeSearchApi(val),
                        focusedBorder: PortColor.gold,
                        height: screenHeight * 0.055,
                        cursorHeight: screenHeight * 0.022,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green[800],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_upward_rounded,
                              color: PortColor.white,
                              size: screenHeight * 0.02,
                            ),
                          ),
                        ),
                        hintText: 'Pick up Location',
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontFamily: AppFonts.kanitReg,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      if (pickupController.text.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextConst(
                                title: "Service lift available at pickup",
                                color: PortColor.black.withOpacity(0.7),
                                fontFamily: AppFonts.kanitReg,
                                size: 13,
                              ),
                            ),
                            Switch(
                              value: pickupLiftAvailable,
                              activeColor: PortColor.button,
                              onChanged: (val) {
                                setState(() {
                                  pickupLiftAvailable = val;
                                });
                              },
                            ),
                          ],
                        ),
                      if (pickupController.text.isNotEmpty && !pickupLiftAvailable)
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.01),
                          child: CustomTextField(
                            controller: pickupFloorController,
                            textStyle: TextStyle(
                              color: Colors.black54,
                              fontFamily: AppFonts.kanitReg,
                              fontSize: 13,
                            ),
                            focusedBorder: PortColor.gold,
                            height: screenHeight * 0.055,
                            cursorHeight: screenHeight * 0.022,
                            prefixIcon: const Icon(Icons.stairs, size: 17),
                            hintText: 'Floor Number at Pickup',
                            hintStyle: TextStyle(
                              color: Colors.black54,
                              fontFamily: AppFonts.kanitReg,
                              fontSize: 13,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              if (val.isNotEmpty) {
                                int number = int.tryParse(val) ?? 0;

                                if (number < 1) {
                                  pickupFloorController.text = "1";
                                  pickupFloorController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: pickupFloorController.text.length),
                                  );
                                } else if (number > 15) {
                                  pickupFloorController.text = "15";
                                  pickupFloorController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: pickupFloorController.text.length),
                                  );
                                }
                              }
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

                // Drop Field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: dropController,
                        focusNode: dropFocus,
                        onChanged: (val) => placeSearchApi(val),
                        textStyle: TextStyle(
                          color: Colors.black54,
                          fontFamily: AppFonts.kanitReg,
                          fontSize: 13,
                        ),
                        focusedBorder: PortColor.gold,
                        height: screenHeight * 0.055,
                        cursorHeight: screenHeight * 0.022,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: PortColor.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_downward_rounded,
                              color: PortColor.white,
                              size: screenHeight * 0.02,
                            ),
                          ),
                        ),
                        hintText: 'Drop Location',
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontFamily: AppFonts.kanitReg,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      if (dropController.text.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextConst(
                                title: "Service lift available at drop",
                                color: PortColor.black.withOpacity(0.7),
                                fontFamily: AppFonts.kanitReg,
                                size: 13,
                              ),
                            ),
                            Switch(
                              value: dropLiftAvailable,
                              activeColor: PortColor.button,
                              onChanged: (val) {
                                setState(() {
                                  dropLiftAvailable = val;
                                });
                              },
                            ),
                          ],
                        ),
                      // 🔹 Floor Number Field for Drop (shown when lift is OFF)
                      if (dropController.text.isNotEmpty && !dropLiftAvailable)
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.01),
                          child: CustomTextField(
                            controller: dropFloorController,
                            textStyle: TextStyle(
                              color: Colors.black54,
                              fontFamily: AppFonts.kanitReg,
                              fontSize: 13,
                            ),
                            focusedBorder: PortColor.gold,
                            height: screenHeight * 0.055,
                            cursorHeight: screenHeight * 0.022,
                            prefixIcon: const Icon(Icons.stairs, size: 17),
                            hintText: 'Floor Number at Drop',
                            hintStyle: TextStyle(
                              color: Colors.black54,
                              fontFamily: AppFonts.kanitReg,
                              fontSize: 13,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              if (val.isNotEmpty) {
                                int number = int.tryParse(val) ?? 0;
                                if (number < 1) {
                                  dropFloorController.text = "1";
                                  dropFloorController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: dropFloorController.text.length),
                                  );
                                } else if (number > 15) {
                                  dropFloorController.text = "15";
                                  dropFloorController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: dropFloorController.text.length),
                                  );
                                }
                              }
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

              ],
            ),

            // Suggestions overlay - USE SEPARATE LOADING VARIABLE
            if (searchResults.isNotEmpty || isLoading)
              Positioned(
                top: isPickupActive ? screenHeight * 0.34 : screenHeight * 0.43,
                left: screenWidth * 0.04,
                right: screenWidth * 0.04,
                child: Container(
                  height: screenHeight * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: isLoading
                      ?  Center(child: CircularProgressIndicator(color: PortColor.gold,))
                      : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final place = searchResults[index];
                      return Column(
                        children: [
                          ListTile(
                            title: TextConst(
                              title: place['description'],
                              color: PortColor.black.withOpacity(0.7),
                            ),
                            onTap: () async {
                              LatLng latLng = await fetchLatLng(
                                place['place_id'],
                              );
                              setState(() {
                                if (isPickupActive) {
                                  pickupController.text = place['description'];
                                } else {
                                  dropController.text = place['description'];
                                }
                                searchResults.clear();
                              });
                              print("Selected: ${place['description']} - $latLng");
                            },
                          ),
                          if (index < searchResults.length - 1)
                            Divider(
                              color: PortColor.gray,
                              thickness: 0.5,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
        bottomSheet: Container(
          height: screenHeight * 0.1,
          color: PortColor.white,
          child: Center(
            child: GestureDetector(
              // USE SEPARATE LOADING VARIABLE FOR CHECK PRICE
              onTap: isCheckPriceLoading ? null : _navigateToAddItemsScreen,
              child: Container(
                width: screenWidth * 0.9,
                padding: EdgeInsets.symmetric(
                  horizontal: screenHeight * 0.009,
                  vertical: screenHeight * 0.014,
                ),
                decoration: BoxDecoration(
                  // USE SEPARATE LOADING VARIABLE FOR CHECK PRICE
                  color: (pickupController.text.isNotEmpty &&
                      dropController.text.isNotEmpty &&
                      !isCheckPriceLoading)
                      ? PortColor.button
                      : PortColor.gray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: isCheckPriceLoading // USE SEPARATE VARIABLE
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PortColor.black,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Processing...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PortColor.black,
                        fontSize: 14,
                        fontFamily: AppFonts.kanitReg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
                    : Text(
                  'Check Price',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: (pickupController.text.isNotEmpty &&
                        dropController.text.isNotEmpty)
                        ? Colors.black
                        : PortColor.black.withOpacity(0.5),
                    fontSize: 14,
                    fontFamily: AppFonts.kanitReg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),

      ),

    );
  }
}

class StepWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isActive;
  final bool isCompleted;

  const StepWidget({
    super.key,
    required this.icon,
    required this.text,
    required this.isActive,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? PortColor.button : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isActive ? Colors.white : Colors.grey,
            size: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 10,
            fontFamily: AppFonts.kanitReg,
          ),
        ),
      ],
    );
  }
}

/// DottedLine
class DottedLine extends StatelessWidget {
  final int dotCount;
  final double dotWidth;
  final double dotHeight;
  final double spacing;

  const DottedLine({
    super.key,
    this.dotCount = 16,
    this.dotWidth = 2,
    this.dotHeight = 1,
    this.spacing = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotCount, (index) {
        return Container(
          width: dotWidth,
          height: dotHeight,
          color: PortColor.gray,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
        );
      }),
    );
  }
}