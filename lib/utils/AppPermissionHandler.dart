import 'package:flutterapp/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app_widget.dart';

Future<bool> requestPermissionGranted(context, requestPermissions) async {
  var result = await PermissionHandler().requestPermissions(requestPermissions);
  switch (result[PermissionGroup.storage]) {
    case PermissionStatus.granted:
      // Application has been given permission to use the feature.
      return true;
    case PermissionStatus.denied:
      // Application has been denied permission to use the feature.
      return false;
    case PermissionStatus.neverAskAgain:
      ConfirmAction res = await showConfirmDialogs(
          context,
          'You was denied Permission. You have give manual permission from app setting. ',
          'Open App Setting',
          'Cancel');
      if (res == ConfirmAction.ACCEPT) {
        PermissionHandler().openAppSettings();
        return false;
      } else if (res == ConfirmAction.CANCEL) {
        return false;
      }
      return false;
    case PermissionStatus.restricted:
      // iOS has restricted access to a specific feature.
      return false;
    default:
      return false;
  }
}
