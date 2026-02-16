import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/view/account/account.dart';
import 'package:yoyomiles/view/home/home.dart';
import 'package:yoyomiles/view/order/order.dart';
import 'package:yoyomiles/view/payment/payment.dart';

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
    final loc = AppLocalizations.of(context)!;

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
          title:  Text(
             loc.exit_app,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: PortColor.blue,
            ),
          ),
          content:  Text(
           loc.want_to_exit_app,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child:  Text(
                loc.cancel,
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              child:  Text(
                loc.exit,
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
    final loc = AppLocalizations.of(context)!;
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
                _buildNavItem(Icons.home, loc.home, 0),
                _buildNavItem(Icons.receipt_long, loc.orders, 1),
                _buildNavItem(Icons.account_balance_wallet, loc.payments, 2),
                _buildNavItem(Icons.account_circle, loc.account, 3),
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
