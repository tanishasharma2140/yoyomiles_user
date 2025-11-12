import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:port_karo/generated/assets.dart';
import 'package:port_karo/main.dart';
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
import 'package:port_karo/utils/utils.dart';
import 'package:port_karo/view/home/apply_coupon/coupons_and_offers.dart';
import 'package:port_karo/view/order/widgets/goods_type_screen.dart';
import 'package:port_karo/view_model/apply_coupon_view_model.dart';
import 'package:port_karo/view_model/order_view_model.dart';
import 'package:port_karo/view_model/select_vehicles_view_model.dart';
import 'package:provider/provider.dart';

class ReviewBooking extends StatefulWidget {
  final int? index;
  final String vehicleName;
  final String price;
  final String distance;
  final String vehicleBodyDetailId;
  final String vehicleBodyTypeId;
  const ReviewBooking({
    super.key,
    this.index,
    required this.price,
    required this.distance,
    required this.vehicleBodyDetailId,
    required this.vehicleBodyTypeId, required this.vehicleName,
  });

  @override
  State<ReviewBooking> createState() => _ReviewBookingState();
}

class _ReviewBookingState extends State<ReviewBooking> {
  String PaymentMethod = "";
  String? selectedGoodsName;
  Map<String, dynamic>? selectedGoodsType;

