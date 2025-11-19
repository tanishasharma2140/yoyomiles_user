import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/model/packer_mover_order_history_model.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view_model/packer_mover_order_history_view_model.dart';
import 'package:provider/provider.dart';

class PackerMoverOrderHistory extends StatefulWidget {
  const PackerMoverOrderHistory({super.key});

  @override
  State<PackerMoverOrderHistory> createState() =>
      _PackerMoverOrderHistoryState();
}

class _PackerMoverOrderHistoryState extends State<PackerMoverOrderHistory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final packerMoverOrderHistoryVm =
          Provider.of<PackerMoverOrderHistoryViewModel>(context, listen: false);
      packerMoverOrderHistoryVm.packerMoverOrderHistoryApi(context);
    });
  }

  Widget _buildOrderCard(Orders order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: PortColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortColor.gold, width: 0.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: PortColor.blackLight,
                ),
                const SizedBox(width: 6),
                TextConst(
                  title: "Shifting Date: ${order.shiftingDate}",
                  color: PortColor.gold,
                  size: 12,
                ),
                const Spacer(),
                Icon(Icons.person, size: 16, color: PortColor.gray),
                const SizedBox(width: 6),
                TextConst(
                  title: order.senderName.toString().trim(),
                  size: 12,
                  color: PortColor.gray,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Address Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pickup Address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_upward,
                              size: 14,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 6),
                          TextConst(
                            title: "Pickup",
                            color: PortColor.blackLight,
                            fontWeight: FontWeight.w600,
                            size: 12,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextConst(
                        title: order.pickupAddress ?? "",
                        color: PortColor.gray,
                        size: 12,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Arrow Icon
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: PortColor.gold,
                  ),
                ),

                const SizedBox(width: 8),

                // Drop Address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: PortColor.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_downward,
                              size: 14,
                              color: PortColor.red,
                            ),
                          ),
                          const SizedBox(width: 6),
                          TextConst(
                            title: "Drop",
                            color: PortColor.blackLight,
                            fontWeight: FontWeight.w600,
                            size: 12,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextConst(
                        title: order.dropAddress ?? "",
                        color: PortColor.gray,
                        size: 12,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Charges and Distance
            Row(
              children: [
                // Total Charges
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FF), // Soft light blue
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF3A78F2),
                      ), // Blue border
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextConst(
                          title: "₹${order.totalCharges}",
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A78F2), // Dark blue
                        ),
                        TextConst(
                          title: "Total Charges",
                          size: 10,
                          color: Color(0xFF3A78F2),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Distance
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PortColor.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: PortColor.blue.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextConst(
                          title: "${order.distance} km",
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: PortColor.blue,
                        ),
                        TextConst(
                          title: "Distance",
                          size: 10,
                          color: PortColor.blue,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Items Count
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PortColor.gold.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: PortColor.gold.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextConst(
                          title: "${order.totalQuantity}",
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: PortColor.gold,
                        ),
                        TextConst(
                          title: "Items",
                          size: 10,
                          color: PortColor.gold,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            buildAgentStatus(order),

            const SizedBox(height: 12),

            // View Details Button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  _showOrderDetails(context, order);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: PortColor.gold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: TextConst(
                    title: "View Order Details",
                    color: PortColor.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAgentStatus(Orders order) {
    final status = order.assignAgentStatus; // 0 or 1
    final agentName = order.agentName ?? "";
    final agentNumber = order.agentMobile ?? "";

    if (status == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Assigned Soon",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          Text(
            "Agent waiting...",
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      );
    }

    // ✅ status == 1 → Agent Assigned
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Assigned",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Agent Name: $agentName",
          style: TextStyle(fontSize: 12, color: Colors.black87),
        ),
        SizedBox(height: 6,),
        Text(
          "Mobile: $agentNumber",
          style: TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  void _showOrderDetails(BuildContext context, Orders order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: PortColor.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PortColor.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextConst(
                    title: "Order Details",
                    size: 17,
                    fontWeight: FontWeight.w700,
                    color: PortColor.blackLight,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: PortColor.gray),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    _buildDetailSection("Order Summary", Icons.receipt, [
                      _buildDetailRow("Order ID", "#${order.id}"),
                      _buildDetailRow("Total Items", "${order.totalQuantity}"),
                      _buildDetailRow(
                        "Total Charges",
                        "₹${order.totalCharges}",
                      ),
                      _buildDetailRow("Distance", "${order.distance} km"),
                      _buildDetailRow(
                        "Shifting Date",
                        order.shiftingDate ?? "",
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Address Details
                    _buildDetailSection("Address Details", Icons.location_on, [
                      _buildDetailRow(
                        "Pickup",
                        order.pickupAddress ?? "",
                        isMultiLine: true,
                      ),
                      _buildDetailRow(
                        "Drop",
                        order.dropAddress ?? "",
                        isMultiLine: true,
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Items List
                    _buildDetailSection(
                      "Items (${order.totalItem?.length ?? 0})",
                      Icons.inventory_2,
                      [
                        if (order.totalItem != null)
                          for (var item in order.totalItem!)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: PortColor.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: PortColor.gold.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: TextConst(
                                      title: "x${item.quantity}",
                                      fontWeight: FontWeight.bold,
                                      color: PortColor.gold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextConst(
                                          title:
                                              item.packerAndMoverTypeName ?? "",
                                          fontWeight: FontWeight.w600,
                                          color: PortColor.blackLight,
                                        ),
                                        TextConst(
                                          title: item.packerName ?? "",
                                          size: 12,
                                          color: PortColor.gray,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Charges Breakdown
                    _buildDetailSection(
                      "Charges Breakdown",
                      Icons.attach_money,
                      [
                        _buildDetailRow(
                          "Single Layer",
                          "₹${order.singleLayerCharges}",
                        ),
                        _buildDetailRow(
                          "Multi Layer",
                          "₹${order.multiLayerCharges}",
                        ),
                        _buildDetailRow(
                          "Unpacking",
                          "₹${order.unpackingCharges}",
                        ),
                        _buildDetailRow(
                          "Dismantle/Reassembly",
                          "₹${order.dismantleReassemblyCharges}",
                        ),
                        _buildDetailRow(
                          "Lift Charges",
                          "₹${order.liftCharges}",
                        ),
                        const Divider(),
                        _buildDetailRow(
                          "Total Amount",
                          "₹${order.totalCharges}",
                          isBold: true,
                          valueColor: PortColor.rapidGreenLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: PortColor.gold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: PortColor.gold),
            ),
            const SizedBox(width: 8),
            TextConst(
              title: title,
              fontWeight: FontWeight.w600,
              size: 15,
              color: PortColor.blackLight,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMultiLine = false,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: TextConst(
              title: label,
              fontWeight: FontWeight.w500,
              color: PortColor.gray,
              size: 14,
            ),
          ),
          Expanded(
            flex: 3,
            child: TextConst(
              title: value,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? PortColor.blackLight,
              size: 14,
              maxLines: isMultiLine ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final packerMoverHistoryVm = Provider.of<PackerMoverOrderHistoryViewModel>(
      context,
    );

    return Scaffold(
      appBar: AppBar(
        title: TextConst(
          title: "Order History",
          size: 18,
          fontWeight: FontWeight.w600,
          color: PortColor.blackLight,
        ),
        centerTitle: true,
        backgroundColor: PortColor.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: PortColor.white,
        child: Column(
          children: [
            // Header Info
            Container(
              width: screenWidth,
              padding: const EdgeInsets.all(16),
              color: PortColor.white,
              child: Column(
                children: [
                  TextConst(
                    title: "Your Moving Orders",
                    size: 16,
                    fontWeight: FontWeight.w600,
                    color: PortColor.blackLight,
                  ),
                  const SizedBox(height: 4),
                  TextConst(
                    title: "See all your packer & mover orders",
                    textAlign: TextAlign.center,
                    size: 12,
                    color: PortColor.gray,
                  ),
                ],
              ),
            ),

            // Orders List
            Expanded(
              child: packerMoverHistoryVm.loading
                  ? Center(
                      child: CupertinoActivityIndicator(
                        radius: 14,
                        color: PortColor.gold,
                      ),
                    )
                  : packerMoverHistoryVm.packerMoverOrderHistoryModel == null ||
                        packerMoverHistoryVm
                                .packerMoverOrderHistoryModel!
                                .orders ==
                            null ||
                        packerMoverHistoryVm
                            .packerMoverOrderHistoryModel!
                            .orders!
                            .isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: PortColor.gray),
                          const SizedBox(height: 16),
                          TextConst(
                            title: "No Orders Yet",
                            size: 18,
                            color: PortColor.gray,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: packerMoverHistoryVm
                          .packerMoverOrderHistoryModel!
                          .orders!
                          .length,
                      itemBuilder: (context, index) {
                        final order = packerMoverHistoryVm
                            .packerMoverOrderHistoryModel!
                            .orders![index];
                        return _buildOrderCard(order);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
