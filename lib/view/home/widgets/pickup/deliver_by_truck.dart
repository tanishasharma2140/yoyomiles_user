import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view/home/widgets/pick_up_location.dart';
import 'package:yoyomiles/view/home/widgets/use_current_location.dart';
import 'package:yoyomiles/view/order/widgets/enter_contact_detail.dart';
import 'package:yoyomiles/view_model/order_view_model.dart';
import 'package:yoyomiles/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

class DeliverByTruck extends StatefulWidget {
  const DeliverByTruck({super.key});

  @override
  State<DeliverByTruck> createState() => _DeliverByTruckState();
}

class _DeliverByTruckState extends State<DeliverByTruck> {

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  bool hasData = false;
  List<dynamic> searchResults = [];
  Map<String, String> placeDetailsCache = {};
  String? selectedLocation;
  String? _currentAddress;
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {});

    _fetchAddress(position.latitude, position.longitude);

  }

  Future<void> _fetchAddress(double latitude, double longitude) async {
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    const String apiKey = 'AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      print('Response: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'];
          setState(() {
            _currentAddress = address;
          });
          final locationData = {
            "address": _currentAddress,
            "name": profileViewModel.profileModel?.data?.firstName ?? "",
            "phone": profileViewModel.profileModel?.data?.phone.toString() ?? "",
            "latitude": latitude,
            "longitude": longitude,
            "order_type": 1,
          };
          print('Location Data: $locationData');
          orderViewModel.setLocationType(0);
          orderViewModel.setLocationData(locationData);
          print('Updated Address: $_currentAddress');
        } else {
          print('No results found for the given coordinates.');
        }
      } else {
        print('Failed to fetch address. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderViewModel = Provider.of<OrderViewModel>(context);
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    // final orderType = orderViewModel.pickupData["order_type"] ?? "N/A";
    // final orderTime = orderViewModel.pickupData["order_time"] ?? "N/A";

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.grey,
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 25),
              height: screenHeight * 0.33,
              width: screenWidth,
              decoration: BoxDecoration(
                color: PortColor.white,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: PortColor.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: screenWidth * 0.04,
                              height: screenHeight * 0.01,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Column(
                              children: List.generate(
                                10,
                                (index) => Container(
                                  width: screenWidth * 0.005,
                                  height: screenHeight * 0.0025,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  color: PortColor.gray,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.location_on_rounded,
                              color: PortColor.red,
                              size: screenHeight * 0.024,
                            ),
                          ],
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        SizedBox(
                          width: screenWidth / 1.3,
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  orderViewModel.setLocationType(0);
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration: const Duration(milliseconds: 400),
                                      pageBuilder: (_, __, ___) => const PickUpLocation(),
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
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02,
                                      vertical: screenHeight * 0.015,
                                    ),
                                    width: screenWidth * 0.78,
                                    decoration: BoxDecoration(
                                      color: PortColor.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: PortColor.gray,
                                          width: screenWidth * 0.002),
                                    ),
                                    child: hasData
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  TextConst(
                                                    title: profileViewModel.profileModel!.data!.firstName??"",
                                                    color: PortColor.black,
                                                    fontFamily: AppFonts.kanitReg,
                                                    size: 12,
                                                  ),
                                                  SizedBox(width: screenWidth*0.03,),
                                                  TextConst(
                                                    title: ".${profileViewModel.profileModel!.data!.phone ?? ''}",
                                                    color: PortColor.gray,
                                                    fontFamily: AppFonts.kanitReg,
                                                    size: 12,
                                                  ),
                                                  const Spacer(),
                                                  Icon(
                                                    Icons
                                                        .arrow_forward_ios_rounded,
                                                    size: screenHeight * 0.017,
                                                  ),
                                                ],
                                              ),
                                              TextConst(
                                                title:
                                                    "SectorH, jankipuram, lucknow, uttar pradesh..",
                                                color: PortColor.black,
                                              ),
                                            ],
                                          )
                                        : (orderViewModel.pickupData != null
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      TextConst(
                                                        title: orderViewModel
                                                                    .pickupData[
                                                                "name"] ??
                                                            "N/A",
                                                        color: PortColor.black,
                                                        fontFamily: AppFonts.kanitReg,
                                                      ),
                                                      SizedBox(width: screenWidth*0.03,),
                                                      TextConst(
                                                        title: orderViewModel
                                                                    .pickupData[
                                                                "phone"] ??
                                                            "N/A",
                                                        color: PortColor.gray,
                                                        fontFamily: AppFonts.kanitReg,
                                                      ),
                                                      const Spacer(),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_ios_rounded,
                                                        size: screenHeight *
                                                            0.017,
                                                      ),
                                                    ],
                                                  ),
                                                  TextConst(
                                                    title: orderViewModel
                                                                .pickupData[
                                                            "address"] ??
                                                        "N/A",
                                                    color: PortColor.black,
                                                    fontFamily: AppFonts.kanitReg,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    size: 10,
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [

                                                ],
                                              ))),
                              ),
                              SizedBox(height: screenHeight * 0.018),
                              TextField(
                                onTap: () {
                                  orderViewModel.setLocationType(1);
                                },
                                onChanged: (value) {
                                  placeSearchApi(value);
                                },
                                decoration: InputDecoration(
                                  constraints: BoxConstraints(
                                      maxHeight: screenHeight * 0.055),
                                  hintText: "Where is your Drop?",
                                  hintStyle: TextStyle(
                                    color: PortColor.gray.withOpacity(0.5),
                                    fontSize: 15,
                                  ),
                                  // suffixIcon: const Icon(Icons.mic,
                                  //     color: PortColor.blue),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: PortColor.gray),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.black),
                                  ),
                                  filled: true,
                                  fillColor: PortColor.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Container(
                  //       decoration: const BoxDecoration(
                  //         color: PortColor.blue,
                  //         shape: BoxShape.circle,
                  //       ),
                  //       child: Icon(
                  //         Icons.add,
                  //         color: PortColor.white,
                  //         size: screenHeight * 0.02,
                  //       ),
                  //     ),
                  //     SizedBox(width: screenWidth * 0.02),
                  //     TextConst(title: "ADD STOP", color: PortColor.black),
                  //   ],
                  // ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.035),
            if (searchResults.isNotEmpty)
              Expanded(
                child: Container(
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
                  child:ListView.separated(
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
                              color: Colors.redAccent, // 🔴 You can use PortColor.blue if needed
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextConst(
                                title: place['description'],
                                color: PortColor.black.withOpacity(0.5),
                                fontFamily: AppFonts.kanitReg,
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
                              pageBuilder: (_, __, ___) => EnterContactDetail(
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
                      child: Divider(
                        color: PortColor.gray,
                        thickness: 0.5,
                      ),
                    ),
                  )
                
                
                ),
              ),

           // const Spacer(),

          ],
        ),
        // bottomSheet: GestureDetector(
        //   onTap: (){
        //     Navigator.push(
        //       context,
        //       PageRouteBuilder(
        //         transitionDuration: const Duration(milliseconds: 400),
        //         pageBuilder: (_, __, ___) =>  UseCurrentLocation(),
        //         transitionsBuilder: (_, animation, __, child) {
        //           final offsetAnimation = Tween<Offset>(
        //             begin: const Offset(0, 1), // start from bottom
        //             end: Offset.zero,          // end at normal position
        //           ).animate(CurvedAnimation(
        //             parent: animation,
        //             curve: Curves.easeOutCubic,
        //           ));
        //
        //           return SlideTransition(
        //             position: offsetAnimation,
        //             child: child,
        //           );
        //         },
        //       ),
        //     );
        //   },
        //   child: Container(
        //     height: screenHeight * 0.08,
        //     color: PortColor.white,
        //     padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         const Icon(Icons.location_on, color: PortColor.blue),
        //         TextConst(
        //             title: " Locate on the map", color: PortColor.black),
        //       ],
        //     ),
        //   ),
        // ),
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
