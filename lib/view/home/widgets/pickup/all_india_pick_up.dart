import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
import 'package:port_karo/view/home/widgets/pickup/all_india_enter_pickup_detail.dart';

/// Replace with your Google Maps API Key
const String googleApiKey = "AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA";

class AllIndiaPickUp extends StatefulWidget {
  const AllIndiaPickUp({super.key});

  @override
  State<AllIndiaPickUp> createState() => _AllIndiaPickUpState();
}

class _AllIndiaPickUpState extends State<AllIndiaPickUp> {
  List<dynamic> searchResults = [];
  bool isLoading = false;

  Future<void> placeSearchApi(String searchCon) async {
    if (searchCon.isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    setState(() => isLoading = true);

    Uri uri = Uri.https("maps.googleapis.com", 'maps/api/place/autocomplete/json', {
      "input": searchCon,
      "key": googleApiKey,
      "components": "country:in",
    });

    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body)['predictions'];
        setState(() {
          searchResults = resData;
        });
      }
    } catch (e) {
      debugPrint("Error fetching places: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, double>> fetchLatLng(String placeId) async {
    Uri uri = Uri.https("maps.googleapis.com", 'maps/api/place/details/json', {
      "place_id": placeId,
      "key": googleApiKey,
    });

    var response = await http.get(uri);
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final location = result['result']['geometry']['location'];
      return {
        "lat": location['lat'],
        "lng": location['lng'],
      };
    } else {
      return {"lat": 0.0, "lng": 0.0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar:  CupertinoNavigationBar(
        middle: Text("Search Pickup Location",style: TextStyle(color: PortColor.blackLight,fontFamily: AppFonts.poppinsReg),),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ✅ Search field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                placeholder: "Search for pickup location...",
                onChanged: (value) => placeSearchApi(value),
              ),
            ),

            // ✅ Show loader or list
            if (isLoading)
              const Center(child: CupertinoActivityIndicator())
            else
              Expanded(
                child: Material(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final place = searchResults[index];
                      final description = place['description'];
                      final placeId = place['place_id'];

                      return ListTile(
                        leading:  Icon(Icons.location_on, color: PortColor.button),
                        title: TextConst(title:description,fontFamily: AppFonts.kanitReg,),
                        onTap: () async {
                          final coords = await fetchLatLng(placeId);

                          // ✅ Navigate to EnterPickupDetails
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => AllIndiaEnterPickupDetail(
                                location: description,
                                lat: coords["lat"]!,
                                lng: coords["lng"]!,
                              ),
                            ),
                          );
                        },

                      );
                    },
                  ),
                ),
              )

          ],
        ),
      ),
    );
  }
}
