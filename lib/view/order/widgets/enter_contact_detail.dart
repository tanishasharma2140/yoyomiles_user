// dart
// lib/view/order/widgets/enter_contact_detail.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/res/custom_text_field.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view/order/widgets/select_vehicles.dart';
import 'package:yoyomiles/view_model/order_view_model.dart';
import 'package:yoyomiles/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

class EnterContactDetail extends StatefulWidget {
  final String selectedLocation;
  final LatLng selectedLatLng;

  const EnterContactDetail({
    super.key,
    required this.selectedLocation,
    required this.selectedLatLng,
  });

  @override
  State<EnterContactDetail> createState() => _EnterContactDetailState();
}

class _EnterContactDetailState extends State<EnterContactDetail>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  late String selectedLocation;
  late GoogleMapController mapController;
  final Completer<GoogleMapController> _controller = Completer();
  bool isContactDetailsSelected = false;
  bool isFullscreenMode = false;
  bool isLoadingAddress = false;

  static const LatLng defaultPosition = LatLng(26.8467, 80.9462);
  LatLng selectedLatLng = defaultPosition;
  int selectedIndex = -1;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _showGoodsLabel = false;
  Timer? _labelTimer;

  @override
  void initState() {
    super.initState();
    fetchLatLngForLocation();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _labelTimer?.cancel();
    nameController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  void fetchLatLngForLocation() {
    setState(() {
      selectedLocation = widget.selectedLocation;
      selectedLatLng = widget.selectedLatLng;
    });
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    // Only fetch and format address in fullscreen mode
    if (!isFullscreenMode || isLoadingAddress) return;

    setState(() {
      isLoadingAddress = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          // Format address only in fullscreen mode
          selectedLocation = _formatAddress(place);
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
      if (mounted) {
        Utils.showErrorMessage(context, "Could not fetch address details");
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingAddress = false;
        });
      }
    }
  }

  String _formatAddress(Placemark place) {
    List<String> addressParts = [];
    if (place.street?.isNotEmpty ?? false) addressParts.add(place.street!);
    if (place.locality?.isNotEmpty ?? false) addressParts.add(place.locality!);
    if (place.subLocality?.isNotEmpty ?? false)
      addressParts.add(place.subLocality!);
    if (place.administrativeArea?.isNotEmpty ?? false)
      addressParts.add(place.administrativeArea!);
    if (place.postalCode?.isNotEmpty ?? false)
      addressParts.add(place.postalCode!);
    if (place.country?.isNotEmpty ?? false) addressParts.add(place.country!);

    return addressParts.isNotEmpty
        ? addressParts.join(", ")
        : "Unknown Location";
  }

  void _showGoodsLabelTemporarily() {
    _labelTimer?.cancel();
    setState(() {
      _showGoodsLabel = true;
    });
    _labelTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showGoodsLabel = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLatLng,
              zoom: 14.0,
            ),
            onMapCreated: (controller) {
              _controller.complete(controller);
              mapController = controller;
            },

            /// ✅ DRAG START → FULLSCREEN MODE
            onCameraMoveStarted: () {
              if (!isFullscreenMode) {
                setState(() {
                  isFullscreenMode = true;
                });
              }
            },

            /// (optional) Tap pe bhi fullscreen
            onTap: (LatLng latLng) {
              if (!isFullscreenMode) {
                setState(() {
                  isFullscreenMode = true;
                });
              }
              selectedLatLng = latLng;
            },

            /// ✅ CAMERA MOVE (dragging)
            onCameraMove: (position) {
              selectedLatLng = position.target;
            },

            /// ✅ DRAG END → FETCH ADDRESS
            onCameraIdle: () async {
              if (isFullscreenMode) {
                await _getAddressFromLatLng(selectedLatLng);
              }
            },

            markers: const <Marker>{},
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),



          // Overlay pin: top when not fullscreen, center when fullscreen.
          // Outer IgnorePointer lets map gestures pass; inner IgnorePointer(false)
          // around the marker enables tap detection only on the marker area.
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Align(
                alignment:
                isFullscreenMode ? Alignment.center : const Alignment(0, -0.65),
                child: IgnorePointer(
                  ignoring: false,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _showGoodsLabelTemporarily();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulsing circle under the marker
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                width: isFullscreenMode ? screenHeight * 0.14 : screenHeight * 0.09,
                                height: isFullscreenMode ? screenHeight * 0.14 : screenHeight * 0.09,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.amber.withOpacity(0.18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.18),
                                      blurRadius: 18,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Marker image with stronger shadow/highlight
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.black38,
                                //     blurRadius: 10,
                                //     offset: const Offset(0, 6),
                                //   ),
                                // ],
                              ),
                              child: Image(
                                image: const AssetImage(Assets.assetsRedLocationPin),
                                height: isFullscreenMode ? screenHeight * 0.095 : screenHeight * 0.065,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Popup label shown on tap
                        if (_showGoodsLabel)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.035,
                              vertical: screenHeight * 0.009,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              "Your goods will be here",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isFullscreenMode ? 14 : 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.04,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(screenHeight * 0.015),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PortColor.white,
                  boxShadow: [
                    BoxShadow(
                      color: PortColor.gray.withOpacity(0.9),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back, size: screenHeight * 0.025),
              ),
            ),
          ),
          // Fullscreen Button
          Positioned(
            top: screenHeight * 0.05,
            right: screenWidth * 0.04,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isFullscreenMode = !isFullscreenMode;
                });
              },
              child: Container(
                width: screenHeight * 0.05,
                height: screenHeight * 0.05,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PortColor.white,
                  boxShadow: [
                    BoxShadow(
                      color: PortColor.gray.withOpacity(0.9),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  isFullscreenMode ? Icons.fullscreen_exit : Icons.fullscreen,
                  size: screenHeight * 0.03,
                ),
              ),
            ),
          ),
          if (!isFullscreenMode)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: buildBottomSheet(context),
            ),
          if (isFullscreenMode)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: buildLocationDetailsSmall(),
            ),
        ],
      ),
    );
  }

  Widget buildBottomSheet(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    return Container(
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
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLocationDetails(),
                SizedBox(height: screenHeight * 0.03),
                CustomTextField(
                  controller: nameController,
                  height: screenHeight * 0.055,
                  cursorHeight: screenHeight * 0.023,
                  labelText: "Receiver's Name",
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z ]'),
                    ),
                  ],
                  suffixIcon: const Icon(
                    Icons.perm_contact_cal_outlined,
                    color: PortColor.blue,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomTextField(
                  controller: mobileController,
                  height: screenHeight * 0.055,
                  cursorHeight: screenHeight * 0.023,
                  labelText: "Receiver's Mobile Number",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  maxLength: 10,
                ),
                SizedBox(height: screenHeight * 0.02),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isContactDetailsSelected = !isContactDetailsSelected;
                      if (isContactDetailsSelected) {
                        // Fill mobile number
                        mobileController.text = profileViewModel
                            .profileModel!
                            .data!
                            .phone
                            .toString();

                        // Fill full name (first + last)
                        final firstName =
                            profileViewModel.profileModel!.data!.firstName ??
                                '';
                        final lastName =
                            profileViewModel.profileModel!.data!.lastName ?? '';
                        nameController.text = "$firstName $lastName"
                            .trim(); // Concatenate with a space
                      } else {
                        mobileController.clear();
                        nameController.clear(); // Clear name when unchecked
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        height: screenHeight * 0.025,
                        width: screenWidth * 0.056,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: PortColor.blue,
                            width: screenWidth * 0.004,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          color: isContactDetailsSelected
                              ? PortColor.blue
                              : Colors.transparent,
                        ),
                        child: isContactDetailsSelected
                            ? Icon(
                          Icons.check,
                          color: PortColor.blackLight,
                          size: screenHeight * 0.02,
                        )
                            : null,
                      ),
                      SizedBox(width: screenWidth * 0.028),
                      Row(
                        children: [
                          TextConst(
                            title: "Use My Mobile Number:",
                            color: PortColor.black,
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          TextConst(
                            title: profileViewModel.profileModel!.data!.phone
                                .toString(),
                            color: PortColor.blue,
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),
                TextConst(
                  title: "Save as (optional):",
                  color: PortColor.gray,
                  fontFamily: AppFonts.kanitReg,
                  size: 12,
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildSaveOption("Home", Icons.home_filled, null, 0),
                    buildSaveOption("Shop", null, Assets.assetsShop, 1),
                    buildSaveOption("Other", Icons.favorite, null, 2),
                  ],
                ),
              ],
            ),
          ),
          buildProceedButton(context),
        ],
      ),
    );
  }

  Widget buildLocationDetailsSmall() {
    return Container(
      height: screenHeight * 0.2,
      width: screenWidth,
      decoration: const BoxDecoration(
        color: PortColor.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15),
          topLeft: Radius.circular(15),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.015),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(
                  image: const AssetImage(Assets.assetsRedlocation),
                  height: screenHeight * 0.02,
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextConst(
                        title: selectedLocation,
                        color: PortColor.black,
                        fontFamily: AppFonts.poppinsReg,
                        size: 13,
                      ),
                      SizedBox(height: screenHeight * 0.007),
                      if (isLoadingAddress)
                        SizedBox(
                          height: screenHeight * 0.006,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                LinearProgressIndicator(
                                  value: 0.6,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: const AlwaysStoppedAnimation(
                                    Colors.transparent,
                                  ), // transparent
                                ),
                                Positioned.fill(
                                  child: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return LinearGradient(
                                        colors: [
                                          PortColor.yellowDiff,
                                          PortColor.yellowAccent,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ).createShader(bounds);
                                    },
                                    blendMode: BlendMode.srcIn,
                                    child: Container(
                                      color: Colors
                                          .white, // color is ignored, shader will override
                                    ),
                                  ),
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
          SizedBox(height: screenHeight * 0.02),
          Container(
            height: screenHeight * 0.086,
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
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isFullscreenMode = false;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  height: screenHeight * 0.055,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: PortColor.subBtn,
                  ),
                  child: TextConst(
                    title: "Confirm Drop Location",
                    color: Colors.black,
                    fontFamily: AppFonts.kanitReg,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLocationDetails() {
    return Row(
      children: [
        Image(
          image: const AssetImage(Assets.assetsRedlocation),
          height: screenHeight * 0.035,
        ),
        SizedBox(width: screenWidth * 0.009),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextConst(
                title: selectedLocation,
                color: PortColor.black,
                fontFamily: AppFonts.poppinsReg,
                size: 13,
              ),
              SizedBox(height: screenHeight * 0.005),
              if (isLoadingAddress)
                SizedBox(
                  height: screenHeight * 0.006,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        LinearProgressIndicator(
                          value: 0.6,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.transparent,
                          ), // transparent
                        ),
                        Positioned.fill(
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                colors: [
                                  PortColor.yellowDiff,
                                  PortColor.yellowAccent,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcIn,
                            child: Container(
                              color: Colors
                                  .white, // color is ignored, shader will override
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: screenHeight * 0.036,
            width: screenWidth * 0.14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: PortColor.gray),
            ),
            child: Center(
              child: TextConst(
                title: "Change",
                color: PortColor.blue,
                fontFamily: AppFonts.poppinsReg,
                size: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSaveOption(
      String label,
      IconData? icon,
      String? asset,
      int index,
      ) {
    bool isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        width: screenWidth * 0.25,
        height: screenHeight * 0.036,
        decoration: BoxDecoration(
          color: isSelected ? PortColor.gold : Colors.transparent,
          border: Border.all(
            color: isSelected ? PortColor.gold : PortColor.gray,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: isSelected ? PortColor.blackLight : PortColor.black,
                size: screenHeight * 0.02,
              ),
            if (asset != null)
              Image(
                image: AssetImage(asset),
                height: screenHeight * 0.02,
                color: isSelected ? Colors.black : null,
              ),
            SizedBox(width: screenWidth * 0.01),
            TextConst(
              title: label,
              color: isSelected ? PortColor.blackLight : PortColor.black,
              fontFamily: AppFonts.poppinsReg,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProceedButton(BuildContext context) {
    final orderViewModel = Provider.of<OrderViewModel>(context);

    bool isNameFilled = nameController.text.trim().isNotEmpty;
    bool isMobileValid =
        mobileController.text.length == 10 &&
            RegExp(r'^[6-9]\d{9}$').hasMatch(mobileController.text);
    bool canProceed = isNameFilled && isMobileValid;

    return Container(
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
        child: GestureDetector(
          onTap: canProceed
              ? () {
            String saveAs = "";
            if (selectedIndex == 0) {
              saveAs = "Home";
            } else if (selectedIndex == 1) {
              saveAs = "Shop";
            } else if (selectedIndex == 2) {
              saveAs = "Other";
            } else {
              saveAs = "Not Selected";
            }

            // 🔹 Final drop location data
            final data = {
              "address": selectedLocation,
              "name": nameController.text.trim(),
              "phone": mobileController.text.trim(),
              "latitude": selectedLatLng.latitude,
              "longitude": selectedLatLng.longitude,
              "save_as": saveAs,
            };

            orderViewModel.setLocationData(data);

            // 🔹 Navigate to next screen
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (_, __, ___) => SelectVehicles(),
                transitionsBuilder: (_, animation, __, child) {
                  final offsetAnimation =
                  Tween<Offset>(
                    begin: const Offset(0, 1), // start from bottom
                    end: Offset.zero, // end at normal position
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  );

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
            height: screenHeight * 0.055,
            width: screenWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: canProceed
                  ? PortColor.subBtn
                  : const LinearGradient(
                colors: [PortColor.grey, PortColor.grey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: TextConst(
              fontFamily: AppFonts.kanitReg,
              title: canProceed
                  ? "Confirm and Proceed"
                  : "Enter Contact Details",
              color: canProceed ? Colors.black : PortColor.gray,
              size: 14,
            ),
          ),
        ),
      ),
    );
  }
}
