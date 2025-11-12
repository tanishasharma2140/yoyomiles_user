import 'package:flutter/foundation.dart';
import 'package:port_karo/utils/utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Launcher {
  // static launchWhatsApp(context, String phone) async {
  //   var whatsAppUrlAndroid = 'whatsapp://send?phone=+91$phone&text=hello';
  //   if (await canLaunchUrl(Uri.parse(whatsAppUrlAndroid))) {
  //     await launchUrl(Uri.parse(whatsAppUrlAndroid));
  //   } else {
  //     Utils.showErrorMessage(context, "Whatsapp not installed");
  //   }
  // }

  static launchDialPad(context, String phone) async {
    var phoneCall = "tel:$phone";
    if (await canLaunchUrl(Uri.parse(phoneCall))) {
      await launchUrl(Uri.parse(phoneCall));
    } else {
      Utils.showErrorMessage(context, "Number Busy");
    }
  }

  static launchEmail(context, String email) async {
    var callEmail = "mailto:$email";
    if (await canLaunchUrl(Uri.parse(callEmail))) {
      await launchUrl(Uri.parse(callEmail));
    } else {
      Utils.showErrorMessage(context, "email not login");
    }
  }

  static launchOnWeb(context, String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (kDebugMode) {
        print("Url not found");
      }
    }
  }

  static shareApk(String urlData, context) async {
    if (urlData.isNotEmpty) {
      await Share.share(
        "Hi, I recommend Yoyomiles for mini trucks requirement. It's convenient & cost effective. Download app ${Uri.parse(urlData)} & get up to Rs 50 cashback on first ride.",
      );
    } else {
      if (kDebugMode) {
        print('Inter Url');
      }
    }
  }
}
