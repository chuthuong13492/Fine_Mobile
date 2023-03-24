import 'dart:ui';

import 'package:fine/Accessories/cart_button.dart';
import 'package:fine/View/home.dart';
import 'package:fine/View/order_history.dart';
import 'package:fine/View/profile.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/theme/color.dart';
import 'package:fine/widgets/bottom_bar_item.dart';
import 'package:flutter/material.dart';

class RootScreen extends StatefulWidget {
  final int initScreenIndex;
  const RootScreen({Key? key, required this.initScreenIndex}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with TickerProviderStateMixin {
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

  Widget MainScreen() {
    return Scaffold(
        floatingActionButton: CartButton(),
        backgroundColor: FineTheme.palettes.neutral200,
        bottomNavigationBar: getBottomBar(),
        body: getBarPage());
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
