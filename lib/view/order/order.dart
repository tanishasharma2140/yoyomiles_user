import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/utils/routes/routes.dart';
import 'package:yoyomiles/view_model/driver_rating_view_model.dart';
import 'package:yoyomiles/view_model/user_history_view_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// ─── Stop Model ──────────────────────────────────────────────────────────────

class StopModel {
  final String name;
  final String phone;
  final double lat;
  final double lng;
  final String address;
  final int status; // 1 = reached, 0 = pending

  StopModel({
    required this.name,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.address,
    required this.status,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) {
    return StopModel(
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      address: json['address']?.toString() ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Parses the stops JSON string safely. Returns empty list on any error.
List<StopModel> parseStops(dynamic stopsRaw) {
  if (stopsRaw == null) return [];
  try {
    final String stopsStr = stopsRaw.toString().trim();
    if (stopsStr.isEmpty || stopsStr == 'null') return [];
    final List<dynamic> jsonList = jsonDecode(stopsStr);
    return jsonList
        .map((e) => StopModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    final userHistoryViewModel = Provider.of<UserHistoryViewModel>(context);
    final loc = AppLocalizations.of(context)!;
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
              title: loc.orders,
              color: PortColor.black,
              fontFamily: AppFonts.kanitReg,
              size: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
    final loc = AppLocalizations.of(context)!;

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

          // ── Parse stops for this order ──
          final List<StopModel> stops = parseStops(history.stops);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.01,
                ),
                child: TextConst(title: loc.past, color: PortColor.gray),
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
                              title: formatDateTime(
                                history.datetime.toString(),
                              ),
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
                        if (history.rideStatus == 6)
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
                                if (history.invoiceLink != null &&
                                    history.invoiceLink
                                        .toString()
                                        .isNotEmpty) {
                                  openInvoicePdf(
                                    history.invoiceLink.toString(),
                                  );
                                }
                              },
                              child: Icon(
                                Icons.download,
                                color: PortColor.blue,
                                size: 18,
                              ),
                            ),
                          )
                        else
                          const SizedBox(),
                      ],
                    ),

