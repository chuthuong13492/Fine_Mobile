import 'dart:ui';

import 'package:fine/Accessories/cart_button.dart';
import 'package:fine/View/barcode_screen.dart';
import 'package:fine/View/box_screen.dart';
import 'package:fine/View/home.dart';
import 'package:fine/View/order_history.dart';
import 'package:fine/View/profile.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/theme/color.dart';
import 'package:fine/widgets/bottom_bar_item.dart';
import 'package:fine/widgets/cruved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RootScreen extends StatefulWidget {
  final int initScreenIndex;
  const RootScreen({Key? key, required this.initScreenIndex}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with TickerProviderStateMixin {
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  int activeTab = 0;
  List barItems = [
    {
      "icon": "assets/icons/Home.svg",
      "active_icon": "assets/icons/Home_fill.svg",
      "page": HomeScreen(),
    },
    {
      "icon": "assets/icons/Order.svg",
      "active_icon": "assets/icons/Order_fill.svg",
      "page": OrderHistoryScreen(),
    },
    {
      "icon": "assets/icons/Profile.svg",
      "active_icon": "assets/icons/Profile_fill.svg",
      "page": ProfileScreen(),
    },
  ];
  final screens = [
    const HomeScreen(),
    const OrderHistoryScreen(),
    const BarcodeScreen(),
    const BoxScreen(),
    const ProfileScreen()
  ];
  final items = <Widget>[
    SvgPicture.asset(
      "assets/icons/Home.svg",
      width: 32,
      height: 32,
    ),
    SvgPicture.asset(
      "assets/icons/Order.svg",
      width: 32,
      height: 32,
    ),
    SvgPicture.asset(
      "assets/icons/Scan.svg",
      width: 32,
      height: 32,
    ),
    SvgPicture.asset(
      "assets/icons/Box.svg",
      width: 32,
      height: 32,
    ),
    SvgPicture.asset(
      "assets/icons/Profile.svg",
      width: 32,
      height: 32,
    ),
  ];

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: ANIMATED_BODY_MS),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void initState() {
    super.initState();
    activeTab = widget.initScreenIndex;
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  animatedPage(page) {
    return FadeTransition(child: page, opacity: _animation);
  }

  void onPageChanged(int index) {
    _controller.reset();
    setState(() {
      activeTab = index;
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return MainScreen();
  }

  // ignore: non_constant_identifier_names
  Widget MainScreen() {
    return Scaffold(
        extendBody: true,
        // floatingActionButton: CartButton(),
        backgroundColor: FineTheme.palettes.neutral200,
        bottomNavigationBar: CurvedNavigationBar(
          color: FineTheme.palettes.primary100,
          backgroundColor: Colors.transparent,
          items: items,
          index: activeTab,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 500),
          onTap: (index) {
            setState(() {
              onPageChanged(index);
            });
          },
        ),
        // body: getBarPage());
        body: screens[activeTab]);
  }

  Widget getBarPage() {
    return IndexedStack(
        index: activeTab,
        children: List.generate(
            barItems.length, (index) => animatedPage(barItems[index]["page"])));
  }

  Widget getBottomBar() {
    return Container(
      height: 78,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              // FineTheme.palettes.primary200,
              // FineTheme.palettes.primary100,
              // FineTheme.palettes.secondary100
              FineTheme.palettes.neutral200,
              FineTheme.palettes.neutral200
            ]),
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 58,
              right: 58,
              bottom: 12,
            ),
            child: BackdropFilter(
                filter: ImageFilter.blur(
              sigmaX: 5,
              sigmaY: 5,
            )),
          ),
          Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24)),
                // gradient: LinearGradient(
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                //   colors: [
                //     Color(0xFF4ACADA).withOpacity(0.4),
                //     Color(0xFF4ACADA).withOpacity(0.1),
                //     Color(0xFF4ACADA).withOpacity(0.4),

                //     // Colors.white.withOpacity(0.8),
                //     // Colors.white.withOpacity(0.8),
                //   ],
                // ),
                boxShadow: [
                  BoxShadow(
                    color: FineTheme.palettes.primary200,
                    blurRadius: 8,
                    // spreadRadius: 1,
                    // offset: Offset(1, 1),
                  )
                ],
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                left: 58,
                right: 58,
                bottom: 12,
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                      barItems.length,
                      (index) => BottomBarItem(
                            barItems[index]["active_icon"],
                            barItems[index]["icon"],
                            isActive: activeTab == index,
                            activeColor: primary,
                            onTap: () {
                              onPageChanged(index);
                            },
                          ))))
        ],
      ),
    );
  }
}
