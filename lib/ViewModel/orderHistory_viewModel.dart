import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:flutter/material.dart';

import '../Model/DAO/index.dart';
import '../Model/DTO/index.dart';

class OrderHistoryViewModel extends BaseModel {
  List<OrderDTO> orderThumbnail = [];
  OrderDAO? _orderDAO;
  dynamic error;
  OrderDTO? orderDetail;
  ScrollController? scrollController;
  List<bool> selections = [true, false];
  OrderDTO? newTodayOrders;

  OrderHistoryViewModel({OrderDTO? dto}) {
    orderDetail = dto;
    _orderDAO = OrderDAO();
    scrollController = ScrollController();
    scrollController!.addListener(() async {
      if (scrollController!.position.pixels ==
          scrollController!.position.maxScrollExtent) {
        int total_page = (_orderDAO!.metaDataDTO.total! / DEFAULT_SIZE).ceil();
        if (total_page > _orderDAO!.metaDataDTO.page!) {
          await getMoreOrders();
        }
      }
    });
  }

  // Future<void> changeStatus(int index) async {
  //   selections = selections.map((e) => false).toList();
  //   selections[index] = true;
  //   notifyListeners();
  //   await getOrders();
  // }
  Future<void> getOrders() async {
    try {
      setState(ViewStatus.Loading);
      // OrderFilter filter = selections[0] ? OrderFilter.NEW : OrderFilter.DONE;
      final data = await _orderDAO?.getOrders();
      orderThumbnail = data!;
      // if (_orderDAO!.metaDataDTO.size! != _orderDAO!.metaDataDTO.total!) {
      //   int size = _orderDAO!.metaDataDTO.total!;
      //   final data = await _orderDAO?.getOrders(size: size);
      //   orderThumbnail = data!;
      // }

      // print(size);
      setState(ViewStatus.Completed);
      // notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getOrders();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }

  Future<void> getNewOrder() async {
    try {
      setState(ViewStatus.Loading);
      final data = await _orderDAO?.getOrders();
      final currentDateData = data?.firstWhere(
          (orderSummary) =>
              DateTime.parse(orderSummary.checkInDate!)
                  .difference(DateTime.now())
                  .inDays ==
              0,
          orElse: () => null as dynamic);
      if (currentDateData != null) {
        orderThumbnail.add(currentDateData);
        newTodayOrders = currentDateData;
      }
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getNewOrder();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }

  Future<void> getMoreOrders() async {
    try {
      setState(ViewStatus.LoadMore);
      // OrderFilter filter =
      //     selections[0] ? OrderFilter.ORDERING : OrderFilter.DONE;

      final data = await _orderDAO?.getMoreOrders(
          page: _orderDAO!.metaDataDTO.page! + 1);

      orderThumbnail += data!;

      await Future.delayed(const Duration(milliseconds: 1000));
      setState(ViewStatus.Completed);
      // notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getMoreOrders();
      } else {
        setState(ViewStatus.Error);
      }
    }
  }

  Future<void> closeNewOrder(orderId) async {
    newTodayOrders = null;
    notifyListeners();
  }
}
