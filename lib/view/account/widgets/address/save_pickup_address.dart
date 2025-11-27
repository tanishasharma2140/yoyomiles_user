import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view/account/widgets/address/save_pick_up_address_detail.dart';
import 'package:yoyomiles/view/home/widgets/use_current_location.dart';
import 'package:http/http.dart'as http;

class SavePickUpAddress extends StatefulWidget {
  const SavePickUpAddress({super.key});

  @override
  State<SavePickUpAddress> createState() => _SavePickUpAddressState();
}

class _SavePickUpAddressState extends State<SavePickUpAddress> {
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
              padding:  EdgeInsets.symmetric(horizontal:screenWidth*0.06, vertical: screenHeight*0.02),
              height: screenHeight * 0.18,
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
                  SizedBox(
                    height: screenHeight * 0.025,
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        size: screenHeight * 0.03,
                        color: PortColor.black.withOpacity(0.7),
                      )),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Row(
                    children: [
                      Container(
                        width: screenWidth * 0.03,
                        height: screenHeight * 0.01,
                        decoration: const BoxDecoration(
                          color: PortColor.gold,
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
                            constraints: BoxConstraints(maxHeight: screenHeight * 0.055),
                            hintText: "Where is your pickup?",
                            hintStyle: TextStyle(
                              color: PortColor.gray.withOpacity(0.5),
                              fontFamily: AppFonts.kanitReg,
                              fontSize: 15,
                            ),
                            // suffixIcon: const Icon(Icons.mic, color: PortColor.gold),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: PortColor.gray),
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
            SizedBox(
              height: screenHeight * 0.02,
            ),
            if (searchResults.isNotEmpty)
              SizedBox(
                height: screenHeight * 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final place = searchResults[index];
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                            ),
                            title: TextConst(
                              title: place['description'],
                              color: PortColor.black.withOpacity(0.5),
                              fontFamily: AppFonts.kanitReg,
                              size: 12,
                            ),
                            onTap: () async {
                              String placeId = place['place_id'];
                              LatLng latLng = await fetchLatLng(placeId);
                              print(latLng);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SavePickUpAddressDetail(
                                    selectedLocation: place['description'],
                                    selectedLatLng: latLng,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (index < searchResults.length - 1)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                              child: Divider(
                                color: PortColor.gray,
                                thickness: screenWidth * 0.002,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),

            if (searchResults.isEmpty)
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.02),
                height: screenHeight * 0.18,
                color: PortColor.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConst(
                      title: "Recent Pickups",
                      color: PortColor.gray,
                      fontFamily: AppFonts.kanitReg,
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.watch_later_outlined,
                          color: PortColor.black.withOpacity(0.6),
                          size: screenHeight * 0.028,
                        ),
                        SizedBox(
                          width: screenWidth * 0.04,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextConst(
                                title: "Sector H",
                                fontFamily: AppFonts.poppinsReg,
                                color: PortColor.black.withOpacity(0.6)),
                            TextConst(
                                title:
                                "Jankipuram,lucknow,UttarPradesh 2260..\nPrachi Singh 3213456787",
                                fontFamily: AppFonts.poppinsReg,
                                color: PortColor.gray)
                          ],
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            Icon(
                              Icons.favorite_border_sharp,
                              color: PortColor.black.withOpacity(0.6),
                              size: screenHeight * 0.025,
                            ),
                            TextConst(
                                title: "Save",
                                color: PortColor.black.withOpacity(0.6), fontFamily: AppFonts.poppinsReg,)
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            const Spacer(),
            Container(
              height: screenHeight * 0.08,
              color: PortColor.white,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(Icons.my_location_outlined, color: PortColor.gold,size: 16,),
                  InkWell(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UseCurrentLocation(),
                          ),
                        );
                      },
                      child: TextConst(title: " Use current location", color: PortColor.black, fontFamily: AppFonts.poppinsReg,size: 13,),),
                  // SizedBox(width: screenWidth * 0.04),

                  Padding(
                    padding:  EdgeInsets.symmetric(vertical: screenHeight*0.02),
                    child: VerticalDivider(
                      color: PortColor.gray.withOpacity(0.5),
                      thickness: screenWidth*0.002,
                    ),
                  ),

                  const Icon(Icons.location_on, color: PortColor.gold,size: 16,),
                  InkWell(
                      onTap: (){

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UseCurrentLocation(),
                          ),
                        );
                      },
                      child: TextConst(title: " Locate on the map", color: PortColor.black, fontFamily: AppFonts.poppinsReg,size: 13,)),
                ],
              ),
            )
          ])),
    );
  }
  Future<void> placeSearchApi(String searchCon) async {
    Uri uri = Uri.https("maps.googleapis.com", 'maps/api/place/autocomplete/json', {
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
