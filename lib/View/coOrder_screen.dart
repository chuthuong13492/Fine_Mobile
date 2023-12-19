import 'dart:async';

import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/View/start_up.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/CountdownTimer/index.dart';
import 'package:fine/widgets/cache_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../ViewModel/cart_viewModel.dart';

class PartyOrderScreen extends StatefulWidget {
  // final PartyOrderDTO? dto;
  const PartyOrderScreen({super.key});

  @override
  State<PartyOrderScreen> createState() => _PartyOrderScreenState();
}

class _PartyOrderScreenState extends State<PartyOrderScreen> {
  CountdownTimerController? controller;
  PartyOrderViewModel? _partyViewModel = Get.find<PartyOrderViewModel>();
  Timer? _timer;
  int index = 0;
  bool? checkAdmin;
  bool? isLoading = true;

  @override
  void initState() {
    super.initState();
    // _timer = Timer.periodic(const Duration(seconds: 1),
    //     (timer) => _partyViewModel!.getPartyOrder());

    _coOrder();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void _coOrder() async {
    // await _partyViewModel!.getPartyOrder();
    setState(() {
      isLoading = false;
      checkAdmin = _partyViewModel?.isAdmin;
    });
    // await _partyViewModel?.confirmationTimeout();
  }

  @override
  Widget build(BuildContext context) {
    // List<Party> listParty = _partyViewModel!.partyOrderDTO!.partyOrder!;
    AccountViewModel acc = Get.find<AccountViewModel>();

    // for (var item in user) {
    //   if (item.customer!.isAdmin == true) {
    //     isAdmin = true;
    //   }
    // }
    return ScopedModel(
      model: Get.find<PartyOrderViewModel>(),
      child: Scaffold(
        // floatingActionButton: const CartParty(),
        backgroundColor: FineTheme.palettes.neutral200,
        bottomNavigationBar: bottomBar(),
        appBar: DefaultAppBar(
          title: "Đơn nhóm",
          backButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Material(
              color: Colors.white,
              child: InkWell(
                onTap: () async {
                  // await Get.find<RootViewModel>().checkHasParty();
                  // await _partyViewModel?.getCoOrderStatus();
                  Get.find<CartViewModel>().getCurrentCart();
                  Get.back();
                },
                child: Icon(Icons.arrow_back_ios,
                    size: 20, color: FineTheme.palettes.primary100),
              ),
            ),
          ),
          actionButton: [
            ScopedModelDescendant<PartyOrderViewModel>(
              builder: (context, child, model) {
                return model.isAdmin == true
                    ? Container(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                            onPressed: () async {
                              await showInviteDialog('text');
                            },
                            icon: Icon(
                              Icons.group_add_rounded,
                              color: FineTheme.palettes.primary100,
                              size: 30,
                            )),
                      )
                    : const SizedBox.shrink();
              },
            )
          ],
        ),
        body: SafeArea(
          child: ScopedModelDescendant<PartyOrderViewModel>(
            builder: (context, child, model) {
              var timeslot =
                  Get.find<RootViewModel>().selectedTimeSlot?.closeTime;
              final currentDate = DateTime.now();
              String currentTimeSlot = timeslot!;
              var beanTime = DateTime(
                currentDate.year,
                currentDate.month,
                currentDate.day,
                double.parse(currentTimeSlot.split(':')[0]).round(),
                double.parse(currentTimeSlot.split(':')[1]).round(),
              );

              int differentTime =
                  beanTime.difference(currentDate).inMilliseconds;

              List<Widget> card = [];
              List<Party>? list;

              if (model.partyOrderDTO != null) {
                list = model.partyOrderDTO!.partyOrder!;
              }
              List<Party>? user;
              if (list != null) {
                user = list
                    .where((element) =>
                        element.customer!.id == acc.currentUser!.id)
                    .toList();
              }

              if (user != null) {
                for (var item in user) {
                  if (item.customer!.isAdmin == true) {
                    list;
                    for (var item in list!) {
                      card.add(_buildPartyList(item));
                    }
                    // for (int i = 0; i < list.length; i++) {
                    //   if (i % 2 != 0) {
                    //     card.insert(
                    //       i,
                    //       Container(
                    //         height: 24,
                    //         color: FineTheme.palettes.neutral200,
                    //       ),
                    //     );
                    //   }
                    // }
                    // checkAdmin = true;
                  } else {
                    user;
                    for (var item in user) {
                      card.add(_buildPartyList(item));
                    }
                    // checkAdmin = false;
                  }
                }
              }
              if (model.status == ViewStatus.Loading) {
                return const Center(
                  child: LoadingFine(),
                );
              } else if (model.status == ViewStatus.Empty) {
                return const SizedBox.shrink();
              } else {
                return ListView(
                  children: [
                    Container(
                      color: FineTheme.palettes.primary300,
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Kết thúc đặt đơn:   ",
                            style: FineTheme.typograhpy.subtitle2
                                .copyWith(color: FineTheme.palettes.shades100),
                          ),
                          Row(
                            children: [
                              buildTimeBlock("${beanTime.hour}"),
                              const SizedBox(width: 4),
                              Text(
                                ":",
                                style: FineTheme.typograhpy.h2.copyWith(
                                    color: FineTheme.palettes.shades100),
                              ),
                              const SizedBox(width: 4),
                              buildTimeBlock("${beanTime.minute}"),
                              // const SizedBox(width: 2),
                              // Text(
                              //   ":",
                              //   style: FineTheme.typograhpy.h2.copyWith(
                              //       color: FineTheme.palettes.shades100),
                              // ),
                              // const SizedBox(width: 2),
                              // buildTimeBlock(
                              //     "${differentTime.s}"),
                            ],
                          ),
                        ],
                      ),
                      // child: CountdownTimer(
                      //   controller: controller,
                      //   endTime: DateTime.now().millisecondsSinceEpoch +
                      //       differentTime,
                      //   onEnd: () async {
                      //     Get.find<RootViewModel>().isOnClick = true;
                      //     await showStatusDialog(
                      //       "assets/images/error.png",
                      //       "Khung giờ đã kết thúc",
                      //       "Đã hết giờ chốt đơn cho khung giờ hiện tại. \n Hẹn gặp bạn ở khung giờ khác nhé 😢.",
                      //     );
                      //     await Get.find<RootViewModel>().getListTimeSlot();
                      //     Get.back();
                      //   },
                      //   widgetBuilder: (context, time) {
                      //     return Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       children: [
                      //         Text(
                      //           "Kết thúc đặt đơn: ",
                      //           style: FineTheme.typograhpy.subtitle2.copyWith(
                      //               color: FineTheme.palettes.shades100),
                      //         ),
                      //         Row(
                      //           children: [
                      //             buildTimeBlock(
                      //                 "${(time?.hours ?? 0) < 10 ? "0" : ""}${time?.hours ?? "0"}"),
                      //             const SizedBox(width: 2),
                      //             Text(
                      //               ":",
                      //               style: FineTheme.typograhpy.h2.copyWith(
                      //                   color: FineTheme.palettes.shades100),
                      //             ),
                      //             const SizedBox(width: 2),
                      //             buildTimeBlock(
                      //                 "${(time?.min ?? 0) < 10 ? "0" : ""}${time?.min ?? "0"}"),
                      //             const SizedBox(width: 2),
                      //             Text(
                      //               ":",
                      //               style: FineTheme.typograhpy.h2.copyWith(
                      //                   color: FineTheme.palettes.shades100),
                      //             ),
                      //             const SizedBox(width: 2),
                      //             buildTimeBlock(
                      //                 "${(time?.sec ?? 0) < 10 ? "0" : ""}${time?.sec ?? "0"}"),
                      //           ],
                      //         ),
                      //       ],
                      //     );
                      //   },
                      // ),
                    ),
                    // SizedBox(
                    //     height: 8,
                    //     child: Container(
                    //       color: FineTheme.palettes.neutral200,
                    //     )),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mã:',
                          style: FineTheme.typograhpy.subtitle2
                              .copyWith(color: FineTheme.palettes.neutral400),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          model.partyCode!,
                          style: FineTheme.typograhpy.subtitle2
                              .copyWith(color: FineTheme.palettes.shades200),
                        ),
                        // const SizedBox(width: 8),
                        IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                  new ClipboardData(text: model.partyCode!));
                            },
                            icon: Icon(
                              Icons.copy,
                              size: 20,
                              color: FineTheme.palettes.neutral500,
                            ))
                      ],
                    ),

                    Container(
                      color: FineTheme.palettes.shades100,
                      child: Column(
                        children: card,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
        // bottomNavigationBar: bottomBar(),
      ),
    );
  }

  Widget buildTimeBlock(String text) {
    return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: FineTheme.palettes.primary300),
            color: FineTheme.palettes.shades100),
        padding: const EdgeInsets.all(4),
        child: Center(
          child: Text(
            text,
            style: FineTheme.typograhpy.subtitle2
                .copyWith(color: FineTheme.palettes.primary300),
          ),
        ));
  }

  Widget _buildPartyList(Party party) {
    final listProduct = party.orderDetails;
    listProduct?.sort((a, b) => a.productName!.compareTo(b.productName!));
    AccountViewModel acc = Get.find<AccountViewModel>();
    bool hasProduct = true;
    // final order = Get.find<OrderViewModel>();
    // if(order.currentCart == null){
    //   hasProduct = true;
    // }
    if (party.orderDetails == null || party.orderDetails!.isEmpty) {
      hasProduct = false;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isConfirm == false
            ? ValueListenableBuilder<int>(
                valueListenable: _partyViewModel!.notifierMemberTimeout,
                builder: (context, value, child) {
                  Duration duration = Duration(seconds: value);
                  int minutes = duration.inMinutes;
                  int remainingSeconds = duration.inSeconds % 60;

                  String minutesStr = minutes.toString().padLeft(2, '0');
                  String secondsStr =
                      remainingSeconds.toString().padLeft(2, '0');

                  if (value == 0) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    width: Get.width,
                    color: FineTheme.palettes.primary100,
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: FineTheme.palettes.shades100),
                                padding: const EdgeInsets.all(4),
                                child: Center(
                                  child: Text(
                                    minutesStr,
                                    style: FineTheme.typograhpy.subtitle1
                                        .copyWith(
                                            color:
                                                FineTheme.palettes.primary100),
                                  ),
                                )),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              ":",
                              style: FineTheme.typograhpy.h2
                                  .copyWith(color: Colors.white),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: FineTheme.palettes.shades100),
                                padding: const EdgeInsets.all(4),
                                child: Center(
                                  child: Text(
                                    secondsStr,
                                    style: FineTheme.typograhpy.subtitle1
                                        .copyWith(
                                            color:
                                                FineTheme.palettes.primary100),
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tíc tắc, Chốt đơn ngay nàoo!!",
                          style: FineTheme.typograhpy.subtitle1
                              .copyWith(color: Colors.white),
                        )
                      ],
                    ),
                  );
                },
              )
            : const SizedBox.shrink(),
        Container(
          width: Get.width,
          height: 16,
          color: FineTheme.palettes.neutral200,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: SlideFadeTransition(
            offset: -1,
            delayStart: const Duration(milliseconds: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 140,
                      child: Text(
                        party.customer!.name!,
                        style: isAdmin
                            ? TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                fontStyle: FontStyle.normal,
                                color: FineTheme.palettes.primary100)
                            : TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                fontStyle: FontStyle.normal,
                                color: FineTheme.palettes.neutral600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAdmin ? '(Trưởng nhóm)' : '',
                      style: isAdmin
                          ? TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              fontStyle: FontStyle.normal,
                              color: FineTheme.palettes.primary100)
                          : TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              fontStyle: FontStyle.normal,
                              color: FineTheme.palettes.neutral500),
                    ),
                    const SizedBox(width: 8),
                    !isAdmin
                        ? isConfirm
                            ? Container(
                                height: 20,
                                width: 90,
                                decoration: BoxDecoration(
                                    color: FineTheme.palettes.primary100,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
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
                            : const SizedBox.shrink()
                        : const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 8),
                MySeparator(color: FineTheme.palettes.neutral500),
                const SizedBox(height: 8),
                !hasProduct
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
                        children: [
                          Column(
                            children: listProduct!
                                .map((e) => productCard(e, isYou))
                                .toList(),
                          ),
                          const SizedBox(height: 8),
                          MySeparator(color: FineTheme.palettes.neutral500),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Text(
                                  'Tạm tính',
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      fontStyle: FontStyle.normal,
                                      color: FineTheme.palettes.shades200),
                                ),
                              ),
                              Text(
                                formatPrice(party.totalAmount!),
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    fontStyle: FontStyle.normal,
                                    color: FineTheme.palettes.primary400),
                              ),
                            ],
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget productCard(OrderDetails orderDetails, bool? isYou) {
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
      list.add(Text(formatPrice(orderDetailList[i].unitPrice!),
          style: FineTheme.typograhpy.caption1
              .copyWith(color: FineTheme.palettes.primary100)));
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: 31,
                        height: 28,
                        child: CacheImage(
                            imageUrl: orderDetails.imageUrl ?? defaultImage),
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
                    text: formatPrice(orderDetails.totalAmount!),
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: FineTheme.palettes.primary400),
                  ),
                ),
              ]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...list,
              const SizedBox(width: 8),
              selectQuantity(orderDetails, isYou!),
            ],
          )
        ],
      ),
    );
  }

  Widget selectQuantity(OrderDetails item, bool isYou) {
    // Color minusColor = FineTheme.palettes.neutral500;
    // if (item.quantity >= 1) {
    //   minusColor = FineTheme.palettes.primary300;
    // }
    // Color plusColor = FineTheme.palettes.primary300;
    // if (!isYou) {
    //   minusColor = FineTheme.palettes.neutral700;
    //   plusColor = FineTheme.palettes.neutral700;
    // }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(item.quantity.toString(), style: FineTheme.typograhpy.subtitle2),
          // const SizedBox(
          //   width: 2,
          // ),
          Text("x", style: FineTheme.typograhpy.subtitle2),
        ],
      ),
    );
  }

  Widget bottomBar() {
    return ScopedModel(
        model: Get.find<PartyOrderViewModel>(),
        child: ScopedModelDescendant<PartyOrderViewModel>(
          builder: (context, child, model) {
            final acc = Get.find<AccountViewModel>();
            int? customer;
            List<Party>? userConfirm;
            List<Party>? listUser;

            if (model.partyOrderDTO != null) {
              customer = model.partyOrderDTO!.partyOrder!.length;
              userConfirm = model.partyOrderDTO!.partyOrder!
                  .where((element) => element.customer!.isConfirm == true)
                  .toList();
              listUser = model.partyOrderDTO!.partyOrder!
                  .where(
                      (element) => element.customer!.id == acc.currentUser!.id)
                  .toList();
            }

            bool? isAllConfirm = false;
            if (userConfirm != null) {
              if (userConfirm.length == customer) {
                isAllConfirm = true;
              }
            }

            bool? isAdmin = false;
            bool? isUserConfirm = false;
            if (listUser != null) {
              for (var item in listUser) {
                if (item.customer!.isConfirm == false) {
                  isUserConfirm = false;
                } else {
                  isUserConfirm = true;
                }
                if (item.customer!.isAdmin == true) {
                  isAdmin = true;
                }
              }
            }

            return Container(
              height: 160,
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 5, bottom: 32),
              color: FineTheme.palettes.shades100,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {
                          if (isAdmin == true) {
                            await _partyViewModel?.getCustomerInParty();
                          } else {
                            if (model.isFinished == false) {
                              await _partyViewModel!.cancelCoOrder(false);
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Icon(
                            Icons.logout_outlined,
                            color: model.isFinished == false
                                ? Colors.red
                                : Colors.white,
                          ),
                        ),
                      ),
                      checkAdmin == true
                          ? Text(
                              '${userConfirm?.length}/${customer} thành viên đã xác nhận')
                          : isUserConfirm == false
                              ? Text("Chưa xác nhận")
                              : Text(
                                  "Đã chốt đơn",
                                  style: FineTheme.typograhpy.body1,
                                ),
                      InkWell(
                        onTap: isAdmin == true
                            ? () async {
                                await _partyViewModel?.getCustomerInParty(
                                    isDelete: true);
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Icon(
                            Icons.group_remove,
                            color: isAdmin == true
                                ? FineTheme.palettes.primary300
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
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
                        if (isAdmin == true) {
                          if (isAllConfirm == true) {
                            final cart = await getCart();
                            if (cart != null) {
                              await model.preCoOrder();
                              // _stopTimer();
                            } else {
                              showStatusDialog(
                                  "assets/images/error.png",
                                  "Giỏ hàng đang trống kìaa",
                                  "Bạn chọn thêm đồ ăn vào giỏ hàng nhe 😃.");
                            }
                          }
                        } else {
                          if (!isUserConfirm!) {
                            await model.confirmationParty();
                            // _stopTimer();
                          }
                        }
                      },
                      child: Center(
                          child: Text(
                        isAdmin == true
                            ? isAllConfirm
                                ? 'Thanh toán'
                                : 'Chưa đủ người xác nhận'
                            : isUserConfirm! == false
                                ? 'Chốt đơn'
                                : model.isFinished == false
                                    ? 'Đã xác nhận'
                                    : "Đơn hàng đã thanh toán",
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            color: FineTheme.palettes.shades100),
                      )),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  // Expanded(
                  //   child: InkWell(
                  //     onTap: () async {
                  //       if (isAdmin == true) {
                  //         await _partyViewModel?.getCustomerInParty();
                  //       } else {
                  //         await _partyViewModel!.cancelCoOrder();
                  //       }

                  //       // await _partyViewModel?.getCustomerInParty();
                  //     },
                  //     child: Center(
                  //       child: Container(
                  //         padding: const EdgeInsets.only(left: 16, right: 16),
                  //         child: Text(
                  //           isAdmin! ? 'Xóa đơn nhóm' : 'Thoát đơn nhóm',
                  //           style: FineTheme.typograhpy.subtitle1
                  //               .copyWith(color: Colors.red),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          },
        ));
  }
}
