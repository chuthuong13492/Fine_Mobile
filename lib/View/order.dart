import 'dart:convert';

import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/View/start_up.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/cache_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../Accessories/index.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  OrderViewModel? _orderViewModel = Get.find<OrderViewModel>();
  AutoScrollController? controller;
  final scrollDirection = Axis.vertical;
  bool onInit = true;
  int index = 0;
  @override
  void initState() {
    super.initState();
    prepareCart();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    // int? timeSlotId = _orderViewModel?.currentCart!.timeSlotId;
    // index = Get.find<RootViewModel>()
    //     .listAvailableTimeSlots
    //     .indexWhere((element) => element.id == timeSlotId);
  }

  void prepareCart() async {
    await _orderViewModel?.prepareOrder();
    setState(() {
      onInit = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: Get.find<OrderViewModel>(),
      child: Scaffold(
          backgroundColor: FineTheme.palettes.shades100,
          appBar: DefaultAppBar(title: "Trang thanh toán"),
          bottomNavigationBar:
              bottomBar(_orderViewModel!.orderDTO!.otherAmounts!),
          body: onInit
              ? const Center(
                  child: Text('Không có giỏ hàng'),
                )
              : ScopedModelDescendant<OrderViewModel>(
                  builder: (context, child, model) {
                    if (model.currentCart != null) {
                      ViewStatus status = model.status;
                      switch (status) {
                        case ViewStatus.Error:
                          return ListView(
                            children: [
                              const Center(
                                child: Text(
                                  "Có gì đó sai sai..\n Vui lòng thử lại.",
                                ),
                              ),
                              const SizedBox(height: 8),
                              Image.asset(
                                'assets/images/error.png',
                                fit: BoxFit.contain,
                              ),
                            ],
                          );
                        case ViewStatus.Loading:

                        case ViewStatus.Completed:
                          return ListView(
                            children: [
                              SizedBox(
                                  height: 8,
                                  child: Container(
                                    color: FineTheme.palettes.neutral200,
                                  )),
                              // Hero(
                              //   tag: CART_TAG,
                              //   child: Container(
                              //       margin: const EdgeInsets.only(top: 8),
                              //       child: layoutAddress()),
                              // ),

                              Container(
                                padding: const EdgeInsets.only(
                                    right: 16, left: 16, top: 10, bottom: 10),
                                child: layoutStaionPickup(model),
                              ),
                              SizedBox(
                                  height: 8,
                                  child: Container(
                                    color: FineTheme.palettes.neutral200,
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
                                    color: FineTheme.palettes.neutral200,
                                  )),
                              Container(
                                padding: const EdgeInsets.only(
                                    right: 16, left: 16, top: 10, bottom: 10),
                                child: layoutPartyCode(),
                              ),
                              // Container(child: buildBeanReward()),
                              SizedBox(
                                  height: 8,
                                  child: Container(
                                    color: FineTheme.palettes.neutral200,
                                  )),
                              Container(
                                  child: layoutOrder(
                                      model.orderDTO!.orderDetails!)),
                              SizedBox(
                                  height: 8,
                                  child: Container(
                                    color: FineTheme.palettes.neutral200,
                                  )),
                              // UpSellCollection(),

                              layoutSubtotal(model.orderDTO!.otherAmounts!),
                            ],
                          );

                        default:
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: LoadingScreen(),
                          );
                      }
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                )),
    );
  }

  Widget layoutStaionPickup(OrderViewModel model) {
    String text = "Đợi tý đang load...";
    final status = model.status;
    // if (model.changeAddress) {
    //   text = "Đang thay đổi...";
    // } else if (location != null) {
    //   // text = destinationDTO.name + " - " + location.address;
    //   text = model.currentStore!.name!;
    // } else {
    //   text = "Chưa chọn";
    // }
    if (model.orderDTO!.stationDTO != null) {
      text = model.orderDTO!.stationDTO!.name!;
    } else {
      text = 'Vui lòng chọn nơi nhận nha 😘';
    }

    if (status == ViewStatus.Error) {
      text = "Có lỗi xảy ra...";
    }
    return InkWell(
      onTap: () {
        Get.toNamed(RouteHandler.STATION_PICKER_SCREEN);
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

  Widget layoutPartyCode() {
    PartyOrderViewModel model = Get.find<PartyOrderViewModel>();

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/Party.svg",
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Vào Party",
                    style: FineTheme.typograhpy.body1,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 30,
                    height: 16,
                    color: Colors.red,
                    child: Center(
                      child: Text(
                        "Mới",
                        style: FineTheme.typograhpy.caption1.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  // await deletePartyCode();
                  // model.partyCode = await getPartyCode();
                  showPartyDialog(model.partyCode);
                },
                child: Text(
                  "Tạo đơn",
                  style: FineTheme.typograhpy.body2
                      .copyWith(color: FineTheme.palettes.primary100),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget layoutAddress() {
    // LocationDTO location = store.locations.firstWhere(
    //   (element) => element.isSelected,
    //   orElse: () => null,
    // );
    // DestinationDTO destination;
    // if (location != null) {
    //   destination = location.destinations.firstWhere(
    //     (element) => element.isSelected,
    //     orElse: () => null,
    //   );
    // }
    RootViewModel root = Get.find<RootViewModel>();
    final destination = root.currentStore!.name;
    // String destination = "Trường Đại Học FPT - Khu công nghệ";
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: InkWell(
        onTap: () async {
          // await orderViewModel.changeLocationOfStore();
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Image(
                              image:
                                  AssetImage("assets/icons/location_icon.png"),
                              width: 24,
                              height: 24,
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 5),
                              width: 120,
                              child: Text(
                                "Địa điểm:",
                                style: FineTheme.typograhpy.subtitle2,
                              ),
                            ),
                            destination != null
                                ? Text(
                                    // destination.name,
                                    destination,
                                    style: FineTheme.typograhpy.caption1,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  )
                                : Text(
                                    "Chọn địa điểm giao hàng",
                                    style: FineTheme.typograhpy.caption1,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                          ],
                        ),
                        // Container(
                        //   padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [

                        //     ],
                        //   ),
                        // ),
                      ],
                    )),
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(0, 4, 16, 0),
                //   child: SvgPicture.asset(
                //     'assets/images/icons/Expand_right.svg',
                //   ),
                // )
              ],
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
                        "${currentTimeSlot.checkoutTime.toString()}",
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

  Widget layoutOrder(List<OrderDetails> list) {
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
        ListView.separated(
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
      ],
    );
  }

  // Widget layoutStore(OrderDetails inverseGeneralOrder) {
  //   // SupplierNoteDTO supplierNote = orderViewModel.currentCart.notes?.firstWhere(
  //   //   (element) => element.supplierId == list[0].master.supplierId,
  //   //   orElse: () => null,
  //   // );

  //   List<Widget> card = [];
  //   List<OrderDetails> orderDetailList = inverseGeneralOrder.orderDetails!;

  //   for (OrderDetails item in orderDetailList) {
  //     card.add(productCard(item));
  //   }

  //   for (int i = 0; i < orderDetailList.length; i++) {
  //     if (i % 2 != 0) {
  //       card.insert(
  //           i,
  //           Container(
  //               color: FineTheme.palettes.shades100,
  //               child: MySeparator(
  //                 color: FineTheme.palettes.neutral500,
  //               )));
  //     }
  //   }

  //   return Container(
  //     margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //           Padding(
  //             padding: const EdgeInsets.only(left: 0, right: 4),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   inverseGeneralOrder.storeName!,
  //                   style: FineTheme.typograhpy.subtitle2
  //                       .copyWith(color: FineTheme.palettes.primary300),
  //                 ),
  //                 Text(
  //                   // ignore: prefer_interpolation_to_compose_strings
  //                   inverseGeneralOrder.orderDetails!.fold<int>(0,
  //                           (previousValue, element) {
  //                         return previousValue + element.quantity;
  //                       }).toString() +
  //                       " món",
  //                   style: FineTheme.typograhpy.subtitle2
  //                       .copyWith(color: FineTheme.palettes.primary300),
  //                 )
  //               ],
  //             ),
  //           ),
  //           // Container(
  //           //     padding: const EdgeInsets.fromLTRB(0, 4, 8, 0),
  //           //     width: Get.width,
  //           //     child: Column(
  //           //       children: [
  //           //         Divider(
  //           //           height: 4,
  //           //           color: FineTheme.palettes.neutral600,
  //           //         ),
  //           //         Padding(
  //           //           padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
  //           //           child: Row(
  //           //             children: [
  //           //               const Icon(
  //           //                 Icons.note_alt_outlined,
  //           //                 color: Colors.black,
  //           //                 size: 18,
  //           //               ),
  //           //               Flexible(
  //           //                 child: Material(
  //           //                   color: Colors.transparent,
  //           //                   child: InkWell(
  //           //                       onTap: () {
  //           //                         orderViewModel.addSupplierNote(
  //           //                             list[0].master.supplierId);
  //           //                       },
  //           //                       child: Padding(
  //           //                         padding: EdgeInsets.only(left: 8, right: 8),
  //           //                         child: Text(
  //           //                             (supplierNote == null)
  //           //                                 ? "Ghi chú cho nhà hàng"
  //           //                                 : supplierNote.content,
  //           //                             overflow: TextOverflow.ellipsis,
  //           //                             style: BeanOiTheme.typography.caption1
  //           //                                 .copyWith(
  //           //                                     color: BeanOiTheme
  //           //                                         .palettes.neutral700)),
  //           //                       )),
  //           //                 ),
  //           //               ),
  //           //             ],
  //           //           ),
  //           //         ),
  //           //         Divider(
  //           //           height: 4,
  //           //           color: BeanOiTheme.palettes.neutral600,
  //           //         ),
  //           //       ],
  //           //     ))
  //         ]),
  //         ...card
  //       ],
  //     ),
  //   );
  // }

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
                      await _orderViewModel?.deleteItem(item);
                    } else {
                      item.quantity--;
                      await _orderViewModel?.updateQuantity(item);
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
                  await _orderViewModel?.updateQuantity(item);
                },
              ),
            ),
          ],
        ),
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
                  border: Border.all(color: FineTheme.palettes.primary300),
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
                    color: FineTheme.palettes.primary300,
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

  Widget bottomBar(List<OtherAmounts> otherAmounts) {
    double? shippingFee;
    for (var item in otherAmounts) {
      if (item.type == 1) {
        shippingFee = item.amount!;
      }
    }
    // var isCurrentTimeSlotAvailable =
    //     Get.find<RootViewModel>().isCurrentTimeSlotAvailable();
    return ScopedModel(
      model: Get.find<OrderViewModel>(),
      child: ScopedModelDescendant<OrderViewModel>(
        builder: (context, child, model) {
          return Container(
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
                  topRight: Radius.circular(40), topLeft: Radius.circular(40)),
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                  Text(
                                    'Tiền mặt',
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '',
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal),
                                ),
                                Text(
                                  _orderViewModel!.status == ViewStatus.Loading
                                      ? "..."
                                      : formatPrice(_orderViewModel!
                                          .orderDTO!.finalAmount!),
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
                            // if (isCurrentTimeSlotAvailable) {
                            //   await model.orderCart();
                            // } else {
                            //   await model.removeCart();
                            //   showStatusDialog(
                            //       "assets/images/error.png",
                            //       "Opps",
                            //       "Hiện tại khung giờ bạn chọn đã chốt đơn. Bạn vui lòng xem khung giờ khác nhé 😓 ");
                            //   Get.back();
                            // }
                          },
                          child: Container(
                            width: 190,
                            height: 40,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
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
                    ],
                  ),
                  // child: Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  //     Expanded(
                  //       flex: 4,
                  //       child: Padding(
                  //         padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
                  //         child: Container(
                  //           alignment: Alignment.centerLeft,
                  //           child: Column(
                  //             mainAxisAlignment: MainAxisAlignment.start,
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Text(
                  //                 "Tổng cộng",
                  //                 style: FineTheme.typograhpy.caption1.copyWith(
                  //                     color: FineTheme.palettes.neutral600),
                  //               ),
                  //               const SizedBox(height: 6),
                  //               Text(
                  //                 _orderViewModel!.status == ViewStatus.Loading
                  //                     ? "..."
                  //                     : formatPrice(_orderViewModel!
                  //                         .orderDTO!.finalAmount!),
                  //                 style: FineTheme.typograhpy.subtitle1
                  //                     .copyWith(fontWeight: FontWeight.bold),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       flex: 7,
                  //       child: Padding(
                  //         padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                  //         child: InkWell(
                  //           onTap: () async {
                  //             await model.orderCart();
                  //           },
                  //           child: Container(
                  //             height: 41,
                  //             padding: const EdgeInsets.all(6),
                  //             decoration: BoxDecoration(
                  //               color: FineTheme.palettes.primary200,
                  //               borderRadius: BorderRadius.circular(8),
                  //               border: Border.all(
                  //                 color: FineTheme.palettes.primary200,
                  //                 width: 1,
                  //                 style: BorderStyle.solid,
                  //               ),
                  //               boxShadow: [
                  //                 BoxShadow(
                  //                   color: FineTheme.palettes.primary300,
                  //                   offset: const Offset(0, 4),
                  //                 ),
                  //               ],
                  //             ),
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               crossAxisAlignment: CrossAxisAlignment.center,
                  //               children: [
                  //                 Text(
                  //                     isMenuAvailable
                  //                         ? "Đặt đơn"
                  //                         : "Khung giờ đã kết thúc",
                  //                     style: FineTheme.typograhpy.subtitle1
                  //                         .copyWith(
                  //                             color: isMenuAvailable
                  //                                 ? Colors.white
                  //                                 : FineTheme
                  //                                     .palettes.neutral800)),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
