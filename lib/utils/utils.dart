import 'package:flutter/material.dart';

enum MessagePosition { top, bottom }

class Utils {
  static void showSuccessMessage(
      BuildContext context, String message,
      {MessagePosition position = MessagePosition.top}) {
    _showOverlayMessage(
        context, message, Colors.green, Icons.check_circle, position);
  }

  static void showErrorMessage(
      BuildContext context, String message,
      {MessagePosition position = MessagePosition.top}) {
    _showOverlayMessage(
        context, message, Colors.redAccent, Icons.error, position);
  }

  static void _showOverlayMessage(
      BuildContext context,
      String message,
      Color backgroundColor,
      IconData icon,
      MessagePosition position,
      ) {
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position == MessagePosition.top ? 50 : null,
        bottom: position == MessagePosition.bottom ? 50 : null,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(24), // 👈 extra rounded
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                GestureDetector(
                  onTap: () => overlayEntry.remove(),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}



// import 'dart:async';
//
// import 'package:flutter/material.dart';
//
// class Utils {
//   static OverlayEntry? _overlayEntry;
//   static bool _isShowing = false;
//
//   static void show(String message, BuildContext context,{Color? color}) {
//     if (_isShowing) {
//       _overlayEntry?.remove();
//     }
//
//     _overlayEntry = OverlayEntry(
//       builder: (BuildContext context) => Center(
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//             decoration: BoxDecoration(
//               color: color??Colors.black.withOpacity(0.8),
//               borderRadius: BorderRadius.circular(24.0),
//             ),
//             child: Text(
//               message,
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//         ),
//       ),
//     );
//
//     Overlay.of(context).insert(_overlayEntry!);
//     _isShowing = true;
//
//     _startTimer();
//   }
//
//   static void _startTimer() {
//     Timer(const Duration(seconds: 2), () {
//       if (_overlayEntry != null) {
//         _overlayEntry!.remove();
//         _isShowing = false;
//       }
//     });
//   }}