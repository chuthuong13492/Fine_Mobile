
import 'package:fine/ViewModel/orderHistory_viewModel.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
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
    // model.getOrders();
  }

  Future<void> refreshFetchOrder() async {
    // await model.getOrders();
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
                // child: _buildOrders(),
                color: Color(0xffefefef),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
