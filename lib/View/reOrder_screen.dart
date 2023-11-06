import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../Accessories/index.dart';
import '../Constant/route_constraint.dart';
import '../Constant/view_status.dart';
import '../Model/DTO/index.dart';
import '../Utils/constrant.dart';
import '../Utils/format_price.dart';
import '../ViewModel/order_viewModel.dart';
import '../ViewModel/root_viewModel.dart';
import '../theme/FineTheme/index.dart';
import '../widgets/cache_image.dart';

class ReOrderScreen extends StatefulWidget {
  const ReOrderScreen({super.key});

  @override
  State<ReOrderScreen> createState() => _ReOrderScreenState();
}

class _ReOrderScreenState extends State<ReOrderScreen> {
  OrderViewModel? _orderViewModel = Get.find<OrderViewModel>();
  bool onInit = true;
  AutoScrollController? controller;
  final scrollDirection = Axis.vertical;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FineTheme.palettes.shades100,
      appBar: DefaultAppBar(title: "Trang thanh toán"),
      bottomNavigationBar: bottomBar(),
      body: ListView(
        children: [
          ScopedModel(
            model: Get.find<OrderViewModel>(),
            child: ScopedModelDescendant<OrderViewModel>(
              builder: (context, child, model) {
                if (model.orderDTO == null) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                        child: Text(
                          "Có gì đó sai sai..\n Vui lòng thử lại.",
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Image.asset(
                          'assets/images/error.png',
                          fit: BoxFit.contain,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: model.notifierTimeRemaining,
                      builder: (context, value, child) {
                        return value != 0
                            ? Container(
                                padding: const EdgeInsets.all(8),
                                width: Get.width,
                                color: FineTheme.palettes.primary50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      value.toString(),
                                      style: FineTheme.typograhpy.subtitle1
                                          .copyWith(
                                              color: FineTheme
                                                  .palettes.primary300),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Thời gian hoàn thành đơn",
                                      style: FineTheme.typograhpy.subtitle1
                                          .copyWith(
                                        color: FineTheme.palettes.primary300,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : SizedBox(
                                height: 8,
                                child: Container(
                                  color: FineTheme.palettes.primary50,
                                ));
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: FineTheme.palettes.primary100,
                      child: Center(
                        child: Text(
                          "Đơn hàng này sẽ vừa với ${model.orderDTO?.boxQuantity} box !!!",
                          style: FineTheme.typograhpy.subtitle2
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          right: 16, left: 16, top: 10, bottom: 10),
                      child: layoutStaionPickup(model),
                    ),
                    SizedBox(
                        height: 8,
                        child: Container(
                          color: FineTheme.palettes.primary50,
                        )),
                    AutoScrollTag(
                      index: 1,
                      key: const ValueKey(1),
                      controller: controller!,
                      highlightColor: Colors.black.withOpacity(0.1),
                      child: timeRecieve(),
                    ),
                    SizedBox(
                        height: 8,
                        child: Container(
                          color: FineTheme.palettes.primary50,
                        )),
                    Container(
                        child: layoutOrder(model.orderDTO!.orderDetails!)),
                    SizedBox(
                        height: 8,
                        child: Container(
                          color: FineTheme.palettes.primary50,
                        )),
                    layoutSubtotal(model.orderDTO!.otherAmounts!),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget layoutSubtotal(List<OtherAmounts> otherAmounts) {
    double? shippingFee;
    for (var item in otherAmounts) {
      if (item.type == 1) {
        shippingFee = item.amount!;
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: FineTheme.palettes.shades100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Chi phí',
                    style: FineTheme.typograhpy.subtitle1,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 16, 0),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(color: FineTheme.palettes.primary100),
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tạm tính",
                          style: FineTheme.typograhpy.subtitle2,
                        ),
                        Text(
                            formatPrice(
                                _orderViewModel!.orderDTO!.totalAmount!),
                            style: FineTheme.typograhpy.subtitle2),
                      ],
                    ),
                  ),
                  MySeparator(
                    color: FineTheme.palettes.primary100,
                  ),
                  // ..._buildOtherAmount(_orderViewModel.orderAmount.others),
                  SlideFadeTransition(
                    offset: -1,
                    delayStart: const Duration(milliseconds: 20),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Discount"),
                              RichText(
                                text: TextSpan(
                                  text: '',
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          // "${_orderViewModel!.orderDTO!.discount ?? 0}",
                                          "0",
                                      // _orderViewModel?.codeParty != null
                                      //     ? "Hoàn tiền ship"
                                      //     : "0",
                                      style: FineTheme.typograhpy.subtitle2
                                          .copyWith(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Phí Ship"),
                              RichText(
                                text: TextSpan(
                                  text: '',
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: formatPrice(shippingFee!),
                                      style: FineTheme.typograhpy.subtitle2
                                          .copyWith(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tổng cộng",
                          style: FineTheme.typograhpy.subtitle2,
                        ),
                        Text(
                            _orderViewModel?.status == ViewStatus.Loading
                                ? "..."
                                : formatPrice(
                                    _orderViewModel!.orderDTO!.finalAmount!),
                            // : _orderViewModel.currentCart.payment ==
                            //         PaymentTypeEnum.Cash
                            //     ? formatPrice(
                            //         orderViewModel.orderAmount.finalAmount)
                            //     : "${formatBean(orderViewModel.orderAmount.finalAmount)} Bean",
                            style: FineTheme.typograhpy.subtitle1
                                .copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget layoutOrder(List<OrderDetails> list) {
    list.sort((a, b) => a.productName!.compareTo(b.productName!));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Đơn hàng của bạn",
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    fontStyle: FontStyle.normal,
                    color: FineTheme.palettes.neutral600),
              ),
            ],
          ),
        ),
        list.length != 0
            ? ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16, left: 16),
                    child: productCard(list[index]),
                  );
                },
                itemCount: list.length,
                separatorBuilder: (context, index) => Divider(
                  color: FineTheme.palettes.neutral700,
                ),
              )
            : Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16, left: 16, top: 8, bottom: 8),
                    child: Text("Giỏ hàng đang trống...",
                        style: FineTheme.typograhpy.subtitle2),
                  ),
                ],
              )
      ],
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
                                          height: 31,
                                          child: CacheImage(
                                              imageUrl: orderDetails.imageUrl ??
                                                  defaultImage),
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
                  color: FineTheme.palettes.neutral500,
                ),
                onPressed: () async {},
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
                  color: FineTheme.palettes.neutral500,
                ),
                onPressed: () async {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget timeRecieve() {
    String text = '';
    RootViewModel root = Get.find<RootViewModel>();
    TimeSlotDTO currentTimeSlot = root.selectedTimeSlot!;
    if (root.isNextDay == true) {
      text = 'Ngày Hôm Sau'.toUpperCase();
    } else {
      text = 'Ngày Hôm Nay'.toUpperCase();
    }
    // List<TimeSlots> listTimeSlotAvailable = root.listAvailableTimeSlots;
    // TimeSlots currentTime = listTimeSlotAvailable.firstWhere(
    //     (element) => element.id == orderViewModel.currentCart.timeSlotId);
    // String currentTimeSlot = currentTime.arriveTime.replaceAll(';', ' - ');
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: InkWell(
        onTap: () {
          // Utils.showSheet(
          //   context,
          //   child: buildCustomPicker(listTimeSlotAvailable),
          //   onClicked: () async {
          //     TimeSlots value = listTimeSlotAvailable[index];
          //     await Get.find<OrderViewModel>().changeTime(value);
          //     Get.back();
          //   },
          // ),
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                // width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // const Image(
                    //   image: AssetImage("assets/icons/clock_icon.png"),
                    //   width: 24,
                    //   height: 24,
                    // ),
                    Container(
                      // padding: const EdgeInsets.only(left: 5),
                      // width: 100,
                      child: Text(
                        "Giờ giao:",
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            fontStyle: FontStyle.normal,
                            color: FineTheme.palettes.neutral600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        currentTimeSlot.checkoutTime.toString(),
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            fontStyle: FontStyle.normal,
                            color: FineTheme.palettes.shades200),
                      ),
                    ),
                  ],
                ),
              ],
            )),
            Text(
              text,
              style: FineTheme.typograhpy.subtitle2
                  .copyWith(color: FineTheme.palettes.primary100),
            ),
          ],
        ),
      ),
    );
  }

  Widget layoutStaionPickup(OrderViewModel model) {
    String text = "Đợi tý đang load...";
    final status = model.status;
    if (model.orderDTO!.stationDTO != null) {
      text = model.orderDTO!.stationDTO!.name!;
    } else {
      text = 'Vui lòng chọn nơi nhận nha 😘';
    }

    if (status == ViewStatus.Error) {
      text = "Có lỗi xảy ra...";
    }
    return InkWell(
      onTap: () async {
        if (model.notifierTimeRemaining.value == 0) {
          await model.getListStation();
        }
        if (model.stationList != null) {
          Get.toNamed(RouteHandler.STATION_PICKER_SCREEN);
        }
      },
      child: Container(
        height: 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: SvgPicture.asset(
                "assets/icons/box_icon.svg",
                height: 30,
                width: 30,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 16),
                    width: Get.width,
                    child: Text(
                      'Giao đến',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          fontStyle: FontStyle.normal,
                          color: FineTheme.palettes.neutral600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 16),
                    width: Get.width,
                    child: Text(
                      text,
                      style: FineTheme.typograhpy.subtitle2,
                    ),
                  )
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Thay đổi',
                  style: FineTheme.typograhpy.caption1,
                ),
                const Icon(
                  Icons.keyboard_arrow_right,
                  size: 25,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomBar() {
    // var isCurrentTimeSlotAvailable =
    //     Get.find<RootViewModel>().isCurrentTimeSlotAvailable();
    return ScopedModel(
      model: Get.find<OrderViewModel>(),
      child: ScopedModelDescendant<OrderViewModel>(
        builder: (context, child, model) {
          final otherAmounts = model.orderDTO!.otherAmounts;
          double? shippingFee;
          for (var item in otherAmounts!) {
            if (item.type == 1) {
              shippingFee = item.amount!;
            }
          }
          return onInit
              ? const SizedBox.shrink()
              : Container(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(40),
                        topLeft: Radius.circular(40)),
                  ),
                  child: Container(
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {},
                                      child: Row(
                                        children: const [
                                          Text(
                                            'Thêm Voucher',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_up,
                                            size: 24,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 102,
                                    child: InkWell(
                                      onTap: () {},
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: const [
                                          Text(
                                            'Ví Fine',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_up,
                                            size: 24,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Phí giao hàng',
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.normal),
                                        ),
                                        Text(
                                          formatPrice(shippingFee!),
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 102,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '',
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.normal),
                                        ),
                                        Text(
                                          formatPrice(
                                              model.orderDTO!.finalAmount!),
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.normal),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Center(
                                child: InkWell(
                                  onTap: () async {
                                    await model.orderCart();
                                  },
                                  child: Container(
                                    width: 190,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        color: Color(0xFF238E9C)),
                                    child: const Center(
                                      child: Text("Đặt ngay",
                                          // isCurrentTimeSlotAvailable
                                          //     ? "Đặt ngay"
                                          //     : "Khung giờ đã kết thúc",
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.normal,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
