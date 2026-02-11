import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_btn.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/res/shimmer_loader.dart';
import 'package:yoyomiles/view/driver_searching/ride_map_screen.dart';
import 'package:yoyomiles/view_model/order_view_model.dart';
import 'package:yoyomiles/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles/view_model/select_vehicles_view_model.dart';

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
  bool isPickupLoading = true;

  // Separate coordinates storage
  double? pickupLat;
  double? pickupLng;
  double? dropLat;
  double? dropLng;

  // Search history to show in popular locations
  List<Map<String, dynamic>> searchHistory = [];

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
    const String apiKey = 'AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM';
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
          isPickupLoading = false;
        }
      }
    } catch (e) {
      print('Error fetching address: $e');
      setState(() {
        isPickupLoading = false;
      });
    }
  }

  // Load search history from shared preferences
  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString('search_history');

      if (historyJson != null) {
        final List<dynamic> decoded = json.decode(historyJson);
        setState(() {
          searchHistory = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      }
    } catch (e) {
      print('Error loading search history: $e');
    }
  }

  // Save to search history with coordinates
  Future<void> _saveToSearchHistory(String name, String address, double? lat, double? lng) async {
    try {
      // Avoid duplicates
      searchHistory.removeWhere((item) => item['name'] == name);

      setState(() {
        searchHistory.insert(0, {
          'name': name,
          'address': address,
          'lat': lat,
          'lng': lng,
        });

        // Keep only last 10 searches
        if (searchHistory.length > 10) {
          searchHistory = searchHistory.sublist(0, 10);
        }
      });

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = json.encode(searchHistory);
      await prefs.setString('search_history', historyJson);
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  void _onLocationSelected(String location, bool isPickup) async {
    // Get coordinates for location
    LatLng? coordinates = await fetchLatLngFromAddress(location);

    if (isPickup) {
      setState(() {
        pickupController.text = location;
      });
      if (coordinates != null) {
        pickupLat = coordinates.latitude;
        pickupLng = coordinates.longitude;
        print("📍 Pickup Coordinates - Lat: $pickupLat, Lng: $pickupLng");
      }
    } else {
      setState(() {
        dropController.text = location;
      });
      if (coordinates != null) {
        dropLat = coordinates.latitude;
        dropLng = coordinates.longitude;
        print("📍 Drop Coordinates - Lat: $dropLat, Lng: $dropLng");

        // Save to search history with coordinates (only for drop locations)
        await _saveToSearchHistory(location, location, dropLat, dropLng);
      }
    }

    searchResults.clear();
  }

  // When selecting from history, use stored coordinates and navigate to map
  void _onHistoryLocationSelected(Map<String, dynamic> location, bool isPickup) {

    Provider.of<SelectVehiclesViewModel>(context, listen: false)
        .clearVehicleData();
    if (isPickup) {
      setState(() {
        pickupController.text = location['name'];
        pickupLat = location['lat'];
        pickupLng = location['lng'];
      });
      print("📍 History Pickup - Lat: $pickupLat, Lng: $pickupLng");
    } else {
      setState(() {
        dropController.text = location['name'];
        dropLat = location['lat'];
        dropLng = location['lng'];
      });
      print("📍 History Drop - Lat: $dropLat, Lng: $dropLng");

      // Auto-navigate to map screen after selecting drop location from history
      _navigateToMapFromHistory();
    }
  }

  // Navigate to map screen from history selection
  void _navigateToMapFromHistory() {
    // Check if both pickup and drop locations are filled with coordinates
    if (pickupController.text.isNotEmpty &&
        dropController.text.isNotEmpty &&
        pickupLat != null &&
        pickupLng != null &&
        dropLat != null &&
        dropLng != null) {

      print("🚀 Navigating from history");
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please ensure both pickup and drop locations are selected'),
          backgroundColor: Colors.orange,
        ),
      );
    }
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
      if (pickupLat == null || pickupLng == null || dropLat == null || dropLng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please wait, fetching location coordinates...')),
        );
        return;
      }

      Provider.of<SelectVehiclesViewModel>(context, listen: false)
          .clearVehicleData();

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
                top: MediaQuery.of(context).padding.top + 5,
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
                                    isPickupLoading
                                        ? ShimmerLoader(
                                      height: 12,
                                      width: screenWidth * 0.5,
                                      borderRadius: 6,
                                    )
                                        : TextConst(
                                      title: pickupController.text.isNotEmpty
                                          ? pickupController.text
                                          : "Tap to select pickup location",
                                      size: 12,
                                      color: pickupController.text.isNotEmpty
                                          ? Colors.grey[600]
                                          : Colors.grey[400],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
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
                    _onHistoryLocationSelected(location, isPickup);
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
                    // When tapping from main screen history, it's for drop location
                    _onHistoryLocationSelected(location, false);
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
      "key": "AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM",
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