import 'package:flutter/material.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
import 'package:port_karo/view/bottom_nav_bar.dart';

class OrderSuccessfully extends StatefulWidget {
  const OrderSuccessfully({super.key});

  @override
  State<OrderSuccessfully> createState() => _OrderSuccessfullyState();
}

class _OrderSuccessfullyState extends State<OrderSuccessfully> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: PortColor.white,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/order-unscreen.gif",
                  width: 170,
                  height: 170,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                TextConst(
                  title: "Your order has been Successfully Placed!! 🎉",
                  color: PortColor.black,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextConst(title: "Go to ", color: PortColor.black),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BottomNavigationPage(initialIndex: 1),
                          ),
                        );
                      },
                      child: TextConst(title: "My Order ", color: PortColor.blue),
                    ),
                    TextConst(title: "Section", color: PortColor.black),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