  @override
  Widget build(BuildContext context) {
    print("tanishaaa");
    print(widget.vehicleBodyDetailId);
    print(widget.vehicleBodyTypeId);
    final applyCouponVm = Provider.of<ApplyCouponViewModel>(context);
    final orderViewModel = Provider.of<OrderViewModel>(context);
    final vehicle = Provider.of<SelectVehiclesViewModel>(
      context,
    ).selectVehicleModel!.data![widget.index!];
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
                  title: "Review Booking",
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
                                title: "View Address detail",
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
                            title: "Free",
                            color: PortColor.black.withOpacity(0.6),
                            fontFamily: AppFonts.poppinsReg,
                            size: 12,
                          ),
                          TextConst(
                            title: " 70 mins ",
                            color: PortColor.black,
                            fontFamily: AppFonts.kanitReg,
                            size: 12,
                          ),
                          TextConst(
                            title: "of loading and unloading tome include.",
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
                title: "Offers and Discounts",
                color: PortColor.black,
                fontFamily: AppFonts.kanitReg,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        CouponsAndOffers(price: widget.price),
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
                        title: "Coupon Applied",
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
                title: "Fare Summary",
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
                          title: "Trip Fare",
                          color: PortColor.black.withOpacity(0.8),
                          fontFamily: AppFonts.poppinsReg,
                          size: 12,
                        ),
                        TextConst(
                          title: " (Incl.Toll)",
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
                            title: "Discount 🎉🎉",
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
                            title: "Fare After Discount",
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
                          title: "GST (18%)",
                          color: PortColor.black.withOpacity(0.8),
                          fontFamily: AppFonts.poppinsReg,
                          size: 12,
                        ),
                        const Spacer(),
                        TextConst(
                          title:
                              applyCouponVm.discount != null &&
                                  applyCouponVm.discount != "0"
                              ? "₹${((double.parse(widget.price) - double.parse(applyCouponVm.discount.toString())) * 0.18).toStringAsFixed(0)}"
                              : "₹${(double.parse(widget.price) * 0.18).toStringAsFixed(0)}",
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
                          title:
                              applyCouponVm.discount != null &&
                                  applyCouponVm.discount != "0"
                              ? "₹${((double.parse(widget.price) - double.parse(applyCouponVm.discount.toString())) + ((double.parse(widget.price) - double.parse(applyCouponVm.discount.toString())) * 0.18)).toStringAsFixed(0)}"
                              : "₹${(double.parse(widget.price) + (double.parse(widget.price) * 0.18)).toStringAsFixed(0)}",
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
                          title: "Amount Payable",
                          color: PortColor.black.withOpacity(0.8),
                          fontFamily: AppFonts.poppinsReg,
                          size: 12,
                        ),
                        TextConst(
                          title: " (Rounded)",
                          color: PortColor.black.withOpacity(0.5),
                          fontFamily: AppFonts.poppinsReg,
                          size: 12,
                        ),
                        const Spacer(),
                        TextConst(
                          title:
                              applyCouponVm.discount != null &&
                                  applyCouponVm.discount != "0"
                              ? "₹${((double.parse(widget.price) - double.parse(applyCouponVm.discount.toString())) + ((double.parse(widget.price) - double.parse(applyCouponVm.discount.toString())) * 0.18)).toStringAsFixed(0)}"
                              : "₹${(double.parse(widget.price) + (double.parse(widget.price) * 0.18)).toStringAsFixed(0)}",
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
              title: "Goods Type",
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
                title: "Read before booking",
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
                          '• Fare doesn\'t include labour charges for loading & unloading',
                      color: PortColor.black,
                      fontFamily: AppFonts.kanitReg,
                      size: 12,
                    ),
                    const SizedBox(height: 8),
                    TextConst(
                      title:
                          '• Fare includes 70 mins free loading/unloading time.',
                      color: PortColor.black,
                      fontFamily: AppFonts.kanitReg,
                      size: 12,
                    ),
                    const SizedBox(height: 8),
                    TextConst(
                      title:
                          '• ₹ 3.5/min for additional loading/unloading time.',
                      color: PortColor.black,
                      fontFamily: AppFonts.kanitReg,
                      size: 12,
                    ),
                    const SizedBox(height: 8),
                    TextConst(
                      title: '• Fare may change if route or location changes.',
                      color: PortColor.black,
                      fontFamily: AppFonts.kanitReg,
                      size: 12,
                    ),
                    const SizedBox(height: 8),
                    TextConst(
                      title: '• Parking charges to be paid by customer.',
                      color: PortColor.black,
                      fontFamily: AppFonts.kanitReg,
                      size: 12,
                    ),
                    const SizedBox(height: 8),
                    TextConst(
                      title: '• Fare includes toll and permit charges, if any.',
                      color: PortColor.black,
                      fontFamily: AppFonts.kanitReg,
                      size: 12,
                    ),
                    const SizedBox(height: 8),
                    TextConst(
                      title: '• We don\'t allow overloading.',
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
                title: "Pay Mode",
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
                      child: Container(
                        height: 40,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextConst(
                                title: "Pay Via Cash",
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
                      child: Container(
                        height: 40,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextConst(
                                title: "Pay Via PG",
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
                  TextConst(title: " Payment", color: PortColor.black),
                  const Spacer(),
                  TextConst(
                    title:
                        applyCouponVm.discount != null &&
                            applyCouponVm.discount != "0"
                        ? "₹${((double.parse(widget.price) - double.parse(applyCouponVm.discount.toString())) + ((double.parse(widget.price) - double.parse(applyCouponVm.discount.toString())) * 0.18)).toStringAsFixed(0)}"
                        : "₹${(double.parse(widget.price) + (double.parse(widget.price) * 0.18)).toStringAsFixed(0)}",
                    color: PortColor.black,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.014),
              InkWell(
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

                  final applyCouponVm = Provider.of<ApplyCouponViewModel>(context, listen: false);
                  final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
                  final vehicle = Provider.of<SelectVehiclesViewModel>(context, listen: false)
                      .selectVehicleModel!
                      .data![widget.index!];

                  // ✅ Step 1: Calculate Final Amount (Discount + GST)
                  double finalAmount;
                  if (applyCouponVm.discount != null && applyCouponVm.discount != "0") {
                    final double base = double.parse(widget.price);
                    final double discount = double.parse(applyCouponVm.discount.toString());
                    final double discountedPrice = base - discount;
                    finalAmount = discountedPrice + (discountedPrice * 0.18);
                  } else {
                    final double base = double.parse(widget.price);
                    finalAmount = base + (base * 0.18);
                  }

                  print("✅ Final Amount to send in API: ₹${finalAmount.toStringAsFixed(0)}");

                  // ✅ Step 2: Call order API with computed amount
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
                    finalAmount.toStringAsFixed(0), // ✅ send calculated amount
                    widget.distance,
                    PaymentMethod,
                    [selectedGoodsType!],
                    orderViewModel.pickupData["order_type"],
                    orderViewModel.pickupData["pickup_date"],
                    orderViewModel.pickupData["save_as"],
                    orderViewModel.dropData["save_as"],
                    widget.vehicleBodyDetailId,
                    widget.vehicleBodyTypeId,
                    context,
                  );
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
                    size: 13,
                  ),
                ),
                GestureDetector(
                  onTap: onChange,
                  child: TextConst(
                    title: isTypeSelected ? "Change" : "Select",
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
