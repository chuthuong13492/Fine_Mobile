import 'dart:async';
import 'dart:ui';

import 'package:fine/Accessories/cart_button.dart';
import 'package:fine/View/cart_screen.dart';
import 'package:fine/View/qrcode_screen.dart';
import 'package:fine/View/box_screen.dart';
import 'package:fine/View/Home/home.dart';
import 'package:fine/View/order_history.dart';
import 'package:fine/View/profile.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/ViewModel/cart_viewModel.dart';
import 'package:fine/ViewModel/orderHistory_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/theme/color.dart';
import 'package:fine/widgets/bottom_bar_item.dart';
import 'package:fine/widgets/cruved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../Accessories/dialog.dart';
import '../Model/DTO/index.dart';
import '../Utils/shared_pref.dart';
import '../ViewModel/partyOrder_viewModel.dart';

class RootScreen extends StatefulWidget {
  final int initScreenIndex;
  const RootScreen({Key? key, required this.initScreenIndex}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with TickerProviderStateMixin {
  Future listenFireBaseMessages() async {
    FirebaseMessaging.onMessage.listen((event) async {
      hideSnackbar();

      RemoteNotification notification = event.notification!;

      switch (event.data["type"]) {
        case 'ForInvitation':
          PartyOrderViewModel party = Get.find<PartyOrderViewModel>();
          int option = await showOptionDialog('${notification.body}');
          if (option == 1) {
            await deletePartyCode();
            String code = event.data['key'];
            await party.joinPartyOrder(code: code);
            hideDialog();
          }
          break;
        case 'ForPopup':
          await showStatusDialog("assets/images/icon-success.png",
              notification.title!, notification.body!);
          break;
        case 'ForFinishOrder':
          OrderDTO? dto;
          if (event.data["orderId"] != null) {
            await Get.find<OrderHistoryViewModel>()
                .getOrderByOrderId(id: event.data["orderId"]);
            if (Get.find<OrderHistoryViewModel>().orderDTO != null) {
              if (Get.find<OrderHistoryViewModel>().orderDTO!.id ==
                  event.data["orderId"]) {
                dto = Get.find<OrderHistoryViewModel>().orderDTO!;
              }
            }
          }
          if (Get.currentRoute == "/qrcode_screen") {
            if (dto != null) {
              final otherAmounts =
                  dto.otherAmounts!.firstWhere((element) => element.type == 1);
              await showOrderDetailDialog(dto.itemQuantity!, dto.totalAmount!,
                  otherAmounts.amount!, dto.finalAmount!);
            }
            Get.back();
          } else {
            if (dto != null) {
              final otherAmounts =
                  dto.otherAmounts!.firstWhere((element) => element.type == 1);
              await showOrderDetailDialog(dto.itemQuantity!, dto.totalAmount!,
                  otherAmounts.amount!, dto.finalAmount!);
            }
          }

          break;
        case 'ForRefund':
          if (event.data["orderId"] != null) {
            await Get.find<OrderHistoryViewModel>()
                .getOrderByOrderId(id: event.data["orderId"]);
          }

          await showStatusDialog("assets/images/logo2.png", notification.title!,
              notification.body!);
          break;
        case 'ForUsual':
          await showFlash(
            context: context,
            duration: const Duration(seconds: 5),
            builder: (context, controller) {
              return FlashBar(
                controller: controller,
                position: FlashPosition.bottom,
                margin: const EdgeInsets.all(8),
                shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                dismissDirections: const [
                  FlashDismissDirection.startToEnd,
                  FlashDismissDirection.endToStart,
                  FlashDismissDirection.vertical,
                ],
                forwardAnimationCurve: Curves.easeInOut,
                reverseAnimationCurve: Curves.slowMiddle,
                backgroundColor: FineTheme.palettes.primary50,
                icon: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: FineTheme.palettes.shades100,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                  ),
                ),
                content: Text(
                  notification.body!,
                  style: FineTheme.typograhpy.subtitle1
                      .copyWith(color: FineTheme.palettes.primary100),
                ),
                title: Text(
                  notification.title!,
                  style: FineTheme.typograhpy.h2
                      .copyWith(color: FineTheme.palettes.primary100),
                ),
              );
            },
          );
          break;
        default:
          await showStatusDialog("assets/images/logo2.png", notification.title!,
              notification.body!);
          break;
      }
      print(event.data);
    });
  }

  RootViewModel? _rootViewModel;
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
    const CartScreen(),
    const ProfileScreen()
  ];
  final items = <Widget>[
    SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: SvgPicture.asset(
          "assets/icons/Home.svg",
          width: 32,
          height: 32,
        ),
      ),
    ),
    SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: SvgPicture.asset(
          "assets/icons/Order.svg",
          width: 32,
          height: 32,
        ),
      ),
    ),
    Stack(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Image.asset(
              "assets/icons/shopping-bag-02.png",
              width: 32,
              height: 32,
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: Get.find<CartViewModel>().notifier,
          builder: (context, value, child) {
            bool check = false;
            if (value as int > 99) {
              check = true;
            } else {
              check = false;
            }
            if (value != 0) {
              return Positioned(
                top: 2,
                left: check ? 20 : 25,
                child: AnimatedContainer(
                  duration: const Duration(microseconds: 300),
                  width: check ? 20 : 15,
                  height: 15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.red,
                    //border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: Text(
                      check ? "99" : value.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight:
                              check ? FontWeight.w500 : FontWeight.w600),
                    ),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    ),
    SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: SvgPicture.asset(
          "assets/icons/Profile.svg",
          width: 32,
          height: 32,
        ),
      ),
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
    // _rootViewModel = Get.find<RootViewModel>();
    // Timer.periodic(const Duration(milliseconds: 500), (_) {
    //   _rootViewModel!.liveLocation();
    // });
    listenFireBaseMessages();
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
        floatingActionButton: CartButton(),
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
