import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/res/custom_text_field.dart';
import 'package:yoyomiles/view_model/add_address_view_model.dart';
import 'package:yoyomiles/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

class SavePickUpAddressDetail extends StatefulWidget {
  final String selectedLocation;
  final LatLng selectedLatLng;

  const SavePickUpAddressDetail({
    super.key,
    required this.selectedLocation,
    required this.selectedLatLng,
  });

  @override
  State<SavePickUpAddressDetail> createState() =>
      _SavePickUpAddressDetailState();
}

class _SavePickUpAddressDetailState extends State<SavePickUpAddressDetail> {
  String selectedAddressType = "Home";
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController addressTypeController = TextEditingController();
  late String selectedLocation;
  late GoogleMapController mapController;
  final Completer<GoogleMapController> _controller = Completer();
  bool isContactDetailsSelected = false;
  bool isFullscreenMode = false;

  static const LatLng defaultPosition = LatLng(26.8467, 80.9462);
  LatLng selectedLatLng = defaultPosition;

  @override
  void initState() {
    super.initState();
    fetchLatLngForLocation();
  }

  void fetchLatLngForLocation() {
    setState(() {
      selectedLocation = widget.selectedLocation;
      selectedLatLng = widget.selectedLatLng;
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
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: selectedLatLng,
                draggable: false,
                infoWindow: InfoWindow(
                  title: "Selected Location",
                  snippet: selectedLocation,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
              ),
            },
            onMapCreated: (controller) {
              _controller.complete(controller);
              mapController = controller;
            },
          ),
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
                SizedBox(height: screenHeight * 0.02),
                CustomTextField(
                  controller: houseController,
                  height: screenHeight * 0.05,
                  cursorHeight: screenHeight * 0.023,
                  labelText: "House/ Apartment/ Shop(optional)",
                ),
                SizedBox(height: screenHeight * 0.02),
                CustomTextField(
                  controller: pinCodeController,
                  height: screenHeight * 0.05,
                  cursorHeight: screenHeight * 0.023,
                  labelText: "Pincode(optional)",
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                SizedBox(height: screenHeight * 0.02),
                CustomTextField(
                  controller: nameController,
                  height: screenHeight * 0.05,
                  cursorHeight: screenHeight * 0.023,
                  labelText: "Name",
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')), // ✅ only alphabets + space
                  ],                  suffixIcon: const Icon(
                    Icons.perm_contact_cal_outlined,
                    color: PortColor.gold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                CustomTextField(
                  controller: contactController,
                  height: screenHeight * 0.05,
                  cursorHeight: screenHeight * 0.023,
                  labelText: "Contact Number",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // ✅ only numbers allowed
                  ],
                  maxLength: 10,
                ),
                SizedBox(height: screenHeight * 0.02),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isContactDetailsSelected = !isContactDetailsSelected;

                      if (isContactDetailsSelected) {
                        // ✅ Fill text field with user's phone number
                        contactController.text =
                            profileViewModel.profileModel?.data?.phone?.toString() ?? '';
                      } else {
                        // ✅ Optionally clear it if unchecked
                        contactController.clear();
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
                            color: PortColor.gold,
                            width: screenWidth * 0.004,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          color: isContactDetailsSelected
                              ? PortColor.gold
                              : Colors.transparent,
                        ),
                        child: isContactDetailsSelected
                            ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: screenHeight * 0.02,
                        )
                            : null,
                      ),
                      SizedBox(width: screenWidth * 0.028),
                      Row(
                        children: [
                          TextConst(
                            title: "Use My Mobile Number: ",
                            color: PortColor.black,
                            fontFamily: AppFonts.poppinsReg,
                            size: 13,
                          ),
                          TextConst(
                            title: profileViewModel.profileModel?.data?.phone?.toString() ?? "",
                            color: PortColor.black,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),
                TextConst(title: "Save as (optional):", color: PortColor.gray),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildSaveOption("Home", Icons.home_filled),
                    buildSaveOption("Shop", Icons.home_work_outlined),
                    buildSaveOption("Other", Icons.favorite),
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
          Row(
            children: [
              Icon(Icons.location_on, color: PortColor.blue),
              SizedBox(width: screenWidth * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: screenWidth * 0.78,
                    child: TextConst(
                      title: selectedLocation,
                      color: PortColor.black,
                      fontFamily: AppFonts.kanitReg,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.007),
                ],
              ),
            ],
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
                vertical: screenHeight * 0.013,
              ),
              child: Container(
                alignment: Alignment.center,
                // height: screenHeight * 0.09,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: PortColor.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextConst(
                  title: "Confirm and Save",
                  color: Colors.white,
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
        Icon(Icons.location_on, color: PortColor.gold),
        SizedBox(width: screenWidth * 0.009),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: screenWidth * 0.5,
              child: TextConst(
                title: selectedLocation,
                color: PortColor.black,
                fontFamily: AppFonts.poppinsReg,
                size: 13,
              ),
            ),
            SizedBox(height: screenHeight * 0.007),
            // Container(
            //     width: screenWidth * 0.5,
            //     child: TextConst(
            //         text: selectedLocation, color: PortColor.black)),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Container(
            height: screenHeight * 0.038,
            width: screenWidth * 0.14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: PortColor.gray),
            ),
            child: Center(
              child: TextConst(
                title: "Change",
                color: PortColor.gold,
                fontFamily: AppFonts.poppinsReg,
                fontWeight: FontWeight.w600,
                size: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSaveOption(String label, IconData? icon, [String? asset]) {
    bool isSelected = selectedAddressType == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAddressType = label;
          addressTypeController.text = label;
        });
      },
      child: Container(
        width: screenWidth * 0.25,
        height: screenHeight * 0.036,
        decoration: BoxDecoration(
          color: isSelected ? PortColor.yellowDiff : Colors.transparent,
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
                color: isSelected ? Colors.white : PortColor.black,
                size: screenHeight * 0.02,
              ),
            SizedBox(width: screenWidth * 0.01),
            TextConst(
              title: label,
              color: isSelected ? Colors.white : PortColor.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProceedButton(BuildContext context) {
    bool isMobileNumberFilled =
        contactController.text.isNotEmpty &&
        contactController.text.length == 10;
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
          onTap: () {
            print("taapped");
            final addAddressViewModel = AddAddressViewModel();
            addAddressViewModel.addAddressApi(
              name: nameController.text,
              latitude: selectedLatLng.latitude,
              longitude: selectedLatLng.longitude,
              address: selectedLocation,
              addressType: selectedAddressType,
              houseArea: houseController.text,
              pinCode: pinCodeController.text,
              phone: contactController.text,
              context: context,
            );
          },
          child: Container(
            alignment: Alignment.center,
            height: screenHeight * 0.03,
            width: screenWidth,
            decoration: BoxDecoration(
              gradient: isMobileNumberFilled
                  ? PortColor.subBtn
                  : const LinearGradient(
                colors: [
                  PortColor.grey,
                  PortColor.grey, // same grey rakha
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextConst(
              title: isMobileNumberFilled ? "  Save" : "Save",
              color: isMobileNumberFilled ? Colors.black : PortColor.black,
              fontFamily: AppFonts.kanitReg,
            ),
          )

        ),
      ),
    );
  }
}