                    // ── Pickup / Stops / Drop Section ──
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
                                // ── Left timeline column ──
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: _buildTimeline(stops),
                                ),

                                SizedBox(width: screenWidth * 0.03),

                                // ── Right address column ──
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      // PICKUP
                                      if (history.orderType != 2) ...[
                                        Row(
                                          children: [
                                            TextConst(
                                              title:
                                              history.senderName ?? "",
                                              color: PortColor.black,
                                              fontFamily: AppFonts.kanitReg,
                                            ),
                                            SizedBox(
                                                width: screenWidth * 0.015),
                                            TextConst(
                                              title: history.senderPhone
                                                  .toString(),
                                              color: PortColor.gray,
                                              fontFamily:
                                              AppFonts.poppinsReg,
                                              size: 13,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.7,
                                          child: TextConst(
                                            title:
                                            history.pickupAddress ?? "",
                                            color: PortColor.gray,
                                            fontFamily: AppFonts.poppinsReg,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            size: 12,
                                          ),
                                        ),
                                      ] else ...[
                                        SizedBox(
                                          width: screenWidth * 0.7,
                                          child: TextConst(
                                            title:
                                            history.pickupAddress ?? "",
                                            color: PortColor.gray,
                                            fontFamily: AppFonts.poppinsReg,
                                            size: 12,
                                          ),
                                        ),
                                      ],

                                      // ── STOPS (if any) ──
                                      if (stops.isNotEmpty) ...[
                                        for (final stop in stops) ...[
                                          SizedBox(
                                              height: screenHeight * 0.02),
                                          _buildStopRow(stop),
                                        ],
                                      ],

                                      SizedBox(height: screenHeight * 0.02),

                                      // DROP
                                      if (history.orderType != 2) ...[
                                        Row(
                                          children: [
                                            TextConst(
                                              title:
                                              history.reciverName ?? "",
                                              color: PortColor.black,
                                              fontFamily: AppFonts.kanitReg,
                                            ),
                                            SizedBox(
                                                width: screenWidth * 0.015),
                                            TextConst(
                                              title: history.reciverPhone
                                                  .toString(),
                                              color: PortColor.gray,
                                              fontFamily:
                                              AppFonts.poppinsReg,
                                              size: 13,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.7,
                                          child: TextConst(
                                            title:
                                            history.dropAddress ?? "",
                                            color: PortColor.gray,
                                            fontFamily: AppFonts.poppinsReg,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            size: 12,
                                          ),
                                        ),
                                      ] else ...[
                                        SizedBox(
                                          width: screenWidth * 0.7,
                                          child: TextConst(
                                            title:
                                            history.dropAddress ?? "",
                                            color: PortColor.gray,
                                            fontFamily: AppFonts.poppinsReg,
                                            size: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Payment Status
                            SizedBox(height: screenHeight * 0.01),
                            Padding(
                              padding: EdgeInsets.only(
                                left: screenWidth * 0.08,
                              ),
                              child: Row(
                                children: [
                                  TextConst(
                                    title: loc.payment_status,
                                    color: PortColor.black,
                                    fontFamily: AppFonts.kanitReg,
                                    size: 12,
                                  ),
                                  TextConst(
                                    title: history.rideStatus == 6
                                        ? loc.success
                                        : loc.failed,
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
                              padding: EdgeInsets.only(
                                left: screenWidth * 0.08,
                              ),
                              child: Row(
                                children: [
                                  TextConst(
                                    title: loc.pay,
                                    color: PortColor.black,
                                    fontFamily: AppFonts.kanitReg,
                                    size: 12,
                                  ),
                                  TextConst(
                                    title: history.paymode == 1
                                        ? loc.cash_on_delivery
                                        : history.paymode == 2
                                        ? loc.online_payment
                                        : history.paymode == 3
                                        ? loc.by_wallet
                                        : loc.nothing,
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
                                    ? loc.completed
                                    : history.rideStatus == 7
                                    ? loc.cancel_by_user
                                    : history.rideStatus == 8
                                    ? loc.cancel_by_driver
                                    : loc.nothing,
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

                          (history.userRating != null &&
                              history.rideStatus != 7 &&
                              history.rideStatus != 8)
                              ? Row(
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  double rating =
                                      double.tryParse(
                                        history.userRating.toString(),
                                      ) ??
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
                              : (history.rideStatus == 7 ||
                              history.rideStatus == 8)
                              ? const SizedBox()
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
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  TextConst(
                                    title: loc.rate_ride,
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

  // ── Timeline dots + dashes for pickup → stops → drop ──────────────────────
  Widget _buildTimeline(List<StopModel> stops) {
    // Total segments = 1 (pickup→first stop or drop) + stops count
    // We draw: green dot → dashes → (orange dot → dashes) × stops → red pin

    return Column(
      children: [
        // Pickup green dot
        Container(
          width: screenWidth * 0.04,
          height: screenHeight * 0.012,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        // Dashes from pickup to first stop (or drop)
        _dashes(),

        // For each stop: orange dot + dashes
        for (int i = 0; i < stops.length; i++) ...[
          Container(
            width: screenWidth * 0.035,
            height: screenWidth * 0.035,
            decoration: BoxDecoration(
              color: stops[i].status == 1
                  ? Colors.orange
                  : Colors.orange.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              stops[i].status == 1 ? Icons.check : Icons.more_horiz,
              color: Colors.white,
              size: 12,
            ),
          ),
          _dashes(),
        ],

        // Drop red pin
        Icon(
          Icons.location_on_rounded,
          color: PortColor.red,
          size: screenHeight * 0.024,
        ),
      ],
    );
  }

  Widget _dashes() {
    return Column(
      children: List.generate(
        14,
            (index) => Container(
          width: screenWidth * 0.003,
          height: screenHeight * 0.0025,
          margin: const EdgeInsets.symmetric(vertical: 1),
          color: PortColor.gray,
        ),
      ),
    );
  }

  // ── Single stop row ────────────────────────────────────────────────────────
  Widget _buildStopRow(StopModel stop) {
    final bool reached = stop.status == 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Name - flexible so it shrinks if needed
            Flexible(
              child: TextConst(
                title: stop.name,
                color: PortColor.black,
                fontFamily: AppFonts.kanitReg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: screenWidth * 0.015),
            TextConst(
              title: stop.phone,
              color: PortColor.gray,
              fontFamily: AppFonts.poppinsReg,
              size: 13,
            ),
            SizedBox(width: screenWidth * 0.015),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: reached
                    ? Colors.green.withOpacity(0.12)
                    : Colors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: reached ? Colors.green : Colors.orange,
                  width: 0.8,
                ),
              ),
              child: Text(
                reached ? "Reached" : "Pending",
                style: TextStyle(
                  fontSize: 10,
                  color: reached ? Colors.green : Colors.orange,
                  fontFamily: AppFonts.poppinsReg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: screenWidth * 0.7,
          child: TextConst(
            title: stop.address,
            color: PortColor.gray,
            fontFamily: AppFonts.poppinsReg,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            size: 12,
          ),
        ),
      ],
    );
  }

  void _showRatingDialog(BuildContext context, String driverId, String id) {
    final driverRating = Provider.of<DriverRatingViewModel>(
      context,
      listen: false,
    );
    final loc = AppLocalizations.of(context)!;

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
                    Text(
                      loc.rate_your_ride,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
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
                    Text(
                      _rating == 0
                          ? loc.tap_to_rate_your
                          : '${_rating.toInt()} ${loc.point_zero}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
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
                                  loc.cancel,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
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
                                    ? Center(
                                  child: CupertinoActivityIndicator(
                                    radius: 14,
                                    color: PortColor.white,
                                  ),
                                )
                                    : Text(
                                  loc.submit,
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
    final loc = AppLocalizations.of(context)!;
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
              title: loc.no_orders,
              color: PortColor.black,
              fontFamily: AppFonts.kanitReg,
              size: 14,
            ),
            SizedBox(height: screenHeight * 0.01),
            TextConst(
              title: loc.order_history,
              color: PortColor.gray,
              fontFamily: AppFonts.poppinsReg,
              size: 12,
            ),
            TextConst(
              title: loc.for_older,
              color: PortColor.gray,
              fontFamily: AppFonts.poppinsReg,
              size: 12,
            ),
            SizedBox(height: screenHeight * 0.025),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, RoutesName.bottomNavBar);
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
                  title: loc.book_now,
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

// ─── Invoice PDF opener ───────────────────────────────────────────────────────

Future<void> openInvoicePdf(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    debugPrint("Could not open PDF");
  }
}