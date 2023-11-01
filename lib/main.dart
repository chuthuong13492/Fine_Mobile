import 'dart:async';
import 'dart:io';

import 'package:fine/Accessories/theme_data.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/View/LoginScreen/login_byPhone.dart';
import 'package:fine/View/LoginScreen/login_byPhoneOTP.dart';
import 'package:fine/View/TopUp/transactionHistory_screen.dart';
import 'package:fine/View/cart_screen.dart';
import 'package:fine/View/checkingOrder_screen.dart';
import 'package:fine/View/coOrder_screen.dart';
import 'package:fine/View/confirm_party_screen.dart';
import 'package:fine/View/Home/home.dart';
import 'package:fine/View/invite_coOrder_screen.dart';
import 'package:fine/View/nav_screen.dart';
import 'package:fine/View/notFoundScreen.dart';
import 'package:fine/View/onboard.dart';
import 'package:fine/View/order.dart';
import 'package:fine/View/order_detail.dart';
import 'package:fine/View/order_history.dart';
import 'package:fine/View/prepareCoOrder_screen.dart';
import 'package:fine/View/product_detail.dart';
import 'package:fine/View/product_filter_list.dart';
import 'package:fine/View/profile.dart';
import 'package:fine/View/qrcode_screen.dart';
import 'package:fine/View/LoginScreen/sign_in.dart';
import 'package:fine/View/sign_up.dart';
import 'package:fine/View/start_up.dart';
import 'package:fine/View/station_picker_screen.dart';
import 'package:fine/View/store_select_screen.dart';
import 'package:fine/View/TopUp/topUp_screen.dart';
import 'package:fine/View/welcome_screen.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
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

import 'View/webview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (!GetPlatform.isWeb) {
  //   HttpOverrides.global = MyHttpOverrides();
  // }
  HttpOverrides.global = MyHttpOverrides();

  await setup();
  createRouteBindings();
  // Timer.periodic(const Duration(milliseconds: 500), (_) {
  //   Get.find<RootViewModel>().liveLocation();
  // });
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
          case RouteHandler.WELCOME_SCREEN:
            return ScaleRoute(page: const WelcomeScreen());
          case RouteHandler.LOGIN_PHONE:
            return CupertinoPageRoute(
                builder: (context) =>
                    LoginByPhoneScreen(isLoginMail: settings.arguments as bool),
                settings: settings);
          case RouteHandler.LOGIN_OTP:
            Map map = settings.arguments as Map;
            return CupertinoPageRoute(
                builder: (context) => LoginWithPhoneOtpScreen(
                      verificationId: map["verId"],
                      isLoginGmail: map["isLoginGmail"],
                    ),
                settings: settings);
          case RouteHandler.LOGIN:
            return CupertinoPageRoute(
                builder: (context) => const SignIn(), settings: settings);
          case RouteHandler.ONBOARD:
            return ScaleRoute(page: const OnBoardScreen());
          case RouteHandler.LOADING:
            return CupertinoPageRoute<bool>(
                builder: (context) => LoadingScreen(
                      title: settings.arguments as String ?? "Đang xử lý...",
                    ),
                settings: settings);
          case RouteHandler.WEBVIEW:
            return FadeRoute(
              page: WebViewScreen(url: settings.arguments as String),
            );
          case RouteHandler.PROFILE:
            return CupertinoPageRoute(
                builder: (context) => const ProfileScreen(),
                settings: settings);
          case RouteHandler.SIGN_UP:
            return CupertinoPageRoute<bool>(
                builder: (context) => SignUp(
                      user: settings.arguments as dynamic,
                    ),
                settings: settings);
          case RouteHandler.STORE_SELECT:
            return ScaleRoute(page: StoreSelectScreen());
          case RouteHandler.ORDER_HISTORY_DETAIL:
            return SlideBottomRoute(
              page: OrderHistoryDetail(order: settings.arguments as dynamic),
            );
          case RouteHandler.TRANSACTION_HISTORY:
            return SlideBottomRoute(
              page: TransactionHistoryScreen(),
            );
          case RouteHandler.QRCODE_SCREEN:
            return CupertinoPageRoute<bool>(
                builder: (context) =>
                    QRCodeScreen(order: settings.arguments as dynamic),
                settings: settings);
          case RouteHandler.INVITE_SCREEN:
            return CupertinoPageRoute<bool>(
                builder: (context) => InviteCoOrderScreen(
                    durationInSeconds: settings.arguments as int),
                settings: settings);
          case RouteHandler.CHECKING_ORDER_SCREEN:
            Map map = settings.arguments as Map;
            return CupertinoPageRoute<bool>(
                builder: (context) => CheckingOrderScreen(order: map["order"]),
                settings: settings);
          case RouteHandler.TOP_UP_SCREEN:
            return CupertinoPageRoute<bool>(
                builder: (context) => const TopUpScreen(), settings: settings);
          case RouteHandler.PRODUCT_DETAIL:
            return CupertinoPageRoute<bool>(
                builder: (context) => ProductDetailScreen(
                      dto: settings.arguments as dynamic,
                    ),
                settings: settings);
          case RouteHandler.ORDER:
            return CupertinoPageRoute<bool>(
                builder: (context) => OrderScreen(), settings: settings);
          case RouteHandler.CART_SCREEN:
            return CupertinoPageRoute<bool>(
                builder: (context) => CartScreen(), settings: settings);
          case RouteHandler.PREPARE_CO_ORDER:
            return CupertinoPageRoute<bool>(
                builder: (context) =>
                    PrepareCoOrderScreen(dto: settings.arguments as dynamic),
                settings: settings);
          case RouteHandler.STATION_PICKER_SCREEN:
            return CupertinoPageRoute<bool>(
                builder: (context) => StationPickerScreen(),
                settings: settings);
          case RouteHandler.PARTY_ORDER_SCREEN:
            return CupertinoPageRoute<bool>(
                builder: (context) => PartyOrderScreen(
                      dto: settings.arguments as dynamic,
                    ),
                settings: settings);
          case RouteHandler.CONFIRM_ORDER_SCREEN:
            return CupertinoPageRoute<bool>(
                builder: (context) => PartyConfirmScreen(), settings: settings);
          case RouteHandler.PRODUCT_FILTER_LIST:
            return CupertinoPageRoute<bool>(
                builder: (context) => ProductsFilterPage(
                      menu: settings.arguments as dynamic,
                    ),
                settings: settings);
          case RouteHandler.NAV:
            return CupertinoPageRoute(
                builder: (context) => RootScreen(
                      initScreenIndex: settings.arguments as int ?? 0,
                    ),
                settings: settings);
          case RouteHandler.HOME:
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
