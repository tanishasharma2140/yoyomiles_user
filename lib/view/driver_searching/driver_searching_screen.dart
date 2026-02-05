import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yoyomiles/view_model/contact_list_view_model.dart';
import 'package:yoyomiles/view_model/driver_ride_view_model.dart';
import 'package:yoyomiles/view_model/payment_view_model.dart';
import 'package:yoyomiles/view_model/update_ride_status_view_model.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/const_with_polyline_map.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view/bottom_nav_bar.dart';
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

  bool _showRideCompletedDialog = false;
  bool _showRideCancelledDialog = false;

  Timer? _searchTimer;
  bool _noDriverDialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
  }

  @override
  void initState() {
    super.initState();
    print("🟢 DriverSearchingScreen initialized");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListening();
      Provider.of<ContactListViewModel>(context, listen: false)
          .contactListApi();
    });
  }

  void _startListening() {
    final orderId =
        widget.orderData?['document_id']?.toString() ??
        widget.orderData?['id']?.toString();

    if (orderId == null) {
      print("❌ No order ID found");
      return;
    }

    print("🎧 Starting DriverRideViewModel listener for: $orderId");

    final driverRideVm = Provider.of<DriverRideViewModel>(
      context,
      listen: false,
    );
    driverRideVm.startListening(orderId);
  }

  @override
  void dispose() {
    // _cancelSearchTimeoutTimer();
    //
    // // Stop listener when leaving screen
    // final driverRideVm = Provider.of<DriverRideViewModel>(
    //   context,
    //   listen: false,
    // );
    // driverRideVm.stopListening();

    super.dispose();
  }

  int? _selectedIndex;
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

  void _startSearchTimeoutTimer() {
    if (_searchTimer != null || _noDriverDialogShown) return;

    _searchTimer = Timer(const Duration(minutes: 3), () {
      if (!mounted) return;
      _showNoDriverAvailableDialog();
    });
  }

  void _cancelSearchTimeoutTimer() {
    _searchTimer?.cancel();
    _searchTimer = null;
  }

  void _showNoDriverAvailableDialog() {
    if (_noDriverDialogShown) return;
    _noDriverDialogShown = true;
    _cancelSearchTimeoutTimer();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(height: 12),

                // TITLE
                const Text(
                  "Oops! Something went wrong",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                // MESSAGE
                Text(
                  "Please try again after some time.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 20),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _cancelSearchTimeoutTimer();

                      // Stop listener when leaving screen
                      final driverRideVm = Provider.of<DriverRideViewModel>(
                        context,
                        listen: false,
                      );
                      driverRideVm.stopListening();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => BottomNavigationPage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) => _noDriverDialogShown = false);
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
                  children: [
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
                    TextConst(
                      title: "Cancel Ride",
                      color: PortColor.black,
                      fontWeight: FontWeight.w600,
                      size: 18,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: (_reasons.length * 50).toDouble().clamp(150, 300),
                      child: ListView.builder(
                        itemCount: _reasons.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIndex = index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    value: index,
                                    groupValue: _selectedIndex,
                                    onChanged: (value) =>
                                        setState(() => _selectedIndex = value),
                                  ),
                                  Expanded(child: Text(_reasons[index])),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Go Back"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selectedIndex == null
                                ? null
                                : () {
                                    updateRideStatusVm.updateRideApi(
                                      context,
                                      widget.orderData?['document_id'],
                                      "7",
                                    );
                                    _cancelSearchTimeoutTimer();

                                    // Stop listener when leaving screen
                                    final driverRideVm =
                                        Provider.of<DriverRideViewModel>(
                                          context,
                                          listen: false,
                                        );
                                    driverRideVm.stopListening();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text("Submit"),
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

  void _showRideCompletedDialogMethod() {
    if (_showRideCompletedDialog) return;
    _showRideCompletedDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: PortColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 50),
                const SizedBox(height: 15),
                Text(
                  "Ride Completed!🎉",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: PortColor.gold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your ride has been completed successfully. Thank you!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PortColor.gold,
                    minimumSize: const Size(120, 45),
                  ),
                  onPressed: () {
                    _cancelSearchTimeoutTimer();

                    final driverRideVm = Provider.of<DriverRideViewModel>(
                      context,
                      listen: false,
                    );
                    driverRideVm.stopListening();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => BottomNavigationPage()),
                      (route) => false,
                    );
                  },
                  child: const Text("OK",style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => _showRideCompletedDialog = false);
  }

  void _showRideCancelledDialogMethod(String orderId) {
    if (_showRideCancelledDialog) return;
    _showRideCancelledDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cancel, color: Colors.red, size: 50),
                const SizedBox(height: 15),
                const Text(
                  "Ride Cancelled!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your ride has been cancelled by driver",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(120, 45),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => BottomNavigationPage()),
                      (route) => false,
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => _showRideCancelledDialog = false);
  }

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
        return "Reached destination";
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

  Widget _buildMapContainer(Map<String, dynamic>? orderData) {
    return SizedBox(
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
                  'ride_status': orderData['rideStatus'] ?? 0,
                },
              ]
            : null,
        rideStatus: orderData?['rideStatus'] ?? 0,
        backIconAllowed: false,
        onAddressFetched: (address) {
          if (_currentAddress != address && mounted) {
            setState(() => _currentAddress = address);
          }
        },
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: PortColor.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 42),
              const SizedBox(height: 18),
              const TextConst(
                title:
                "Exit Ride?",
                  size: 20, fontWeight: FontWeight.w700
              ),
              const SizedBox(height: 10),
              const TextConst(
                title:
                "Are you sure you want to exit this ride?",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("No",style: TextStyle(fontFamily: AppFonts.kanitReg,color:Colors.black),),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final driverRideVm = Provider.of<DriverRideViewModel>(
                          context,
                          listen: false,
                        );
                        driverRideVm.stopListening();
                        Provider.of<UpdateRideStatusViewModel>(
                          context,
                          listen: false,
                        ).updateRideApi(
                          context,
                          widget.orderData?['document_id'],
                          "9",
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Yes",style: TextStyle(fontFamily: AppFonts.kanitReg,color:Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: PortColor.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              if (await _onBackPressed()) Navigator.pop(context);
            },
          ),
          title: const Text(
            "Trip Status",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),

        body: Consumer<DriverRideViewModel>(
          builder: (context, driverRideVm, child) {
            final orderData = driverRideVm.currentRideData;

            if (orderData == null) {
              return const Center(
                child: CupertinoActivityIndicator(
                  radius: 14,
                  color: PortColor.gold,
                ),
              );
            }

            final rideStatus = driverRideVm.rideStatus;
            final payMode = driverRideVm.payMode;
            final orderId = orderData['document_id']?.toString() ?? '';

            // Status 5 = Reached destination → Show payment screen
            if (rideStatus == 5) {
              print("📍 Status 5 detected - Preparing to navigate to Payment");
              return CollectPaymentScreen(orderId: orderId);
            }

            // Status 6 = Payment completed → Show success dialog
            if (rideStatus == 6 && (payMode == 1 || payMode == 3) && !_showRideCompletedDialog) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                print("✅ Cash Payment - Showing Ride Completed Dialog NOW");
                _showRideCompletedDialogMethod();
              });
            }

            if (rideStatus == 8 && !_showRideCancelledDialog) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showRideCancelledDialogMethod(orderId);
              });
            }

            // Searching state
            if (driverRideVm.isSearching) {
              _startSearchTimeoutTimer();
            } else {
              _cancelSearchTimeoutTimer();
            }

            return _buildMainLayout(
              orderData: orderData,
              driverData: driverRideVm.driverData,
              rideStatus: rideStatus,
              payMode: payMode,
              otp: driverRideVm.otp,
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainLayout({
    required Map<String, dynamic> orderData,
    Map<String, dynamic>? driverData,
    required int rideStatus,
    required int payMode,
    required String otp,
  }) {
    // 🔥 Show searching only when status 0 AND no driver
    final isSearching = driverData == null && rideStatus == 0;
    final showOtpAndCancel = rideStatus >= 1 && rideStatus <= 3;
    final showOtp = showOtpAndCancel && otp != "N/A" && otp.isNotEmpty;

    return Stack(
      children: [
        _buildMapContainer(orderData),
        DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.65,
          maxChildSize: 0.65,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatusHeader(rideStatus, payMode),
                    const SizedBox(height: 16),

                    // 🔥 SAFE NULL CHECK - Show searching OR driver info
                    if (isSearching)
                      _buildSearchingStatus()
                    else if (driverData != null)
                      _buildDriverInfo(driverData)
                    else
                      _buildDriverLoadingPlaceholder(),

                    if (showOtp) _buildOtpSection(otp),
                    AddressCard(orderData: orderData),
                    _buildPaymentContainer(payMode, orderData),
                    if (showOtpAndCancel) _buildCancelButton(),
                    _buildEmergencySection(),
                    if (rideStatus >= 4 && rideStatus <= 6)
                      _buildCompletionMessage(rideStatus, payMode),
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

  // 🔥 LOADING PLACEHOLDER FOR DRIVER INFO
  Widget _buildDriverLoadingPlaceholder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(int rideStatus, int payMode) {
    return Column(
      children: [
        if (rideStatus == 4)
          Icon(Icons.verified, color: Colors.green, size: 40),
        if (rideStatus == 5 || rideStatus == 6)
          Icon(Icons.check_circle, color: Colors.green, size: 40),
        if (rideStatus == 7 || rideStatus == 8)
          Icon(Icons.cancel, color: Colors.red, size: 40),
        TextConst(
          title: _getRideStatusText(rideStatus),
          fontWeight: FontWeight.bold,
          size: 16,
          color: _getStatusColor(rideStatus),
        ),
      ],
    );
  }

  Color _getStatusColor(int status) {
    if (status >= 4 && status <= 6) return Colors.green;
    if (status == 7 || status == 8) return Colors.red;
    if (status >= 1 && status <= 3) return PortColor.gold;
    return Colors.grey;
  }

  Widget _buildSearchingStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextConst(
            title: "Searching for drivers nearby...",
            color: PortColor.gold,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(PortColor.gold),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(Map<String, dynamic> driverData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
              driverData['owner_selfie'] ?? 'https://via.placeholder.com/150',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConst(
                  title:
                      "${driverData['vehicle_type_name']} - ${driverData['vehicle_no']}",
                  fontWeight: FontWeight.bold,
                ),
                TextConst(
                  title:
                      "${driverData['driver_name']} • ${driverData['phone']}",
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              final phone = driverData['phone']?.toString();
              if (phone != null && phone.isNotEmpty) {
                LauncherI.launchCall(phone);
              }
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.call, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpSection(String otp) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                "Your Trip OTP",
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
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
                letterSpacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySection() {
    final contactListVm =
    Provider.of<ContactListViewModel>(context, listen: false);

    final String supportNumber =
        contactListVm.contactListModel?.sosNumber ?? "6306513131";
    final String sosMessage =
        contactListVm.contactListModel?.sosMessage ?? "Hello";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// LEFT INFO
          Expanded(
            child: Row(
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 22,
                ),
                SizedBox(width: 6),
                TextConst(
                  title: "Emergency",
                  size: 15,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),

          /// 🔴 SOS BUTTON
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              _openWhatsApp(
                phone: supportNumber,
                message: sosMessage,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextConst(
                title: "SOS",
                color: Colors.white,
                size: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 8),

          /// 🟡 CHAT SUPPORT
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              _openWhatsApp(
                phone: supportNumber,
                message: "Hello Support, I need help with my ongoing ride.",
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: PortColor.gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildPaymentContainer(int payMode, Map<String, dynamic> orderData) {
    final method = payMode == 2
        ? "Online"
        : payMode == 3
        ? "Wallet"
        : "Cash";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.payment, color: PortColor.gold),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(method, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text(
                "Payment method",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "₹${orderData['amount']}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: _showCancelBottomSheet,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: TextConst(title: "Cancel Ride", color: Colors.red, size: 16),
        ),
      ),
    );
  }

  Widget _buildCompletionMessage(int status, int payMode) {
    String message = status == 4 ? "🚗 Ride Started!" : "🎉 Trip Completed!";

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class CollectPaymentScreen extends StatelessWidget {
  final String orderId;

  const CollectPaymentScreen({super.key, required this.orderId});

  /// 💰 Complete Cash Payment
  // void _completeCashPayment(BuildContext context) {
  //   final updateRideStatusVm = Provider.of<UpdateRideStatusViewModel>(
  //     context,
  //     listen: false,
  //   );
  //
  //   // Update ride status to 6 (Completed Successfully)
  //   updateRideStatusVm.updateRideApi(context, orderId, "6");
  //
  //   print("💵 Cash payment completed for order: $orderId");
  // }

  /// 💳 Complete Online Payment
  void _completeOnlinePayment(BuildContext context) {
    final paymentVm = Provider.of<PaymentViewModel>(context, listen: false);
    final driverRideVm = Provider.of<DriverRideViewModel>(
      context,
      listen: false,
    );

    final amount = driverRideVm.currentRideData?['amount']?.toString() ?? "0";

    // Call payment API with:
    // paymode: 1 (for online payment)
    // amount: ride amount
    // orderId: firebase order ID
    paymentVm.paymentApi(
      1, // paymode for online payment
      amount,
      orderId,
      context,
    );

    print("💳 Online payment initiated for order: $orderId, amount: ₹$amount");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverRideViewModel>(
      builder: (context, driverRideVm, child) {
        final payMode = driverRideVm.payMode;
        final amount = driverRideVm.currentRideData?['amount'] ?? 0;

        print("🎨 CollectPaymentScreen - PayMode: $payMode, Amount: ₹$amount");

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const Text(
                "Payment",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔥 Icon based on paymode
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: payMode == 1
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        payMode == 1 ? Icons.money : Icons.credit_card,
                        color: payMode == 1 ? Colors.green : Colors.orange,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔥 Title
                    Text(
                      payMode == 1 ? "Cash Payment" : "Online Payment",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: payMode == 1 ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔥 Amount Display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.currency_rupee,
                            color: PortColor.gold,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            amount.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: PortColor.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔥 Dynamic Content based on paymode
                    if (payMode == 1) ...[
                      // ✅ CASH PAYMENT UI
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Please pay cash to the driver",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // COMPLETE PAYMENT BUTTON (Cash)
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: ElevatedButton(
                      //     onPressed: () => _completeCashPayment(context),
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.green,
                      //       padding: const EdgeInsets.symmetric(vertical: 16),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //       elevation: 0,
                      //     ),
                      //     child: const Text(
                      //       "Payment Done",
                      //       style: TextStyle(
                      //         color: Colors.white,
                      //         fontSize: 18,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ] else ...[
                      // ✅ ONLINE PAYMENT UI
                      const Text(
                        "Complete your online payment below",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 20),

                      // PAYMENT GATEWAY SECTION
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              _completeOnlinePayment(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PortColor.gold,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              TextConst(
                                title:
                                "Pay Now",
                                color: Colors.white,
                                size: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Payment Methods Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.security,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Secure payment powered by Razorpay",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AddressCard extends StatelessWidget {
  final Map<String, dynamic>? orderData;

  const AddressCard({Key? key, required this.orderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📍 Pickup/Drop Icons with Dotted Line
          _buildLocationIndicator(),

          const SizedBox(width: 16),

          // 📝 Address Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pickup Address
                _buildAddressDetail(
                  name: orderData?['sender_name'] ?? "",
                  phone: orderData?['sender_phone']?.toString() ?? "",
                  address: orderData?['pickup_address'] ?? "",
                  orderType: orderData?['order_type'] ?? 1,
                ),

                const SizedBox(height: 12),

                // Drop Address
                _buildAddressDetail(
                  name: orderData?['reciver_name'] ?? "",
                  phone: orderData?['reciver_phone']?.toString() ?? "",
                  address: orderData?['drop_address'] ?? "",
                  orderType: orderData?['order_type'] ?? 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📍 Location Indicator (Green -> Dotted Line -> Red)
  Widget _buildLocationIndicator() {
    final orderType = orderData?['order_type'] ?? 1;

    return Column(
      children: [
        // Green Pickup Icon
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          child: const Icon(Icons.arrow_upward, color: Colors.white, size: 14),
        ),

        // Dotted Line
        Container(
          width: 2,
          height: orderType == 2 ? 25 : 45,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: CustomPaint(painter: DottedLinePainter()),
        ),

        // Red Drop Icon
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
    );
  }

  /// 📝 Single Address Detail Widget
  /// order_type: 1 → Name + Phone + Address
  /// order_type: 2 → Only Address
  Widget _buildAddressDetail({
    required String name,
    required String phone,
    required String address,
    required int orderType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ⭐ SHOW NAME & PHONE ONLY IF order_type == 1 (Ride)
        if (orderType == 1 && name.isNotEmpty) ...[
          Row(
            children: [
              // Name
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: AppFonts.kanitReg,
                  color: PortColor.gold,
                ),
              ),

              // Phone (if available)
              if (phone.isNotEmpty) ...[
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
            ],
          ),
          const SizedBox(height: 4),
        ],

        // ⭐ Address - ALWAYS VISIBLE
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

}

/// 🎨 Dotted Line Painter for Visual Separator
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

class LauncherI {
  static Future<void> launchCall(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}


void _openWhatsApp({
  required String phone,
  String message = "",
}) async {
  final cleanNumber = phone
      .replaceAll("+", "")
      .replaceAll(" ", "")
      .replaceAll("-", "");

  final encodedMessage = Uri.encodeComponent(message);

  final Uri whatsappUrl = Uri.parse(
    "https://wa.me/$cleanNumber?text=$encodedMessage",
  );

  if (await canLaunchUrl(whatsappUrl)) {
    await launchUrl(
      whatsappUrl,
      mode: LaunchMode.externalApplication,
    );
  } else {
    debugPrint("❌ WhatsApp not installed");
  }
}

