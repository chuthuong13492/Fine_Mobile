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
  List<OrderDTO>? newTodayOrders;

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

      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getOrders();
      } else
        setState(ViewStatus.Error);
    } finally {}
  }

  Future<void> getMoreOrders() async {
    try {
      setState(ViewStatus.LoadMore);
      // OrderFilter filter =
      //     selections[0] ? OrderFilter.ORDERING : OrderFilter.DONE;

      final data =
          await _orderDAO?.getOrders(page: _orderDAO!.metaDataDTO.page! + 1);

      orderThumbnail += data!;

      await Future.delayed(const Duration(milliseconds: 1000));
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getMoreOrders();
      } else
        setState(ViewStatus.Error);
    }
  }
}
