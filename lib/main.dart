import 'dart:io';

import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/View/home.dart';
import 'package:fine/View/nav_screen.dart';
import 'package:fine/View/notFoundScreen.dart';
import 'package:fine/View/onboard.dart';
import 'package:fine/View/sign_in.dart';
import 'package:fine/View/start_up.dart';
import 'package:fine/ViewModel/startup_viewModel.dart';
import 'package:fine/setup.dart';
import 'package:fine/theme/color.dart';
import 'package:fine/Utils/pageNavigation.dart';
import 'package:fine/Utils/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  await setup();
  createRouteBindings();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fine_App',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RoutHandler.LOGIN:
            return ScaleRoute(page: SignIn());
          case RoutHandler.ONBOARD:
            return ScaleRoute(page: OnBoardScreen());
          // case RoutHandler.LOADING:
          //    return CupertinoPageRoute<bool>(
          //       builder: (context) => LoadingScreen(
          //             title: settings.arguments ?? "Đang xử lý...",
          //           ),
          //       settings: settings);
          case RoutHandler.NAV:
            return CupertinoPageRoute(
                builder: (context) => RootScreen(), settings: settings);
          case RoutHandler.HOME:
            return CupertinoPageRoute(
                builder: (context) => HomeScreen(), settings: settings);
          default:
            return CupertinoPageRoute(
                builder: (context) => NotFoundScreen(), settings: settings);
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StartUpView(),
    );
  }
}
