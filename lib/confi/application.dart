import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class ApplicationGlobal{
  static String url;

  static requestPermission(VoidCallback onRequestGranted) async {
    var status = await Permission.storage.status;
    if (status.isUndetermined) {
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print(statuses[Permission.storage]);

      if (statuses[Permission.storage].isGranted) {
        debugPrint("status is granted   isUndetermined");
        try {
          //Do something
          onRequestGranted();
        } catch (e) {
          debugPrint("error :   ${e.toString()}");
        }
        //Do something
        onRequestGranted();
      } else if (statuses[Permission.storage].isDenied) {
        debugPrint("status is granted   isDenied");
        requestPermission(onRequestGranted);
      } else if (statuses[Permission.storage].isPermanentlyDenied) {
        debugPrint("status is granted   isPermanentlyDenied");
        openAppSettings();
      }

      // it should print PermissionStatus.granted
    } else if (status.isGranted) {
      debugPrint("status is granted");
      try {
        //Do something.
        onRequestGranted();
      } catch (e) {
        debugPrint("error :   ${e.toString()}");
      }
    } else if (status.isDenied) {
      debugPrint("status is denied");
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print(statuses[Permission.storage]); //
    } else if (status.isPermanentlyDenied) {
      debugPrint("status is permanent denied");
      openAppSettings();
    } else if (status.isRestricted) {
      debugPrint("status is restricted");
    }
  }
}
