import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Utils/format_phone.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/ViewModel/orderHistory_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../Accessories/index.dart';
import '../Model/DTO/index.dart';

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
              return Column(
                children: [
                  SizedBox(
                      height: 8,
                      child: Container(
                        color: FineTheme.palettes.primary50,
                      )),
                  InkWell(
                    onTap: () async {
                      Get.find<OrderViewModel>().fetchStatus(orderDTO!.id!);
                      Get.toNamed(RouteHandler.QRCODE_SCREEN,
                          arguments: orderDTO);
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
                              // child: IconButton(
                              //   padding: const EdgeInsets.all(0),
                              //   onPressed: () async {
                              //     Get.find<OrderViewModel>()
                              //         .fetchStatus(orderDTO.id!);
                              //     Get.toNamed(RouteHandler.QRCODE_SCREEN,
                              //         arguments: orderDTO);
                              //   },
                              //   icon: const Icon(
                              //     Icons.chevron_right_outlined,
                              //     color: Colors.black,
                              //     size: 30,
                              //   ),
                              // ),
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
                    padding: const EdgeInsets.only(bottom: 10),
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
                  SizedBox(
                      height: 8,
                      child: Container(
                        color: FineTheme.palettes.neutral200,
                      )),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: layoutFinePoint(orderDTO),
                  ),
                  SizedBox(
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
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 250,
                child: Row(
                  children: [
                    Text(
                      '${orderDetails![index].quantity}x',
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
                      '${orderDetails[index].productName}',
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
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.topRight,
                child: Text(
                  '${formatPrice(orderDetails[index].totalAmount!)}',
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
      itemCount: orderDetails!.length,
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
              child: const Text(
                'Tiền mặt',
                style: TextStyle(
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
