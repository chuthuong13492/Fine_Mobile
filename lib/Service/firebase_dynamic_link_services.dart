import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

import '../Constant/route_constraint.dart';

class DynamicLinkService {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      // Listen and retrieve dynamic links here
      final String deepLink = dynamicLinkData.link.toString(); // Get DEEP LINK
      // Ex: https://namnp.page.link/product/013232
      final String path = dynamicLinkData.link.path; // Get PATH
      // Ex: product/013232
      if (deepLink.isEmpty) return;
      handleNaviagtion(path);
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
    initUniLinks();
  }

  Future<void> initUniLinks() async {
    try {
      final initialLink = await dynamicLinks.getInitialLink();
      if (initialLink == null) return;
      handleNaviagtion(initialLink.link.path);
    } catch (e) {
      // Error
    }
  }
  // Future handleDynamicLinks() async {
  //   FirebaseDynamicLinks.instance.onLink.listen((event) async {
  //     final Uri deepLink = event.link;
  //     // handleNaviagtion(event);
  //     if (deepLink != null) {
  //       print("Link: ${deepLink.path}");
  //       handleNaviagtion(deepLink.path);
  //     } else {
  //       print("Resume WTF");
  //     }
  //   }, onError: (error) async {
  //     print('onLinkError');
  //     print(error.message);
  //   });

  //   final PendingDynamicLinkData? data =
  //       await FirebaseDynamicLinks.instance.getInitialLink();
  //   final Uri deepLink = data!.link;

  //   if (deepLink != null) {
  //     print("Link: ${deepLink.path}");
  //     // ignore: unawaited_futures
  //     Timer.periodic(const Duration(milliseconds: 500), (timer) {
  //       if (Get.key.currentState == null) return;
  //       handleNaviagtion(deepLink.path);
  //       timer.cancel();
  //     });
  //   } else {
  //     print("Init WTF");
  //   }
  // }

  void handleNaviagtion(String path) {
    // final Uri deepLink = data.link;
    // if (deepLink != null) {
    //   print("deepLink: ${deepLink}");
    // }
    switch (path) {
      case RouteHandler.HOME:
        Get.toNamed(RouteHandler.NAV, arguments: 0);
        break;
      // case RouteHandler.GIFT:
      //   Get.toNamed(RouteHandler.NAV, arguments: 1);
      //   break;
      case RouteHandler.PROFILE:
        Get.toNamed(RouteHandler.NAV, arguments: 2);
        break;
      default:
        Get.toNamed(path);
    }
  }
}
