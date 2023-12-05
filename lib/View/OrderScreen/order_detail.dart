import 'package:fine/Constant/view_status.dart';
import 'package:fine/Utils/format_phone.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/ViewModel/orderHistory_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../Accessories/index.dart';
import '../../Constant/route_constraint.dart';
import '../../Model/DTO/index.dart';
import '../../ViewModel/station_viewModel.dart';

class OrderHistoryDetail extends StatefulWidget {
  final OrderDTO order;
  const OrderHistoryDetail({super.key, required this.order});

  @override
  State<OrderHistoryDetail> createState() => _OrderHistoryDetailState();
}

class _OrderHistoryDetailState extends State<OrderHistoryDetail> {
  OrderHistoryViewModel? _orderDetailModel;
  @override
  void initState() {
    super.initState();
    // _orderDetailModel = OrderHistoryViewModel(dto: this.widget.order);
    Get.find<OrderHistoryViewModel>()
        .getOrderByOrderId(id: this.widget.order.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FineTheme.palettes.shades100,
      appBar: DefaultAppBar(
        title: "Đơn hàng của bạn",
        // backButton: Container(
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(32),
        //   ),
        //   child: Material(
        //     color: Colors.white,
        //     child: InkWell(
        //       onTap: () {
        //         Get.back();
        //       },
        //       child: Icon(Icons.arrow_back_ios,
        //           size: 20, color: FineTheme.palettes.primary100),
        //     ),
        //   ),
        // ),
      ),
      body: ScopedModel(
          model: Get.find<OrderHistoryViewModel>(),
          child: ScopedModelDescendant<OrderHistoryViewModel>(
            builder: (context, child, model) {
              final orderDTO = model.orderDTO;
              if (model.status == ViewStatus.Loading) {
                return const SizedBox.shrink();
              }
              List<Widget> refundWidgetList = [];
              final refundProduct = orderDTO?.otherAmounts
                  ?.where((element) => element.type == 3)
                  .toList();
              if (refundProduct != null) {
                for (var item in refundProduct) {
                  List<String> parts = item.note!.split('-');
                  refundWidgetList.add(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${parts[1]}x",
                              style: FineTheme.typograhpy.subtitle2.copyWith(
                                  color: FineTheme.palettes.shades200),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.circle,
                              size: 4,
                              color: FineTheme.palettes.primary100,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              parts[2],
                              style: FineTheme.typograhpy.subtitle2.copyWith(
                                  color: FineTheme.palettes.shades200),
                            ),
                          ],
                        ),
                        Text(
                          formatPrice(double.parse(parts[0])),
                          style: FineTheme.typograhpy.subtitle2
                              .copyWith(color: FineTheme.palettes.shades200),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                refundWidgetList = [];
              }
              return ListView(
                children: [
                  SizedBox(
                      height: 8,
                      child: Container(
                        color: FineTheme.palettes.primary50,
                      )),
                  InkWell(
                    onTap: () async {
                      final orderModel = Get.find<OrderViewModel>();
                      _orderDetailModel = Get.find<OrderHistoryViewModel>();
                      if (orderModel.orderStatusDTO!.orderStatus! > 10) {
                        await Get.find<StationViewModel>().getBoxListByStation(
                            _orderDetailModel!.orderDTO!.id!);
                        Get.toNamed(RouteHandler.BOX_SCREEN,
                            arguments: _orderDetailModel!.orderDTO);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.only(
                          right: 16, left: 16, top: 10, bottom: 10),
                      child: Container(
                        height: 50,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 16),
                                    width: Get.width,
                                    child: Text(
                                      'Giao đến',
                                      style: FineTheme.typograhpy.caption1,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(left: 16),
                                    width: Get.width,
                                    child: Text(
                                      orderDTO!.stationDTO!.name!,
                                      style: FineTheme.typograhpy.subtitle2,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Center(
                              child: Icon(
                                Icons.chevron_right_outlined,
                                color: FineTheme.palettes.shades200,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: 8,
                      child: Container(
                        color: FineTheme.palettes.primary50,
                      )),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                                Container(
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
                                    "${orderDTO.timeSlot!.checkoutTime}",
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
                          orderDTO.orderType == 2
                              ? 'Ngày hôm sau'.toUpperCase()
                              : 'Ngày hôm nay'.toUpperCase(),
                          style: FineTheme.typograhpy.subtitle2
                              .copyWith(color: FineTheme.palettes.primary100),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: 8,
                      child: Container(
                        color: FineTheme.palettes.primary50,
                      )),
                  Container(
                    // padding: const EdgeInsets.only(bottom: 0),
                    child: layoutOrderDetails(orderDTO.orderDetails),
                  ),
                  SizedBox(
                      height: 8,
                      child: Container(
                        color: FineTheme.palettes.primary50,
                      )),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: layoutOrderAmount(orderDTO),
                  ),
                  refundProduct != null && refundProduct.isNotEmpty
                      ? Container(
                          color: FineTheme.palettes.primary50,
                          padding: const EdgeInsets.all(16),
                          // height: 30,

                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            decoration: BoxDecoration(
                                color: FineTheme.palettes.shades100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: FineTheme.palettes.primary100)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Hoàn tiền",
                                  style: FineTheme.typograhpy.subtitle2
                                      .copyWith(
                                          color: FineTheme.palettes.primary400),
                                ),
                                ...refundWidgetList.toList(),
                              ],
                            ),
                          ))
                      : SizedBox(
                          height: 8,
                          child: Container(
                            color: FineTheme.palettes.primary50,
                          )),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: layoutFinePoint(orderDTO),
                  ),
                  orderDTO.refundLinkedOrder != 0
                      ? SizedBox(
                          height: 30,
                          child: Container(
                            color: FineTheme.palettes.primary50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Bạn được hoàn tiền vào ví",
                                  style: FineTheme.typograhpy.subtitle1
                                      .copyWith(
                                          color: FineTheme.palettes.primary100),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.circle,
                                  size: 4,
                                  color: FineTheme.palettes.primary300,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formatPrice(orderDTO.refundLinkedOrder!),
                                  style: FineTheme.typograhpy.subtitle1
                                      .copyWith(
                                          color: FineTheme.palettes.primary300),
                                ),
                              ],
                            ),
                          ))
                      : SizedBox(
                          height: 8,
                          child: Container(
                            color: FineTheme.palettes.primary50,
                          )),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: layoutCustomer(orderDTO),
                  ),
                ],
              );
            },
          )),
    );
  }

  Widget layoutOrderDetails(List<OrderDetails>? orderDetails) {
    List<OrderDetails>? productList =
        orderDetails!.where((element) => element.quantity != 0).toList();
    List<OrderDetails>? productEmptyList =
        orderDetails.where((element) => element.quantity == 0).toList();
    return Column(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                  0, 10, 0, productEmptyList.isNotEmpty ? 0 : 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Text(
                        '${productList[index].quantity}x',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          color: FineTheme.palettes.shades200,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${productList[index].productName}',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: FineTheme.palettes.shades200,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  Expanded(
                      child: Container(
                    alignment: Alignment.topRight,
                    child: Text(
                      formatPrice(productList[index].totalAmount!),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        color: FineTheme.palettes.shades200,
                      ),
                    ),
                  )),
                ],
              ),
            );
          },
          itemCount: productList.length,
        ),
        // Padding(
        //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        //   child: MySeparator(),
        // ),
        productEmptyList.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${productEmptyList[index].quantity}x',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                color: FineTheme.palettes.shades200,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${productEmptyList[index].productName}',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  color: FineTheme.palettes.shades200,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        Expanded(
                            child: Container(
                          alignment: Alignment.topRight,
                          child: Text(
                            formatPrice(productEmptyList[index].totalAmount!),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                              color: FineTheme.palettes.shades200,
                            ),
                          ),
                        )),
                      ],
                    ),
                  );
                },
                itemCount: productEmptyList.length,
              )
            : const SizedBox.shrink()
      ],
    );
  }

  Widget layoutOrderAmount(OrderDTO? order) {
    double? shippingFee;
    for (var item in order!.otherAmounts!) {
      if (item.type == 1) {
        shippingFee = item.amount;
      }
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Text(
                'Tạm tính (${order.itemQuantity} món)',
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal),
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                formatPrice(order.totalAmount!),
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal),
              ),
            )),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Expanded(
              child: Text(
                'Phí giao hàng',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal),
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                formatPrice(shippingFee!),
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal),
              ),
            )),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Expanded(
              child: Text(
                'Thanh toán bằng',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal),
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                'Ví Fine',
                style: FineTheme.typograhpy.subtitle1
                    .copyWith(color: FineTheme.palettes.primary100),
              ),
            )),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Expanded(
              child: Text(
                'Tổng cộng',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal),
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                formatPrice(order.finalAmount!),
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal),
              ),
            )),
          ],
        ),
      ],
    );
  }

  Widget layoutFinePoint(OrderDTO? order) {
    return Stack(
      children: [
        Container(
          width: 400,
          height: 90,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/point_img.png"),
                fit: BoxFit.fill),
          ),
        ),
        Center(
          child: Container(
            alignment: Alignment.center,
            width: Get.width,
            child: Row(
              children: [
                Expanded(
                  child: Image.asset(
                    "assets/icons/Grape.png",
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                Text(
                  'Bạn nhận được ${order!.point} trái nho cho đơn hàng này',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      color: FineTheme.palettes.shades100),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget layoutCustomer(OrderDTO? dto) {
    return Container(
      width: Get.width,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Expanded(
                child: Text(
                  'Mã đơn hàng',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal),
                ),
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  dto!.orderCode!,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      overflow: TextOverflow.ellipsis),
                ),
              )),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Expanded(
                child: Text(
                  'Tên khách hàng',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal),
                ),
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  dto.customer!.name!,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      overflow: TextOverflow.ellipsis),
                ),
              )),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Expanded(
                child: Text(
                  'Số điện thoại',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal),
                ),
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  formatPhoneNumberWithDots(dto.customer!.phone!),
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      overflow: TextOverflow.ellipsis),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
