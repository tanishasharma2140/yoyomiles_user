import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:port_karo/generated/assets.dart';
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
import 'package:port_karo/view_model/wallet_history_view_model.dart';
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
      final walletHistoryViewModel =
      Provider.of<WalletHistoryViewModel>(context, listen: false);
      walletHistoryViewModel.walletHistoryApi();
    });
  }



  final List transactions = [
    {
      "date": "Dec 23, 2024",
      "amount": "1.0",
    },
    {
      "date": "Dec 23, 2024",
      "amount": "1.0",
    },
    {
      "date": "Dec 23, 2024",
      "amount": "1.0",
    },
  ];

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
          border: Border.all(color: PortColor.gold,width: 0.5),
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

  @override
  Widget build(BuildContext context) {
    final walletHistoryViewModel = Provider.of<WalletHistoryViewModel>(context);


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
                TextConst(title: "Courier Credits", color: PortColor.black),
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
                  TextConst(title: "Balance ₹0", color: PortColor.black),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isBottomSheetVisible = true;
                      });
                    },
                    child: TextConst(
                      title: "Add Money",
                      color: PortColor.gold,
                      fontFamily: AppFonts.kanitReg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.01,
          ),
          Expanded(
            child: walletHistoryViewModel.loading
                ? const Center(
              child: CircularProgressIndicator(color: PortColor.gold),
            )
                : (walletHistoryViewModel.walletHistoryModel?.data?.isNotEmpty ?? false)
                ? Container(
              width: screenWidth,
              color: PortColor.white,
              child: ListView.builder(
                itemCount: walletHistoryViewModel.walletHistoryModel!.data!.length,
                itemBuilder: (context, index) {
                  final transaction = walletHistoryViewModel.walletHistoryModel!.data![index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.01,
                        ),
                        child: TextConst(
                          title: transaction.datetime.toString(),
                          color: PortColor.gray,
                        ),
                      ),
                      Divider(
                        thickness: screenWidth * 0.002,
                        color: PortColor.grey,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.035,
                        ),
                        child: Row(
                          children: [
                            Image(
                              image: AssetImage(Assets.assetsRuppee),
                              height: screenHeight * 0.07,
                              width: screenWidth * 0.13,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            TextConst(
                              title: "Wallet Recharge",
                              color: PortColor.black,
                            ),
                            const Spacer(),
                            TextConst(
                              title: "₹${transaction.amount.toString()}",
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
                : Center(
              child: TextConst(title: "No Data Found",fontFamily: AppFonts.kanitReg,),
            ),
          )

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
              TextConst(title: "Add Money", color: PortColor.black),
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
                        hintText: 'Enter Amount',
                        hintStyle: const TextStyle(color: PortColor.gray),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                          const BorderSide(color: PortColor.gray),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                          const BorderSide(color: PortColor.gray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: PortColor.gray, width: 1.5),
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
                      colors: [
                        PortColor.grey,
                        PortColor.grey,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: TextConst(
                      title: "Proceed",
                      fontFamily: AppFonts.kanitReg,
                      fontWeight: FontWeight.w600,
                      color: isProceedEnabled ? PortColor.black : PortColor.gray,
                    ),
                  ),
                ),
              )

            ],
          ),
        ),
      )
          : null,
    );
  }
}
