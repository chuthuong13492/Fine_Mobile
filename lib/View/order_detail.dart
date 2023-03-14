import 'package:fine/Accessories/dash_border.dart';
import 'package:fine/Constant/order_status.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/Utils/format_time.dart';
import 'package:fine/ViewModel/orderHistory_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import "package:collection/collection.dart";

import '../Model/DTO/index.dart';

class OrderHistoryDetail extends StatefulWidget {
  final OrderDTO order;

  OrderHistoryDetail({Key? key, required this.order}) : super(key: key);

  @override
  _OrderHistoryDetailState createState() => _OrderHistoryDetailState();
}

class _OrderHistoryDetailState extends State<OrderHistoryDetail> {
  OrderHistoryViewModel _orderDetailModel = Get.find<OrderHistoryViewModel>();
  bool isShow = false;

  @override
  void initState() {
    super.initState();
    _orderDetailModel = OrderHistoryViewModel(dto: widget.order);
    // _orderDetailModel.getOrderDetail(widget.order.id);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: Get.find<OrderHistoryViewModel>(),
      child: Scaffold(
        // bottomNavigationBar: _buildCancelBtn(),
        appBar: AppBar(
            centerTitle: true,
            title: Text('Đơn hàng',
                style: TextStyle(color: FineTheme.palettes.primary300)),
            backgroundColor: Colors.white,
            leading: Container(
              child: IconButton(
                  icon: Icon(
                    AntDesign.left,
                    size: 24,
                    color: FineTheme.palettes.primary300,
                  ),
                  onPressed: () {
                    Get.back();
                  }),
            )),
        body: SingleChildScrollView(
          child: ScopedModelDescendant<OrderHistoryViewModel>(
            builder: (context, child, model) {
              RootViewModel root = Get.find<RootViewModel>();
              var timeSlot = root.selectedTimeSlot;
              final status = model.status;

              if (status == ViewStatus.Loading)
                return AspectRatio(
                  aspectRatio: 1,
                  child: Center(child: CircularProgressIndicator()),
                );

              final orderDetail = model.orderDetail;

              var confirmOrder = FineTheme.palettes.neutral1000;
              var receiveOrder = FineTheme.palettes.neutral1000;
              var readyOrder = FineTheme.palettes.neutral1000;
              var finishOrder = FineTheme.palettes.neutral1000;
              // if (orderDetail.status == OrderFilter.NEW) {
              //   confirmOrder = FineTheme.palettes.primary400;
              // }
              // if (orderDetail.status == OrderFilter.ORDERING) {
              //   confirmOrder = FineTheme.palettes.primary300;
              //   receiveOrder = FineTheme.palettes.primary300;
              // }
              // if (orderDetail.status == OrderFilter.ORDERING) {
              //   receiveOrder = FineTheme.palettes.primary300;
              //   confirmOrder = FineTheme.palettes.primary300;
              //   readyOrder = FineTheme.palettes.primary300;
              // }
              // if (orderDetail.status == OrderFilter.DONE) {
              //   finishOrder = FineTheme.palettes.primary300;
              //   receiveOrder = FineTheme.palettes.primary300;
              //   readyOrder = FineTheme.palettes.primary300;
              //   confirmOrder = FineTheme.palettes.primary300;
              // }

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: Get.width,
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 8),
                      decoration: BoxDecoration(
                        // color: kBackgroundGrey[0],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  height: 25,
                                  alignment: Alignment.centerLeft,
                                  child:
                                      // orderDetail.status == OrderFilter.NEW
                                      //     ?
                                      Text(
                                    'Đang thực hiện ☕',
                                    style: FineTheme.typograhpy.subtitle1
                                        .copyWith(
                                            color:
                                                FineTheme.palettes.primary300),
                                    textAlign: TextAlign.start,
                                  )
                                  // : Text('Hoàn thành',
                                  //     style: Get.theme.textTheme.headline3
                                  //         .copyWith(color: kPrimary)),
                                  ),
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                  child: Divider(),
                                ),
                              ),
                              Text(
                                DateFormat('HH:mm dd/MM').format(
                                    DateTime.parse(widget.order.checkInDate!)),
                                style: FineTheme.typograhpy.subtitle2,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 16, right: 16, top: 8),
                      height: 188,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: const Color(0xffD9D9D9),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.2,
                              // width: double.infinity * 0.25,
                              child: const Text(
                                'Bạn đã xác nhận đơn hàng của mình!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 8),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.2,
                              // width: double.infinity * 0.25,
                              child: const Text(
                                'F.I.N.E đã chốt đơn hàng của bạn rồi nhé!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 8),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.2,
                              // width: double.infinity * 0.25,
                              child: const Text(
                                'Đơn hàng đã sẵn sàng để giao! Mau nhận thôi nào',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 8),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.2,
                              // width: double.infinity * 0.25,
                              child: const Text(
                                'Đơn hàng giao thành công! Chúc bạn ngon miệng!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 8),
                              ),
                            )
                          ]),
                    ),
                    Container(
                        // height: 70,
                        padding: const EdgeInsets.all(6),
                        margin:
                            const EdgeInsets.only(left: 16, right: 16, top: 8),
                        decoration: BoxDecoration(
                            color: Color(0xffFFFFFF),
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    // width: double.infinity * 0.25,
                                    child: Column(
                                      children: [
                                        Text(
                                          '1',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: confirmOrder),
                                        ),
                                        Text('Xác nhận',
                                            textAlign: TextAlign.center,
                                            style: FineTheme
                                                .typograhpy.subtitle1
                                                .copyWith(
                                                    fontSize: 14,
                                                    color: confirmOrder)),
                                      ],
                                    )),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    // width: double.infinity * 0.25,
                                    child: Column(
                                      children: [
                                        Text(
                                          '2',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: receiveOrder),
                                        ),
                                        Text('Chốt đơn',
                                            textAlign: TextAlign.center,
                                            style: FineTheme
                                                .typograhpy.subtitle1
                                                .copyWith(
                                                    fontSize: 14,
                                                    color: receiveOrder)),
                                      ],
                                    )),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    // width: double.infinity * 0.25,
                                    child: Column(
                                      children: [
                                        Text(
                                          '3',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12, color: readyOrder),
                                        ),
                                        Text('Sẵn sàng',
                                            textAlign: TextAlign.center,
                                            style: FineTheme
                                                .typograhpy.subtitle1
                                                .copyWith(
                                                    fontSize: 14,
                                                    color: readyOrder)),
                                      ],
                                    )),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    // width: double.infinity * 0.25,
                                    child: Column(
                                      children: [
                                        Text(
                                          '4',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12, color: finishOrder),
                                        ),
                                        Text('Hoàn thành',
                                            textAlign: TextAlign.center,
                                            style: FineTheme
                                                .typograhpy.subtitle1
                                                .copyWith(
                                                    fontSize: 14,
                                                    color: finishOrder)),
                                      ],
                                    ))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Column(
                                      children: [
                                        widget.order.checkInDate != null
                                            ? Text(
                                                DateFormat('HH:mm').format(
                                                    DateTime.parse(widget
                                                        .order.checkInDate!)),
                                                style: FineTheme
                                                    .typograhpy.subtitle1
                                                    .copyWith(
                                                        color: Colors.black))
                                            : Text('19 : 00')
                                      ],
                                    )),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Column(
                                      children: [
                                        Text('00:00',
                                            style: FineTheme
                                                .typograhpy.subtitle1
                                                .copyWith(color: Colors.black))
                                      ],
                                    )),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Column(
                                      children: [
                                        Text('00:00',
                                            style: FineTheme
                                                .typograhpy.subtitle1
                                                .copyWith(color: Colors.black))
                                      ],
                                    )),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Column(
                                      children: [
                                        Text(
                                          '00:00',
                                          style: FineTheme.typograhpy.subtitle1
                                              .copyWith(color: Colors.black),
                                        )
                                      ],
                                    ))
                              ],
                            )
                          ],
                        )),
                    Container(
                        margin:
                            const EdgeInsets.only(left: 16, right: 16, top: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_sharp,
                                    color: Color(0xffF17F23),
                                    size: 15,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 10),
                                    child: Text("Nhận đơn tại: ",
                                        style: FineTheme.typograhpy.subtitle1
                                            .copyWith(
                                                fontSize: 14,
                                                color: Colors.black)),
                                  ),
                                  Expanded(
                                    child: Text(
                                        'Trường Đại Học FPT - Khu công nghệ'
                                            .toString(),
                                        style: FineTheme.typograhpy.subtitle1
                                            .copyWith(
                                                fontSize: 14,
                                                color: Colors.black)),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  const ImageIcon(
                                    AssetImage("assets/icons/clock_icon.png"),
                                    color: Color(0xffF17F23),
                                    size: 15,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 10),
                                    child: Text("Giờ nhận đơn: ",
                                        style: FineTheme.typograhpy.subtitle1
                                            .copyWith(
                                                fontSize: 14,
                                                color: Colors.black)),
                                  ),
                                  timeSlot!.checkoutTime != null
                                      ? Text(formatTime(timeSlot.checkoutTime!),
                                          style: FineTheme.typograhpy.subtitle1
                                              .copyWith(
                                                  fontSize: 14,
                                                  color: Colors.black))
                                      : const Text('19 : 00'),
                                ],
                              ),
                            ),
                          ],
                        )),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 16, right: 16, top: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: FineTheme.palettes.shades100,
                      ),
                      child: Column(
                        children: [
                          layoutSubtotal(widget.order),
                          Row(
                            children: [
                              Container(
                                  padding: const EdgeInsets.only(
                                      left: 16, bottom: 8),
                                  child: GestureDetector(
                                      onTap: () => setState(() =>
                                          {isShow = !isShow, print('$isShow')}),
                                      child: Row(
                                        children: [
                                          Text(
                                              'Xem chi tiết đơn hàng (${2} Món)',
                                              style: FineTheme
                                                  .typograhpy.caption2
                                                  .copyWith(
                                                      color: FineTheme.palettes
                                                          .neutral1000)),
                                          if (isShow == false) ...[
                                            const Icon(
                                                Icons.arrow_drop_down_rounded)
                                          ] else ...[
                                            const Icon(
                                                Icons.arrow_drop_up_rounded)
                                          ],
                                        ],
                                      )))
                            ],
                          ),
                          if (isShow)
                            Container(
                              // transform: Matrix4.translationValues(0, -16, 0),
                              margin:
                                  const EdgeInsets.only(left: 16, right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: FineTheme.palettes.shades100,
                              ),
                              child: buildOrderSummaryList(widget.order),
                            ),
                        ],
                      ),
                    ),
                    // if (isShow == true)
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget _buildCancelBtn() {
  //   OrderFilter status = this.widget.order.status;

  //   if (status == OrderFilter.NEW) {
  //     return ScopedModelDescendant<OrderHistoryViewModel>(
  //         builder: (context, child, model) {
  //       return Container(
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.grey,
  //               offset: Offset(0.0, 1.0), //(x,y)
  //               blurRadius: 6.0,
  //             ),
  //           ],
  //         ),
  //         height: 125,
  //         padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
  //         child: Container(
  //           child: ListView(
  //             children: [
  //               Container(
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(8),
  //                   border: Border.all(color: kPrimary, width: 2),
  //                 ),
  //                 child: TextButton(
  //                     onPressed: () async {
  //                       int option = await showOptionDialog(
  //                           "Vui lòng liên hệ FanPage",
  //                           firstOption: "Quay lại",
  //                           secondOption: "Liên hệ");
  //                       if (option == 1) {
  //                         if (!await launch("https://www.m.me/beanoivn"))
  //                           throw 'Could not launch https://www.m.me/beanoivn';
  //                       }
  //                     },
  //                     child: Text(
  //                       "Ét o ét! Liên hệ BeanOi ngay! ",
  //                       style: TextStyle(
  //                           fontWeight: FontWeight.normal,
  //                           color: kPrimary,
  //                           fontSize: 16),
  //                     )),
  //               ),
  //               SizedBox(
  //                 height: 6,
  //               ),
  //               Center(
  //                 child: InkWell(
  //                   onTap: () {
  //                     model.cancelOrder(this.widget.order.id);
  //                   },
  //                   child: Text("Hủy đơn 😢",
  //                       style: Get.theme.textTheme.headline3
  //                           .copyWith(color: Colors.grey)),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     });
  //   } else if (status == OrderFilter.DONE) {
  //     return Container(
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.grey,
  //               offset: Offset(0.0, 1.0), //(x,y)
  //               blurRadius: 6.0,
  //             ),
  //           ],
  //         ),
  //         padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
  //         child: Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(10),
  //               border: Border.all(color: kPrimary, width: 3),
  //             ),
  //             child: TextButton(
  //               onPressed: () async {
  //                 int option = await showOptionDialog(
  //                     "Vui lòng liên hệ FanPage",
  //                     firstOption: "Quay lại",
  //                     secondOption: "Liên hệ");
  //                 if (option == 1) {
  //                   if (!await launch("https://www.m.me/beanoivn"))
  //                     throw 'Could not launch https://www.m.me/beanoivn';
  //                 }
  //               },
  //               child: Text(
  //                 "Ét o ét! Liên hệ BeanOi ngay! ",
  //                 style: TextStyle(
  //                     fontWeight: FontWeight.normal,
  //                     color: kPrimary,
  //                     fontSize: 18),
  //               ),
  //             )));
  //   } else {
  //     return Container(
  //       padding: EdgeInsets.only(top: 8, bottom: 8),
  //       child: Text('Các đầu bếp đang chuẩn bị cho bạn đó 🥡',
  //           textAlign: TextAlign.center,
  //           style: Get.theme.textTheme.headline4.copyWith(color: Colors.grey)),
  //     );
  //   }
  // }

  Widget buildOrderSummaryList(OrderDTO orderDetail) {
    Map<int, List<InverseGeneralOrder>> map = groupBy(
        orderDetail.inverseGeneralOrder!,
        (InverseGeneralOrder item) => item.id!);

    int totalBoard = map.length;
    print('totalBoard $totalBoard');

    return ScopedModel(
      model: Get.find<OrderHistoryViewModel>(),
      child: ScopedModelDescendant<OrderHistoryViewModel>(
        builder: (context, child, model) {
          return Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                List<InverseGeneralOrder> items = map.values.elementAt(index);
                List<OrderDetails>? orderDetails =
                    widget.order.inverseGeneralOrder!.map((e) => e.orderDetails)
                        as List<OrderDetails>;
                int count = 0;
                orderDetails.forEach((element) {
                  count += element.quantity;
                });
                // SupplierNoteDTO note = orderDetail.notes?.firstWhere(
                //     (element) => element.supplierId == items[0].supplierId,
                //     orElse: () => null);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          items[0].storeName!,
                          style: FineTheme.typograhpy.subtitle1
                              .copyWith(fontSize: 14, color: Colors.black),
                        ),
                        Text(
                          count.toString() + " x ",
                          style: FineTheme.typograhpy.subtitle1
                              .copyWith(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                    // (note != null)
                    //     ? Container(
                    //         width: Get.width,
                    //         color: Colors.yellow[100],
                    //         child: Text.rich(TextSpan(
                    //             text: "Ghi chú:\n",
                    //             style: Get.theme.textTheme.headline6
                    //                 .copyWith(color: Colors.red),
                    //             children: [
                    //               TextSpan(
                    //                   text: "- " + note.content,
                    //                   style: Get.theme.textTheme.headline4
                    //                       .copyWith(color: Colors.grey))
                    //             ])),
                    //       )
                    //     : SizedBox.shrink(),

                    Container(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(width: 1, color: Colors.black)),
                        // borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return buildOrderItem(
                                items[index], orderDetails[index]);
                          },
                          separatorBuilder: (context, index) =>
                              // MySeparator()
                              Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: null),
                          itemCount: items.length),
                    ),
                    const SizedBox(height: 10),
                    if (index + 1 < totalBoard) ...[
                      const MySeparator(),
                    ],
                    const SizedBox(height: 10),

                    // SizedBox(
                    //   height: 8,
                    // ),
                  ],
                );
              },
              // separatorBuilder: (context, index) => Divider(),
              itemCount: map.keys.length,
            ),
          );
        },
      ),
    );
  }

  Widget buildOrderItem(InverseGeneralOrder item, OrderDetails orderDetails) {
    final orderChilds = item.orderDetails;

    // double orderItemPrice = item.amount;
    // orderChilds?.forEach((element) {
    //   orderItemPrice += element.amount;
    // });
    // // orderItemPrice *= orderMaster.quantity;
    // Widget displayPrice = Text(
    //   "${formatPrice(orderItemPrice)}",
    //   style: FineTheme.typograhpy.caption1.copyWith(color: Colors.black),
    // );
    // if (item.type == ProductType.GIFT_PRODUCT) {
    //   displayPrice = RichText(
    //       text: TextSpan(
    //           style: Get.theme.textTheme.headline4,
    //           text: orderItemPrice.toString() + " ",
    //           children: [
    //         WidgetSpan(
    //             alignment: PlaceholderAlignment.bottom,
    //             child: Image(
    //               image: AssetImage("assets/images/icons/bean_coin.png"),
    //               width: 20,
    //               height: 20,
    //             ))
    //       ]));
    // }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Wrap(
                children: [
                  Text(
                    "${orderDetails.quantity} x",
                    style: FineTheme.typograhpy.caption1
                        .copyWith(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // item.type != ProductType.MASTER_PRODUCT
                        //     ?
                        Text(
                          orderDetails.productName!,
                          style: FineTheme.typograhpy.caption1
                              .copyWith(color: Colors.black),
                          textAlign: TextAlign.start,
                        ),
                        // : SizedBox.shrink(),
                        ...orderChilds!
                            .map(
                              (child) => Text(child.productName!),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Flexible(child: displayPrice)
          ],
        ),
      ],
    );
  }

  Widget layoutSubtotal(OrderDTO orderDetail) {
    // int index = _orderDetailModel.listPayments.values
    //     .toList()
    //     .indexOf(orderDetail.paymentType);

    // String payment = "Không xác định";
    // if (index >= 0 && index < _orderDetailModel.listPayments.keys.length) {
    //   payment = _orderDetailModel.listPayments.keys.elementAt(index);
    // }
    // if (orderDetail.paymentType == PaymentTypeEnum.Momo) {
    //   payment = "Momo";
    // }
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: FineTheme.palettes.shades100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Đơn hàng",
                        style: FineTheme.typograhpy.subtitle1.copyWith(
                            fontSize: 14, color: const Color(0xfff17f23)),
                      ),
                    ],
                  ),
                ),
                newDesignPayment(orderDetail),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget newDesignPayment(OrderDTO orderDetail) {
    // int index = _orderDetailModel.listPayments.values
    //     .toList()
    //     .indexOf(orderDetail.paymentType);
    // String payment = "Không xác định";
    // if (index >= 0 && index < _orderDetailModel.listPayments.keys.length) {
    //   payment = _orderDetailModel.listPayments.keys.elementAt(index);
    // }
    // if (orderDetail.paymentType == PaymentTypeEnum.Momo) {
    //   payment = "Momo";
    // }
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phương thức thanh toán',
                style: FineTheme.typograhpy.caption1
                    .copyWith(color: FineTheme.palettes.neutral800),
              ),
              Text('Tiền mặt',
                  style: FineTheme.typograhpy.caption1
                      .copyWith(color: FineTheme.palettes.neutral1000))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng',
                style: FineTheme.typograhpy.caption1
                    .copyWith(color: FineTheme.palettes.neutral800),
              ),
              Text(
                "${formatPrice(orderDetail.finalAmount!)}",
                style: FineTheme.typograhpy.caption1
                    .copyWith(color: FineTheme.palettes.neutral1000),
              ),
            ],
          )
        ],
      ),
    );
  }
}
