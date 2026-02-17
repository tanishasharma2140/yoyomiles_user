import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view/payment/widgets/payment_porter_credit.dart';
import 'package:yoyomiles/view_model/payment_view_model.dart';
import 'package:yoyomiles/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final TextEditingController _controller = TextEditingController();
  bool isProceedEnabled = false;
  bool isBottomSheetVisible = false;

  @override
  void dispose() {
    isBottomSheetVisible = false;
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
        height: screenHeight * 0.04,
        width: screenWidth * 0.14,
        decoration: BoxDecoration(
          color: PortColor.rapidSplash,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: PortColor.gold, width: 0.4),
        ),
        child: Center(
          child: TextConst(
            title: label,
            color: PortColor.blackLight,
            fontWeight: FontWeight.w600,
            size: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paytmVm = Provider.of<PaymentViewModel>(context);
    // final addMoneyPaymentVm = Provider.of<AddMoneyPaymentViewModel>(context);
    final profileVm = Provider.of<ProfileViewModel>(context);
    final loc = AppLocalizations.of(context)!;

    return PopScope(
      onPopInvokedWithResult: (val, res) {
        if (isBottomSheetVisible) {
          setState(() {
            isBottomSheetVisible = false;
          });
        }
      },
      child: Stack(
        children: [
          /// Main Body
          Column(
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
                    title: loc.payments,
                    color: PortColor.black,
                    fontFamily: AppFonts.kanitReg,
                    size: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              isBottomSheetVisible = false;
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PaymentPorterCredit(),
                              ),
                            );
                          },
                          child: TextConst(
                            title: loc.yoyomiles_credit,
                            color: PortColor.black,
                            fontFamily: AppFonts.poppinsReg,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isBottomSheetVisible = true;
                            });
                            facebookAppEvents.logEvent(
                              name: 'add_money_from_wallet',
                            );
                          },
                          child: Container(
                            height: screenHeight * 0.04,
                            width: screenWidth * 0.25,
                            decoration: BoxDecoration(
                              color: PortColor.rapidSplash,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: PortColor.gray.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: TextConst(
                                title: loc.add_money,
                                color: PortColor.black,
                                fontFamily: AppFonts.poppinsReg,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextConst(
                      title: "${loc.balance} ₹${profileVm.profileModel?.data?.wallet??"e"}",
                      color: PortColor.gray,
                      size: 13,
                    ),
                    Divider(thickness: screenWidth * 0.001),
                  ],
                ),
              ),
            ],
          ),

          /// Bottom Sheet
          if (isBottomSheetVisible)
            Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
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
                          SizedBox(height: screenHeight * 0.014),
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
                                    hintStyle: const TextStyle(
                                      color: PortColor.gray,
                                    ),
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
                            onTap: isProceedEnabled
                                ? () {
                              double enteredAmount =
                                  double.tryParse(_controller.text) ?? 0;

                              if (enteredAmount >= 10) {
                                final formattedAmount =
                                enteredAmount.toStringAsFixed(2);

                                paytmVm.paymentApi(
                                  5,
                                  formattedAmount,
                                  "",
                                  context,
                                );
                              } else {
                                Utils.showErrorMessage(
                                  context,
                                  loc.at_least,
                                );
                              }
                            }
                                : null,
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
                                child: !paytmVm.loading
                                    ? TextConst(
                                  title: loc.proceed,
                                  fontFamily: AppFonts.kanitReg,
                                  color: isProceedEnabled
                                      ? PortColor.black
                                      : PortColor.gray,
                                )
                                    : const CupertinoActivityIndicator(
                                  radius: 14,
                                  color: PortColor.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// 🔴 CLOSE BUTTON ON TOP RIGHT
                Positioned(
                  right: 12,
                  bottom: screenHeight * 0.26 + -17,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isBottomSheetVisible = false;
                        _controller.clear();
                        isProceedEnabled = false;
                      });
                    },
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
              ],
            )

        ],
      ),
    );
  }
}
