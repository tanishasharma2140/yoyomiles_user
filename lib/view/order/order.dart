import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:port_karo/generated/assets.dart';
import 'package:port_karo/main.dart';
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
import 'package:port_karo/utils/routes/routes.dart';
import 'package:port_karo/view_model/driver_rating_view_model.dart';
import 'package:port_karo/view_model/user_history_view_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userHistoryViewModel = Provider.of<UserHistoryViewModel>(
        context,
        listen: false,
      );
      userHistoryViewModel.userHistoryApi();
    });
  }

  String formatDateTime(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  Future<void> generatePdf(context, history) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Order Invoice",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Vehicle: ${history.vehicleName ?? ""}"),
              pw.Text("Amount: ₹ ${history.amount ?? ""}"),
              pw.Text("Date: ${history.datetime.toString()}"),
              pw.SizedBox(height: 10),
              pw.Text(
                "Sender: ${history.senderName ?? ""} (${history.senderPhone})",
              ),
              pw.Text("Pickup Address: ${history.pickupAddress ?? ""}"),
              pw.SizedBox(height: 10),
              pw.Text(
                "Receiver: ${history.reciverName ?? ""} (${history.reciverPhone})",
              ),
              pw.Text("Drop Address: ${history.dropAddress ?? ""}"),
              pw.SizedBox(height: 20),
              pw.Text(
                "Payment Status: ${history.paymentStatus == 0
                    ? "Pending"
                    : history.paymentStatus == 1
                    ? "Success"
                    : "Failed"}",
              ),
              pw.Text(
                "Pay Mode: ${history.paymode == 1
                    ? "Cash on Delivery"
                    : history.paymode == 2
                    ? "Online Payment"
                    : "Nothing"}",
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/order_invoice_${history.id}.pdf");
    await file.writeAsBytes(await pdf.save());

    // ✅ Ab ye use karo
    await OpenFilex.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final userHistoryViewModel = Provider.of<UserHistoryViewModel>(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 20, left: 20),
          height: screenHeight * 0.095,
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
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextConst(
              title: "  Orders",
              color: PortColor.black,
              fontFamily: AppFonts.kanitReg,
              size: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Expanded to fill remaining screen
        Expanded(
          child:
              userHistoryViewModel.userHistoryModel != null &&
                  userHistoryViewModel.userHistoryModel!.data!.isNotEmpty
              ? orderListUi()
              : noOrderFoundUi(),
        ),
      ],
    );
  }

  Widget orderListUi() {
    final userHistoryViewModel = Provider.of<UserHistoryViewModel>(context);

    return RefreshIndicator(
      onRefresh: () async {
        await userHistoryViewModel.userHistoryApi();
      },
      color: PortColor.blue,
      backgroundColor: Colors.white,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: userHistoryViewModel.userHistoryModel?.data?.length ?? 0,
        itemBuilder: (context, index) {
          final history = userHistoryViewModel.userHistoryModel!.data![index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.01,
                ),
                child: TextConst(title: "Past", color: PortColor.gray),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                color: PortColor.white,
                child: Column(
                  children: [
                    // Vehicle & Amount Row
                    Row(
                      children: [
                        Image.network(history.vehicleImage ?? "", height: 50),
                        SizedBox(width: screenWidth * 0.03),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextConst(
                              title: history.vehicleName ?? "",
                              color: PortColor.black,
                            ),
                            TextConst(
                              title: formatDateTime(history.datetime.toString()),
                              color: PortColor.gray,
                              fontFamily: AppFonts.poppinsReg,
                              size: 12,
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextConst(
                          title: ("₹ ${history.amount?.toString() ?? ""}"),
                          color: PortColor.black,
                        ),
                        SizedBox(width: 8),
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.yellow.shade50,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              generatePdf(context, history);
                            },
                            child: Icon(
                              Icons.download,
                              color: PortColor.blue,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Pickup & Drop Address Section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.01,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                          vertical: screenHeight * 0.02,
                        ),
                        decoration: BoxDecoration(
                          color: PortColor.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:  EdgeInsets.only(top: 10),
                                  child: Column(
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
                                          14,
                                              (index) => Container(
                                            width: screenWidth * 0.003,
                                            height: screenHeight * 0.0025,
                                            margin:
                                            const EdgeInsets.symmetric(vertical: 1),
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
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ⭐ Sender Details
                                    if (history.orderType != 2) ...[
                                      Row(
                                        children: [
                                          TextConst(
                                            title: history.senderName ?? "",
                                            color: PortColor.black,
                                            fontFamily: AppFonts.kanitReg,
                                          ),
                                          SizedBox(width: screenWidth * 0.015),
                                          TextConst(
                                            title: history.senderPhone.toString(),
                                            color: PortColor.gray,
                                            fontFamily: AppFonts.poppinsReg,
                                            size: 13,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.7,
                                        child: TextConst(
                                          title: history.pickupAddress ?? "",
                                          color: PortColor.gray,
                                          fontFamily: AppFonts.poppinsReg,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          size: 12,
                                        ),
                                      ),
                                    ] else ...[
                                      // ⭐ order_type = 2 → NO NAME/NUMBER
                                      SizedBox(
                                        width: screenWidth * 0.7,
                                        child: TextConst(
                                          title: history.pickupAddress ?? "",
                                          color: PortColor.gray,
                                          fontFamily: AppFonts.poppinsReg,
                                          size: 12,
                                        ),
                                      ),
                                    ],

                                    SizedBox(height: screenHeight * 0.02),

                                    // ⭐ Receiver Details
                                    if (history.orderType != 2) ...[
                                      Row(
                                        children: [
                                          TextConst(
                                            title: history.reciverName ?? "",
                                            color: PortColor.black,
                                            fontFamily: AppFonts.kanitReg,
                                          ),
                                          SizedBox(width: screenWidth * 0.015),
                                          TextConst(
                                            title: history.reciverPhone.toString(),
                                            color: PortColor.gray,
                                            fontFamily: AppFonts.poppinsReg,
                                            size: 13,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.7,
                                        child: TextConst(
                                          title: history.dropAddress ?? "",
                                          color: PortColor.gray,
                                          fontFamily: AppFonts.poppinsReg,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          size: 12,
                                        ),
                                      ),
                                    ] else ...[
                                      // ⭐ order_type = 2 → NO NAME/NUMBER (ONLY Address)
                                      SizedBox(
                                        width: screenWidth * 0.7,
                                        child: TextConst(
                                          title: history.dropAddress ?? "",
                                          color: PortColor.gray,
                                          fontFamily: AppFonts.poppinsReg,
                                          size: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),

                            // Payment Status
                            SizedBox(height: screenHeight * 0.01),
                            Padding(
                              padding: EdgeInsets.only(left: screenWidth * 0.08),
                              child: Row(
                                children: [
                                  TextConst(
                                    title: "Payment Status: ",
                                    color: PortColor.black,
                                    fontFamily: AppFonts.kanitReg,
                                    size: 12,
                                  ),
                                  TextConst(
                                    title: history.rideStatus == 6
                                        ? "Success"
                                        : "Failed",
                                    color: history.rideStatus == 6
                                        ? Colors.green
                                        : Colors.red,
                                    fontFamily: AppFonts.poppinsReg,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),

                            // Pay Mode
                            SizedBox(height: screenHeight * 0.006),
                            Padding(
                              padding: EdgeInsets.only(left: screenWidth * 0.08),
                              child: Row(
                                children: [
                                  TextConst(
                                    title: "Pay Mode: ",
                                    color: PortColor.black,
                                    fontFamily: AppFonts.kanitReg,
                                    size: 12,
                                  ),
                                  TextConst(
                                    title: history.paymode == 1
                                        ? "Cash on Delivery"
                                        : history.paymode == 2
                                        ? "Online Payment"
                                        : "Nothing",
                                    color: PortColor.gray,
                                    fontFamily: AppFonts.poppinsReg,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Ride Status + Rating / Button
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.009,
                      ),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Icon(
                                history.rideStatus == 6
                                    ? Icons.check_circle
                                    : history.rideStatus == 7
                                    ? Icons.cancel
                                    : history.rideStatus == 8
                                    ? Icons.warning
                                    : Icons.help,
                                color: history.rideStatus == 6
                                    ? Colors.green
                                    : history.rideStatus == 7
                                    ? Colors.red
                                    : history.rideStatus == 8
                                    ? Colors.orange
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              TextConst(
                                title: history.rideStatus == 6
                                    ? "Completed"
                                    : history.rideStatus == 7
                                    ? "Cancel by User"
                                    : history.rideStatus == 8
                                    ? "Cancel by Driver"
                                    : "Nothing",
                                color: history.rideStatus == 6
                                    ? Colors.green
                                    : history.rideStatus == 7
                                    ? Colors.red
                                    : history.rideStatus == 8
                                    ? Colors.orange
                                    : Colors.grey,
                                fontFamily: AppFonts.kanitReg,
                              ),
                            ],
                          ),
                          const Spacer(),

                          // ⭐ Rating / Rate Ride Button
                          history.userRating != null
                              ? Row(
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  double rating = double.tryParse(
                                      history.userRating.toString()) ??
                                      0.0;
                                  return Icon(
                                    index < rating.round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
                              ),
                              SizedBox(width: 5),
                              TextConst(
                                title: '${history.userRating}/5',
                                color: Colors.black,
                                fontFamily: AppFonts.kanitReg,
                                size: 14,
                              ),
                            ],
                          )
                              : GestureDetector(
                            onTap: () {
                              _showRatingDialog(
                                context,
                                 history.id.toString(),
                                history.driverId.toString(),
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: screenHeight * 0.04,
                              width: screenWidth * 0.42,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  TextConst(
                                    title: 'Rate Ride',
                                    color: Colors.white,
                                    fontFamily: AppFonts.kanitReg,
                                    size: 14,
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
            ],
          );
        },
      ),
    );
  }

  void _showRatingDialog(
    BuildContext context,
    String driverId,
    String id,
  ) {
    final driverRating = Provider.of<DriverRatingViewModel>(
      context,
      listen: false,
    );

    double _rating = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              child: Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      'Rate Your Ride',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = (index + 1).toDouble();
                            });
                          },
                          child: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 40,
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: 12),

                    // Rating Text
                    Text(
                      _rating == 0
                          ? 'Tap to rate your experience'
                          : '${_rating.toInt()}.0 Star Rating',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),

                    SizedBox(height: 24),

                    // Buttons Container
                    Container(
                      height: 50,
                      child: Row(
                        children: [
                          // Cancel Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // Submit Button
                          Expanded(
                            child: GestureDetector(
                              onTap: _rating > 0
                                  ? () {
                                      driverRating.driverRatingApi(
                                        context,
                                        driverId,
                                        id,
                                        _rating.toString(),
                                      );
                                    }
                                  : null,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _rating > 0
                                      ? Colors.amber
                                      : Colors.amber.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: driverRating.loading
                                    ?  Center(
                                  child: CupertinoActivityIndicator(
                                    radius: 14,
                                    color: PortColor.white,
                                  ),
                                )
                                    : Text(
                                        'Submit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget noOrderFoundUi() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.15),
            Container(
              height: screenHeight * 0.2,
              width: screenHeight * 0.2,
              decoration: const BoxDecoration(
                color: PortColor.white,
                shape: BoxShape.circle,
                image: DecorationImage(image: AssetImage(Assets.assetsBox)),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            TextConst(
              title: "No Orders !",
              color: PortColor.black,
              fontFamily: AppFonts.kanitReg,
              size: 14,
            ),
            SizedBox(height: screenHeight * 0.01),
            TextConst(
              title: 'Order history limited to last 2 years',
              color: PortColor.gray,
              fontFamily: AppFonts.poppinsReg,
              size: 12,
            ),
            TextConst(
              title: 'For older orders, contact our support team.',
              color: PortColor.gray,
              fontFamily: AppFonts.poppinsReg,
              size: 12,
            ),
            SizedBox(height: screenHeight * 0.025),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context,RoutesName.bottomNavBar);
              },
              child: Container(
                alignment: Alignment.center,
                height: screenHeight * 0.05,
                width: screenWidth * 0.4,
                decoration: BoxDecoration(
                  gradient: PortColor.subBtn,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextConst(
                  title: 'Book Now',
                  color: PortColor.black,
                  fontFamily: AppFonts.kanitReg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
