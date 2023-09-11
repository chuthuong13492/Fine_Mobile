import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Utils/platform.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/custom_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/foundation.dart';

import '../Accessories/dialog.dart';

class PushNotificationService {
  static PushNotificationService? _instance;

  static PushNotificationService? getInstance() {
    if (_instance == null) {
      _instance = PushNotificationService();
    }
    return _instance;
  }

  static void destroyInstance() {
    _instance = null;
  }

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future init() async {
    // NotificationSettings settings = await _fcm.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );

    if ((defaultTargetPlatform == TargetPlatform.iOS)) {
      await _fcm.requestPermission();
      _fcm.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    // FirebaseMessaging.onMessage.listen((event) async {
    //   hideSnackbar();

    //   RemoteNotification notification = event.notification!;

    //   await showStatusDialog(
    //       "assets/images/logo2.png", notification.title!, notification.body!);
    //   print(event.data);
    // });
    // RemoteMessage? message =
    //     await FirebaseMessaging.instance.getInitialMessage();

    // FirebaseMessaging.onMessageOpenedApp.listen((event) {
    //   var screen = event.data['screen'];
    //   if (screen == RoutHandler.PRODUCT_FILTER_LIST) {
    //     Get.toNamed(
    //       RoutHandler.PRODUCT_FILTER_LIST,
    //       arguments: event.data,
    //     );
    //   }
    // });
  }

  Future<String?> getFcmToken() async {
    if (!isSmartPhoneDevice()) return null;
    String token = await _fcm.getToken() as String;
    return token;
  }
}
