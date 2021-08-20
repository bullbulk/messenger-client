import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

Future<String?> getDeviceID() async {
  String? deviceID;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (kIsWeb) {
    // The web doesnt have a device ID, so use a combination fingerprint
    WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
    deviceID = webInfo.userAgent;
    /* } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    deviceID = iosInfo.identifierForVendor; */
  } else if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    deviceID = androidInfo.androidId;
  } else if (Platform.isLinux) {
    LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
    deviceID = linuxInfo.machineId;
  } else {
    WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
    deviceID = windowsInfo.computerName +
        windowsInfo.numberOfCores.toString() +
        windowsInfo.systemMemoryInMegabytes.toString();
  }
  return deviceID;
}
