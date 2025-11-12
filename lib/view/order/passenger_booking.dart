import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:port_karo/main.dart';
import 'package:port_karo/res/app_btn.dart';
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
import 'package:port_karo/view/driver_searching/ride_map_screen.dart';
import 'package:port_karo/view_model/order_view_model.dart';
import 'package:port_karo/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

class PassengerBooking extends StatefulWidget {
  const PassengerBooking({super.key});

  @override
  State<PassengerBooking> createState() => _PassengerBookingState();
}

class _PassengerBookingState extends State<PassengerBooking> {
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadSearchHistory();
  }

  bool hasData = false;
  List<dynamic> searchResults = [];
  String? _currentAddress;
  bool isSearchingPickup = false;
  bool isSearchingDrop = false;
  TextEditingController pickupController = TextEditingController();
  TextEditingController dropController = TextEditingController();

  // Separate coordinates storage
  double? pickupLat;
  double? pickupLng;
  double? dropLat;
  double? dropLng;

  // Search history to show in popular locations
  List<Map<String, String>> searchHistory = [];

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
    _fetchAddress(position.latitude, position.longitude);
  }

  Future<void> _fetchAddress(double latitude, double longitude) async {
    const String apiKey = 'AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'];
          setState(() {
            _currentAddress = address;
          });
          pickupController.text = _currentAddress ?? "";
          // Set current location as pickup coordinates
          pickupLat = latitude;
          pickupLng = longitude;
        }
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
  }

  // Load search history from shared preferences or local storage
  void _loadSearchHistory() {
    // For now, using empty list. You can implement shared preferences here
    setState(() {
      searchHistory = [];
    });
  }

  // Save to search history
  void _saveToSearchHistory(String name, String address) {
    // Avoid duplicates
    if (!searchHistory.any((item) => item['name'] == name)) {
      setState(() {
        searchHistory.insert(0, {
          'name': name,
          'address': address,
        });

        // Keep only last 10 searches
        if (searchHistory.length > 10) {
          searchHistory = searchHistory.sublist(0, 10);
        }
      });
    }
  }

  void _onLocationSelected(String location, bool isPickup) async {
    if (isPickup) {
      setState(() {
        pickupController.text = location;
      });
      // Get coordinates for pickup location
      LatLng? coordinates = await fetchLatLngFromAddress(location);
      if (coordinates != null) {
        pickupLat = coordinates.latitude;
        pickupLng = coordinates.longitude;
        print("📍 Pickup Coordinates - Lat: $pickupLat, Lng: $pickupLng");
      }
    } else {
      setState(() {
        dropController.text = location;
      });
      // Get coordinates for drop location
      LatLng? coordinates = await fetchLatLngFromAddress(location);
      if (coordinates != null) {
        dropLat = coordinates.latitude;
        dropLng = coordinates.longitude;
        print("📍 Drop Coordinates - Lat: $dropLat, Lng: $dropLng");
      }
    }
    searchResults.clear();

    // Save to search history
    _saveToSearchHistory(location, location);
  }

  // Get LatLng from address
  Future<LatLng?> fetchLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print('Error converting address to LatLng: $e');
    }
    return null;
  }

  // Navigate to map screen
  void _proceedToMapScreen() {
    if (dropController.text.isNotEmpty && pickupController.text.isNotEmpty) {
      print("Proceed button pressed");
      print("Pickup: ${pickupController.text}");
      print("Drop: ${dropController.text}");
      print("Pickup Coordinates - Lat: $pickupLat, Lng: $pickupLng");
      print("Drop Coordinates - Lat: $dropLat, Lng: $dropLng");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RideMapScreen(
            pickupLocation: pickupController.text,
            dropLocation: dropController.text,
            pickupLat: pickupLat,
            pickupLng: pickupLng,
            dropLat: dropLat,
            dropLng: dropLng,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderViewModel = Provider.of<OrderViewModel>(context);
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Back button and title
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, size: 24),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      TextConst(
                        title: "Drop",
                        size: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: AppFonts.kanitReg,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location Cards
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        // Pickup Location - Editable
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSearchingPickup = true;
                              isSearchingDrop = false;
                            });
                            _showLocationSearchSheet(true);
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextConst(
                                      title: "Pickup Location",
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontFamily: AppFonts.kanitReg,
                                    ),
                                    const SizedBox(height: 2),
                                    TextConst(
                                      title: pickupController.text.isNotEmpty
                                          ? pickupController.text
                                          : "Tap to select pickup location",
                                      size: 12,
                                      color: pickupController.text.isNotEmpty
                                          ? Colors.grey[600]
                                          : Colors.grey[400],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (pickupLat != null && pickupLng != null)
                                      TextConst(
                                        title: "Lat: ${pickupLat!.toStringAsFixed(6)}, Lng: ${pickupLng!.toStringAsFixed(6)}",
                                        size: 10,
                                        color: Colors.grey[500],
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 35,
                                width: 35,
                                color: Colors.transparent,
                                child: Icon(
                                  Icons.edit,
                                  color: PortColor.blackLight,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Drop Location
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSearchingPickup = false;
                              isSearchingDrop = true;
                            });
                            _showLocationSearchSheet(false);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.red[400],
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextConst(
                                      title: "Drop Location",
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontFamily: AppFonts.kanitReg,
                                    ),
                                    const SizedBox(height: 2),
                                    TextConst(
                                      title: dropController.text.isNotEmpty
                                          ? dropController.text
                                          : "Tap to select drop location",
                                      size: 12,
                                      color: dropController.text.isNotEmpty
                                          ? Colors.grey[600]
                                          : Colors.grey[400],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (dropLat != null && dropLng != null)
                                      TextConst(
                                        title: "Lat: ${dropLat!.toStringAsFixed(6)}, Lng: ${dropLng!.toStringAsFixed(6)}",
                                        size: 10,
                                        color: Colors.grey[500],
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 35,
                                width: 35,
                                color: Colors.transparent,
                                child: Icon(
                                  Icons.edit,
                                  color: PortColor.blackLight,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              height: 8,
              color: Colors.grey[100],
            ),

            // Search History or Empty State
            Expanded(
              child: _buildSearchHistory(),
            ),

            // Proceed Button
            if (dropController.text.isNotEmpty && pickupController.text.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: AppBtn(title: "Proceed", onTap: _proceedToMapScreen),
              ),
            SizedBox(height: screenHeight * 0.02)
          ],
        ),
      ),
    );
  }

  // ... (Rest of the methods remain the same)
  void _showLocationSearchSheet(bool isPickup) {
    TextEditingController searchController = TextEditingController();
    List<dynamic> localSearchResults = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPickup ? "Select Pickup" : "Select Drop",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.kanitReg,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search location...",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontFamily: AppFonts.kanitReg,
                        ),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey[500]),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.close, size: 20),
                          onPressed: () {
                            searchController.clear();
                            setModalState(() {
                              localSearchResults.clear();
                            });
                          },
                        )
                            : null,
                      ),
                      onChanged: (value) async {
                        if (value.isNotEmpty) {
                          final results = await _performSearch(value);
                          setModalState(() {
                            localSearchResults = results;
                          });
                        } else {
                          setModalState(() {
                            localSearchResults.clear();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Results or History
                  Expanded(
                    child: localSearchResults.isNotEmpty
                        ? _buildSearchResultsList(localSearchResults, isPickup, setModalState)
                        : _buildSearchHistoryInSheet(isPickup, setModalState),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResultsList(List<dynamic> results, bool isPickup, Function setModalState) {
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
      itemBuilder: (context, index) {
        final place = results[index];
        return ListTile(
          leading: Icon(Icons.location_on_outlined, color: Colors.blue[600]),
          title: Text(
            place['description'],
            style: TextStyle(fontFamily: AppFonts.kanitReg),
          ),
          onTap: () {
            _onLocationSelected(place['description'], isPickup);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildSearchHistoryInSheet(bool isPickup, Function setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (searchHistory.isNotEmpty) ...[
          Text(
            "Recent Searches",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontFamily: AppFonts.kanitReg,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: searchHistory.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final location = searchHistory[index];
                return ListTile(
                  leading: Icon(Icons.history_outlined, color: Colors.grey[500]),
                  title: Text(
                    location['name']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.kanitReg,
                    ),
                  ),
                  subtitle: Text(
                    location['address']!,
                    style: TextStyle(fontFamily: AppFonts.kanitReg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    _onLocationSelected(location['name']!, isPickup);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ] else ...[
          // Empty state when no search history
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No recent searches",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: AppFonts.kanitReg,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your recent location searches will appear here",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontFamily: AppFonts.kanitReg,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchHistory() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              searchHistory.isNotEmpty ? "Recent Searches" : "Search History",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontFamily: AppFonts.kanitReg,
              ),
            ),
          ),
          Expanded(
            child: searchHistory.isNotEmpty
                ? ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: searchHistory.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final location = searchHistory[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: Icon(
                    Icons.history_outlined,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  title: Text(
                    location['name']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: AppFonts.kanitReg,
                    ),
                  ),
                  subtitle: Text(
                    location['address']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: AppFonts.kanitReg,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    _onLocationSelected(location['name']!, false);
                  },
                );
              },
            )
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No search history",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: AppFonts.kanitReg,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your recent location searches will appear here",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: AppFonts.kanitReg,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> _performSearch(String query) async {
    Uri uri = Uri.https("maps.googleapis.com", 'maps/api/place/autocomplete/json', {
      "input": query,
      "key": "AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA",
      "components": "country:in",
    });

    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['predictions'] ?? [];
      }
    } catch (e) {
      print('Error in place search: $e');
    }
    return [];
  }
}