import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/res/custom_text_field.dart';
import 'package:yoyomiles/view/home/widgets/city_toggle.dart';

class PackerMover extends StatefulWidget {
  const PackerMover({super.key});

  @override
  State<PackerMover> createState() => _PackerMoverState();
}

class _PackerMoverState extends State<PackerMover> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropController = TextEditingController();
  final FocusNode pickupFocus = FocusNode();
  final FocusNode dropFocus = FocusNode();

  List<dynamic> searchResults = [];
  bool isPickupActive = false;
  bool isLoading = false; // loader

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
    setState(() => isLoading = true); // start loader
    Uri uri = Uri.https("maps.googleapis.com", 'maps/api/place/autocomplete/json', {
      "input": searchCon,
      "key": "AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM", // replace with your API key
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
      if (mounted) setState(() => isLoading = false); // stop loader
    }
  }

  Future<LatLng> fetchLatLng(String placeId) async {
    Uri uri = Uri.https("maps.googleapis.com", 'maps/api/place/details/json', {
      "place_id": placeId,
      "key": "AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM",
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
                Container(
                  height: screenHeight * 0.07,
                  width: screenWidth,
                  color: PortColor.white,
                  child: Row(
                    children: [
                      SizedBox(width: screenWidth * 0.3),
                      TextConst(
                        title: "Packer and Mover",
                        color: PortColor.black,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Image(
                          image: AssetImage(Assets.assetsCrossicon),
                        ),
                      ),
                    ],
                  ),
                ),

                /// Step Widget Section
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.02),
                  height: screenHeight * 0.17,
                  decoration: BoxDecoration(
                    color: PortColor.white,
                    border: Border(
                      bottom: BorderSide(
                          color: PortColor.gray, width: screenWidth * 0.002),
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
                          Icon(Icons.arrow_back,
                              color: PortColor.black,
                              size: screenHeight * 0.02),
                          SizedBox(width: screenWidth * 0.02),
                          TextConst(
                              title: "Packer and Mover",
                              color: PortColor.black),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          StepWidget(
                              icon: Icons.location_on,
                              TextConst: 'Moving details',
                              isActive: true),
                          DottedLine(),
                          StepWidget(
                              icon: Icons.inventory,
                              TextConst: 'Add items',
                              isActive: false),
                          DottedLine(),
                          StepWidget(
                              icon: Icons.add_box,
                              TextConst: 'Add ons',
                              isActive: false),
                          DottedLine(),
                          StepWidget(
                              icon: Icons.receipt,
                              TextConst: 'Review',
                              isActive: false),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: CityToggle(
                    pickupLocation: pickupController.text,
                    dropLocation: dropController.text,
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                /// Pick up field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: CustomTextField(
                    controller: pickupController,
                    focusNode: pickupFocus,
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        placeSearchApi(val);
                      } else {
                        setState(() => searchResults.clear());
                      }
                    },
                    focusedBorder: PortColor.buttonBlue,
                    height: screenHeight * 0.055,
                    cursorHeight: screenHeight * 0.022,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[800],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_upward_rounded,
                            color: PortColor.white, size: screenHeight * 0.02),
                      ),
                    ),
                    hintText: 'Pick up Location',
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                /// Drop field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: CustomTextField(
                    controller: dropController,
                    focusNode: dropFocus,
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        placeSearchApi(val);
                      } else {
                        setState(() => searchResults.clear());
                      }
                    },
                    focusedBorder: PortColor.buttonBlue,
                    height: screenHeight * 0.055,
                    cursorHeight: screenHeight * 0.022,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: PortColor.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_downward_rounded,
                            color: PortColor.white, size: screenHeight * 0.02),
                      ),
                    ),
                    hintText: 'Drop Location',
                  ),
                ),
              ],
            ),

            /// Suggestions List or Loader
            if (searchResults.isNotEmpty || isLoading)
              Positioned(
                top: isPickupActive ? screenHeight * 0.27 : screenHeight * 0.37,
                left: 0,
                right: 0,
                child: Container(
                  height: screenHeight * 0.25,
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
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
                              String placeId = place['place_id'];
                              LatLng latLng = await fetchLatLng(placeId);

                              setState(() {
                                if (isPickupActive) {
                                  pickupController.text = place['description'];
                                } else {
                                  dropController.text = place['description'];
                                }
                                searchResults.clear();
                              });

                              print("Selected: ${place['description']}");
                              print("LatLng: $latLng");
                            },
                          ),
                          if (index < searchResults.length - 1)
                            Divider(color: PortColor.gray, thickness: 0.5),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class StepWidget extends StatelessWidget {
  final IconData icon;
  final String TextConst;
  final bool isActive;

  const StepWidget({
    required this.icon,
    required this.TextConst,
    required this.isActive,
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
            icon,
            color: isActive ? Colors.white : Colors.grey,
            size: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          TextConst,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class DottedLine extends StatelessWidget {
  const DottedLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(10, (index) {
        return Container(
          width: 0.9,
          height: 1,
          color: PortColor.gray,
          margin: const EdgeInsets.symmetric(horizontal: 2),
        );
      }),
    );
  }
}
