import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view/bottom_nav_bar.dart';
import 'package:yoyomiles/view/order/widgets/add_stops_page.dart';
import 'package:yoyomiles/view/order/widgets/review_booking.dart';
import 'package:yoyomiles/view_model/order_view_model.dart';
import 'package:yoyomiles/view_model/select_vehicles_view_model.dart';
import 'package:yoyomiles/view_model/service_type_view_model.dart';
import 'package:provider/provider.dart';

class SelectVehicles extends StatefulWidget {
  const SelectVehicles({super.key});

  @override
  State<SelectVehicles> createState() => _SelectVehiclesState();
}

class _SelectVehiclesState extends State<SelectVehicles> {
  int? selectedIndex;

  double? distance;
  bool isDistanceLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

      orderViewModel.stops.clear();
      _fetchDistanceAndVehicles();
    });
  }

  Future<void> _fetchDistanceAndVehicles() async {
    setState(() {
      isDistanceLoading = true;
    });

    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    final selectVehiclesViewModel = Provider.of<SelectVehiclesViewModel>(context, listen: false);
    final serviceTypeViewModel = Provider.of<ServiceTypeViewModel>(context, listen: false);

    double pickupLat = double.tryParse(orderViewModel.pickupData!["latitude"].toString()) ?? 0.0;
    double pickupLng = double.tryParse(orderViewModel.pickupData!["longitude"].toString()) ?? 0.0;
    double dropLat = double.tryParse(orderViewModel.dropData!["latitude"].toString()) ?? 0.0;
    double dropLng = double.tryParse(orderViewModel.dropData!["longitude"].toString()) ?? 0.0;

    List<LatLng> points = [];
    points.add(LatLng(pickupLat, pickupLng));

    // Add stops in between
    for (var stop in orderViewModel.stops) {
      double? sLat = double.tryParse(stop['latitude'].toString());
      double? sLng = double.tryParse(stop['longitude'].toString());
      if (sLat != null && sLng != null) {
        points.add(LatLng(sLat, sLng));
      }
    }

    points.add(LatLng(dropLat, dropLng));

    double totalDistance = 0.0;
    print("📍 --- Distance Calculation Start ---");
    for (int i = 0; i < points.length - 1; i++) {
      final roadDistance = await GoogleDistanceService.getRoadDistance(
        pickupLat: points[i].latitude,
        pickupLng: points[i].longitude,
        dropLat: points[i + 1].latitude,
        dropLng: points[i + 1].longitude,
      );

      if (roadDistance != null) {
        totalDistance += roadDistance;
        print("Segment $i to ${i + 1}: $roadDistance km");
      } else {
        print("Segment $i to ${i + 1}: FAILED");
      }
    }
    print("🏁 Total Distance: $totalDistance km");
    print("📍 --- Distance Calculation End ---");

    final double formattedDistance = double.parse(totalDistance.toStringAsFixed(1));

    setState(() {
      distance = formattedDistance;
      isDistanceLoading = false;
    });

    selectVehiclesViewModel.selectVehicleApi(
      serviceTypeViewModel.selectedVehicleId ?? "1",
      formattedDistance,
      serviceTypeViewModel.selectedVehicleType ?? "1",
      pickupLat,
      pickupLng,
      dropLat,
      dropLng,
      context,
      stopsList: orderViewModel.stops,
    );
  }

  // String getVehicleName(int vehicleId) {
  //   switch (vehicleId) {
  //     case 1: return "Tata Ace";
  //     case 2: return "3 Wheeler";
  //     case 3: return "2 Wheeler";
  //     case 4: return "Taxi";
  //     default: return "Vehicle $vehicleId";
  //   }
  // }

  List<dynamic> getOtherVehicles(SelectVehiclesViewModel viewModel) {
    return viewModel.selectVehicleModel?.data
            ?.where((vehicle) => vehicle.selectedStatus != 1)
            .toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    if (isDistanceLoading) {
      return const Scaffold(
        backgroundColor: PortColor.white,
        body: Center(
          child: CircularProgressIndicator(color: PortColor.gold),
        ),
      );
    }

    final orderViewModel = Provider.of<OrderViewModel>(context);
    final selectVehiclesViewModel = Provider.of<SelectVehiclesViewModel>(context);
    final usedDistance = distance ?? 0.0;
    final loc = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.bg,
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 18),
              height: screenHeight * 0.09,
              width: screenWidth,
              decoration: BoxDecoration(
                color: PortColor.white,
                boxShadow: [
                  BoxShadow(
                    color: PortColor.gray.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: screenHeight * 0.025),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  TextConst(
                    title: loc.select_vehicle,
                    color: PortColor.black,
                    size: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.045,
                vertical: screenWidth * 0.04,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.01,
                  vertical: screenHeight * 0.023,
                ),
                margin: const EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                  color: PortColor.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.green,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(9, (index) {
                              return  Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: PortColor.gray,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          )
                          ,Icon(
                            Icons.location_on_rounded,
                            color: PortColor.red,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextConst(
                                  title: orderViewModel.pickupData?["name"]?.toString() ?? "N/A",
                                  color: PortColor.black,
                                  fontFamily: AppFonts.kanitReg,
                                  size: 12,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              TextConst(
                                title: orderViewModel.pickupData?["phone"]?.toString() ?? "N/A",
                                color: PortColor.gray,
                                fontFamily: AppFonts.kanitReg,
                                size: 12,
                              ),
                            ],
                          ),
                          TextConst(
                            title: orderViewModel.pickupData?["address"]?.toString() ?? "N/A",
                            color: PortColor.gray,
                            fontFamily: AppFonts.poppinsReg,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            size: 12,
                          ),
                          if (orderViewModel.stops.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            ...orderViewModel.stops.map((stop) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle, size: 6, color: PortColor.gold),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextConst(
                                      title: stop["address"] ?? "Stop",
                                      color: PortColor.gray,
                                      size: 11,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                          SizedBox(height: screenHeight * 0.008),
                          Row(
                            children: [
                              Expanded(
                                child: TextConst(
                                  title: orderViewModel.dropData?["name"]?.toString() ?? "N/A",
                                  color: PortColor.black,
                                  fontFamily: AppFonts.kanitReg,
                                  size: 12,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              TextConst(
                                title: orderViewModel.dropData?["phone"]?.toString() ?? "N/A",
                                color: PortColor.gray,
                                fontFamily: AppFonts.kanitReg,
                                size: 12,
                              ),
                            ],
                          ),
                          TextConst(
                            title: orderViewModel.dropData?["address"]?.toString() ?? "N/A",
                            color: PortColor.gray,
                            fontFamily: AppFonts.poppinsReg,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            size: 12,
                          ),
                          SizedBox(height: screenHeight * 0.017),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const BottomNavigationPage(),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: PortColor.blue,
                                      size: screenHeight * 0.022,
                                    ),
                                    SizedBox(width: screenWidth * 0.01),
                                    TextConst(
                                      title: loc.edit_location,
                                      color: PortColor.black,
                                      fontFamily: AppFonts.poppinsReg,
                                      size: 13,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.1),
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AddStopsPage(),
                                    ),
                                  );
                                  _fetchDistanceAndVehicles();
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add_location_alt_outlined,
                                      color: PortColor.blue,
                                      size: screenHeight * 0.022,
                                    ),
                                    SizedBox(width: screenWidth * 0.01),
                                    TextConst(
                                      title: orderViewModel.stops.isEmpty ? loc.adds_stops : loc.edit_stops,
                                      color: PortColor.black,
                                      fontFamily: AppFonts.poppinsReg,
                                      size: 13,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextConst(
                                title: "Distance : $distance km",size: 12,),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextConst(
              title: loc.choose_the_vehicle,
              fontWeight: FontWeight.w400,
              size: 15,
            ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
        bottomSheet: Container(
          width: screenWidth,
          decoration: const BoxDecoration(
            color: PortColor.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: screenHeight * 0.5,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                child: selectVehiclesViewModel.loading
                    ? const Center(
                        child: CircularProgressIndicator(color: PortColor.blue),
                      )
                    : Builder(
                        builder: (context) {
                          final vehicles = selectVehiclesViewModel.selectVehicleModel?.data;
                          if (vehicles == null) {
                            return Center(
                              child: Text(
                                loc.something_went_wrong,
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontFamily: AppFonts.kanitReg,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          if (vehicles.isEmpty) {
                            return Center(
                              child: Text(
                                loc.no_vehicle,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: AppFonts.kanitReg,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return SingleChildScrollView(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: vehicles.length,
                              itemBuilder: (context, index) {
                                final vehicle = vehicles[index];
                                final isSelected = selectedIndex == index;
                                return _buildVehicleItem(
                                  vehicle: vehicle,
                                  isSelected: isSelected,
                                  index: index,
                                  distance: usedDistance,
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
              Container(
                height: screenHeight * 0.09,
                decoration: BoxDecoration(
                  color: PortColor.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.017,
                  ),
                  child: InkWell(
                    onTap: selectedIndex != null
                        ? () {
                            if (selectVehiclesViewModel.selectVehicleModel?.data == null ||
                                selectedIndex! >= selectVehiclesViewModel.selectVehicleModel!.data!.length) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(loc.invalid_vehicle_selection),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final selectedVehicle = selectVehiclesViewModel.selectVehicleModel!.data![selectedIndex!];
                            final vehicleName = selectedVehicle.vehicleName ?? "Unknown Vehicle";
                            final vehicleId = selectedVehicle.vehicleId ?? 0;
                            final vehicleBodyDetailId = selectedVehicle.vehicleBodyDetailsId?.toString() ?? "0";
                            final vehicleBodyTypeId = selectedVehicle.vehicleBodyTypesId?.toString() ?? "0";
                            final double amount = double.tryParse(selectedVehicle.amount.toString()) ?? 0.0;

                            facebookAppEvents.logEvent(name: 'select_vehicle_for_logistic');

                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 400),
                                pageBuilder: (_, __, ___) => ReviewBooking(
                                  vehicleName: vehicleName,
                                  index: selectedIndex,
                                  price: amount.toString(),
                                  distance: usedDistance.toString(),
                                  vehicleBodyDetailId: vehicleBodyDetailId,
                                  vehicleBodyTypeId: vehicleBodyTypeId,
                                  vehicleIds: vehicleId.toString(),
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
                          }
                        : null,
                    child: Container(
                      alignment: Alignment.center,
                      height: screenHeight * 0.03,
                      width: screenWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: selectedIndex != null
                            ? PortColor.subBtn
                            : const LinearGradient(
                                colors: [PortColor.darkPurple, PortColor.darkPurple],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                      ),
                      child: TextConst(
                        title: selectedIndex != null
                            ? "${loc.proceed_with} ${selectVehiclesViewModel.selectVehicleModel?.data?[selectedIndex!].vehicleName ?? 'Vehicle'}"
                            : loc.select_vehicle,
                        color: PortColor.black,
                        fontFamily: AppFonts.kanitReg,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleItem({
    required dynamic vehicle,
    required bool isSelected,
    required int index,
    required double distance,
    required VoidCallback onTap,
  }) {
    final vehicleName = vehicle.vehicleName?.toString() ?? "Unknown Vehicle";
    final bodyDetails = vehicle.bodyDetail?.toString() ?? "No details";
    final amount = vehicle.amount ?? 0;
    final vehicleImage = vehicle.vehicleImage?.toString() ?? "";
    final measurementImage = vehicle.measurementsImg?.toString() ?? "";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          bottom: screenHeight * 0.02,
          left: screenWidth * 0.04,
          right: screenWidth * 0.04,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? PortColor.blue.withOpacity(0.08) : PortColor.white,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: PortColor.blue, width: 2)
              : Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? Column(
                children: [
                  Center(
                    child: measurementImage.isNotEmpty
                        ? Image.network(
                            measurementImage,
                            height: screenHeight * 0.1,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(Assets.assetsBike, height: screenHeight * 0.09),
                          )
                        : Image.asset(Assets.assetsBike, height: screenHeight * 0.09),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextConst(
                              title: vehicleName,
                              color: PortColor.black,
                              fontFamily: AppFonts.kanitReg,
                              size: 14,
                            ),
                            SizedBox(height: screenHeight * 0.004),
                            TextConst(
                              title: bodyDetails,
                              color: PortColor.gray,
                              fontFamily: AppFonts.poppinsReg,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                      TextConst(
                        title: "₹$amount",
                        color: PortColor.black,
                        fontFamily: AppFonts.kanitReg,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  vehicleImage.isNotEmpty
                      ? Image.network(
                          vehicleImage,
                          height: screenHeight * 0.09,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(Assets.assetsBike, height: screenHeight * 0.09),
                        )
                      : Image.asset(Assets.assetsBike, height: screenHeight * 0.09),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextConst(
                          title: vehicleName,
                          color: PortColor.black,
                          fontFamily: AppFonts.kanitReg,
                          size: 14,
                        ),
                        SizedBox(height: screenHeight * 0.004),
                        TextConst(
                          title: bodyDetails,
                          color: PortColor.gray,
                          fontFamily: AppFonts.poppinsReg,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                  TextConst(
                    title: "₹$amount",
                    color: PortColor.black,
                    fontFamily: AppFonts.kanitReg,
                    size: 16,
                  ),
                ],
              ),
      ),
    );
  }
}

class GoogleDistanceService {
  static const String apiKey = "AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM";

  static Future<double?> getRoadDistance({
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
  }) async {
    final url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=$pickupLat,$pickupLng'
        '&destinations=$dropLat,$dropLng'
        '&mode=driving'
        '&units=metric'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['rows'][0]['elements'][0]['status'] == "OK") {
          final distanceInMeters = data['rows'][0]['elements'][0]['distance']['value'];
          return distanceInMeters / 1000.0;
        }
      }
    } catch (e) {
      debugPrint("DistanceMatrix error: $e");
    }
    return null;
  }
}
