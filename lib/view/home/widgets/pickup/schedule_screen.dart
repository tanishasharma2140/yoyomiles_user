import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/model/daily_slot_model.dart';
import 'package:yoyomiles/model/final_summary_model.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view/home/widgets/packer_mover_terms_condition.dart';
import 'package:yoyomiles/view_model/daily_slot_view_model.dart';
import 'package:yoyomiles/view_model/final_summary_view_model.dart';
import 'package:yoyomiles/view_model/proceed_order_view_model.dart';
import 'package:yoyomiles/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';
import '../../../../res/constant_color.dart' show PortColor;

class ScheduleScreen extends StatefulWidget {
  final  Map<String, dynamic> data;
  const ScheduleScreen({super.key, required this.data});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {

  bool _singleLayer = false;
  bool _multiLayer = false;
  bool _unpacking = false;
  bool _dismantle = false;
  String? _selectedTimeSlot;
  String? _selectedSession = "Morning";
  bool _slotConfirmed = false;
  int selectedDateIndex = 0;
  String? selectedDate;
  int selectedSingle = 0;
  int selectedMulti = 0;
  int selectedUnpack = 0;
  int selectedDismantle = 0;

  @override
  void initState() {
    super.initState();

    // Final summary data load hone ka wait karo
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final summaryVm = Provider.of<FinalSummaryViewModel>(context, listen: false);

      if (summaryVm.finalSummaryModel != null) {
        // Set selected date from final summary
        selectedDate ??= summaryVm.finalSummaryModel!.dateBaseAddAmount!.first.date
            ?? DateTime.now().add(Duration(days: 1)).toString().split(" ")[0];

        // Load slots for selected date
        final dailySlotVm = Provider.of<DailySlotViewModel>(context, listen: false);
        dailySlotVm.dailySlotApi(selectedDate!);
      }
    });
  }


  void _showPickupSlotModal() {
    final dailySlotVm = Provider.of<DailySlotViewModel>(context, listen: false);
    final summaryVm = Provider.of<FinalSummaryViewModel>(context, listen: false);
    final loc = AppLocalizations.of(context)!;


    // Final summary se selected date le rahe hain
    final availableDates = summaryVm.finalSummaryModel?.dateBaseAddAmount ?? [];

    // Current selected date from main screen - YEH IMPORTANT HAI
    String currentSelectedDate = selectedDate ?? availableDates.first.date ?? '';

    // Ensure slots are loaded for the selected date before opening modal
    if (currentSelectedDate.isNotEmpty) {
      dailySlotVm.dailySlotApi(currentSelectedDate);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<DailySlotViewModel>(
        builder: (context, dailySlotVm, child) {
          final dailySlots = dailySlotVm.dailySlotModel;

          return StatefulBuilder(
            builder: (context, setModalState) {

              // Format date for display
              String formatDateForDisplay(String dateString) {
                if (dateString.isEmpty) return 'Date not available';
                try {
                  DateTime date = DateTime.parse(dateString);
                  String day = date.day.toString().padLeft(2, '0');
                  String month = _getMonthName(date.month);
                  String year = date.year.toString();
                  return '$day $month $year';
                } catch (e) {
                  return dateString;
                }
              }

              // Debug print - check if correct date is being used
              print('Modal - Selected Date: $currentSelectedDate');
              print('Modal - DailySlots Date: ${dailySlots?.date}');
              print('Modal - Loading: ${dailySlotVm.loading}');

              return Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: PortColor.bg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: PortColor.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.close,
                              color: PortColor.black,
                              size: screenHeight * 0.025,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          TextConst(
                            title: loc.select_pickup_slot,
                            color: PortColor.black,
                            fontFamily: AppFonts.kanitReg,
                            fontWeight: FontWeight.w600,
                            size: 16,
                          ),
                        ],
                      ),
                    ),

                    // Loading State
                    if (dailySlotVm.loading) ...[
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CupertinoActivityIndicator(
                                radius: 18,
                                color: PortColor.button,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              TextConst(
                                title: "${loc.loading_slot_for} ${formatDateForDisplay(currentSelectedDate)}...",
                                color: Colors.grey,
                                fontFamily: AppFonts.kanitReg,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                    // Data Loaded Successfully
                    else if (dailySlots != null) ...[
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date Section - Only show selected date from main screen
                              Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                    vertical: screenHeight * 0.015,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PortColor.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: PortColor.button),
                                  ),
                                  child: TextConst(
                                    title: formatDateForDisplay(currentSelectedDate),
                                    fontFamily: AppFonts.poppinsReg,
                                    color: PortColor.button,
                                    fontWeight: FontWeight.w600,
                                    size: 14,
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.03),

                              // Check if slots data matches the selected date
                              if (dailySlots.date != currentSelectedDate) ...[
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.orange,
                                        size: screenHeight * 0.06,
                                      ),
                                      SizedBox(height: screenHeight * 0.02),
                                      TextConst(
                                        title: loc.loading_slot_for,
                                        fontFamily: AppFonts.kanitReg,
                                        color: Colors.orange,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                              else ...[
                                // Time Slot Sections in Row - ONLY SHOW IF DATE MATCHES
                                Row(
                                  children: [
                                    // Morning Section
                                    if (dailySlots.slots?.morning != null)
                                      Expanded(
                                        child: _buildTimeSlotCardFromApi(
                                          "Morning",
                                          dailySlots.slots!.morning!,
                                          Icons.wb_sunny_outlined,
                                          _selectedSession == "Morning",
                                              () {
                                            setModalState(() {
                                              _selectedSession = "Morning";
                                              _selectedTimeSlot = null;
                                            });
                                          },
                                        ),
                                      ),

                                    if (dailySlots.slots?.morning != null)
                                      SizedBox(width: screenWidth * 0.02),

                                    // Afternoon Section
                                    if (dailySlots.slots?.afternoon != null)
                                      Expanded(
                                        child: _buildTimeSlotCardFromApi(
                                          "Afternoon",
                                          dailySlots.slots!.afternoon!,
                                          Icons.light_mode_outlined,
                                          _selectedSession == "Afternoon",
                                              () {
                                            setModalState(() {
                                              _selectedSession = "Afternoon";
                                              _selectedTimeSlot = null;
                                            });
                                          },
                                        ),
                                      ),

                                    if (dailySlots.slots?.afternoon != null)
                                      SizedBox(width: screenWidth * 0.02),

                                    // Evening Section
                                    if (dailySlots.slots?.evening != null)
                                      Expanded(
                                        child: _buildTimeSlotCardFromApi(
                                          "Evening",
                                          dailySlots.slots!.evening!,
                                          Icons.nights_stay_outlined,
                                          _selectedSession == "Evening",
                                              () {
                                            setModalState(() {
                                              _selectedSession = "Evening";
                                              _selectedTimeSlot = null;
                                            });
                                          },
                                        ),
                                      ),
                                  ],
                                ),

                                SizedBox(height: screenHeight * 0.03),

                                // Individual Time Slots based on selected session
                                if (_selectedSession != null && _getSelectedSessionSlots() != null) ...[
                                  TextConst(
                                    title: loc.available_time,
                                    fontFamily: AppFonts.kanitReg,
                                    fontWeight: FontWeight.w600,
                                    size: 16,
                                    color: PortColor.black,
                                  ),
                                  SizedBox(height: screenHeight * 0.02),

                                  _buildAvailableSlotsList(setModalState),
                                ],

                                // No slots available message
                                if (_selectedSession != null && _getSelectedSessionSlots() == null) ...[
                                  Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.schedule,
                                          color: Colors.grey,
                                          size: screenHeight * 0.06,
                                        ),
                                        SizedBox(height: screenHeight * 0.02),
                                        TextConst(
                                          title: "${loc.no_slot_available} $_selectedSession",
                                          fontFamily: AppFonts.kanitReg,
                                          color: Colors.grey,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],

                              SizedBox(height: screenHeight * 0.05),
                            ],
                          ),
                        ),
                      ),
                    ]

                    // No Data State
                    else ...[
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: Colors.grey,
                                  size: screenHeight * 0.06,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                TextConst(
                                  title: "${loc.no_slot_available} ${formatDateForDisplay(currentSelectedDate)}",
                                  color: Colors.grey,
                                  fontFamily: AppFonts.kanitReg,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                GestureDetector(
                                  onTap: () {
                                    dailySlotVm.dailySlotApi(currentSelectedDate);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04,
                                      vertical: screenHeight * 0.01,
                                    ),
                                    decoration: BoxDecoration(
                                      color: PortColor.button,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextConst(
                                      title: loc.load_slot,
                                      color: PortColor.black,
                                      fontFamily: AppFonts.kanitReg,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                    // Confirm Button
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: PortColor.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: _selectedTimeSlot != null
                            ? () {
                          Navigator.pop(context);
                          setState(() {
                            _slotConfirmed = true;
                          });
                          facebookAppEvents.logEvent(
                            name: 'slot_confirm',
                          );
                        }
                            : null,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.018,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedTimeSlot != null
                                ? PortColor.button
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: TextConst(
                              title: loc.confirm_slot,
                              fontFamily: AppFonts.kanitReg,
                              color: _selectedTimeSlot != null
                                  ? PortColor.black
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                              size: 14,
                            ),
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
      ),
    );
  }
// Helper function to get month name
  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'JAN';
      case 2: return 'FEB';
      case 3: return 'MAR';
      case 4: return 'APR';
      case 5: return 'MAY';
      case 6: return 'JUN';
      case 7: return 'JUL';
      case 8: return 'AUG';
      case 9: return 'SEP';
      case 10: return 'OCT';
      case 11: return 'NOV';
      case 12: return 'DEC';
      default: return '';
    }
  }

  Morning? _getSelectedSessionSlots() {
    final dailySlots = Provider.of<DailySlotViewModel>(context, listen: false).dailySlotModel;

    switch (_selectedSession) {
      case "Morning":
        return dailySlots?.slots?.morning;
      case "Afternoon":
        return dailySlots?.slots?.afternoon;
      case "Evening":
        return dailySlots?.slots?.evening;
      default:
        return null;
    }
  }


// Updated time slot card that uses API data
  Widget _buildTimeSlotCardFromApi(
      String title,
      Morning sessionData,
      IconData icon,
      bool isSelected,
      VoidCallback onTap,
      ) {
    final isAvailable = sessionData.availableTimeStatus == 1;
    final slotCount = sessionData.availableSlots?.length ?? 0;

    final effectiveIsSelected = isAvailable && isSelected;
    final loc = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenHeight * 0.02,
        ),
        decoration: BoxDecoration(
          color: effectiveIsSelected
              ? PortColor.gold.withOpacity(0.2)
              : (isAvailable ? PortColor.white : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: effectiveIsSelected
                ? PortColor.gold
                : (isAvailable ? PortColor.gray.withOpacity(0.3) : Colors.grey.shade400),
            width: effectiveIsSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: effectiveIsSelected
                    ? PortColor.gold
                    : (isAvailable ? PortColor.gold.withOpacity(0.1) : Colors.grey.shade400),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: effectiveIsSelected ? PortColor.white : (isAvailable ? PortColor.gold : Colors.grey.shade600),
                size: screenHeight * 0.025,
              ),
            ),

            SizedBox(height: screenHeight * 0.01),

            // Title
            TextConst(
              title: title,
              fontFamily: AppFonts.kanitReg,
              fontWeight: FontWeight.w600,
              size: 14,
              color: effectiveIsSelected
                  ? PortColor.black
                  : (isAvailable ? Colors.grey.shade700 : Colors.grey.shade500),
            ),

            SizedBox(height: screenHeight * 0.005),

            // Time Range
            TextConst(
              title: sessionData.amToPm ?? "$slotCount ${loc.slots}",
              fontFamily: AppFonts.poppinsReg,
              color: effectiveIsSelected
                  ? PortColor.black
                  : (isAvailable ? Colors.grey.shade600 : Colors.grey.shade500),
              size: 12,
              fontWeight: FontWeight.w500,
            ),

            // Availability Status
            if (!isAvailable) ...[
              SizedBox(height: screenHeight * 0.005),
              TextConst(
                title: loc.not_available,
                fontFamily: AppFonts.poppinsReg,
                color: Colors.red,
                size: 10,
              ),
            ],
          ],
        ),
      ),
    );
  }
