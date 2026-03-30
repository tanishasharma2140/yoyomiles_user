  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
  import 'package:yoyomiles/main.dart';
  import 'package:yoyomiles/res/app_fonts.dart';
  import 'package:yoyomiles/res/constant_color.dart';
  import 'package:yoyomiles/res/constant_text.dart';
  import 'package:yoyomiles/utils/utils.dart';
  import 'package:yoyomiles/view/home/apply_coupon/coupons_and_offers.dart';
  import 'package:yoyomiles/view/order/widgets/goods_type_screen.dart';
  import 'package:yoyomiles/view_model/apply_coupon_view_model.dart';
  import 'package:yoyomiles/view_model/gst_percentage_view_model.dart';
  import 'package:yoyomiles/view_model/order_view_model.dart';
import 'package:yoyomiles/view_model/profile_view_model.dart';
  import 'package:yoyomiles/view_model/select_vehicles_view_model.dart';
  import 'package:provider/provider.dart';
import 'package:yoyomiles/view_model/settings_view_model.dart';
  import 'package:yoyomiles/view_model/vehicle_loading_view_model.dart';

  class ReviewBooking extends StatefulWidget {
    final int? index;
    final String vehicleName;
    final String price;
    final String distance;
    final String vehicleBodyDetailId;
    final String vehicleBodyTypeId;
    final String vehicleIds;
    const ReviewBooking({
      super.key,
      this.index,
      required this.price,
      required this.distance,
      required this.vehicleBodyDetailId,
      required this.vehicleBodyTypeId, required this.vehicleName, required this.vehicleIds,
    });

    @override
    State<ReviewBooking> createState() => _ReviewBookingState();
  }

  class _ReviewBookingState extends State<ReviewBooking> {

    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_){
        final vehicleLoadingVm = Provider.of<VehicleLoadingViewModel>(context, listen: false);
        vehicleLoadingVm.vehicleLoadingApi(widget.vehicleIds);
        final gstPercentageVm = Provider.of<GstPercentageViewModel>(context,listen: false);
        gstPercentageVm.gstPercentageApi();
        final settingsVm = Provider.of<SettingsViewModel>(context, listen: false);
        settingsVm.settingApi(context, "2");
      });
    }

    String PaymentMethod = "";
    String? selectedGoodsName;
    Map<String, dynamic>? selectedGoodsType;
    double selectedPrice = 0.0;

    @override
    Widget build(BuildContext context) {
      print("tanishaaa");
      print(widget.vehicleBodyDetailId);
      print(widget.vehicleBodyTypeId);
      final vehicleLoadingVm = Provider.of<VehicleLoadingViewModel>(context);
      final applyCouponVm = Provider.of<ApplyCouponViewModel>(context);
      final orderViewModel = Provider.of<OrderViewModel>(context);
      final vehicle = Provider.of<SelectVehiclesViewModel>(
        context,
      ).selectVehicleModel!.data![widget.index!];

      final gstAmountVm = Provider.of<GstPercentageViewModel>(context);
      final profileVm = Provider.of<ProfileViewModel>(context);
      final settingsVm = Provider.of<SettingsViewModel>(context);

// 🔥 Convert wallet to double safely
      double walletBalance = double.tryParse(
          profileVm.profileModel?.data?.wallet?.toString() ?? "0"
      ) ?? 0.0;

// GST amount from API (direct)
      double gstAmount = double.tryParse(
          gstAmountVm.gstPercentageModel?.data?.gstPercentage ?? "0") ??
          0.0;

// Base fare
      double baseFare = double.tryParse(widget.price) ?? 0.0;

// Discount
      double discount =
      (applyCouponVm.discount != null && applyCouponVm.discount != "0")
          ? double.tryParse(applyCouponVm.discount.toString()) ?? 0.0
          : 0.0;

      double fareAfterDiscount = baseFare - discount;

      double netFare =
      discount > 0 ? fareAfterDiscount + gstAmount : baseFare + gstAmount;

      bool canPayViaWallet = walletBalance >= netFare;
      final loc = AppLocalizations.of(context)!;

      void processOrder(double amount) {
        facebookAppEvents.logEvent(name: 'booking_for_logistics');

        orderViewModel.orderApi(
          vehicle.vehicleId.toString(),
          orderViewModel.pickupData["address"],
          orderViewModel.dropData["address"],
          orderViewModel.dropData["latitude"],
          orderViewModel.dropData["longitude"],
          orderViewModel.pickupData["latitude"],
          orderViewModel.pickupData["longitude"],
          orderViewModel.pickupData["name"],
          orderViewModel.pickupData["phone"],
          orderViewModel.dropData["name"],
          orderViewModel.dropData["phone"],
          amount.toStringAsFixed(0),
          widget.distance,
          PaymentMethod,
          [selectedGoodsType!],
          orderViewModel.pickupData["order_type"] ?? 1,
          orderViewModel.pickupData["pickup_date"],
          orderViewModel.pickupData["save_as"],
          orderViewModel.dropData["save_as"],
          widget.vehicleBodyDetailId,
          widget.vehicleBodyTypeId,
          context,
        );
      }

      void showPriceBottomSheet(BuildContext context, double basePrice) {
        double currentPrice = basePrice;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    top: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Handle bar
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Title
                           TextConst(
                             title:
                            "Now you can set a price\nthat works for you",
                            textAlign: TextAlign.center,
                             fontFamily: AppFonts.kanitReg,
                             size: 20,
                             fontWeight: FontWeight.bold,
                             color: Colors.black,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "₹${currentPrice.toStringAsFixed(0)}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.kanitReg,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Tip text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.lightbulb_outline,
                                  size: 16, color: Colors.grey),
                              SizedBox(width: 6),
                              TextConst(
                                title:
                                "Higher the price, higher the chance\nof getting a ride",
                                textAlign: TextAlign.center,
                                  color: Colors.grey, size: 13,
                                fontFamily: AppFonts.kanitReg,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Slider labels
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: ["-10", "+10", "+20", "+30", "+40"]
                                .map(
                                  (e) => Text(
                                e,
                                style: TextStyle(
                                  color: e == "-10"
                                      ? Colors.black
                                      : Colors.green,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            )
                                .toList(),
                          ),

                          const SizedBox(height: 8),

                          // Slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.green,
                              inactiveTrackColor: Colors.grey.shade300,
                              thumbColor: Colors.white,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 14,
                                elevation: 4,
                              ),
                              overlayColor:
                              Colors.green.withOpacity(0.2),
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: currentPrice,
                              min: basePrice - 10,
                              max: basePrice + 40,
                              divisions: 5,
                              onChanged: (val) {
                                setModalState(() {
                                  currentPrice = val;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Book Button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedPrice = currentPrice;
                              });

                              Navigator.pop(context);
                              processOrder(currentPrice);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 54,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: const Color(0xFFFFC107),
                              ),
                              child: Text(
                                "Book ${widget.vehicleName} for ₹${currentPrice.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ❌ Cross Icon (Top Right)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      }
      return SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: PortColor.bg,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(screenHeight * 0.06),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: screenHeight * 0.025),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: PortColor.black,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  TextConst(
                    title: loc.review_booking,
                    color: PortColor.black,
                    size: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),

          body: ListView(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.035,
                  vertical: screenHeight * 0.02,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.018,
                  ),
                  height: screenHeight * 0.17,
                  decoration: BoxDecoration(
                    color: PortColor.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 0.5,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.network(
                            vehicle.vehicleImage.toString(),
                            height: screenHeight * 0.065,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                Assets.assetsPortericon,
                                height: screenHeight * 0.065,
                              );
                            },
                          ),
                          SizedBox(width: screenWidth * 0.035),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextConst(
                                title: vehicle.vehicleName.toString(),
                                color: PortColor.black,
                                fontFamily: AppFonts.poppinsReg,
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: TextConst(
                                  title: loc.view_add_detail,
                                  color: PortColor.gold,
                                  fontFamily: AppFonts.poppinsReg,
                                ),
                              ),
                            ],
                          ),
                          // Spacer(),
                          // TextConst(text: " 14 mins ", color: Colors.green),
                          // TextConst(text: "away", color: Colors.black),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                        ),
                        height: screenHeight * 0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [
                              PortColor.lightGreen,
                              PortColor.lightGreen2,
                              PortColor.white,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.alarm, size: screenHeight * 0.018),
                            SizedBox(width: screenWidth * 0.01),
                            TextConst(
                              title: loc.free,
                              color: PortColor.black.withOpacity(0.6),
                              fontFamily: AppFonts.poppinsReg,
                              size: 12,
                            ),
                            TextConst(
                              title: " ${vehicleLoadingVm.vehicleLoadingModel?.data?.loadingTimeMinute??"0"}${loc.mins} ",
                              color: PortColor.black,
                              fontFamily: AppFonts.kanitReg,
                              size: 12,
                            ),
                            TextConst(
                              title: loc.of_loading_unloading,
                              color: PortColor.black.withOpacity(0.6),
                              fontFamily: AppFonts.poppinsReg,
                              size: 12,
                            ),
                            // Icon(
                            //   Icons.info_outline,
                            //   color: PortColor.blue,
                            //   size: screenHeight * 0.025,
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
                child: TextConst(
                  title: loc.offer_discount,
                  color: PortColor.black,
                  fontFamily: AppFonts.kanitReg,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              GestureDetector(
                onTap: () {
                  final applyCouponVm =
                  Provider.of<ApplyCouponViewModel>(context, listen: false);

                  applyCouponVm.setVehicleId(widget.vehicleIds);
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 400),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          CouponsAndOffers(price: widget.price, vehicleId: widget.vehicleIds,),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0); // bottom se start
                            const end = Offset.zero; // normal position
                            const curve = Curves.easeInOut;

                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 0.5,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          Assets.assetsApplyCoupon,
                          height: 30,
                          width: 30,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 6),
                        TextConst(
                          title: loc.coupon_applied,
                          fontFamily: AppFonts.kanitReg,
                          size: 14,
                          color: PortColor.black,
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                          color: PortColor.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
                child: TextConst(
                  title: loc.fare_summary,
                  color: PortColor.black,
                  fontFamily: AppFonts.kanitReg,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.028,
                  ),
                  decoration: BoxDecoration(
                    color: PortColor.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 0.5,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          TextConst(
                            title: loc.trip_fare,
                            color: PortColor.black.withOpacity(0.8),
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                          TextConst(
                            title: loc.incl_toll,
                            color: PortColor.black.withOpacity(0.5),
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                          const Spacer(),
                          TextConst(
                            title: "₹${(widget.price)}",
                            color: PortColor.black,
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.012),

                      // Discount Row - Show only if discount is available
                      if (applyCouponVm.discount != null &&
                          applyCouponVm.discount != "0")
                        Row(
                          children: [
                            TextConst(
                              title: loc.discount,
                              color: PortColor.black.withOpacity(0.8),
                              fontFamily: AppFonts.poppinsReg,
                              size: 12,
                            ),
                            const Spacer(),
                            TextConst(
                              title: "-₹${applyCouponVm.discount ?? "0"}",
                              color: Colors.green,
                              fontFamily: AppFonts.poppinsReg,
                              size: 12,
                            ),
                          ],
                        ),

                      if (applyCouponVm.discount != null &&
                          applyCouponVm.discount != "0")
                        SizedBox(height: screenHeight * 0.012),

                      // Calculate fare after discount
                      if (applyCouponVm.discount != null &&
                          applyCouponVm.discount != "0")
                        Row(
                          children: [
                            TextConst(
                              title: loc.fare_after_discount,
                              color: PortColor.black.withOpacity(0.8),
                              fontFamily: AppFonts.poppinsReg,
                              size: 12,
                            ),
                            const Spacer(),
                            TextConst(
                              title:
                                  "₹${(double.parse(widget.price) - double.parse(applyCouponVm.discount.toString())).toStringAsFixed(0)}",
                              color: PortColor.black,
                              fontFamily: AppFonts.poppinsReg,
                              size: 12,
                            ),
                          ],
                        ),

                      if (applyCouponVm.discount != null &&
                          applyCouponVm.discount != "0")
                        SizedBox(height: screenHeight * 0.012),

                      // GST Calculation on discounted amount
                      Row(
                        children: [
                          TextConst(
                            title: loc.booking_fees_conv_charge,
                            color: PortColor.black.withOpacity(0.8),
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                          const Spacer(),
                          TextConst(
                            title: "₹${gstAmount}",
                            color: Colors.green,
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                        ],
                      ),


                      SizedBox(height: screenHeight * 0.01),
                      const Divider(),
                      SizedBox(height: screenHeight * 0.01),

                      // Net Fare Calculation
                      Row(
                        children: [
                          TextConst(
                            title: "Net Fare",
                            color: PortColor.black.withOpacity(0.8),
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                          const Spacer(),
                          TextConst(
                            title: "₹${netFare.toStringAsFixed(2)}",
                            color: PortColor.black,
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                        ],
                      ),



                      SizedBox(height: screenHeight * 0.01),
                      const Divider(),
                      SizedBox(height: screenHeight * 0.005),

                      // Amount Payable
                      Row(
                        children: [
                          TextConst(
                            title: loc.amount_payable,
                            color: PortColor.black.withOpacity(0.8),
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                          TextConst(
                            title: loc.exact,
                            color: PortColor.black.withOpacity(0.5),
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                          const Spacer(),
                          TextConst(
                            title: "₹${netFare.toStringAsFixed(2)}",
                            color: PortColor.black,
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                        ],
                      ),


                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              GoodsTypeCard(
                title: loc.good_type,
                selectedType: selectedGoodsName ?? "Select Goods Type",
                onChange: () async {
                  final result = await Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const GoodsTypeScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            final tween = Tween(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeInOut));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      selectedGoodsName = result["goods_name"];
                      selectedGoodsType = {
                        "id": result["id"].toString(),
                        "goods_name": result["goods_name"],
                      };
                    });
                  }
                },
              ),

              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
                child: TextConst(
                  title: loc.read_before_booking,
                  color: PortColor.black,
                  fontFamily: AppFonts.kanitReg,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 0.5,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextConst(
                        title:
                            loc.labour_charges,
                        color: PortColor.black,
                        fontFamily: AppFonts.kanitReg,
                        size: 12,
                      ),
                      const SizedBox(height: 8),
                      TextConst(
                        title:
                            '${loc.fare_include} ${vehicleLoadingVm.vehicleLoadingModel?.data?.loadingTimeMinute??"0"} ${loc.min_free_loading}',
                        color: PortColor.black,
                        fontFamily: AppFonts.kanitReg,
                        size: 12,
                      ),
                      // const SizedBox(height: 8),
                      // TextConst(
                      //   title:
                      //       '• ₹ 3.5/min for additional loading/unloading time.',
                      //   color: PortColor.black,
                      //   fontFamily: AppFonts.kanitReg,
                      //   size: 12,
                      // ),
                      // const SizedBox(height: 8),
                      // TextConst(
                      //   title: '• Fare may change if route or location changes.',
                      //   color: PortColor.black,
                      //   fontFamily: AppFonts.kanitReg,
                      //   size: 12,
                      // ),
                      const SizedBox(height: 8),
                      TextConst(
                        title: loc.parking_charge,
                        color: PortColor.black,
                        fontFamily: AppFonts.kanitReg,
                        size: 12,
                      ),
                      const SizedBox(height: 8),
                      TextConst(
                        title: loc.fare_include_toll,
                        color: PortColor.black,
                        fontFamily: AppFonts.kanitReg,
                        size: 12,
                      ),
                      const SizedBox(height: 8),
                      TextConst(
                        title: loc.we_dont_allow,
                        color: PortColor.black,
                        fontFamily: AppFonts.kanitReg,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.007),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
                child: TextConst(
                  title: loc.pay_mode,
                  color: PortColor.black,
                  fontFamily: AppFonts.kanitReg,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    // vertical: screenHeight * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: PortColor.white,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 0.5,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            PaymentMethod = "1";
                          });
                        },
                        child: SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextConst(
                                  title: loc.pay_via_cash,
                                  color: PortColor.black,
                                  fontFamily: AppFonts.poppinsReg,
                                  size: 13,
                                ),
                              ),
                              if (PaymentMethod == "1")
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                        ),
                      ),
                      // SizedBox(height: screenHeight * 0.01),
                      const Divider(),
                      // SizedBox(height: screenHeight * 0.01),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            PaymentMethod = "2";
                          });
                        },
                        child: SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextConst(
                                  title: loc.pay_via_online,
                                  color: PortColor.black,
                                  fontFamily: AppFonts.poppinsReg,
                                  size: 13,
                                ),
                              ),
                              if (PaymentMethod == "2")
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (canPayViaWallet) ...[
                        const Divider(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              PaymentMethod = "3";
                            });
                          },
                          child: SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextConst(
                                    title: loc.pay_via_wallet,
                                    fontFamily: AppFonts.poppinsReg,
                                    size: 13,
                                  ),
                                ),
                                if (PaymentMethod == "3")
                                  const Icon(Icons.check_circle, color: Colors.green),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.2),
            ],
          ),
          bottomSheet: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.025,
              vertical: screenHeight * 0.012,
            ),
            height: screenHeight * 0.17,
            color: PortColor.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Image(
                      image: const AssetImage(Assets.assetsRupeetwo),
                      height: screenHeight * 0.04,
                    ),
                    TextConst(title: loc.payment, color: PortColor.black),
                    const Spacer(),
                    TextConst(
                      title: "₹${netFare.toStringAsFixed(2)}",
                      color: PortColor.black,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.014),
                GestureDetector(
                  onTap: () {
                    print("Booking button tapped ✅");

                    if (selectedGoodsType == null) {
                      Utils.showErrorMessage(context, "Please Select Goods Type");
                      return;
                    }

                    if (PaymentMethod.isEmpty) {
                      Utils.showErrorMessage(context, "Please select Pay Mode");
                      return;
                    }

                    double minBidLimit = double.tryParse(
                            settingsVm.settingsModel?.data?.minBidLimit
                                    ?.toString() ??
                                "0") ??
                        0.0;

                    if (minBidLimit < netFare) {
                      showPriceBottomSheet(context, netFare);
                    } else {
                      processOrder(netFare);
                    }
                  },


                  child: Container(
                    alignment: Alignment.center,
                    height: screenHeight * 0.06,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: PortColor.subBtn,
                    ),
                    child: !orderViewModel.loading
                        ? TextConst(
                            title: vehicle.vehicleName.toString(),
                            color: PortColor.black,
                            fontFamily: AppFonts.kanitReg,
                          )
                        : CupertinoActivityIndicator(
                            radius: 16,
                            color: PortColor.white,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget payment({required String text, required Color color}) {
      return Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: color),
      );
    }
  }

  class GoodsTypeCard extends StatelessWidget {
    final String title;
    final String selectedType;
    final VoidCallback onChange;

    const GoodsTypeCard({
      super.key,
      required this.title,
      required this.selectedType,
      required this.onChange,
    });

    @override
    Widget build(BuildContext context) {
      double screenWidth = MediaQuery.of(context).size.width;
      final loc = AppLocalizations.of(context)!;

      // ✅ Condition to check if a type is selected
      bool isTypeSelected = selectedType != "Select Goods Type";

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.035,
          vertical: 8,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 0.5,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon + Title
              Row(
                children: [
                  const Icon(Icons.grid_view, size: 18, color: PortColor.gray),
                  const SizedBox(width: 6),
                  TextConst(
                    title: title,
                    fontFamily: AppFonts.kanitReg,
                    size: 14,
                    fontWeight: FontWeight.w500,
                    color: PortColor.gray,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextConst(
                      title: selectedType,
                      fontFamily: AppFonts.kanitReg,
                      fontWeight: FontWeight.w600,
                      size: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: onChange,
                    child: TextConst(
                      title: isTypeSelected ? loc.change : loc.select,
                      color: PortColor.blue,
                      fontFamily: AppFonts.poppinsReg,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
