import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view/home/sender_address.dart';
import 'package:yoyomiles/view/home/widgets/use_current_location.dart';
import 'package:http/http.dart' as http;

class PickUpLocation extends StatefulWidget {
  const PickUpLocation({super.key});

  @override
  State<PickUpLocation> createState() => _PickUpLocationState();
}

class _PickUpLocationState extends State<PickUpLocation> {
  List<dynamic> searchResults = [];
  Map<String, String> placeDetailsCache = {};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.bg,
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.03,
              ),
              height: screenHeight * 0.2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.025),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      size: screenHeight * 0.03,
                      color: PortColor.black.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Container(
                        width: screenWidth * 0.03,
                        height: screenHeight * 0.01,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.047),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            placeSearchApi(value);
                          },
                          decoration: InputDecoration(
                            constraints: BoxConstraints(
                              maxHeight: screenHeight * 0.055,
                            ),
                            hintText: "Where is your pickup?",
                            hintStyle: TextStyle(
                              color: PortColor.gray.withOpacity(0.5),
                              fontFamily: AppFonts.kanitReg,
                              fontSize: 15,
                            ),
                            // suffixIcon: const Icon(
                            //   Icons.mic,
                            //   color: PortColor.blue,
                            // ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: PortColor.gray,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            filled: true,
                            fillColor: PortColor.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            if (searchResults.isNotEmpty)
              Container(
                height: screenHeight * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.separated(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final place = searchResults[index];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                      ),
                      title: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextConst(
                              title: place['description'],
                              color: PortColor.black.withOpacity(0.5),
                              fontFamily: AppFonts.kanitReg,
                              size: 12,
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {
                        String placeId = place['place_id'];
                        LatLng latLng = await fetchLatLng(placeId);
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 400),
                            pageBuilder: (_, __, ___) => SenderAddress(
                              selectedLocation: place['description'],
                              selectedLatLng: latLng,
                            ),
                            transitionsBuilder: (_, animation, __, child) {
                              final offsetAnimation = Tween<Offset>(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ));

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Divider(color: Colors.grey.shade300, thickness: 0.5),
                  ),
                )

              ),
            const Spacer(),
            Container(
              height: screenHeight * 0.08,
              color: PortColor.white,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 400),
                          pageBuilder: (_, __, ___) => const UseCurrentLocation(),
                          transitionsBuilder: (_, animation, __, child) {
                            final offsetAnimation = Tween<Offset>(
                              begin: const Offset(0, 1), // start from bottom
                              end: Offset.zero,          // end at normal position
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ));

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 45,
                      width: 160,
                      child:  Row(
                        children: [
                          const Icon(
                            Icons.my_location_outlined,
                            color: PortColor.blue,
                            size: 15,
                          ),
                          TextConst(
                            title: " Use current location",
                            color: PortColor.black,
                            fontFamily: AppFonts.kanitReg,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),


                  // SizedBox(width: screenWidth * 0.04),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.01,
                    ),
                    child: VerticalDivider(
                      color: PortColor.gray.withOpacity(0.5),
                      thickness: screenWidth * 0.002,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 400),
                          pageBuilder: (_, __, ___) => const UseCurrentLocation(),
                          transitionsBuilder: (_, animation, __, child) {
                            final offsetAnimation = Tween<Offset>(
                              begin: const Offset(0, 1), // start from bottom
                              end: Offset.zero,          // end at normal position
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ));

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 45,
                      width: 160,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: PortColor.blue,
                            size: 15,
                          ),
                          TextConst(
                            title: " Locate on the map",
                            color: PortColor.black,
                            fontFamily: AppFonts.kanitReg,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> placeSearchApi(String searchCon) async {
    Uri uri =
        Uri.https("maps.googleapis.com", 'maps/api/place/autocomplete/json', {
          "input": searchCon,
          "key": "AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM",
          "components": "country:in",
        });
    var response = await http.get(uri);
    print(response.body);
    print("hello");
    if (response.statusCode == 200) {
      final resData = jsonDecode(response.body)['predictions'];
      if (resData != null) {
        setState(() {
          searchResults = resData;
        });
      }
    } else {
      print('Error fetching suggestions: ${response.body}');
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
      print('Error fetching location details: ${response.body}');
      return const LatLng(0.0, 0.0); // Default fallback
    }
  }
}
