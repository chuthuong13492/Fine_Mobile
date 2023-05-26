import 'dart:io';

import 'package:fine/Accessories/theme_data.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/View/home.dart';
import 'package:fine/View/login.dart';
import 'package:fine/View/nav_screen.dart';
import 'package:fine/View/notFoundScreen.dart';
import 'package:fine/View/onboard.dart';
import 'package:fine/View/order.dart';
import 'package:fine/View/order_detail.dart';
import 'package:fine/View/order_history.dart';
import 'package:fine/View/product_detail.dart';
import 'package:fine/View/product_filter_list.dart';
import 'package:fine/View/profile.dart';
import 'package:fine/View/sign_in.dart';
import 'package:fine/View/start_up.dart';
import 'package:fine/View/store_select_screen.dart';
import 'package:fine/View/welcome_screen.dart';
import 'package:fine/ViewModel/startup_viewModel.dart';
import 'package:fine/setup.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/theme/color.dart';
import 'package:fine/Utils/pageNavigation.dart';
import 'package:fine/Utils/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (!GetPlatform.isWeb) {
  //   HttpOverrides.global = MyHttpOverrides();
  // }
  HttpOverrides.global = MyHttpOverrides();

  await setup();
  createRouteBindings();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
      title: 'Fine Delivery',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RoutHandler.WELCOME_SCREEN:
            return ScaleRoute(page: const WelcomeScreen());
          case RoutHandler.LOGIN:
            return CupertinoPageRoute(
                builder: (context) => const SignIn(), settings: settings);
          case RoutHandler.ONBOARD:
            return ScaleRoute(page: const OnBoardScreen());
          case RoutHandler.LOADING:
            return CupertinoPageRoute<bool>(
                builder: (context) => LoadingScreen(
                      title: settings.arguments as String ?? "Đang xử lý...",
                    ),
                settings: settings);
          case RoutHandler.PROFILE:
            return CupertinoPageRoute(
                builder: (context) => const ProfileScreen(),
                settings: settings);
          case RoutHandler.STORE_SELECT:
            return ScaleRoute(page: StoreSelectScreen());
          case RoutHandler.ORDER_HISTORY_DETAIL:
            return SlideBottomRoute(
              page: OrderHistoryDetail(order: settings.arguments as dynamic),
            );
          case RoutHandler.PRODUCT_DETAIL:
            return CupertinoPageRoute<bool>(
                builder: (context) => ProductDetailScreen(
                      dto: settings.arguments as dynamic,
                    ),
                settings: settings);
          case RoutHandler.ORDER:
            return CupertinoPageRoute<bool>(
                builder: (context) => OrderScreen(), settings: settings);
          case RoutHandler.PRODUCT_FILTER_LIST:
            return CupertinoPageRoute<bool>(
                builder: (context) => ProductsFilterPage(
                      params: settings.arguments as Map<String, dynamic>,
                    ),
                settings: settings);
          case RoutHandler.NAV:
            return CupertinoPageRoute(
                builder: (context) => RootScreen(
                      initScreenIndex: settings.arguments as int ?? 0,
                    ),
                settings: settings);
          case RoutHandler.HOME:
            return CupertinoPageRoute(
                builder: (context) => const HomeScreen(), settings: settings);
          default:
            return CupertinoPageRoute(
                builder: (context) => const NotFoundScreen(),
                settings: settings);
        }
      },
      theme: CustomTheme.lightTheme,
      home: const StartUpView(),
    );
  }
}
