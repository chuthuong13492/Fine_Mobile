import 'dart:async';

import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/ViewModel/orderHistory_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

class CheckingOrderScreen extends StatefulWidget {
  // final bool? isFetch;
  final OrderDTO order;

  const CheckingOrderScreen({super.key, required this.order});

  @override
  State<CheckingOrderScreen> createState() => _CheckingOrderScreenState();
}

class _CheckingOrderScreenState extends State<CheckingOrderScreen> {
  OrderViewModel _orderViewModel = Get.find<OrderViewModel>();
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    // if (widget.isFetch == true) {
    _timer = Timer.periodic(
        const Duration(seconds: 2),
        (timer) async =>
            await _orderViewModel.fetchStatus(this.widget.order.id!));
    // } else {
    //   _orderViewModel.fetchStatus(this.widget.order.id!);
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FineTheme.palettes.shades100,
      body: CustomScrollView(
        physics: NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            leading: Container(
              margin: const EdgeInsets.only(left: 8),
              // padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: Container(
                  // decoration: BoxDecoration(
                  //     borderRadius:
                  //         const BorderRadius.all(Radius.circular(100)),
                  //     border: Border.all(color: FineTheme.palettes.primary100)),
                  child: IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () async {
                        await Get.find<RootViewModel>().checkHasParty();
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: Color(0xFF238E9C),
                        size: 42,
                      )),
                ),
              ),
            ),
            backgroundColor: FineTheme.palettes.shades100,
          ),
          SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                          // margin: const EdgeInsets.only(top: -50),
                          transform: Matrix4.translationValues(30, 0.0, 0.0),
                          height: 400,
                          child: Image.asset(
                            'assets/images/human_boxes.png',
                            height: 410,
                            width: 200,
                          )),
                    ),
                    Container(
                      width: Get.width,
                      height: 350,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36),
                        color: FineTheme.palettes.primary100,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            width: 85,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCheckingOrder(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckingOrder() {
    final orderHistory = Get.find<OrderHistoryViewModel>();
    final inputFormat = DateFormat('HH:mm:ss');
    final outputFormat = DateFormat('HH:mm');
    final arriveTime = outputFormat.format(
        inputFormat.parse(orderHistory.orderDTO!.timeSlot!.arriveTime!));
    final checkoutTime = outputFormat.format(
        inputFormat.parse(orderHistory.orderDTO!.timeSlot!.checkoutTime!));
    int _curStep = 2;
    final List<String> titles = [
      'Xác nhận đơn hàng',
      'Đơn hàng đã chuẩn bị tại cửa hàng',
      'Đơn hàng đang đến trạm',
      'Bạn có thể lấy đơn hàng từ trạm rồi!!! '
    ];

    return ScopedModel(
      model: Get.find<OrderViewModel>(),
      child: ScopedModelDescendant<OrderViewModel>(
        builder: (context, child, model) {
          final status = model.orderStatusDTO!.orderStatus;
          bool hasBox = false;
          if (status == 10) {
            hasBox = true;
          }
          switch (status) {
            case 4:
              _curStep = 2;
              break;
            // case 5:
            //   _curStep = 3;
            //   break;
            case 6:
              _curStep = 3;
              break;
            case 9:
              _curStep = 4;
              break;
            case 10:
              _curStep = 5;
              break;
            case 11:
              _curStep = 5;
              break;
            default:
              _curStep = 2;
          }

          return Container(
            width: Get.width,
            height: 290,
            child: Column(
              children: [
                StepProgressView(
                  curStep: _curStep,
                  color: FineTheme.palettes.shades100,
                  titles: titles,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    SvgPicture.asset("assets/icons/box_order.svg"),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        width: Get.width,
                        child: Text(
                          model.orderStatusDTO!.orderStatus == 10 ||
                                  model.orderStatusDTO!.orderStatus == 11
                              ? "Đơn hàng được đặt ở ${model.orderStatusDTO!.stationName}"
                              : 'FINE sẽ báo vị trí box khi đơn hàng được giao đến',
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              fontStyle: FontStyle.normal,
                              color: FineTheme.palettes.shades100),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(
                        RouteHandler.ORDER_HISTORY_DETAIL,
                        arguments: widget.order,
                      );
                    },
                    child: Container(
                      // alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: FineTheme.palettes.shades100,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'Xem chi tiết đơn hàng',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            fontStyle: FontStyle.normal,
                            color: FineTheme.palettes.shades100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: Get.width,
                  // height: 1,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: FineTheme.palettes.shades100,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Container(
                    width: Get.width,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            // width: 120,
                            height: 40,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: FineTheme.palettes.shades100,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Khung giờ giao',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            fontStyle: FontStyle.normal,
                                            color:
                                                FineTheme.palettes.neutral400),
                                      ),
                                      Text(
                                        '$arriveTime - $checkoutTime',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            fontStyle: FontStyle.normal,
                                            color:
                                                FineTheme.palettes.shades100),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              await orderHistory.getOrderByOrderId(
                                  id: widget.order.id);
                              final orderDTO = orderHistory.orderDTO;
                              if (hasBox) {
                                Get.toNamed(
                                  RouteHandler.QRCODE_SCREEN,
                                  arguments: orderDTO,
                                );
                              } else {
                                await showStatusDialog(
                                    "assets/images/error-loading.gif",
                                    'Chưa có QR Code rùi',
                                    'Đơn hàng chưa tới station');
                              }
                            },
                            child: Container(
                              // width: 80,
                              height: 40,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // SvgPicture.asset(
                                  //   'assets/icons/Home.svg',
                                  //   height: 20,
                                  //   width: 20,
                                  // ),
                                  Icon(
                                    Icons.qr_code,
                                    size: 20,
                                    color: FineTheme.palettes.shades100,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mã Qr Code',
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              fontStyle: FontStyle.normal,
                                              color: FineTheme
                                                  .palettes.neutral400),
                                        ),
                                        Container(
                                          width: 150,
                                          child: Text(
                                            hasBox
                                                ? 'Chi tiết QR Code'
                                                : 'Đang xử lý...',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                fontStyle: FontStyle.normal,
                                                color: FineTheme
                                                    .palettes.shades100),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
