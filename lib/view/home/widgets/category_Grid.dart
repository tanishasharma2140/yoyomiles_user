import 'package:flutter/material.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/res/shimmer_loader.dart';
import 'package:yoyomiles/view/home/widgets/pickup/deliver_by_packer_mover.dart';
import 'package:yoyomiles/view/home/widgets/pickup/deliver_by_truck.dart';
import 'package:yoyomiles/view/order/passenger_booking.dart';
import 'package:yoyomiles/view_model/service_type_view_model.dart';
import 'package:provider/provider.dart';
import '../../../model/service_type_model.dart';

class CategoryGrid extends StatefulWidget {
  const CategoryGrid({super.key});

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  String? _selectedVehicleId;
  String? _selectedVehicleName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serviceTypeViewModel = Provider.of<ServiceTypeViewModel>(
        context,
        listen: false,
      );
      serviceTypeViewModel.serviceTypeApi();
    });
  }

  void _handleVehicleSelection(
      VehicleData vehicle,
      String section,
      int categoryIndex,
      int vehicleIndex,
      ) {
    final serviceTypeViewModel = Provider.of<ServiceTypeViewModel>(
      context,
      listen: false,
    );

    setState(() {
      _selectedVehicleId = vehicle.id?.toString();
      _selectedVehicleName = vehicle.name;
    });

    // ✅ Store both ID and Type
    serviceTypeViewModel.setSelectedVehicleId(_selectedVehicleId!);
    serviceTypeViewModel.setSelectedVehicleType(vehicle.type ?? 0);

    // ✅ Debug logs
    print("Selected Vehicle ID: $_selectedVehicleId");
    print("Selected Vehicle Name: $_selectedVehicleName");
    print("Selected Vehicle Type: ${vehicle.type}");
    print("Section: $section");
    print("Category Index: $categoryIndex");
    print("Vehicle Index: $vehicleIndex");

    // ✅ Navigation logic based on section
    if (section == "Logistic Parcel Delivery") {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => const DeliverByTruck(),
          transitionsBuilder: (_, animation, __, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    } else if (section == "Packers and Movers") {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => const DeliverByPackerMover(),
          transitionsBuilder: (_, animation, __, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    } else if (section == "Passenger Booking") {
      // ✅ Fix: Correct syntax + navigation
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => const PassengerBooking(),
          transitionsBuilder: (_, animation, __, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceTypeViewModel = Provider.of<ServiceTypeViewModel>(context);

    return serviceTypeViewModel.loading
        ? _buildShimmerLoader()
        : serviceTypeViewModel.serviceTypeModel?.data?.isNotEmpty == true
        ? _buildCategoryGrid(serviceTypeViewModel)
        : const Center(child: Text("No vehicles Available"));
  }

  Widget _buildShimmerLoader() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Logistic Parcel Delivery"),
          _buildShimmerRow(3),
          const SizedBox(height: 20),
          _buildSectionHeader("Passenger Booking"),
          _buildShimmerRow(2),
          const SizedBox(height: 20),
          _buildSectionHeader("Packers and Movers"),
          _buildShimmerRow(1),
        ],
      ),
    );
  }

  Widget _buildShimmerRow(int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 120,
      child: Row(
        children: List.generate(
          count,
              (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < count - 1 ? 10 : 0),
              child: ShimmerLoader(
                width: double.infinity,
                height: 120,
                borderRadius: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(ServiceTypeViewModel serviceTypeViewModel) {
    final categories = serviceTypeViewModel.serviceTypeModel!.data!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (categories.isNotEmpty &&
              categories[0].data != null &&
              categories[0].data!.isNotEmpty)
            _buildServiceSection(categories[0]),
          const SizedBox(height: 20),
          if (categories.length > 1 &&
              categories[1].data != null &&
              categories[1].data!.isNotEmpty)
            _buildServiceSection(categories[1]),
          const SizedBox(height: 20),
          if (categories.length > 2 &&
              categories[2].data != null &&
              categories[2].data!.isNotEmpty)
            _buildServiceSection(categories[2], isPackersAndMovers: true),
        ],
      ),
    );
  }

  Widget _buildServiceSection(ServiceCategory category,
      {bool isPackersAndMovers = false}) {
    List<VehicleData> vehicles = category.data!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(category.comment ?? "Services"),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          height: isPackersAndMovers ? 140 : 120,
          child: Row(
            children: List.generate(
              isPackersAndMovers ? 1 : vehicles.length,
                  (index) {
                if (index < 3) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: index < (isPackersAndMovers ? 0 : vehicles.length - 1)
                              ? 10
                              : 0),
                      child: _buildVehicleCard(
                        vehicles[isPackersAndMovers ? 0 : index],
                        category.comment!,
                        index,
                        isPackersAndMovers: isPackersAndMovers,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextConst(title: title, size: 15, fontWeight: FontWeight.w800),
    );
  }

  Widget _buildVehicleCard(
      VehicleData vehicle,
      String section,
      int vehicleIndex, {
        bool isPackersAndMovers = false,
      }) {
    return GestureDetector(
      onTap: () {
        _handleVehicleSelection(vehicle, section, 0, vehicleIndex);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01,
                horizontal: screenWidth * 0.03,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: TextConst(
                        title: vehicle.name ?? "Vehicle",
                        size: 13,
                        fontWeight: FontWeight.w400,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.006),
              child: Align(
                alignment: Alignment.bottomRight,
                child: vehicle.images != null && vehicle.images!.isNotEmpty
                    ? Image.network(
                  vehicle.images!,
                  height: isPackersAndMovers ? 93 : 70,
                  width: isPackersAndMovers ? 340 : 90,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage(
                        isPackersAndMovers: isPackersAndMovers);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildPlaceholderImage(
                        isPackersAndMovers: isPackersAndMovers);
                  },
                )
                    : _buildPlaceholderImage(
                    isPackersAndMovers: isPackersAndMovers),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage({bool isPackersAndMovers = false}) {
    return Container(
      height: isPackersAndMovers ? 90 : 70,
      width: isPackersAndMovers ? 110 : 90,
      color: Colors.grey[200],
      child: Icon(
        Icons.directions_car,
        color: Colors.grey[400],
        size: isPackersAndMovers ? 40 : 30,
      ),
    );
  }
}
