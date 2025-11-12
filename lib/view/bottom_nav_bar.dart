import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/view/account/account.dart';
import 'package:port_karo/view/home/home.dart';
import 'package:port_karo/view/order/order.dart';
import 'package:port_karo/view/payment/payment.dart';

class BottomNavigationPage extends StatefulWidget {
  final int initialIndex;
  final Widget? page;
  const BottomNavigationPage({super.key, this.initialIndex = 0, this.page});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const OrderPage(),
    const PaymentsPage(),
    const AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      // 🔹 If not on Home, go back to Home
      setState(() {
        _selectedIndex = 0;
      });
      return false; // Don't exit app
    } else {
      // 🔹 Already on Home → show exit dialog
      return (await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          title: const Text(
            "Exit App",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: PortColor.blue,
            ),
          ),
          content: const Text(
            "Are you sure you want to exit this app?",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              child: const Text(
                "Exit",
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ],
        ),
      )) ??
          false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: PortColor.bg,
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, "Home", 0),
                _buildNavItem(Icons.receipt_long, "Orders", 1),
                _buildNavItem(Icons.account_balance_wallet, "Payments", 2),
                _buildNavItem(Icons.account_circle, "Account", 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        width: 80,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: _selectedIndex == index ? PortColor.blackLight : PortColor.gray,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _selectedIndex == index ? PortColor.blackLight : PortColor.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
