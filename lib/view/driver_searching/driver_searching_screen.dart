import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:port_karo/view_model/update_ride_status_view_model.dart';
import 'package:port_karo/generated/assets.dart';
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/const_with_polyline_map.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
import 'package:port_karo/view/bottom_nav_bar.dart' show BottomNavigationPage;
import 'package:port_karo/view/payment_summary_screen.dart';
import 'package:provider/provider.dart';

class DriverSearchingScreen extends StatefulWidget {
  final Map<String, dynamic>? orderData;

  const DriverSearchingScreen({super.key, this.orderData});

  @override
  State<DriverSearchingScreen> createState() => _DriverSearchingScreenState();
}

class _DriverSearchingScreenState extends State<DriverSearchingScreen> {
  String? _currentAddress;
  late double screenHeight;
  late double screenWidth;

  // 🔥 FLAGS FOR DIALOGS
  bool _showRideCompletedDialog = false;
  bool _showRideCancelledDialog = false;
  bool _showOtpVerifiedDialog = false;
  bool _showCollectPaymentDialog = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
  }

  @override
  void initState() {
    super.initState();
    print("🟢 Received orderData: ${widget.orderData}");
  }

  int? _selectedIndex;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _reasons = [
    "Wrong/Inappropriate Vehicle",
    "My reason is not listed",
    "Driver asked me to cancel",
    "Changed my mind",
    "Driver issue - delaying to come",
    "Unable to contact driver",
    "Expected a shorter arrival time",
    "Driver asking for extra money",
    "Driver not moving",
  ];

  // ✅ SAFE CONVERSION METHODS
  double? _safeToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.tryParse(value);
      } catch (e) {
        print("❌ Error converting string to double: $value");
        return null;
      }
    }
    return null;
  }

  int? _safeToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.tryParse(value);
      } catch (e) {
        print("❌ Error converting string to int: $value");
        return null;
      }
    }
    return null;
  }

  void _showCancelBottomSheet() {
    final updateRideStatusVm = Provider.of<UpdateRideStatusViewModel>(
      context,
      listen: false,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Title
                    TextConst(
                      title: "Cancel Ride",
                      color: PortColor.black,
                      fontWeight: FontWeight.w600,
                      size: 18,
                    ),
                    const SizedBox(height: 4),
                    TextConst(
                      title: "Please choose a reason for cancellation 😊",
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 12),

                    // Reasons List
                    SizedBox(
                      height: (_reasons.length * 50).toDouble().clamp(150, 300),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _reasons.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    value: index,
                                    groupValue: _selectedIndex,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedIndex = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _reasons[index],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Buttons
                    Row(
                      children: [
                        // Go Back button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Go Back",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Submit button
                        Expanded(
                          child: GestureDetector(
                            onTap: _selectedIndex == null
                                ? null
                                : () {
                              updateRideStatusVm.updateRideApi(
                                context,
                                widget.orderData?['document_id'],
                                "7",
                              );
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: _selectedIndex == null
                                    ? Colors.red[200]
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  if (_selectedIndex != null)
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.4),
                                      offset: const Offset(0, 3),
                                      blurRadius: 5,
                                    ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "Submit",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // 🔥 RIDE COMPLETED DIALOG FOR CASH PAYMENT
  void _showRideCompletedDialogMethod() {
    if (_showRideCompletedDialog) {
      print("⚠️ Ride completed dialog already showing");
      return;
    }

    print("✅ Showing RIDE COMPLETED dialog for cash payment");

    setState(() {
      _showRideCompletedDialog = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _buildRideCompletedDialog();
      },
    ).then((_) {
      print("🔒 Ride completed dialog closed");
      setState(() {
        _showRideCompletedDialog = false;
      });
    });
  }

  // 🔥 RIDE CANCELLED DIALOG (Driver side cancellation - status 8)
  void _showRideCancelledDialogMethod(String orderId) {
    if (_showRideCancelledDialog) {
      print("⚠️ Ride cancelled dialog already showing");
      return;
    }

    print("❌ Showing RIDE CANCELLED dialog by driver for order: $orderId");

    setState(() {
      _showRideCancelledDialog = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _buildRideCancelledDialog(orderId);
      },
    ).then((_) {
      print("🔒 Ride cancelled dialog closed");
      setState(() {
        _showRideCancelledDialog = false;
      });
    });
  }

  // 🔥 RIDE COMPLETED DIALOG WIDGET
  Widget _buildRideCompletedDialog() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: PortColor.rapidGreen, size: 50),
              const SizedBox(height: 15),
              Text(
                "Ride Completed!🎉🎉",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: PortColor.gold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Your ride has been completed successfully. Thank you!",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PortColor.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(120, 45),
                ),
                onPressed: () {
                  print("🏠 OK pressed from ride completed");
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => BottomNavigationPage(),
                    ),
                        (route) => false,
                  );
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 RIDE CANCELLED DIALOG WIDGET (Driver side cancellation)
  Widget _buildRideCancelledDialog(String orderId) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel, color: Colors.red, size: 50),
              const SizedBox(height: 15),
              Text(
                "Ride Cancelled!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Your ride has been cancelled by driver",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Text(
                "Order ID: $orderId",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PortColor.gold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(120, 45),
                ),
                onPressed: () {
                  print("🏠 OK pressed from cancelled - Navigating to Home");
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => BottomNavigationPage(),
                    ),
                        (route) => false,
                  );
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get payment method text
  String _getPaymentMethodText(int payMode) {
    switch (payMode) {
      case 1:
        return "Cash";
      case 2:
        return "Online";
      default:
        return "Cash";
    }
  }

  // Helper method to get ride status text
  String _getRideStatusText(int rideStatus) {
    switch (rideStatus) {
      case 0:
        return "Waiting for driver";
      case 1:
        return "Accepted by driver";
      case 2:
        return "On the way to pickup";
      case 3:
        return "Arrived at Pickup Point";
      case 4:
        return "OTP Verified - Ride Started";
      case 5:
        return "Ride Completed";
      case 6:
        return "Ride Completed Successfully";
      case 7:
        return "Cancelled by User";
      case 8:
        return "Cancelled by Driver";
      default:
        return "Waiting for driver";
    }
  }

  // ✅ METHOD: Real-time data ke saath map build karein
  Widget _buildMapContainerWithData(Map<String, dynamic>? orderData) {
    return SizedBox(
      // height: screenHeight * 0.5,
      child: ConstWithPolylineMap(
        data: orderData != null
            ? [
          {
            'id': orderData['document_id'] ?? 'unknown',
            'pickup_address': orderData['pickup_address'],
            'pickup_latitute': orderData['pickup_latitute'],
            'pick_longitude': orderData['pick_longitude'],
            'drop_address': orderData['drop_address'],
            'drop_latitute': orderData['drop_latitute'],
            'drop_logitute': orderData['drop_logitute'],
            'ride_status': _safeToInt(orderData['ride_status']) ?? 0,
          },
        ]
            : null,
        rideStatus: _safeToInt(orderData?['ride_status']) ?? 0,
        backIconAllowed: false,
        onAddressFetched: (address) {
          if (_currentAddress != address) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _currentAddress = address;
              });
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderData?['document_id']?.toString();
    if (orderId == null) {
      return const Scaffold(body: Center(child: Text("Order ID not found")));
    }

    return Scaffold(
      backgroundColor: PortColor.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Trip Status",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('order')
            .doc(orderId)
            .snapshots(),
        builder: (context, orderSnapshot) {
          if (orderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!orderSnapshot.hasData || !orderSnapshot.data!.exists) {
            return const Center(child: Text("Order not found"));
          }

          final orderData =
              orderSnapshot.data!.data() as Map<String, dynamic>? ?? {};

          // ✅ SAFE CONVERSIONS FOR ALL NUMERIC FIELDS
          final rideStatus = _safeToInt(orderData['ride_status']) ?? 0;
          final driverId = orderData['accepted_driver_id'];
          final payMode = _safeToInt(orderData['paymode']) ?? 1;
          final amount = _safeToDouble(orderData['amount']) ?? 0.0;
          final distance = _safeToDouble(orderData['distance']) ?? 0.0;
          final firebaseOrderId = orderId;
          final otp = orderData['otp']?.toString() ?? "N/A";

          // ✅ DEBUG PRINT
          print("""
🔍 ORDER STATUS UPDATE:
   - Ride Status: $rideStatus (${_getRideStatusText(rideStatus)})
   - Driver ID: $driverId
   - Payment Mode: $payMode (${_getPaymentMethodText(payMode)})
   - OTP: $otp
   - Amount: $amount
""");

          // ✅ REAL-TIME ORDER DATA UPDATE WITH SAFE CONVERSIONS
          final updatedOrderData = {
            ...widget.orderData ?? {},
            'document_id': orderId,
            'ride_status': rideStatus,
            'pickup_latitute': orderData['pickup_latitute'],
            'pick_longitude': orderData['pick_longitude'],
            'drop_latitute': orderData['drop_latitute'],
            'drop_logitute': orderData['drop_logitute'],
            'pickup_address': orderData['pickup_address'],
            'drop_address': orderData['drop_address'],
            'otp': otp,
          };

          // 🔥 CONDITION 1: Online payment - navigate to PaymentSummaryScreen
          if (rideStatus == 5 && payMode == 2) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print("💳 Navigating to Payment Summary (Online Payment)");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentSummaryScreen(
                    amount: amount,
                    distance: distance,
                    firebaseOrderId: firebaseOrderId,
                  ),
                ),
              );
            });
          }

          // 🔥 CONDITION 2: Cash payment completed - show ride completed dialog
          if (rideStatus == 5 && payMode == 1 && !_showCollectPaymentDialog) {
            print("💵 STREAMBUILDER: Reached destination with cash payment - show collect payment dialog!");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showCollectPaymentDialogMethod();
            });
          }

          if (rideStatus == 6 && payMode == 1 && !_showRideCompletedDialog) {
            print("💵 STREAMBUILDER: Ride completed with cash payment!");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showRideCompletedDialogMethod();
            });
          }
          // 🔥 CONDITION 3: OTP Verified (Status 4) - show OTP verified dialog
          if (rideStatus == 4 && !_showOtpVerifiedDialog) {
            print("✅ STREAMBUILDER: OTP Verified - Ride Started!");
            WidgetsBinding.instance.addPostFrameCallback((_) {});
          }

          // 🔥 CONDITION 4: Ride cancelled by driver (status 8) - show cancelled dialog
          if (rideStatus == 8 && !_showRideCancelledDialog) {
            print("❌ STREAMBUILDER: Ride cancelled by driver detected!");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showRideCancelledDialogMethod(orderId);
            });
          }

          if (driverId == null) {
            // No driver assigned
            return _buildSearchingSection(updatedOrderData);
          }

          // Driver assigned, show driver info + OTP for appropriate status
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('driver')
                .doc(driverId.toString())
                .snapshots(),
            builder: (context, driverSnapshot) {
              if (driverSnapshot.connectionState == ConnectionState.waiting) {
                return _buildMainLayout(
                  middleSection: _buildSearchingStatus(),
                  orderData: updatedOrderData,
                  driverData: null,
                );
              }

              if (!driverSnapshot.hasData || !driverSnapshot.data!.exists) {
                return _buildMainLayout(
                  middleSection: _buildSearchingStatus(),
                  orderData: updatedOrderData,
                  driverData: null,
                );
              }

              final driverData =
              driverSnapshot.data!.data() as Map<String, dynamic>;

              return _buildMainLayout(
                middleSection: _buildDriverInfo(driverData),
                orderData: updatedOrderData,
                driverData: driverData,
              );
            },
          );
        },
      ),
    );
  }

  void _showCollectPaymentDialogMethod() {
    if (_showCollectPaymentDialog) return;
    _showCollectPaymentDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: PortColor.gold, width: 2),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black26,
          title: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[100]!, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_on, color: Colors.white, size: 18),
                ),
                SizedBox(width: 10),
                TextConst(
                  title: "Reached Destination",
                  size: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                ),
              ],
            ),
          ),
          content: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment, color: PortColor.grey, size: 14),
                    SizedBox(width: 6),
                    TextConst(
                      title: "Make Payment of Trip",
                      color: PortColor.blackLight,
                      size: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      _showCollectPaymentDialog = false;
    });
  }

  // Main Layout - UPDATED WITH PROPER OTP HANDLING
  Widget _buildMainLayout({
    required Widget middleSection,
    Map<String, dynamic>? orderData,
    Map<String, dynamic>? driverData,
  }) {
    final rideStatus = _safeToInt(orderData?['ride_status']) ?? 0;
    final payMode = _safeToInt(orderData?['paymode']) ?? 1;
    final otp = orderData?['otp']?.toString() ?? "N/A";

    String rideStatusText = _getRideStatusText(rideStatus);

    // ✅ UPDATED: Check if we should show OTP and Cancel Ride
    bool showOtpAndCancel = rideStatus >= 1 && rideStatus <= 3;
    bool showOtpSection = showOtpAndCancel && otp != "N/A" && otp.isNotEmpty;

    return Stack(
      children: [
        // Map stays fixed in the background - WITH REAL-TIME DATA
        _buildMapContainerWithData(orderData),

        // Draggable bottom sheet
        DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // small drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ✅ UPDATED: Ride status with icons
                    Column(
                      children: [
                        if (rideStatus == 4) // OTP Verified
                          Icon(Icons.verified, color: Colors.green, size: 40),
                        if (rideStatus == 5 || rideStatus == 6) // Completed
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 40,
                          ),
                        if (rideStatus == 7 || rideStatus == 8) // Cancelled
                          Icon(Icons.cancel, color: Colors.red, size: 40),

                        Center(
                          child: TextConst(
                            title: rideStatusText,
                            fontFamily: AppFonts.kanitReg,
                            fontWeight: FontWeight.bold,
                            size: 16,
                            color: _getStatusColor(rideStatus),
                          ),
                        ),

                        if (rideStatus == 6 && payMode == 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Payment completed with cash",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    middleSection,

                    if (showOtpSection) _buildOtpSection(otp),

                    // Address card
                    buildAddressCard(),

                    // Payment container
                    buildPaymentContainer(payMode),

                    if (showOtpAndCancel)
                      GestureDetector(
                        onTap: _showCancelBottomSheet,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: PortColor.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: PortColor.red),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: TextConst(
                            title: "Cancel Ride",
                            fontFamily: AppFonts.kanitReg,
                            color: PortColor.red,
                            size: 16,
                          ),
                        ),
                      ),

                    // ✅ COMPLETION MESSAGE for status 4,5,6
                    if (rideStatus >= 4 && rideStatus <= 6)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getStatusColor(rideStatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(rideStatus),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _getCompletionMessage(rideStatus),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(rideStatus),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getCompletionSubtitle(rideStatus, payMode),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _getStatusColor(rideStatus),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Helper method to get status color
  Color _getStatusColor(int rideStatus) {
    switch (rideStatus) {
      case 4: // OTP Verified
        return Colors.green;
      case 5: // Completed
      case 6: // Completed Successfully
        return Colors.green;
      case 7: // Cancelled by User
      case 8: // Cancelled by Driver
        return Colors.red;
      case 1: // Accepted
      case 2: // On the way
      case 3: // Arrived
        return PortColor.gold;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get completion message
  String _getCompletionMessage(int rideStatus) {
    switch (rideStatus) {
      case 4:
        return "🚗 Ride Started!";
      case 5:
      case 6:
        return "🎉 Trip Completed!";
      default:
        return "";
    }
  }

  // Helper method to get completion subtitle
  String _getCompletionSubtitle(int rideStatus, int payMode) {
    switch (rideStatus) {
      case 4:
        return "Your ride has started. Have a safe journey!";
      case 5:
        return payMode == 1
            ? "Payment completed with cash"
            : "Please complete the payment";
      case 6:
        return "Thank you for choosing our service";
      default:
        return "";
    }
  }

  // Searching Section
  Widget _buildSearchingSection(Map<String, dynamic>? orderData) {
    return _buildMainLayout(
      middleSection: _buildSearchingStatus(),
      orderData: orderData,
      driverData: null,
    );
  }

  Widget _buildSearchingStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextConst(
            title: "Searching for drivers nearby...",
            color: PortColor.gold,
          ),
          const SizedBox(height: 8),
          TextConst(
            title: "Finding partner near you.",
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(PortColor.gold),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  // OTP Section - ENHANCED WITH BETTER UI
  Widget _buildOtpSection(String otp) {
    print("🔑 OTP Section Called - OTP Value: $otp");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock Icon with background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),

              // OTP Label
              TextConst(
                title: "Your Trip OTP",
                color: Colors.blue[800],
                fontWeight: FontWeight.w600,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // OTP Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Text(
              otp,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
                fontFamily: AppFonts.kanitReg,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            "Share this OTP with driver at pickup time",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blue[700], fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Driver Info
  Widget _buildDriverInfo(Map<String, dynamic> driverData) {
    final name = driverData['driver_name'] ?? "Unknown Driver";
    final phone = driverData['phone']?.toString() ?? "N/A";
    final vehicle = driverData['vehicle_no'] ?? "N/A";
    final vehicleType = driverData['vehicle_type_name'] ?? "Vehicle";
    final driverImage =
        driverData['owner_selfie'] ??
            driverData['vehicle_type_image'] ??
            'assets/images/driver_avatar.png';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PortColor.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: driverImage.startsWith('http')
                ? NetworkImage(driverImage) as ImageProvider
                : AssetImage(driverImage),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConst(
                  title: "$vehicleType - $vehicle",
                  fontWeight: FontWeight.bold,
                  size: 15,
                ),
                Row(
                  children: [
                    TextConst(title: name, color: PortColor.blackLight),
                    SizedBox(width: screenWidth * 0.02),
                    TextConst(title: "• $phone", color: PortColor.blackLight),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: PortColor.gold.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.call, color: PortColor.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // Address Card
  Widget buildAddressCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PortColor.white,
        border: Border.all(color: PortColor.grey),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circles + Dotted Line
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: CustomPaint(painter: DottedLinePainter()),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _singleAddressDetail(
                      name:
                      widget.orderData?['sender_name'] ?? "Tanisha Sharma",
                      phone:
                      widget.orderData?['sender_phone']?.toString() ??
                          "7235947667",
                      address:
                      widget.orderData?['pickup_address'] ??
                          "Naya Khera, Jankipuram Extension,...",
                    ),
                    const SizedBox(height: 12),
                    _singleAddressDetail(
                      name:
                      widget.orderData?['reciver_name'] ?? "Tanisha Sharma",
                      phone:
                      widget.orderData?['reciver_phone']?.toString() ??
                          "7235947667",
                      address:
                      widget.orderData?['drop_address'] ??
                          "Tedhi Pulia, Sector H, Jankipuram, ...",
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }

  Widget _singleAddressDetail({
    required String name,
    required String phone,
    required String address,
  }) {
    final orderType = widget.orderData?['order_type']?.toString() ?? "1";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ⭐ SHOW ONLY IF order_type == 1
        if (orderType == "1") ...[
          Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: AppFonts.kanitReg,
                  color: PortColor.gold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "• $phone",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontFamily: AppFonts.kanitReg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],

        // ⭐ Address always visible
        Text(
          address,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            fontFamily: AppFonts.kanitReg,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }


  // Updated Payment Container with dynamic payment method
  Widget buildPaymentContainer(int payMode) {
    final paymentMethod = _getPaymentMethodText(payMode);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PortColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortColor.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(Assets.assetsRupeetwo, height: 50, width: 50),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextConst(
                title: paymentMethod,
                size: 16,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 4),
              Text(
                "Payment method",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: AppFonts.kanitReg,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "₹ ${widget.orderData?['amount'] ?? '456'}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: PortColor.gold,
              fontFamily: AppFonts.kanitReg,
            ),
          ),
        ],
      ),
    );
  }
}

// Dotted Line
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const double dashWidth = 3;
    const double dashSpace = 4;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