// Build available slots list from API data
  Widget _buildAvailableSlotsList(StateSetter setModalState) {
    final sessionSlots = _getSelectedSessionSlots();
    final loc = AppLocalizations.of(context)!;

    if (sessionSlots == null || sessionSlots.availableSlots == null) {
      return Center(
        child: TextConst(
          title: loc.no_slot_available,
          color: Colors.grey,
          fontFamily: AppFonts.kanitReg,
        ),
      );
    }

    // ✅ Check session availability from API
    final bool isSessionAvailable =
        sessionSlots.availableTimeStatus == 1;

    return Column(
      children: sessionSlots.availableSlots!.map((slot) {

        // ✅ Slot is available only if:
        // 1) Session is available AND
        // 2) Slot remaining > 0
        final bool isSlotAvailable =
            isSessionAvailable && (slot.remaining != null && slot.remaining! > 0);

        return _buildTimeSlotItemFromApi(
          slot,
          isSlotAvailable,
          setModalState,
        );
      }).toList(),
    );
  }


// Updated time slot item that uses API data
  Widget _buildTimeSlotItemFromApi(
      AvailableSlots slot,
      bool isAvailable,
      StateSetter setModalState,
      ) {
    bool isSelected = _selectedTimeSlot == slot.slotName;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: GestureDetector(
        onTap: isAvailable ? () {
          setModalState(() {
            _selectedTimeSlot = slot.slotName;
          });
        } : null,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.02,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? PortColor.gold.withOpacity(0.2)
                : (isAvailable ? PortColor.white : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? PortColor.gold
                  : (isAvailable ? PortColor.gray.withOpacity(0.3) : Colors.grey.shade300),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: PortColor.gold.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Selection indicator
              Container(
                width: screenWidth * 0.04,
                height: screenWidth * 0.04,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? PortColor.gold
                        : (isAvailable ? Colors.grey.shade400 : Colors.grey.shade300),
                    width: 2,
                  ),
                  color: isSelected ? PortColor.gold : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                  Icons.check,
                  color: PortColor.white,
                  size: screenWidth * 0.03,
                )
                    : null,
              ),

              SizedBox(width: screenWidth * 0.03),

              // Time slot text and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConst(
                      title: slot.slotName ?? "Unknown Slot",
                      fontFamily: AppFonts.kanitReg,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? PortColor.black
                          : (isAvailable ? Colors.grey.shade700 : Colors.grey.shade500),
                      size: 14,
                    ),

                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentSummary() {
    final profileVm = Provider.of<ProfileViewModel>(context, listen: false);
    final proceedOrderVm = Provider.of<ProceedOrderViewModel>(context, listen: false);
    final summaryVm = Provider.of<FinalSummaryViewModel>(context, listen: false);
    final loc = AppLocalizations.of(context)!;

    // ✅ Get total amount dynamically from FinalSummaryModel
    final totalAmount = summaryVm.finalSummaryModel?.totalAmount ?? 0;

    final cityType = widget.data['service_type'] ?? '';
    final distance = widget.data['distance'] ?? 0;
    final pickupAddress = widget.data['pickup_address'] ?? '';
    final dropAddress = widget.data['drop_address'] ?? '';
    final pickupLatitude = widget.data['pickup_lat'] ?? '';
    final pickupLongitude = widget.data['pickup_lng'] ?? '';
    final dropLatitude = widget.data['drop_lat'] ?? '';
    final dropLongitude = widget.data['drop_lng'] ?? '';
    final pickupPointLiftInfo = widget.data['pickup_point']?['has_lift'] ?? 0;
    final dropPointLiftInfo = widget.data['drop_point']?['has_lift'] ?? 0;


    // ✅ Get selected date & time slot (from your current screen state)
    final shiftingDate = selectedDate ?? "N/A";
    final shiftingTime = _selectedTimeSlot ?? "Not selected";

    // ✅ Optional - Format date for display

    String formattedToday(String dateString) {
      try {
        final date = DateTime.parse(dateString);
        return "${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}";
      } catch (_) {
        return dateString;
      }
    }
    final String todayDate = DateTime.now().toString().split(" ")[0];


    // ✅ Charges logic
    final charges = summaryVm.finalSummaryModel?.charges;

    final singleLayerApplied = _singleLayer ? 1 : 0;
    final multiLayerApplied = _multiLayer ? 1 : 0;
    final unpackingApplied = _unpacking ? 1 : 0;
    final dismantleApplied = _dismantle ? 1 : 0;

    final singleLayerCharges =
    singleLayerApplied == 1 ? (charges?.singleLayerCharges?.amount ?? 0) : 0;

    final multiLayerCharges =
    multiLayerApplied == 1 ? (charges?.multiLayerCharges?.amount ?? 0) : 0;

    final unpackingCharges =
    unpackingApplied == 1 ? (charges?.unpackingCharges?.amount ?? 0) : 0;

    final dismantleReassemblyCharges =
    dismantleApplied == 1 ? (charges?.dismantleReassemblyCharges?.amount ?? 0) : 0;

    // ✅ Correct slot selection
    final selectedSlot = _getSelectedSessionSlots()?.availableSlots?.firstWhere(
          (slot) => slot.slotName == _selectedTimeSlot,
      orElse: () => AvailableSlots(),
    );

    final int slotId = selectedSlot?.slotId ?? 0;             // ✅ Correct slot_id
    final int dailySlotId = selectedSlot?.dailySlotsId ?? 0;  // ✅ Correct daily_slots_id

    print("✅ FINAL VALUES SENDING TO API");
    print("date: $todayDate");
    print("slotId: $slotId");
    print("dailySlotId: $dailySlotId");
    print("singleLayerCharges: $singleLayerCharges");
    print("multiLayerCharges: $multiLayerCharges");
    print("unpackingCharges: $unpackingCharges");
    print("dismantleCharges: $dismantleReassemblyCharges");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: PortColor.bg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // HEADER
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              decoration: BoxDecoration(
                color: PortColor.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: PortColor.black,
                      size: screenHeight * 0.025,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  TextConst(
                    title: loc.payment_summary,
                    color: PortColor.black,
                    fontFamily: AppFonts.kanitReg,
                    fontWeight: FontWeight.w600,
                    size: 16,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  children: [
                    // 🟢 SHIFTING DATE & TIME DYNAMIC
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: PortColor.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: PortColor.gray.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            decoration: BoxDecoration(
                              color: PortColor.gold.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              color: PortColor.gold,
                              size: screenHeight * 0.025,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextConst(
                                  title: loc.shifting_on,
                                  fontFamily: AppFonts.kanitReg,
                                  color: Colors.grey.shade600,
                                  size: 12,
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                TextConst(
                                  title:
                                  "${formattedToday(shiftingDate)} · $shiftingTime",
                                  fontFamily: AppFonts.kanitReg,
                                  fontWeight: FontWeight.w600,
                                  size: 14,
                                  color: PortColor.black,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // 🟢 TOTAL AMOUNT DYNAMIC
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: PortColor.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: PortColor.gray.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextConst(
                                  title: loc.total_amount,
                                  fontFamily: AppFonts.kanitReg,
                                  color: Colors.grey.shade600,
                                  size: 12,
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                TextConst(
                                  title: "₹${totalAmount.toStringAsFixed(0)}",
                                  fontFamily: AppFonts.kanitReg,
                                  fontWeight: FontWeight.w600,
                                  size: 18,
                                  color: PortColor.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: PortColor.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: PortColor.gray.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextConst(
                                  title: loc.payment_summary,
                                  fontFamily: AppFonts.kanitReg,
                                  fontWeight: FontWeight.w600,
                                  size: 14,
                                  color: PortColor.black,
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                TextConst(
                                  title: "${loc.pay_booking_amount} ₹${totalAmount.toStringAsFixed(0)}",
                                  fontFamily: AppFonts.kanitReg,
                                  color: Colors.grey.shade600,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.04),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: loc.please_make_sure,
                            style: TextStyle(
                              fontFamily: AppFonts.kanitReg,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          TextSpan(
                            text: loc.terms_condition,
                            style: TextStyle(
                              fontFamily: AppFonts.kanitReg,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: PortColor.button,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration: const Duration(milliseconds: 400),
                                    pageBuilder: (_, __, ___) => PackerMoverTermsCondition(),
                                    transitionsBuilder: (_, animation, __, child) {
                                      final offsetAnimation = Tween<Offset>(
                                        begin: const Offset(0, 1),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ));

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                          ),
                          TextSpan(
                            text: ".",
                            style: TextStyle(
                              fontFamily: AppFonts.kanitReg,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),

            // 🟢 PAY BUTTON (dynamic amount)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              decoration: BoxDecoration(
                color: PortColor.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  proceedOrderVm.proceedOrderApi(
                    date: todayDate,                // ✅ FIXED
                    cityType: cityType,
                    distance: distance,
                    singleLayerCharges: singleLayerCharges,
                    multiLayerCharges: multiLayerCharges,
                    unpackingCharges: unpackingCharges,
                    dismantleReassemblyCharges: dismantleReassemblyCharges,
                    pickupAddress: pickupAddress,
                    pickupLatitude: pickupLatitude,
                    pickupLongitude: pickupLongitude,
                    dropAddress: dropAddress,
                    dropLatitude: dropLatitude,
                    dropLongitude: dropLongitude,
                    senderName: profileVm.profileModel?.data?.firstName ?? '',
                    shiftingDate: shiftingDate,
                    dailySlotId: dailySlotId,           // ✅ FIXED
                    slotId: slotId,                     // ✅ FIXED
                    paymentStatus: 0,
                    pickupPointLiftInfo: pickupPointLiftInfo,
                    dropPointLiftInfo: dropPointLiftInfo,
                    context: context,
                    totalCharges: totalAmount.toStringAsFixed(0),
                  );
                },
                child: Consumer<ProceedOrderViewModel>(
                  builder: (context, proceedOrderVm, child) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                      decoration: BoxDecoration(
                        color: PortColor.button,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: proceedOrderVm.loading
                          ? Center(
                        child: CupertinoActivityIndicator(
                          radius: 12,      // size
                          color: PortColor.white,
                        ),
                      )
                          : Center(
                        child: TextConst(
                          title:
                          "${loc.pay_booking_amount} ₹${totalAmount.toStringAsFixed(0)}",
                          fontFamily: AppFonts.kanitReg,
                          color: PortColor.black,
                          fontWeight: FontWeight.w600,
                          size: 14,
                        ),
                      ),
                    );
                  },
                )

              ),
            ),
          ],
        ),
      ),
    );
  }


  // void _showPaymentSummary() {
  //   final profileVm = Provider.of<ProfileViewModel>(context, listen: false);
  //   final proceedOrderVm = Provider.of<ProceedOrderViewModel>(context, listen: false);
  //   final summaryVm = Provider.of<FinalSummaryViewModel>(context, listen: false);
  //
  //   final totalAmount = summaryVm.finalSummaryModel?.totalAmount ?? 0;
  //
  //   // ✅ Extract global moving details
  //   final cityType = widget.data['service_type'] ?? '';
  //   final distance = widget.data['distance'] ?? 0;
  //   final pickupAddress = widget.data['pickup_address'] ?? '';
  //   final dropAddress = widget.data['drop_address'] ?? '';
  //   final pickupLatitude = widget.data['pickup_lat'] ?? '';
  //   final pickupLongitude = widget.data['pickup_lng'] ?? '';
  //   final dropLatitude = widget.data['drop_lat'] ?? '';
  //   final dropLongitude = widget.data['drop_lng'] ?? '';
  //   final pickupPointLiftInfo = widget.data['pickup_point']?['has_lift'] ?? 0;
  //   final dropPointLiftInfo = widget.data['drop_point']?['has_lift'] ?? 0;
  //
  //   // ✅ API required date = CURRENT DATE (formatted)
  //   final String formattedToday =
  //       "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
  //
  //   // ✅ shifting date/time selected by user
  //   final shiftingDate = selectedDate ?? "N/A";
  //   final shiftingTime = _selectedTimeSlot ?? "Not selected";
  //
  //   String formatDate(String dateString) {
  //     try {
  //       final date = DateTime.parse(dateString);
  //       return "${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}";
  //     } catch (_) {
  //       return dateString;
  //     }
  //   }
  //
  //   // ✅ Charges logic
  //   final charges = summaryVm.finalSummaryModel?.charges;
  //
  //   final singleLayerApplied = _singleLayer ? 1 : 0;
  //   final multiLayerApplied = _multiLayer ? 1 : 0;
  //   final unpackingApplied = _unpacking ? 1 : 0;
  //   final dismantleApplied = _dismantle ? 1 : 0;
  //
  //   final singleLayerCharges =
  //   singleLayerApplied == 1 ? (charges?.singleLayerCharges?.amount ?? 0) : 0;
  //
  //   final multiLayerCharges =
  //   multiLayerApplied == 1 ? (charges?.multiLayerCharges?.amount ?? 0) : 0;
  //
  //   final unpackingCharges =
  //   unpackingApplied == 1 ? (charges?.unpackingCharges?.amount ?? 0) : 0;
  //
  //   final dismantleReassemblyCharges =
  //   dismantleApplied == 1 ? (charges?.dismantleReassemblyCharges?.amount ?? 0) : 0;
  //
  //   // ✅ Correct slot selection
  //   final selectedSlot = _getSelectedSessionSlots()?.availableSlots?.firstWhere(
  //         (slot) => slot.slotName == _selectedTimeSlot,
  //     orElse: () => AvailableSlots(),
  //   );
  //
  //   final int slotId = selectedSlot?.slotId ?? 0;             // ✅ Correct slot_id
  //   final int dailySlotId = selectedSlot?.dailySlotsId ?? 0;  // ✅ Correct daily_slots_id
  //
  //   print("✅ FINAL VALUES SENDING TO API");
  //   print("date: $formattedToday");
  //   print("slotId: $slotId");
  //   print("dailySlotId: $dailySlotId");
  //   print("singleLayerCharges: $singleLayerCharges");
  //   print("multiLayerCharges: $multiLayerCharges");
  //   print("unpackingCharges: $unpackingCharges");
  //   print("dismantleCharges: $dismantleReassemblyCharges");
  //
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Container(
  //       height: MediaQuery.of(context).size.height * 0.55,
  //       decoration: BoxDecoration(
  //         color: PortColor.bg,
  //         borderRadius: const BorderRadius.only(
  //           topLeft: Radius.circular(20),
  //           topRight: Radius.circular(20),
  //         ),
  //       ),
  //       child: Column(
  //         children: [
  //           // Header…
  //           // UI code remains same…
  //
  //           // ✅ PAY BUTTON
  //           Container(
  //             padding: EdgeInsets.symmetric(
  //               horizontal: screenWidth * 0.05,
  //               vertical: screenHeight * 0.02,
  //             ),
  //             color: PortColor.white,
  //             child: GestureDetector(
  //               onTap: () {
  //                 proceedOrderVm.proceedOrderApi(
  //                   date: formattedToday,                // ✅ FIXED
  //                   cityType: cityType,
  //                   distance: distance,
  //                   singleLayerCharges: singleLayerCharges,
  //                   multiLayerCharges: multiLayerCharges,
  //                   unpackingCharges: unpackingCharges,
  //                   dismantleReassemblyCharges: dismantleReassemblyCharges,
  //                   pickupAddress: pickupAddress,
  //                   pickupLatitude: pickupLatitude,
  //                   pickupLongitude: pickupLongitude,
  //                   dropAddress: dropAddress,
  //                   dropLatitude: dropLatitude,
  //                   dropLongitude: dropLongitude,
  //                   senderName: profileVm.profileModel?.data?.firstName ?? '',
  //                   shiftingDate: shiftingDate,
  //                   dailySlotId: dailySlotId,           // ✅ FIXED
  //                   slotId: slotId,                     // ✅ FIXED
  //                   paymentStatus: "pending",
  //                   pickupPointLiftInfo: pickupPointLiftInfo,
  //                   dropPointLiftInfo: dropPointLiftInfo,
  //                   context: context,
  //                 );
  //               },
  //               child: Container(
  //                 width: double.infinity,
  //                 padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
  //                 decoration: BoxDecoration(
  //                   color: PortColor.button,
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 child: Center(
  //                   child: TextConst(
  //                     title: "Pay booking ₹${totalAmount.toStringAsFixed(0)}",
  //                     fontFamily: AppFonts.kanitReg,
  //                     color: PortColor.black,
  //                     fontWeight: FontWeight.w600,
  //                     size: 14,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  String currentMonthYear() {
    final now = DateTime.now();
    String month = _getMonthName(now.month);
    return "$month ${now.year}";
  }



  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final summary = Provider.of<FinalSummaryViewModel>(context);
    final charges = summary.finalSummaryModel?.charges;
    if (charges == null) {
      return const Center(child: CupertinoActivityIndicator());
    }    return Stack(
      children: [
        SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: PortColor.bg,
            body: Column(
              children: [
                SizedBox(height: topPadding),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.02,
                  ),
                  height: screenHeight * 0.17,
                  decoration: BoxDecoration(
                    color: PortColor.white,
                    border: Border(
                      bottom: BorderSide(
                        color: PortColor.gray,
                        width: screenWidth * 0.002,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: PortColor.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 30,
                              width: 30,
                              color: Colors.transparent,
                              child: Icon(
                                Icons.arrow_back,
                                color: PortColor.black,
                                size: screenHeight * 0.026,
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          TextConst(
                            title: loc.packer_move,
                            color: PortColor.black,
                            fontWeight: FontWeight.w600,
                            size: 16,
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StepWidget(
                            icon: Icons.check,
                            text: loc.moving_detail,
                            isActive: true,
                            isCompleted: true,
                          ),
                          DottedLine(),
                          StepWidget(
                            icon: Icons.inventory,
                            text: loc.add_items,
                            isActive: true,
                            isCompleted: true,
                          ),
                          DottedLine(),
                          StepWidget(
                            icon: Icons.receipt,
                            text: loc.schedule,
                            isActive: true,
                            isCompleted: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextConst(
                          title: loc.select_shifting_date,
                          fontFamily: AppFonts.kanitReg,
                          size: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        const SizedBox(height: 8),

                        TextConst(
                          title: currentMonthYear(),
                          fontFamily: AppFonts.poppinsReg,
                          color: PortColor.button,
                          fontWeight: FontWeight.w600,
                          size: 13,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 80, // 👈 compact height
                          child: GridView.builder(
                            scrollDirection: Axis.horizontal,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 1,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: summary
                                .finalSummaryModel!
                                .dateBaseAddAmount!
                                .length,
                            itemBuilder: (context, index) {
                              final item = summary
                                  .finalSummaryModel!
                                  .dateBaseAddAmount![index];

                              bool isSelected = (index == selectedDateIndex);

                              return _buildDateItem(
                                item.label.toString(),
                                item.date.toString(),
                                "₹${item.amount}",
                                isSelected,
                                index,
                                item,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        TextConst(
                          title: loc.recommended_add_ons,
                          fontFamily: AppFonts.kanitReg,
                          size: 15,
                        ),
                        const SizedBox(height: 16),

                        // Single-layer packing
                        _buildAddonItem(
                          charges.singleLayerCharges!.heading!,
                          "₹${charges.singleLayerCharges!.amount}\n${charges.singleLayerCharges!.subHeading}",
                          _singleLayer,
                          (value) {
                            setState(() {
                              _singleLayer = value!;
                              _multiLayer = false;

                              selectedSingle = value ? 1 : 0; // ✅ always 1 or 0
                              selectedMulti = 0; // disable other layer
                            });

                            final summaryVm =
                                Provider.of<FinalSummaryViewModel>(
                                  context,
                                  listen: false,
                                );
                            summaryVm.finalSummaryApi(
                              selectedDate,
                              summary.finalSummaryModel!.distance,
                              summary.finalSummaryModel!.pickupPoint,
                              summary.finalSummaryModel!.dropPoint,
                              selectedSingle,
                              selectedMulti,
                              selectedUnpack,
                              selectedDismantle,
                              context,
                            );
                          },
                          context,
                        ),

                        const SizedBox(height: 12),

                        _buildAddonItem(
                          charges.multiLayerCharges!.heading!,
                          "₹${charges.multiLayerCharges!.amount}\n${charges.multiLayerCharges!.subHeading}",
                          _multiLayer,
                          (value) {
                            setState(() {
                              _multiLayer = value!;
                              _singleLayer = false;

                              selectedMulti = value ? 1 : 0;
                              selectedSingle = 0;
                            });

                            final summaryVm =
                                Provider.of<FinalSummaryViewModel>(
                                  context,
                                  listen: false,
                                );
                            summaryVm.finalSummaryApi(
                              selectedDate,
                              summary.finalSummaryModel!.distance,
                              summary.finalSummaryModel!.pickupPoint,
                              summary.finalSummaryModel!.dropPoint,
                              selectedSingle,
                              selectedMulti,
                              selectedUnpack,
                              selectedDismantle,
                              context,
                            );
                          },
                          context,
                        ),

                        const SizedBox(height: 12),

                        _buildAddonItem(
                          charges.unpackingCharges!.heading!,
                          "₹${charges.unpackingCharges!.amount}\n${charges.unpackingCharges!.subHeading}",
                          _unpacking,
                          (value) {
                            setState(() {
                              _unpacking = value!;
                              selectedUnpack = value ? 1 : 0;
                            });

                            final summaryVm =
                                Provider.of<FinalSummaryViewModel>(
                                  context,
                                  listen: false,
                                );
                            summaryVm.finalSummaryApi(
                              selectedDate,
                              summary.finalSummaryModel!.distance,
                              summary.finalSummaryModel!.pickupPoint,
                              summary.finalSummaryModel!.dropPoint,
                              selectedSingle,
                              selectedMulti,
                              selectedUnpack,
                              selectedDismantle,
                              context,
                            );
                          },
                          context,
                        ),

                        const SizedBox(height: 12),

                        _buildAddonItem(
                          charges.dismantleReassemblyCharges!.heading!,
                          "₹${charges.dismantleReassemblyCharges!.amount}\n${charges.dismantleReassemblyCharges!.subHeading}",
                          _dismantle,
                          (value) {
                            setState(() {
                              _dismantle = value!;
                              selectedDismantle = value ? 1 : 0;
                            });

                            final summaryVm =
                                Provider.of<FinalSummaryViewModel>(
                                  context,
                                  listen: false,
                                );
                            summaryVm.finalSummaryApi(
                              selectedDate,
                              summary.finalSummaryModel!.distance,
                              summary.finalSummaryModel!.pickupPoint,
                              summary.finalSummaryModel!.dropPoint,
                              selectedSingle,
                              selectedMulti,
                              selectedUnpack,
                              selectedDismantle,
                              context,
                            );
                          },
                          context,
                        ),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomSheet: _slotConfirmed
                ? _buildPaymentBottomSheet()
                : _buildSelectSlotBottomSheet(),
          ),
        ),
        if (summary.loading)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black54,
            alignment: Alignment.center,
            child: CupertinoActivityIndicator(
              radius: 18,
              color: PortColor.white,
            ),
          ),
      ],
    );
  }

  Widget _buildSelectSlotBottomSheet() {
    final summary = Provider.of<FinalSummaryViewModel>(context);
    final loc = AppLocalizations.of(context)!;
    print(
      "Total Amount:${summary.finalSummaryModel!.totalAmount.toString()}",
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              /// Left side - Total Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   TextConst(
                    title: loc.total_amount,
                    fontFamily: AppFonts.kanitReg,
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  TextConst(
                    title:
                        '₹${summary.finalSummaryModel!.totalAmount.toString()}',
                    fontFamily: AppFonts.kanitReg,
                    size: 13,
                    color: PortColor.blackLight,
                  ),
                ],
              ),

              const Spacer(),

              /// Right side - Select Pickup Slot Button
              GestureDetector(
                onTap: _showPickupSlotModal,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: PortColor.button,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextConst(
                    title: loc.select_pickup_slot,
                    fontFamily: AppFonts.kanitReg,
                    color: PortColor.black,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentBottomSheet() {
    final summary = Provider.of<FinalSummaryViewModel>(context);
    final loc = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              /// Left side - Total Amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConst(
                      title: loc.total_amount,
                      fontFamily: AppFonts.kanitReg,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    TextConst(
                      title: "₹${summary.finalSummaryModel!.totalAmount.toString()}",
                      fontFamily: AppFonts.kanitReg,
                      size: 16,
                      fontWeight: FontWeight.w600,
                      color: PortColor.black,
                    ),
                  ],
                ),
              ),

              /// Right side - Pay Booking Amount Button
              GestureDetector(
                onTap: () {
                  if (selectedDate == null || selectedDate == "") {
                    selectedDate = summary.finalSummaryModel!.dateBaseAddAmount!.first.date;
                  }
                  _showPaymentSummary();
                },                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: PortColor.button,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextConst(
                    title: loc.pay_booking_amount,
                    fontFamily: AppFonts.kanitReg,
                    color: PortColor.black,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateItem(
    String day,
    String weekDate,
    String price,
    bool isSelected,
    int index,
    DateBaseAddAmount item,
  ) {
    final summary = Provider.of<FinalSummaryViewModel>(context, listen: false);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDateIndex = index;
          selectedDate = item.date;
        });

        final summaryVm = Provider.of<FinalSummaryViewModel>(
          context,
          listen: false,
        );

        summaryVm.finalSummaryApi(
          selectedDate,
          summary.finalSummaryModel!.distance,
          summary.finalSummaryModel!.pickupPoint,
          summary.finalSummaryModel!.dropPoint,
          selectedSingle,
          selectedMulti,
          selectedUnpack,
          selectedDismantle,
          context,
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? PortColor.gold.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? PortColor.gold : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextConst(title: day, fontWeight: FontWeight.bold, size: 12),
            const SizedBox(height: 2),
            TextConst(
              title: weekDate,
              color: isSelected ? Colors.black : Colors.grey,
              size: 10,
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? PortColor.gray : PortColor.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddonItem(
    String title,
    String description,
    bool isSelected,
    ValueChanged<bool?> onChanged,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        onChanged(!isSelected);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? PortColor.button : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: onChanged,
              activeColor: PortColor.button,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextConst(
                    title: title,
                    color: isSelected ? PortColor.button : Colors.black,
                    fontFamily: AppFonts.kanitReg,
                    fontWeight: FontWeight.w500,
                  ),
                  TextConst(
                    title: description,
                    color: Colors.grey,
                    fontFamily: AppFonts.poppinsReg,
                    size: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StepWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isActive;
  final bool isCompleted;

  const StepWidget({
    super.key,
    required this.icon,
    required this.text,
    required this.isActive,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? PortColor.button : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isActive ? Colors.white : Colors.grey,
            size: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 10,
            fontFamily: AppFonts.kanitReg,
          ),
        ),
      ],
    );
  }
}

/// DottedLine
class DottedLine extends StatelessWidget {
  final int dotCount;
  final double dotWidth;
  final double dotHeight;
  final double spacing;

  const DottedLine({
    super.key,
    this.dotCount = 16,
    this.dotWidth = 2,
    this.dotHeight = 1,
    this.spacing = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotCount, (index) {
        return Container(
          width: dotWidth,
          height: dotHeight,
          color: PortColor.gray,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
        );
      }),
    );
  }
}
