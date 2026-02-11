import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:yoyomiles/check_for_update.dart';
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/animated_text_slider.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/res/shimmer_loader.dart';
import 'package:yoyomiles/services/internet_checker_service.dart';
import 'package:yoyomiles/utils/routes/routes.dart';
import 'package:yoyomiles/view/coins/coins.dart';
import 'package:yoyomiles/view/driver_searching/driver_searching_screen.dart';
import 'package:yoyomiles/view/home/widgets/category_Grid.dart';
import 'package:yoyomiles/view/home/widgets/pick_up_location.dart';
import 'package:yoyomiles/view_model/active_ride_view_model.dart';
import 'package:yoyomiles/view_model/port_banner_view_model.dart';
import 'package:yoyomiles/view_model/profile_view_model.dart';
import 'package:yoyomiles/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(initialPage: 0);
  final checker = InternetCheckerService();
  int _currentPage = 0;
  Timer? _timer;

  // Current location variables
  String currentAddress = "Fetching location...";
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();

    facebookAppEvents.logEvent(
      name: 'home_screen_opened',
    );

    // 🔹 Banner API call after build
    checker.startMonitoring(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UserViewModel userViewModel = UserViewModel();
      String? userId = await userViewModel.getUser();

      print("activeRideVm");

      final activeRideVM = Provider.of<ActiveRideViewModel>(context, listen: false);

      await activeRideVM.activeRideApi(userId.toString()); // <<< await important

      final ride = activeRideVM.activeRideModel;

      if (!mounted) return;

      if (ride != null) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => DriverSearchingScreen(
              orderData: {
                ...ride.toJson(),
                'document_id': ride.data?.id.toString(),
                'sender_name': ride.data?.senderName,
                'sender_phone': ride.data?.senderPhone,
                'reciver_name': ride.data?.reciverName,
                'reciver_phone': ride.data?.reciverPhone,
                'pickup_address': ride.data?.pickupAddress,
                'drop_address': ride.data?.dropAddress,
                'order_type': ride.data?.orderType,
              },
            ),
          ),
        );
        activeRideVM.setModelData(null);
      } else {
        print("🚫 No Active Ride Found");
      }

      print("chliactiveRideVm");
      final portBannerVm = Provider.of<PortBannerViewModel>(
        context,
        listen: false,
      );
      portBannerVm.portBannerApi();
    });

    // 🔹 Get current
    _getCurrentLocation();

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      final bannerVm = Provider.of<PortBannerViewModel>(context, listen: false);
      final bannerLength = bannerVm.portBannerModel?.data?.length ?? 0;

      if (bannerLength == 0) return;

      if (_currentPage < bannerLength - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (!mounted || !_pageController.hasClients) return;

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });

  }

  Future<void> _refresh() async {
    // Banner reload
    final portBannerVm = Provider.of<PortBannerViewModel>(
      context,
      listen: false,
    );
    await portBannerVm.portBannerApi();

    // Location reload
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Permission check karo
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            currentAddress = "Location permission denied";
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          currentAddress = "Location permission permanently denied";
          _isLoadingLocation = false;
        });
        return;
      }

      // Current position get karo
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // Address get karo coordinates se
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          currentAddress =
              "${placemark.street ?? placemark.thoroughfare ?? 'Unnamed Road'}, ${placemark.locality ?? placemark.subAdministrativeArea ?? ''}, ${placemark.administrativeArea ?? ''}";
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          currentAddress = "Unnamed Road, Uttar Pradesh";
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        currentAddress = "Unnamed Road, Uttar Pradesh";
        _isLoadingLocation = false;
      });
      debugPrint("Error getting location: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = Provider.of<PortBannerViewModel>(context);
    final profile = Provider.of<ProfileViewModel>(context);

    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        child: RefreshIndicator(
          color: PortColor.gold,
          onRefresh: _refresh,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: screenHeight * 0.25,
                      width: screenWidth,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFF176),
                            Color(0xFFFFD54F),
                            Color(0xFFFFA726),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: banner.portBannerModel?.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          final portBanner = banner.portBannerModel?.data?[index];
                          return ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            child: Image.network(
                              portBanner?.imageUrl ?? "",
                              fit: BoxFit.cover,
                              width: screenWidth,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: PortColor.gold,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(Icons.error, color: Colors.red),
                                  ),
                            ),
                          );
                        },
                      ),
                    ),

                    // 🔹 Pickup Location Container
                    Positioned(
                      bottom: -30,
                      child: Container(
                        height: screenHeight * 0.08,
                        width: screenWidth * 0.9,
                        decoration: BoxDecoration(
                          color: PortColor.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const PickUpLocation(),
                            //   ),
                            // );
                          },
                          child: Row(
                            children: [
                              SizedBox(width: screenWidth * 0.02),
                              Image.asset(
                               "assets/location_anni.gif",
                                height: screenHeight * 0.04,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextConst(
                                    title: 'Picked up from',
                                    color: PortColor.black,
                                    fontFamily: AppFonts.poppinsReg,
                                  ),
                                  _isLoadingLocation
                                      ? ShimmerLoader(
                                    height: screenHeight * 0.01,
                                    width: screenWidth * 0.5,
                                    borderRadius: 9,
                                  )
                                      : TextConst(
                                    title: currentAddress,
                                    color: PortColor.gray,
                                    fontFamily: AppFonts.poppinsReg,
                                    size: 12,
                                  ),
                                ],
                              ),
                              // const Spacer(),
                              // const Icon(
                              //   Icons.keyboard_arrow_down_rounded,
                              //   color: PortColor.black,
                              // ),
                              SizedBox(width: screenWidth * 0.02),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Rest of your code remains same
                SizedBox(height: screenHeight * 0.05),
                const CategoryGrid(),
                SizedBox(height: screenHeight * 0.03),
                Container(
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    color: PortColor.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.03),
                      GestureDetector(
                        onTap: () {
                          facebookAppEvents.logEvent(
                            name: 'yoyomiles_reward_page',
                          );
                         Navigator.push(context, CupertinoPageRoute(builder: (context)=>CoinsPage()));
                        },
                        child: Container(
                          width: screenWidth * 0.9,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFF176), // Light Yellow
                                Color(0xFFFFD54F), // Amber
                                Color(0xFFFFA726), // Orange
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Image(
                                image: AssetImage(Assets.assetsCoin),
                                height: 36,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextConst(
                                    title: 'Explore Yoyomiles Reward',
                                    color: PortColor.black,
                                    fontFamily: AppFonts.kanitReg,
                                  ),
                                  TextConst(
                                    title: 'Get ₹${profile.profileModel?.data?.referralAmount??"0"} coins for each referral!',
                                    color: PortColor.grayLight,
                                    fontFamily: AppFonts.poppinsReg,
                                    size: 12,
                                  ),
                                ],
                              ),
                              // const Spacer(),
                              // Icon(
                              //   Icons.arrow_forward,
                              //   color: PortColor.black,
                              //   size: screenHeight * 0.03,
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextConst(
                            title: "Announcements",
                            color: PortColor.gray,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                        ),
                        height: screenHeight * 0.09,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: PortColor.grayLight.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(12),
                          color: PortColor.white,
                        ),
                        child: InkWell(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const SeeWhatNew(),
                            //   ),
                            // );
                          },
                          child: Row(
                            children: [
                              Image(
                                image: AssetImage(Assets.assetsAnnouncement),
                                height: screenHeight * 0.05,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: AnimatedTextSlider()),
                              // Container(
                              //   height: screenHeight * 0.025,
                              //   width: screenWidth * 0.15,
                              //   decoration: BoxDecoration(
                              //     color: Colors.yellow[50],
                              //     borderRadius: BorderRadius.circular(8),
                              //   ),
                              //   child: Align(
                              //     alignment: Alignment.center,
                              //     child: TextConst(
                              //       title: 'View all',
                              //       color: PortColor.gold,
                              //       size: 12,
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(width: screenWidth * 0.02),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
