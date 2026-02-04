import 'package:flutter/cupertino.dart';
import 'package:in_app_update/in_app_update.dart';

Future<void> checkForUpdate() async {
  try {
    final AppUpdateInfo updateInfo =
    await InAppUpdate.checkForUpdate();

    if (updateInfo.updateAvailability ==
        UpdateAvailability.updateAvailable) {

      if (updateInfo.immediateUpdateAllowed) {
        // 🔥 FORCE UPDATE
        await InAppUpdate.performImmediateUpdate();
      } else if (updateInfo.flexibleUpdateAllowed) {
        // 🙂 NORMAL UPDATE
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    }
  } catch (e) {
    debugPrint("In-App Update error: $e");
  }
}
