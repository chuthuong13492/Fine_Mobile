import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/OrderDTO.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/orderHistory_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../Accessories/index.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  OrderHistoryViewModel _orderHistoryViewModel =
      Get.find<OrderHistoryViewModel>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  int count = 0;
  @override
  void initState() {
    super.initState();
    _orderHistoryViewModel.getOrders();
    // Get.find<OrderHistoryViewModel>().getMoreOrders();
  }

  Future<void> refreshFetchOrder() async {
    await _orderHistoryViewModel.getOrders();
    // await model.getMoreOrders();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: Get.find<OrderHistoryViewModel>(),
      child: Scaffold(
        appBar: DefaultAppBar(
          title: "Lịch sử",
          backButton: const SizedBox.shrink(),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            orderStatusBar(),
            const SizedBox(height: 2),
            Expanded(
              child: Container(
                // ignore: sort_child_properties_last
                child: _buildOrders(),
                color: const Color(0xffefefef),
              ),
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  Widget orderStatusBar() {
    return ScopedModelDescendant<OrderHistoryViewModel>(
      builder: (context, child, model) {
        return Center(
          child: Container(
            // color: Colors.amber,
            // padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Center(
              child: ToggleButtons(
                renderBorder: false,
                selectedColor: FineTheme.palettes.primary100,
                onPressed: (int index) async {
                  await model.changeStatus(index);
                },
                // borderRadius: BorderRadius.circular(24),
                isSelected: model.selections,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      "Đang thực hiện",
                      textAlign: TextAlign.center,
                      style: FineTheme.typograhpy.subtitle1,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      "Hoàn thành",
                      textAlign: TextAlign.center,
                      style: FineTheme.typograhpy.subtitle1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

////////////////////
  Widget _buildOrders() {
    return ScopedModelDescendant<OrderHistoryViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      final orderSummaryList = model.orderThumbnail
          .where((element) =>
              element.itemQuantity != 0 && element.orderStatus != 3)
          .toList();

      if (status == ViewStatus.Loading) {
        return const Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
          child: Center(
            child: LoadingFine(),
          ),
        );
      } else if (status == ViewStatus.Empty ||
          orderSummaryList == null ||
          orderSummaryList.isEmpty) {
        return Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bạn chưa đặt đơn hàng nào hôm nay 😵',
                  style: FineTheme.typograhpy.subtitle2,
                ),
                MaterialButton(
                  onPressed: () {
                    Get.offAndToNamed(RouteHandler.NAV);
                  },
                  child: Text(
                    '🥡 Đặt ngay 🥡',
                    style: FineTheme.typograhpy.subtitle2.copyWith(
                      color: FineTheme.palettes.primary300,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }

      if (status == ViewStatus.Error) {
        return Center(
          child: AspectRatio(
            aspectRatio: 1 / 4,
            child: Image.asset(
              'assets/images/error.png',
              width: 24,
            ),
          ),
        );
      }

      return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: refreshFetchOrder,
        child: Container(
          // padding: const EdgeInsets.only(bottom: 30),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: Get.find<OrderHistoryViewModel>().scrollController,
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            children: [
              // ...listWidget.toList(),
              ...orderSummaryList
                  .map((orderSummary) => _buildOrderSummary(orderSummary))
                  .toList(),
              loadMoreIcon(),
            ],
          ),
        ),
      );
    });
  }

//////////////////
  Widget loadMoreIcon() {
    return ScopedModelDescendant<OrderHistoryViewModel>(
      builder: (context, child, model) {
        switch (model.status) {
          case ViewStatus.LoadMore:
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildOrderSummary(OrderDTO orderSummary) {
    final isToday =
        orderSummary.checkInDate!.difference(DateTime.now()).inDays == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: isToday
              ? Text(
                  'Hôm nay 😋',
                  style: FineTheme.typograhpy.h1,
                )
              : Text(DateFormat('dd/MM/yyyy').format(orderSummary.checkInDate!),
                  style: FineTheme.typograhpy.subtitle1
                      .copyWith(color: Colors.black)),
        ),
        // ...orderSummary.inverseGeneralOrder!
        //     .toList()
        //     .map((order) => _buildOrderItem(order))
        //     .toList(),
        _buildOrderItem(orderSummary),
      ],
    );
  }

  Widget _buildOrderItem(OrderDTO orderDTO) {
    bool isSuccess = false;
    String text = "";
    int priceFormat = (orderDTO.finalAmount! / 1000).floor();
    final status = orderDTO.orderStatus;
    switch (status) {
      case 4:
        isSuccess = false;
        text = "Đang thực hiện";
        break;
      case 6:
        isSuccess = false;
        text = "Đang được chuẩn bị";
        break;
      case 9:
        isSuccess = false;
        text = "Đang đến station";
        break;
      case 10:
        isSuccess = true;
        text = "Đã hoàn thành";
        break;
      case 11:
        isSuccess = true;
        text = "Đã hoàn thành";
        break;
      case 12:
        isSuccess = false;
        text = "Đã hủy";
        break;
      case 13:
        isSuccess = false;
        text = "Đã hủy";
        break;
      default:
        isSuccess = false;
        text = "Đang thực hiện";
    }

    return Container(
      color: Colors.white,
      // height: 80,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),

      child: Column(
        children: [
          ListTile(
              onTap: () async {
                if (status != 12 || status != 13) {
                  _onTapOrderHistory(orderDTO);
                } else {
                  await showStatusDialog("assets/images/logo2.png", "Oops!",
                      "Đơn này đã bị hủy mất rùi!!");
                }
              },
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              leading: IconButton(
                  onPressed: () async {
                    if (status != 11) {
                      await _orderHistoryViewModel.getOrderByOrderId(
                          id: orderDTO.id);
                      await Get.find<OrderViewModel>()
                          .fetchStatus(orderDTO.id!);
                      await Get.toNamed(RouteHandler.QRCODE_SCREEN,
                          arguments: _orderHistoryViewModel.orderDTO);
                    } else {
                      await showStatusDialog("assets/images/logo2.png",
                          'Đã lấy hàng', 'Bạn đã nhận đơn hàng này rùi nè');
                    }
                  },
                  icon: Icon(
                    FontAwesomeIcons.qrcode,
                    size: 25,
                    color: FineTheme.palettes.primary100,
                  )),
              title: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                child: Row(
                  children: [
                    isSuccess
                        ? const Icon(Icons.check_circle_rounded, size: 18)
                        : const Icon(FontAwesomeIcons.spinner, size: 18),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      text,
                      style: FineTheme.typograhpy.subtitle1
                          .copyWith(color: FineTheme.palettes.neutral700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderDTO.orderCode!,
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: FineTheme.palettes.shades200),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      orderDTO.isPartyMode == true
                          ? Row(
                              children: [
                                Text(
                                  'Đơn nhóm',
                                  style: FineTheme.typograhpy.subtitle2
                                      .copyWith(
                                          color: FineTheme.palettes.neutral500),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.circle,
                                  size: 5,
                                  color: FineTheme.palettes.neutral500,
                                ),
                                const SizedBox(width: 4),
                              ],
                            )
                          : const SizedBox.shrink(),
                      Row(
                        children: [
                          Text(
                            // formatPrice(orderDTO.finalAmount!),
                            "${priceFormat}k",
                            style: FineTheme.typograhpy.subtitle2
                                .copyWith(color: FineTheme.palettes.neutral500),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(Ví Fine)',
                            style: FineTheme.typograhpy.subtitle2
                                .copyWith(color: FineTheme.palettes.neutral500),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.circle,
                            size: 4,
                            color: FineTheme.palettes.neutral500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            orderDTO.itemQuantity.toString() + ' Món',
                            style: FineTheme.typograhpy.subtitle2
                                .copyWith(color: FineTheme.palettes.neutral500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                size: 25,
                color: FineTheme.palettes.neutral800,
              )),
          // Text("Chi tiết", style: TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  void _onTapOrderHistory(OrderDTO order) async {
    await _orderHistoryViewModel.getOrderByOrderId(id: order.id);

    // get orderDetail
    // await Get.toNamed(RouteHandler.ORDER_HISTORY_DETAIL,
    //     arguments: _orderHistoryViewModel.orderDTO);
    // _orderHistoryViewModel.getOrders();
    await Get.find<OrderViewModel>()
        .fetchStatus(_orderHistoryViewModel.orderDTO!.id!);
    await Get.toNamed(RouteHandler.CHECKING_ORDER_SCREEN, arguments: {
      "order": _orderHistoryViewModel.orderDTO,
      "isFetch": false,
    });
  }
}
