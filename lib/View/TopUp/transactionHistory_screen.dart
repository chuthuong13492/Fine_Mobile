import 'package:fine/Accessories/index.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/ViewModel/topUp_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../Constant/route_constraint.dart';
import '../../Constant/view_status.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _viewModel = Get.find<TopUpViewModel>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _viewModel.getTransaction();
    // Get.find<OrderHistoryViewModel>().getMoreOrders();
  }

  Future<void> refreshFetchTransaction() async {
    await _viewModel.getTransaction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      appBar: DefaultAppBar(
        title: "Lịch sử nạp tiền",
        backButton: Container(
          child: IconButton(
            icon: Icon(
              AntDesign.close,
              size: 24,
              color: FineTheme.palettes.primary100,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          statusBar(),
          const SizedBox(height: 2),
          Expanded(
            child: Container(
              // ignore: sort_child_properties_last
              child: _buildHistorySection(),
              color: const Color(0xffefefef),
            ),
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  Widget statusBar() {
    return ScopedModel(
      model: Get.find<TopUpViewModel>(),
      child: ScopedModelDescendant<TopUpViewModel>(
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
                        "Thành công",
                        textAlign: TextAlign.center,
                        style: FineTheme.typograhpy.subtitle1,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text(
                        "Đang xử lý",
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
      ),
    );
  }

  Widget loadMoreIcon() {
    return ScopedModelDescendant<TopUpViewModel>(
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

  Widget _buildHistorySection() {
    return ScopedModel(
        model: Get.find<TopUpViewModel>(),
        child: ScopedModelDescendant<TopUpViewModel>(
          builder: (context, child, model) {
            final status = model.status;
            final transactionList = model.listTransaction;
            if (status == ViewStatus.Loading) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
                child: Center(
                  child: LoadingFine(),
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
              onRefresh: refreshFetchTransaction,
              key: _refreshIndicatorKey,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: Get.find<TopUpViewModel>().scrollController,
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                children: [
                  ...transactionList
                      .map((transactionSummary) =>
                          _buildOrderSummary(transactionSummary))
                      .toList(),
                  loadMoreIcon(),
                ],
              ),
            );
          },
        ));
  }

  Widget _buildOrderSummary(TransactionDTO transaction) {
    final isToday =
        transaction.createdAt!.difference(DateTime.now()).inDays == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: isToday
              ? Row(
                  children: [
                    Text(
                      'Hôm nay 😋, ',
                      style: FineTheme.typograhpy.subtitle1,
                    ),
                    Text(
                      DateFormat('HH:mm').format(transaction.createdAt!),
                      style: FineTheme.typograhpy.subtitle1,
                    ),
                  ],
                )
              : Text(
                  DateFormat('dd/MM/yyyy, HH:mm')
                      .format(transaction.createdAt!),
                  style: FineTheme.typograhpy.subtitle1
                      .copyWith(color: Colors.black)),
        ),
        // ...orderSummary.inverseGeneralOrder!
        //     .toList()
        //     .map((order) => _buildOrderItem(order))
        //     .toList(),
        _buildTransactionItem(transaction),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionDTO item) {
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
              contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        item.isIncrease == true ? "Nạp tiền" : "Thanh toán",
                        style: FineTheme.typograhpy.subtitle2
                            .copyWith(color: FineTheme.palettes.shades200),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    item.note!,
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: FineTheme.palettes.neutral500),
                    maxLines: 2,
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
                  item.isIncrease == true
                      ? Text(
                          "+ ${formatPrice(item.amount!)}",
                          textAlign: TextAlign.right,
                          style: Get.theme.textTheme.headline2?.copyWith(
                              color: item.status == 1 || item.status == 3
                                  ? Colors.red
                                  : Colors.green),
                        )
                      : Text(
                          "- ${formatPrice(item.amount!)}",
                          textAlign: TextAlign.right,
                          style: Get.theme.textTheme.headline2
                              ?.copyWith(color: Colors.red),
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
}
