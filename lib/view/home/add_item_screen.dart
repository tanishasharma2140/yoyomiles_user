import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/model/packer_mover_model.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view_model/packer_mover_view_model.dart';
import 'package:yoyomiles/view_model/save_selected_item_view_model.dart';
import 'package:provider/provider.dart';

class AddItemsScreen extends StatefulWidget {
  final Map<String, dynamic> movingDetailsData;

  const AddItemsScreen({super.key, required this.movingDetailsData});

  @override
  _AddItemsScreenState createState() => _AddItemsScreenState();
}

class _AddItemsScreenState extends State<AddItemsScreen> {
  int currentStep = 1;
  String selectedCategory = 'Living Room';
  final ScrollController _scrollController = ScrollController();

  Timer? _scrollTimer;

  // Dynamic category data
  Map<String, List<Map<String, dynamic>>> categoryItems = {};
  final List<String> _categories = [
    'Living Room',
    'Bedroom',
    'Kitchen',
    'Others',
  ];

  // Map packer_type to category names
  final Map<int, String> _packerTypeToCategory = {
    1: 'Living Room',
    2: 'Bedroom',
    3: 'Kitchen',
    4: 'Others',
  };

  bool _isDataProcessed = false;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeEmptyData();

    // Print received moving details data
    _printReceivedMovingDetails();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCategory(selectedCategory);
      final packerMoverVm = Provider.of<PackerMoverViewModel>(
        context,
        listen: false,
      );
      packerMoverVm.packerMoverApi();
    });
  }

  // void _storeMovingDetailsGlobally() {
  //   final movingDetailsVm = Provider.of<MovingDetailsViewModel>(context, listen: false);
  //   movingDetailsVm.setMovingDetails(widget.movingDetailsData);
  // }

  void _printReceivedMovingDetails() {
    print("═══════════════════════════════════════");
    print("RECEIVED MOVING DETAILS IN ADD ITEMS SCREEN:");

    print("Distance: ${widget.movingDetailsData['distance'] ?? 'N/A'} km");

    // Safe access for nested maps
    final pickupPoint =
        widget.movingDetailsData['pickup_point'] as Map<String, dynamic>? ?? {};
    final dropPoint =
        widget.movingDetailsData['drop_point'] as Map<String, dynamic>? ?? {};

    print(
      "Pickup Point - Lift: ${pickupPoint['has_lift'] ?? 'N/A'}, Floors: ${pickupPoint['floors'] ?? 'N/A'}",
    );
    print(
      "Drop Point - Lift: ${dropPoint['has_lift'] ?? 'N/A'}, Floors: ${dropPoint['floors'] ?? 'N/A'}",
    );

    print(
      "Pickup Location: ${widget.movingDetailsData['pickup_address'] ?? 'N/A'}",
    );
    print(
      "Drop Location: ${widget.movingDetailsData['drop_address'] ?? 'N/A'}",
    );

    // ✅ Newly added: print coordinates
    print(
      "Pickup Latitude: ${widget.movingDetailsData['pickup_lat'] ?? 'N/A'}",
    );
    print(
      "Pickup Longitude: ${widget.movingDetailsData['pickup_lng'] ?? 'N/A'}",
    );
    print(
      "Drop Latitude: ${widget.movingDetailsData['drop_lat'] ?? 'N/A'}",
    );
    print(
      "Drop Longitude: ${widget.movingDetailsData['drop_lng'] ?? 'N/A'}",
    );

    print("Service Type: ${widget.movingDetailsData['service_type'] ?? 'N/A'}");
    print("Shifting Date: ${widget.movingDetailsData['shifting_date'] ?? 'N/A'}");
    print("═══════════════════════════════════════");
  }


  void _initializeEmptyData() {
    for (var category in _categories) {
      categoryItems[category] = [];
    }
  }

  void _processApiData(PackerMoversModel? apiData) {
    if (apiData?.data == null || _isDataProcessed) return;

    setState(() {
      // Clear existing data
      for (var category in _categories) {
        categoryItems[category] = [];
      }

      // Process API data
      for (var categoryData in apiData!.data!) {
        final categoryName = _packerTypeToCategory[categoryData.packerType];
        if (categoryName != null && categoryItems.containsKey(categoryName)) {
          final packers = categoryData.packers ?? [];

          for (var packer in packers) {
            final subItems = packer.subItems ?? [];
            final processedSubItems = subItems.map((subItem) {
              return {
                'name': subItem.itemName ?? '',
                'count': 0,
                'itemId': subItem.itemId,
                'amount': subItem.amount,
                'comment': subItem.comment,
              };
            }).toList();

            // Only add if there are sub-items
            if (processedSubItems.isNotEmpty) {
              categoryItems[categoryName]!.add({
                'name': packer.packerName ?? '',
                'expanded': false,
                'subItems': processedSubItems,
                'packerId': packer.packerMoverId,
                'imageIcon': packer.imageIcon,
                'comment': packer.comment,
              });
            }
          }
        }
      }
      _isDataProcessed = true;
    });
  }

  int get selectedItemsCount {
    int count = 0;
    categoryItems.forEach((category, items) {
      for (var item in items) {
        for (var subItem in item['subItems']) {
          count += (subItem['count'] as int);
        }
      }
    });
    return count;
  }

  // Updated selectedItemsList for API format
  List<Map<String, dynamic>> get selectedItemsList {
    List<Map<String, dynamic>> selected = [];
    categoryItems.forEach((category, items) {
      for (var item in items) {
        for (var subItem in item['subItems']) {
          if (subItem['count'] > 0) {
            selected.add({
              'packer_and_mover_type_id': subItem['itemId'], // API format
              'quantity': subItem['count'],
              // Additional info for display (optional)
              'category': category,
              'mainItem': item['name'],
              'subItem': subItem['name'],
              'amount': subItem['amount'],
              'comment': subItem['comment'],
            });
          }
        }
      }
    });
    return selected;
  }

  // Get only the required fields for API call
  List<Map<String, dynamic>> get selectedItemsForApi {
    List<Map<String, dynamic>> selected = [];
    categoryItems.forEach((category, items) {
      for (var item in items) {
        for (var subItem in item['subItems']) {
          if (subItem['count'] > 0) {
            selected.add({
              "packer_and_mover_type_id": subItem['itemId'],
              "quantity": subItem['count'],
            });
          }
        }
      }
    });
    return selected;
  }

  void _onScroll() {
    _scrollTimer?.cancel();
    _isScrolling = true;

    _scrollTimer = Timer(const Duration(milliseconds: 50), () {
      if (!_scrollController.hasClients || !mounted) return;

      final scrollOffset = _scrollController.offset;
      double accumulatedHeight = 0;
      String? newSelectedCategory;

      for (final category in _categories) {
        final sectionHeight = _calculateSectionHeight(category);

        if (scrollOffset >= accumulatedHeight - 50 &&
            scrollOffset < accumulatedHeight + sectionHeight - 50) {
          newSelectedCategory = category;
          break;
        }

        accumulatedHeight += sectionHeight;
      }

      if (newSelectedCategory != null &&
          newSelectedCategory != selectedCategory) {
        setState(() {
          selectedCategory = newSelectedCategory!;
        });
      }

      _isScrolling = false;
    });
  }

  double _calculateSectionHeight(String category) {
    final items = categoryItems[category] ?? [];
    double height = screenHeight * 0.08;

    for (var item in items) {
      height += screenHeight * 0.07;
      if (item['expanded']) {
        height += (item['subItems'].length * screenHeight * 0.06);
      }
    }

    height += screenHeight * 0.03;
    return height;
  }

  void _scrollToCategory(String category) {
    _scrollTimer?.cancel();

    final categoryIndex = _categories.indexOf(category);
    if (categoryIndex == -1) return;

    double scrollOffset = 0;
    for (int i = 0; i < categoryIndex; i++) {
      final cat = _categories[i];
      scrollOffset += _calculateSectionHeight(cat);
    }

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _checkPrice() {
    final loc = AppLocalizations.of(context)!;
    if (selectedItemsCount == 0) {
       Utils.showErrorMessage(context, loc.please_enter_atleast_one );
      return;
    }

    try {
      final distance = _toInt(
        widget.movingDetailsData['distance'],
      ); // Convert double to int

      // Pickup and drop point - dynamic access
      final dynamic pickupPointDynamic =
      widget.movingDetailsData['pickup_point'];
      final dynamic dropPointDynamic = widget.movingDetailsData['drop_point'];

      // Convert to Map if needed
      final Map<String, dynamic> pickupPoint =
      pickupPointDynamic is Map<String, dynamic> ? pickupPointDynamic : {};
      final Map<String, dynamic> dropPoint =
      dropPointDynamic is Map<String, dynamic> ? dropPointDynamic : {};

      // Debug prints
      print("═══════════════════════════════════════");
      print("distance: ${widget.movingDetailsData['distance']} -> $distance");
      print("═══════════════════════════════════════");
      facebookAppEvents.logEvent(
        name: 'add_items_for_packer_mover',
      );

      // Check which fields are missing
      List<String> missingFields = [];

      if (distance == null) missingFields.add('distance');

      final selectedItemVm = Provider.of<SaveSelectedItemViewModel>(
        context,
        listen: false,
      );
      selectedItemVm.saveSelectedItemsApi(
        widget.movingDetailsData['service_type'], // cityType static hai dynamic krna hai
        distance,
        pickupPoint,
        dropPoint,
        selectedItemsForApi,
        context,
        widget.movingDetailsData

      );
    } catch (e, stackTrace) {
      print("Error in _checkPrice: $e");
      print("Stack trace: $stackTrace");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  // Helper method to convert any numeric type to int
  int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    } else if (value is double) {
      return value.round(); // ya toInt() bhi use kar sakte hain
    } else if (value is String) {
      return int.tryParse(value);
    } else {
      return null;
    }
  }

  void _retryLoading() {
    final packerMoverVm = Provider.of<PackerMoverViewModel>(
      context,
      listen: false,
    );
    packerMoverVm.clearError();
    packerMoverVm.packerMoverApi();
    setState(() {
      _isDataProcessed = false;
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final packerMoverVm = Provider.of<PackerMoverViewModel>(context);
    // Process API data when it's available
    if (packerMoverVm.packerMoversData != null && !_isDataProcessed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processApiData(packerMoverVm.packerMoversData);
      });
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.bg,
        body: Column(
          children: [
            SizedBox(height: topPadding),
            // Header Section
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
                      const DottedLine(),
                      StepWidget(
                        icon: Icons.inventory,
                        text: loc.add_items,
                        isActive: true,
                        isCompleted: false,
                      ),
                      const DottedLine(),
                      StepWidget(
                        icon: Icons.receipt,
                        text: loc.schedule,
                        isActive: false,
                        isCompleted: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content
            if (packerMoverVm.loading)
            // LOADING STATE - Jab tak data na aaye
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: PortColor.gold),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        loc.loading_item,
                        style: TextStyle(
                          color: PortColor.black,
                          fontSize: 16,
                          fontFamily: AppFonts.kanitReg,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (packerMoverVm.error != null)
            // ERROR STATE
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: screenHeight * 0.06,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        packerMoverVm.error!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontFamily: AppFonts.kanitReg,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      ElevatedButton(
                        onPressed: _retryLoading,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PortColor.button,
                          foregroundColor: PortColor.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.06,
                            vertical: screenHeight * 0.015,
                          ),
                        ),
                        child: Text(
                          loc.retry,
                          style: TextStyle(
                            fontFamily: AppFonts.kanitReg,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_hasNoData(packerMoverVm.packerMoversData))
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.grey,
                          size: screenHeight * 0.08,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          loc.no_item_available,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontFamily: AppFonts.kanitReg,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          loc.please_try_again_later,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                            fontFamily: AppFonts.kanitReg,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
              // DATA LOADED SUCCESSFULLY - Jab data aa jaye
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.02),

                      // Category Tabs
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          height: screenHeight * 0.04,
                          decoration: BoxDecoration(
                            color: PortColor.grey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _categories
                                .map(
                                  (category) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCategory = category;
                                  });
                                  _scrollToCategory(category);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedCategory == category
                                        ? PortColor.button
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: PortColor.black,
                                        fontFamily: AppFonts.kanitReg,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Instruction Text
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                        ),
                        child: Text(
                          loc.add_items_to_get_the,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontFamily: AppFonts.kanitReg,
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Items List with ListView.builder
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.02,
                          ),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return _buildCategorySection(category, index);
                          },
                        ),
                      ),

                      // Bottom Summary Bar
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.02,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$selectedItemsCount ${loc.item_added}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: PortColor.black,
                                  ),
                                ),
                                if (selectedItemsCount > 0)
                                  GestureDetector(
                                    onTap: _showSelectedItems,
                                    child: Text(
                                      loc.view_all,
                                      style: TextStyle(
                                        color: PortColor.button,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: _showSelectedItems,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.06,
                                  vertical: screenHeight * 0.012,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: PortColor.button),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  loc.view_all,
                                  style: TextStyle(
                                    color: PortColor.button,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: GestureDetector(
                                onTap: _checkPrice,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.015,
                                    horizontal: screenWidth * 0.01,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PortColor.button,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    loc.check_price,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: AppFonts.kanitReg,
                                      color: PortColor.black,
                                      fontSize: 12,
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
          ],
        ),
      ),
    );
  }

  // Helper method to check if no data is available
  bool _hasNoData(PackerMoversModel? apiData) {
    if (apiData == null || apiData.data == null) return true;

    // Check if any category has items
    for (var categoryData in apiData.data!) {
      final packers = categoryData.packers ?? [];
      for (var packer in packers) {
        final subItems = packer.subItems ?? [];
        if (subItems.isNotEmpty) {
          return false; // Data available
        }
      }
    }
    return true; // No data found
  }

  void _showSelectedItems() {
    final loc = AppLocalizations.of(context)!;
    if (selectedItemsList.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar( SnackBar(content: Text(loc.no_item_selected)));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: screenHeight * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.selected_item,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: PortColor.black,
                        fontFamily: AppFonts.kanitReg,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 20, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Total Items Count
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Row(
                  children: [
                    Text(
                      "$selectedItemsCount ${loc.item_added}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PortColor.black,
                        fontFamily: AppFonts.kanitReg,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Categories and Items List
              Expanded(child: _buildSelectedItemsByCategory()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedItemsByCategory() {
    // Group selected items by category
    Map<String, List<Map<String, dynamic>>> categorizedItems = {};

    for (var item in selectedItemsList) {
      final category = item['category'];
      if (!categorizedItems.containsKey(category)) {
        categorizedItems[category] = [];
      }
      categorizedItems[category]!.add(item);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      itemCount: categorizedItems.length,
      itemBuilder: (context, index) {
        final category = categorizedItems.keys.elementAt(index);
        final items = categorizedItems[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Header
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.015),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: PortColor.black,
                  fontFamily: AppFonts.kanitReg,
                ),
              ),
            ),

            // Items in this category
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, itemIndex) {
                final item = items[itemIndex];
                return Container(
                  margin: EdgeInsets.only(bottom: screenHeight * 0.012),
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    children: [
                      // Item Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: PortColor.button,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconForItem(item['mainItem']),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.03),

                      // Item Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['subItem'],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: PortColor.black,
                                fontSize: 14,
                                fontFamily: AppFonts.kanitReg,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              item['mainItem'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: AppFonts.kanitReg,
                              ),
                            ),
                            if (item['comment'] != null &&
                                item['comment'].isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Text(
                                  item['comment'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: AppFonts.kanitReg,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Quantity
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: PortColor.button.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'x${item['quantity']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: PortColor.button,
                            fontSize: 14,
                            fontFamily: AppFonts.kanitReg,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Space between categories
            if (index < categorizedItems.length - 1)
              SizedBox(height: screenHeight * 0.025),
          ],
        );
      },
    );
  }

  Widget _buildCategorySection(String category, int categoryIndex) {
    final loc = AppLocalizations.of(context)!;
    final items = categoryItems[category] ?? [];
    final totalItemsInCategory = items.fold<int>(0, (sum, item) {
      return sum +
          (item['subItems'] as List<Map<String, dynamic>>).fold<int>(
            0,
                (subSum, subItem) => subSum + (subItem['count'] as int),
          );
    });

    return Column(
      key: Key(category),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 16,
                fontFamily: AppFonts.kanitReg,
                fontWeight: FontWeight.w600,
                color: PortColor.black,
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            if (totalItemsInCategory > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.005,
                ),
                decoration: BoxDecoration(
                  color: PortColor.button,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '$totalItemsInCategory ${loc.add_items}',
                  style: TextStyle(
                    fontSize: 10,
                    color: PortColor.black,
                    fontFamily: AppFonts.kanitReg,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: screenHeight * 0.015),
        if (items.isEmpty)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                loc.no_item_available_in,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontFamily: AppFonts.kanitReg,
                ),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, itemIndex) {
                final item = items[itemIndex];
                return Column(
                  children: [
                    _buildExpandableItem(item, category, itemIndex),
                    if (itemIndex < items.length - 1)
                      Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                  ],
                );
              },
            ),
          ),
        if (categoryIndex < _categories.length - 1)
          SizedBox(height: screenHeight * 0.03),
      ],
    );
  }

  Widget _buildExpandableItem(
      Map<String, dynamic> item,
      String category,
      int itemIndex,
      ) {
    final subItems = item['subItems'] as List<Map<String, dynamic>>;
    final totalSubItems = subItems.fold<int>(
      0,
          (sum, subItem) => sum + (subItem['count'] as int),
    );

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.005,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: totalSubItems > 0
                  ? PortColor.button
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              _getIconForItem(item['name']),
              color: totalSubItems > 0 ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
          ),
          title: Text(
            item['name'],
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: PortColor.black,
              fontFamily: AppFonts.kanitReg,
            ),
          ),
          subtitle: item['comment'] != null && item['comment'].isNotEmpty
              ? Text(
            item['comment'],
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (totalSubItems > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: PortColor.button.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalSubItems',
                    style: TextStyle(
                      color: PortColor.button,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              SizedBox(width: screenWidth * 0.02),
              Icon(
                item['expanded'] ? Icons.expand_less : Icons.expand_more,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ],
          ),
          onTap: () {
            setState(() {
              item['expanded'] = !item['expanded'];
            });
          },
        ),

        if (item['expanded'])
          Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.12,
              right: screenWidth * 0.04,
              bottom: screenHeight * 0.01,
            ),
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: subItems.length,
              itemBuilder: (context, subItemIndex) {
                final subItem = subItems[subItemIndex];
                return Column(
                  children: [
                    _buildSubItemTile(subItem, subItemIndex),
                    if (subItemIndex < subItems.length - 1)
                      Divider(
                        height: screenHeight * 0.02,
                        thickness: 0.5,
                        color: Colors.grey.shade200,
                      ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSubItemTile(Map<String, dynamic> subItem, int subItemIndex) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subItem['name'],
                  style: TextStyle(
                    fontSize: 13,
                    color: PortColor.black.withOpacity(0.8),
                    fontFamily: AppFonts.kanitReg,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (subItem['comment'] != null && subItem['comment'].isNotEmpty)
                  Text(
                    subItem['comment'],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (subItem['count'] > 0) {
                        subItem['count']--;
                      }
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: subItem['count'] > 0
                          ? Colors.red.shade50
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        bottomLeft: Radius.circular(6),
                      ),
                    ),
                    child: Icon(
                      Icons.remove,
                      size: 16,
                      color: subItem['count'] > 0 ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 30,
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      '${subItem['count']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: PortColor.black,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      subItem['count']++;
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                    ),
                    child: Icon(Icons.add, size: 16, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForItem(String itemName) {
    final name = itemName.toLowerCase();

    if (name.contains('chair')) return Icons.chair;
    if (name.contains('table')) return Icons.table_restaurant;
    if (name.contains('tv') || name.contains('monitor')) return Icons.tv;
    if (name.contains('cabinet') || name.contains('storage'))
      return Icons.weekend;
    if (name.contains('bed')) return Icons.bed;
    if (name.contains('wardrobe') || name.contains('almirah'))
      return Icons.weekend;
    if (name.contains('dressing')) return Icons.table_restaurant;
    if (name.contains('fridge')) return Icons.kitchen;
    if (name.contains('microwave')) return Icons.microwave;
    if (name.contains('gas')) return Icons.local_fire_department;
    if (name.contains('plant')) return Icons.local_florist;
    if (name.contains('sports') || name.contains('equipment'))
      return Icons.sports_basketball;
    if (name.contains('sofa')) return Icons.weekend;
    if (name.contains('mattress')) return Icons.bed;
    if (name.contains('ac') || name.contains('fan') || name.contains('cooler'))
      return Icons.ac_unit;
    if (name.contains('washing')) return Icons.local_laundry_service;
    if (name.contains('vehicle') ||
        name.contains('bike') ||
        name.contains('scooter'))
      return Icons.directions_bike;
    if (name.contains('carton') || name.contains('box'))
      return Icons.inventory_2;
    if (name.contains('gunny') || name.contains('bag'))
      return Icons.shopping_bag;
    if (name.contains('bathroom') ||
        name.contains('bucket') ||
        name.contains('tub'))
      return Icons.bathtub;
    if (name.contains('utility')) return Icons.home_repair_service;
    if (name.contains('suitcase') || name.contains('trolley'))
      return Icons.luggage;
    if (name.contains('piano') ||
        name.contains('guitar') ||
        name.contains('instrument'))
      return Icons.music_note;
    if (name.contains('treadmill') || name.contains('exercise'))
      return Icons.fitness_center;
    if (name.contains('pool') || name.contains('snooker')) return Icons.sports;

    return Icons.category;
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