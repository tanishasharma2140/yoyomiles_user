import 'dart:math';
import 'package:flutter/material.dart';
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view/bottom_nav_bar.dart';
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serviceTypeViewModel = Provider.of<ServiceTypeViewModel>(
        context,
        listen: false,
      );
      final selectVehiclesViewModel = Provider.of<SelectVehiclesViewModel>(
        context,
        listen: false,
      );
      final orderViewModel = Provider.of<OrderViewModel>(
        context,
        listen: false,
      );

      double pickupLat =
          double.tryParse(orderViewModel.pickupData["latitude"].toString()) ??
              0.0;
      double pickupLon =
          double.tryParse(orderViewModel.pickupData["longitude"].toString()) ??
              0.0;
      double dropLat =
          double.tryParse(orderViewModel.dropData["latitude"].toString()) ??
              0.0;
      double dropLon =
          double.tryParse(orderViewModel.dropData["longitude"].toString()) ??
              0.0;

      double distance = calculateDistance(
        pickupLat,
        pickupLon,
        dropLat,
        dropLon,
      );

      debugPrint("sadefdwr4tg $distance");


      selectVehiclesViewModel.selectVehicleApi(
        serviceTypeViewModel.selectedVehicleId!,
        distance.toString(),
        serviceTypeViewModel.selectedVehicleType!,
        orderViewModel.pickupData['latitude'],
        orderViewModel.pickupData['longitude'],
        context,
      );

      // selectVehiclesViewModel.selectVehiclesApi(
      //   serviceTypeViewModel.selectedVehicleId!,
      //   distance.toString(),
      // ).then((_) {
      //   _setDefaultSelectedVehicle(selectVehiclesViewModel);
      // });
    });
  }

  String getVehicleName(int vehicleId) {
    switch (vehicleId) {
      case 1:
        return "Tata Ace";
      case 2:
        return "3 Wheeler";
      case 3:
        return "2 Wheeler";
      case 4:
        return "Taxi";
      default:
        return "Vehicle $vehicleId";
    }
  }

  // Method to set default selected vehicle based on selected_status


  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0;

    double dLat = _degreeToRadian(lat2 - lat1);
    double dLon = _degreeToRadian(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(_degreeToRadian(lat1)) *
                cos(_degreeToRadian(lat2)) *
                sin(dLon / 2) *
                sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }



  // Helper method to get other vehicles
  List<dynamic> getOtherVehicles(SelectVehiclesViewModel viewModel) {
    return viewModel.selectVehicleModel?.data
        ?.where((vehicle) => vehicle.selectedStatus != 1)
        .toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    final orderViewModel = Provider.of<OrderViewModel>(context);
    final selectVehiclesViewModel = Provider.of<SelectVehiclesViewModel>(
      context,
    );

    double pickupLat = orderViewModel.pickupData["latitude"] ?? 0.0;
    double pickupLon = orderViewModel.pickupData["longitude"] ?? 0.0;
    double dropLat = orderViewModel.dropData["latitude"] ?? 0.0;
    double dropLon = orderViewModel.dropData["longitude"] ?? 0.0;
    double distance = calculateDistance(pickupLat, pickupLon, dropLat, dropLon);

    print("distance $distance");


    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.bg,
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 18),
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
                    title: "Select Vehicles",
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
                            12,
                                (index) => Container(
                              width: screenWidth * 0.003,
                              height: screenHeight * 0.0025,
                              margin: const EdgeInsets.symmetric(vertical: 1),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TextConst(
                                title:
                                orderViewModel.pickupData["name"] ?? "N/A",
                                color: PortColor.black,
                                fontFamily: AppFonts.kanitReg,
                                size: 12,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              TextConst(
                                title:
                                orderViewModel.pickupData["phone"] ?? "N/A",
                                color: PortColor.gray,
                                fontFamily: AppFonts.kanitReg,
                                size: 12,
                              ),
                            ],
                          ),
                          TextConst(
                            title:
                            orderViewModel.pickupData["address"] ?? "N/A",
                            color: PortColor.gray,
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              TextConst(
                                title: orderViewModel.dropData["name"] ?? "N/A",
                                color: PortColor.black,
                                fontFamily: AppFonts.kanitReg,
                                size: 12,
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              TextConst(
                                title:
                                orderViewModel.dropData["phone"] ?? "N/A",
                                color: PortColor.gray,
                                fontFamily: AppFonts.kanitReg,
                                size: 12,
                              ),
                            ],
                          ),
                          TextConst(
                            title: orderViewModel.dropData["address"] ?? "N/A",
                            color: PortColor.gray,
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                          SizedBox(height: screenHeight * 0.017),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BottomNavigationPage(),
                                ),
                              );
                            },
                            child: Container(
                              height: 40,
                              // padding: EdgeInsets.symmetric(
                              //   horizontal: screenWidth * 0.03,
                              //   vertical: screenHeight * 0.01,
                              // ),
                              decoration: BoxDecoration(
                                // color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: PortColor.blue,
                                    size: screenHeight * 0.025,
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  TextConst(
                                    title: "EDIT LOCATION",
                                    color: PortColor.black,
                                    fontFamily: AppFonts.poppinsReg,
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
            ),
            TextConst(
              title: "Choose the vehicle for your delivery",
              fontWeight: FontWeight.w400,
              size: 15,
            ),
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

                // ✅ Handle null or empty list
                if (vehicles == null) {
                  return const Center(
                    child: Text(
                      "Something went wrong. Please try again later.",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontFamily: AppFonts.kanitReg,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (vehicles.isEmpty) {
                  return const Center(
                    child: Text(
                      "No vehicles available.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: AppFonts.kanitReg,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // ✅ Safe ListView rendering
                return SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      final isSelected = selectedIndex == index;

                      // Debug log
                      print("Vehicle index $index => ${vehicle.vehicleBodyDetailsId}");

                      return _buildVehicleItem(
                        vehicle: vehicle,
                        isSelected: isSelected,
                        index: index,
                        distance: distance,
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
                      final selectedVehicle = selectVehiclesViewModel
                          .selectVehicleModel!.data![selectedIndex!];

                      final vehicleName = selectedVehicle.vehicleName ?? "Unknown Vehicle";
                      final vehicleId = selectedVehicle.vehicleId ?? 0;
                      final vehicleBodyDetailId =
                      selectedVehicle.vehicleBodyDetailsId.toString();
                      final vehicleBodyTypeId =
                          selectedVehicle.vehicleBodyTypesId?.toString() ?? "0";

                      final distanceStr = distance.toInt().toString();
                      final price = ((double.tryParse(
                          selectedVehicle.amount.toString()) ?? 0) *
                          distance)
                          .toInt()
                          .toString();

                      // 🧾 Debug Prints
                      print("======== Vehicle Selection Details ========");
                      print("Vehicle Name: $vehicleName");
                      print("Vehicle ID: $vehicleId");
                      print("Vehicle Body Detail ID: $vehicleBodyDetailId");
                      print("Vehicle Body Type ID: $vehicleBodyTypeId");
                      print("Distance: $distanceStr");
                      print("Price: $price");
                      print("==========================================");

                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 400),
                          pageBuilder: (_, __, ___) => ReviewBooking(
                            vehicleName: vehicleName, // ✅ send vehicle name
                            index: selectedIndex,
                            price: price,
                            distance: distanceStr,
                            vehicleBodyDetailId: vehicleBodyDetailId,
                            vehicleBodyTypeId: vehicleBodyTypeId,
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
                          colors: [
                            PortColor.darkPurple,
                            PortColor.darkPurple,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: TextConst(
                        title: selectedIndex != null
                            ? "Proceed with ${selectVehiclesViewModel.selectVehicleModel?.data![selectedIndex!].vehicleName ?? 'Vehicle'}"
                            : "Select a Vehicle",
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
    // CORRECTED: Use vehicleId instead of vehicleid
    final vehicleName = vehicle.vehicleName ?? "n/a";
    final bodyDetails = vehicle.bodyDetail ?? "fewrffewr";
    final amount = vehicle.amount ?? 0;
    final vehicleImage = vehicle.vehicleImage ?? "frewvgre";
    final measurementImage = vehicle.measurementsImg ?? "frewvgre";
    final selectedStatus = vehicle.selectedStatus ?? 0;



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
            // Centered image
            Center(
              child: Image.network(
                measurementImage,
                height: screenHeight * 0.1,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    Assets.assetsBike,
                    height: screenHeight * 0.09,
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle info (left side)
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
                // Amount (right side)
                TextConst(
                  title:
                  "₹${(((double.tryParse(amount.toString()) ?? 0) * distance).toInt())}",
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
            // Image first
            Image.network(
              vehicleImage,
              height: screenHeight * 0.09,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  Assets.assetsBike,
                  height: screenHeight * 0.09,
                );
              },
            ),
            const SizedBox(width: 12),
            // Vehicle ID and body details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextConst(
                    title: vehicleName, // CORRECTED here too
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
            // Amount at right
            TextConst(
              title:
              "₹${(((double.tryParse(amount.toString()) ?? 0) * distance).toInt())}",
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