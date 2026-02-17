import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view_model/profile_view_model.dart';
import 'package:yoyomiles/view_model/user_transaction_view_model.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';

class PaymentPorterCredit extends StatefulWidget {
  const PaymentPorterCredit({super.key});

  @override
  State<PaymentPorterCredit> createState() => _PaymentPorterCreditState();
}

class _PaymentPorterCreditState extends State<PaymentPorterCredit> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("trabsactuyon");
      final userTransactionVm = Provider.of<UserTransactionViewModel>(
        context,
        listen: false,
      );
      userTransactionVm.userTransactionApi(context);
      final profileVm = Provider.of<ProfileViewModel>(context,listen: false);
      profileVm.profileApi(context);
    });
  }


  final TextEditingController _controller = TextEditingController();
  bool isBottomSheetVisible = false;
  bool isProceedEnabled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateProceedButton() {
    setState(() {
      isProceedEnabled =
          _controller.text.isNotEmpty && int.tryParse(_controller.text) != null;
    });
  }

  void _addAmount(int amount) {
    int currentAmount = int.tryParse(_controller.text) ?? 0;
    int newAmount = currentAmount + amount;
    _controller.text = newAmount.toString();
    _updateProceedButton();
  }

  Widget _quickAddButton(String label, int amount) {
    return GestureDetector(
      onTap: () => _addAmount(amount),
      child: Container(
        height: 40,
        width: 50,
        decoration: BoxDecoration(
          border: Border.all(color: PortColor.gold, width: 0.5),
          color: PortColor.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: TextConst(
            title: label,
            fontFamily: AppFonts.kanitReg,
            color: PortColor.blue,
          ),
        ),
      ),
    );
  }
  String formatDate(String date) {
    try {
      DateTime dt = DateTime.parse(date);
      return "${dt.day}-${dt.month}-${dt.year}";
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userTransactionVm = Provider.of<UserTransactionViewModel>(context);
    final profileVm = Provider.of<ProfileViewModel>(context);
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: PortColor.bg,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 15),
            height: screenHeight * 0.095,
            width: screenWidth,
            decoration: BoxDecoration(
              color: PortColor.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(width: screenWidth * 0.04),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: PortColor.black,
                    size: screenHeight * 0.025,
                  ),
                ),
                SizedBox(width: screenWidth * 0.28),
                TextConst(title: loc.yoyomiles_credit, color: PortColor.black),
              ],
            ),
          ),
          Container(
            height: screenHeight * 0.07,
            width: screenWidth,
            decoration: BoxDecoration(
              color: PortColor.yellowAccent.withOpacity(0.5),
              border: const Border(bottom: BorderSide(color: PortColor.white)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Row(
                children: [
                  TextConst(
                    title:
                        "${loc.yoyomiles_credit} ₹${profileVm.profileModel?.data?.wallet ?? "e"}",
                    color: PortColor.black,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Expanded(
            child: userTransactionVm.loading
                ? const Center(child: CupertinoActivityIndicator(radius: 14))
                : (userTransactionVm.userTransactionModel?.data?.isNotEmpty ??
                      false)
                ? ListView.builder(
                    padding: EdgeInsets.only(top: screenHeight * 0.01),
                    itemCount:
                        userTransactionVm.userTransactionModel!.data!.length,
                    itemBuilder: (context, index) {
                      final txn =
                          userTransactionVm.userTransactionModel!.data![index];

                      // ⭐ STATUS LOGIC
                      int status = txn.paymentGatewayStatus ?? 0;

                      String statusText = status == 1
                          ? "Success"
                          : status == 2
                          ? "Failed"
                          : "Pending";

                      Color statusColor = status == 1
                          ? Colors.green
                          : status == 2
                          ? Colors.red
                          : Colors.orange;

                      // ⭐ AMOUNT LOGIC (Recharge = +, Other = - if needed)
                      bool isAdded =
                          double.tryParse(txn.amount.toString()) != 0.0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // DATE
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.005,
                            ),
                            child: Text(
                              formatDate(txn.createdAt.toString()),
                              style: TextStyle(
                                color: PortColor.gray,
                                fontFamily: AppFonts.poppinsReg,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          // TRANSACTION CARD
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.015,
                            ),
                            margin: EdgeInsets.only(
                              bottom: screenHeight * 0.008,
                            ),
                            color: Colors.white,
                            child: Row(
                              children: [
                                // ⭐ ICON BOX
                                Container(
                                  height: screenHeight * 0.055,
                                  width: screenHeight * 0.055,
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isAdded
                                        ? Icons.arrow_circle_down
                                        : Icons.arrow_circle_up,
                                    color: statusColor,
                                    size: 30,
                                  ),
                                ),

                                SizedBox(width: screenWidth * 0.04),

                                // ⭐ DETAILS
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      txn.subType == 1
                                          ? "Wallet Recharge"
                                          : "Wallet Transaction",
                                      style: TextStyle(
                                        fontFamily: AppFonts.kanitReg,
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.004),
                                    Text(
                                      "Order ID: ${txn.orderId}",
                                      style: TextStyle(
                                        fontFamily: AppFonts.poppinsReg,
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Platform Fee: ${txn.platformFee}",
                                      style: TextStyle(
                                        fontFamily: AppFonts.poppinsReg,
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),

                                const Spacer(),

                                // ⭐ AMOUNT + STATUS BADGE
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "₹${txn.totalAmount}", // show total_amount
                                      style: TextStyle(
                                        color: statusColor,
                                        fontFamily: AppFonts.kanitReg,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(height: screenHeight * 0.004),

                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontFamily: AppFonts.poppinsReg,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : Center(
                    child: TextConst(
                      title: loc.no_transaction,
                      fontFamily: AppFonts.kanitReg,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ],
      ),
      bottomSheet: isBottomSheetVisible
          ? Container(
              height: screenHeight * 0.26,
              width: screenWidth,
              decoration: BoxDecoration(
                color: PortColor.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: PortColor.gray.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.015),
                    TextConst(title: loc.add_money, color: PortColor.black),
                    SizedBox(height: screenHeight * 0.012),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            cursorColor: PortColor.gray,
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            onChanged: (value) => _updateProceedButton(),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              hintText: loc.enter_amount,
                              hintStyle: const TextStyle(color: PortColor.gray),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: PortColor.gray,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: PortColor.gray,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: PortColor.gray,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        _quickAddButton("+500", 500),
                        SizedBox(width: screenWidth * 0.04),
                        _quickAddButton("+1000", 1000),
                        SizedBox(width: screenWidth * 0.04),
                        _quickAddButton("+2000", 2000),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.055),
                    GestureDetector(
                      onTap: isProceedEnabled ? () {} : null,
                      child: Container(
                        height: screenHeight * 0.06,
                        width: screenWidth * 0.88,
                        decoration: BoxDecoration(
                          gradient: isProceedEnabled
                              ? PortColor.subBtn
                              : const LinearGradient(
                                  colors: [PortColor.grey, PortColor.grey],
                                ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: TextConst(
                            title: loc.proceed,
                            fontFamily: AppFonts.kanitReg,
                            fontWeight: FontWeight.w600,
                            color: isProceedEnabled
                                ? PortColor.black
                                : PortColor.gray,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
