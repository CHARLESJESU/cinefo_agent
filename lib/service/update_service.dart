import 'package:in_app_update/in_app_update.dart';

class UpdateService {
  static Future<void> forceUpdate() async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      // replace with your logger if needed
      print('Force update failed: $e');
    }
  }
}