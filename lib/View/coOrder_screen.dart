import 'dart:async';

import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/View/start_up.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/cache_image.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class PartyOrderScreen extends StatefulWidget {
  final PartyOrderDTO? dto;
  const PartyOrderScreen({super.key, this.dto});

  @override
  State<PartyOrderScreen> createState() => _PartyOrderScreenState();
}

class _PartyOrderScreenState extends State<PartyOrderScreen> {
  PartyOrderViewModel? _partyViewModel = Get.find<PartyOrderViewModel>();
  Timer? _timer;
  int index = 0;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2),
        (timer) => _partyViewModel!.getPartyOrder());
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: Get.find<PartyOrderViewModel>(),
      child: Scaffold(
        backgroundColor: FineTheme.palettes.neutral200,
        bottomNavigationBar: bottomBar(),
        appBar: DefaultAppBar(
          title: "Đơn nhóm của bạn",
          backButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  _stopTimer();
                  Get.offAllNamed(RoutHandler.NAV);
                },
                child: Icon(Icons.arrow_back_ios,
                    size: 20, color: FineTheme.palettes.primary100),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            children: [
              SizedBox(
                  height: 8,
                  child: Container(
                    color: FineTheme.palettes.neutral200,
                  )),
              Container(
                color: Colors.white,
                child: ScopedModelDescendant<PartyOrderViewModel>(
                  builder: (context, child, model) {
                    List<Widget> card = [];
                    List<Party> list = model.partyOrderDTO!.partyOrder!;
                    for (var item in list) {
                      card.add(_buildPartyList(item));
                    }
                    for (int i = 0; i < list.length; i++) {
                      if (i % 2 != 0) {
                        card.insert(
                          i,
                          Container(
                            height: 24,
                            color: FineTheme.palettes.neutral200,
                          ),
                        );
                      }
                    }
                    if (list == null || list.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Không có người tham gia"),
                      );
                    }
                    return Container(
                      child: Column(
                        children: card,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar: bottomBar(),
      ),
    );
  }

  Widget _buildPartyList(Party party) {
    final listProduct = party.orderDetails;
    AccountViewModel acc = Get.find<AccountViewModel>();
    bool hasProduct = false;
    if (party.orderDetails == null || party.orderDetails!.isEmpty) {
      hasProduct = true;
    }
    bool isYou = false;
    if (acc.currentUser!.id == party.customer!.id) {
      isYou = true;
    }
    bool isAdmin = false;
    if (party.customer!.isAdmin == true) {
      isAdmin = true;
    }
    bool isConfirm = false;
    if (party.customer!.isConfirm == true) {
      isConfirm = true;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: SlideFadeTransition(
        offset: -1,
        delayStart: const Duration(milliseconds: 20),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  party.customer!.name!,
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      fontStyle: FontStyle.normal,
                      color: FineTheme.palettes.neutral600),
                ),
                const SizedBox(width: 8),
                Text(
                  isAdmin
                      ? '(Trưởng nhóm)'
                      : isYou
                          ? 'Bạn'
                          : '',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      fontStyle: FontStyle.normal,
                      color: FineTheme.palettes.neutral500),
                ),
                const SizedBox(width: 8),
                isConfirm
                    ? Container(
                        height: 20,
                        width: 90,
                        decoration: BoxDecoration(
                            color: FineTheme.palettes.primary100,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: Center(
                          child: Text(
                            'Đã xác nhận',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                fontStyle: FontStyle.normal,
                                color: FineTheme.palettes.shades100),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 8),
            MySeparator(color: FineTheme.palettes.neutral500),
            const SizedBox(height: 8),
            hasProduct
                ? Text(
                    'Đang chọn món... ',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        fontStyle: FontStyle.normal,
                        color: FineTheme.palettes.neutral700),
                  )
                : Column(
                    children: listProduct!.map((e) => productCard(e)).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget productCard(OrderDetails orderDetails) {
    List<Widget> list = [];
    double price = 0;
    int startProduct = 0;
    // if (item.master.type == ProductType.MASTER_PRODUCT) {
    //   price = item.products[0].price * item.quantity;
    //   startProduct = 1;
    // } else {
    //   price = item.master.price * item.quantity;
    //   startProduct = 0;
    // }
    if (orderDetails.orderId != null) {
      price = orderDetails.unitPrice! * orderDetails.quantity;
      startProduct = 1;
    }
    List<OrderDetails>? orderDetailList = [];
    orderDetailList.add(orderDetails);
    for (int i = startProduct; i < orderDetailList.length; i++) {
      list.add(
        const SizedBox(
          height: 4,
        ),
      );
      list.add(Text(orderDetailList[i].productName!,
          style: FineTheme.typograhpy.overline));
      price += orderDetailList[i].unitPrice! * orderDetails.quantity;
    }
    // item.description = "Test đơn hàng";

    // if (item.description != null && item.description.isNotEmpty) {
    //   list.add(SizedBox(
    //     height: 4,
    //   ));
    //   list.add(Text(
    //     item.description,
    //   ));
    // }

    // bool isGift = false;
    // if (item.master.type == ProductType.GIFT_PRODUCT) {
    //   isGift = true;
    // }

    return Container(
      color: FineTheme.palettes.shades100,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: InkWell(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          width: 31,
                                          height: 28,
                                          child: CacheImage(
                                              imageUrl: defaultImage),
                                        ),
                                      ),
                                    ),
                                    Text(orderDetails.productName!,
                                        style: FineTheme.typograhpy.subtitle2),
                                  ],
                                ),
                                Row(children: [
                                  RichText(
                                    text: TextSpan(
                                      text: formatPrice(price),
                                      style: FineTheme.typograhpy.subtitle2
                                          .copyWith(color: Colors.black),
                                      // children: [
                                      //   WidgetSpan(
                                      //     alignment:
                                      //         PlaceholderAlignment.bottom,
                                      //     child: Container(),
                                      //   )
                                      // ],
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...list,
                      const SizedBox(width: 8),
                      selectQuantity(orderDetails),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget selectQuantity(
    OrderDetails item,
  ) {
    Color minusColor = FineTheme.palettes.neutral500;
    if (item.quantity >= 1) {
      minusColor = FineTheme.palettes.primary300;
    }
    Color plusColor = FineTheme.palettes.primary300;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: IconButton(
                padding: const EdgeInsets.all(0.0),
                icon: Icon(
                  AntDesign.minuscircleo,
                  size: 16,
                  color: minusColor,
                ),
                onPressed: () async {
                  if (item.quantity >= 1) {
                    if (item.quantity == 1) {
                      await _partyViewModel?.deleteItem(item);
                    } else {
                      item.quantity--;
                      await _partyViewModel?.updateQuantity(item);
                    }
                  }
                },
              ),
            ),
            Container(
              width: 30,
              child: Text(
                item.quantity.toString(),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 18,
              width: 18,
              child: IconButton(
                padding: const EdgeInsets.all(0.0),
                icon: Icon(
                  AntDesign.pluscircleo,
                  size: 16,
                  color: plusColor,
                ),
                onPressed: () async {
                  item.quantity++;
                  await _partyViewModel?.updateQuantity(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomBar() {
    return ScopedModel(
        model: Get.find<PartyOrderViewModel>(),
        child: ScopedModelDescendant<PartyOrderViewModel>(
          builder: (context, child, model) {
            int customer = model.partyOrderDTO!.partyOrder!.length;
            final userConfirm = model.partyOrderDTO!.partyOrder!
                .where((element) => element.customer!.isConfirm == true)
                .toList();
            bool? isAllConfirm = false;
            if (userConfirm.length == customer) {
              isAllConfirm = true;
            }
            return Container(
              height: 150,
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 22, bottom: 32),
              color: FineTheme.palettes.shades100,
              child: Column(
                children: [
                  Text(
                      '${userConfirm.length}/${customer} thành viên đã xác nhận'),
                  const SizedBox(height: 10),
                  Container(
                    height: 52,
                    width: Get.width,
                    decoration: BoxDecoration(
                        color: FineTheme.palettes.primary100,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(5),
                        )),
                    child: InkWell(
                      onTap: () async {
                        if (!isAllConfirm!) {
                          await model.confirmationParty();
                          _stopTimer();
                          Get.offAllNamed(RoutHandler.CONFIRM_ORDER_SCREEN);
                        } else {
                          await model.preCoOrder();
                          _stopTimer();
                          Get.offAllNamed(RoutHandler.ORDER);
                        }
                      },
                      child: Center(
                          child: Text(
                        isAllConfirm ? 'Thanh toán' : 'Xác nhận món',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            color: FineTheme.palettes.shades100),
                      )),
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }
}
