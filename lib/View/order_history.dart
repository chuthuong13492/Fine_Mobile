import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/OrderDTO.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/orderHistory_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import '../Accessories/index.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  OrderHistoryViewModel model = Get.find<OrderHistoryViewModel>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    model.getOrders();
  }

  Future<void> refreshFetchOrder() async {
    await model.getOrders();
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
            // orderStatusBar(),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                child: _buildOrders(),
                color: Color(0xffefefef),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrders() {
    return ScopedModelDescendant<OrderHistoryViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      final orderSummaryList = model.orderThumbnail;
      if (status == ViewStatus.Loading) {
        return const Center(
          child: LoadingFine(),
        );
      } else if (status == ViewStatus.Empty ||
          orderSummaryList == null ||
          orderSummaryList.length == 0) {
        return Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Bạn chưa đặt đơn hàng nào hôm nay 😵'),
                MaterialButton(
                  onPressed: () {
                    Get.back();
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
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: model.scrollController,
            padding: const EdgeInsets.all(8),
            children: [
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
    final isToday = DateTime.parse(orderSummary.checkInDate!)
            .difference(DateTime.now())
            .inDays ==
        0;

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
              : Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(orderSummary.checkInDate!)),
                  style: FineTheme.typograhpy.subtitle1
                      .copyWith(color: Colors.black)),
        ),
        ...orderSummary.inverseGeneralOrder!
            .toList()
            .map((order) => _buildOrderItem(order))
            .toList(),
      ],
    );
  }

  Widget _buildOrderItem(InverseGeneralOrder inverseGeneralOrder) {
    var campus = Get.find<RootViewModel>().currentStore;
    final itemQuantity = inverseGeneralOrder.orderDetails!.fold<int>(0,
        (previousValue, element) {
      return previousValue + element.quantity;
    }).toString();
    return Container(
      // height: 80,
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          // side: BorderSide(color: Colors.red),
        ),
        child: Column(
          children: [
            ListTile(
              onTap: () {
                // _onTapOrderHistory(inverseGeneralOrder);
              },
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        "${inverseGeneralOrder.id} / ${itemQuantity} món",
                        style: FineTheme.typograhpy.h2.copyWith(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    campus!.address!,
                    style: FineTheme.typograhpy.subtitle2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    // order.paymentType == PaymentTypeEnum.BeanCoin
                    //     ? "${formatBean(order.finalAmount)} Bean"
                    //     :
                    "${formatPrice(inverseGeneralOrder.finalAmount!)}",
                    textAlign: TextAlign.right,
                    style: FineTheme.typograhpy.h2,
                  )
                ],
              ),
            ),
            // Text("Chi tiết", style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  void _onTapOrderHistory(order) async {
    // get orderDetail
    // await Get.toNamed(RouteHandler.ORDER_HISTORY_DETAIL, arguments: order);
    model.getOrders();
  }
}
