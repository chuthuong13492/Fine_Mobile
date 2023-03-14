import 'package:fine/ViewModel/base_model.dart';
import 'package:flutter/material.dart';

import '../Model/DAO/index.dart';
import '../Model/DTO/index.dart';

class OrderHistoryViewModel extends BaseModel {
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
    // scrollController.addListener(() async {
    //   if (scrollController.position.pixels ==
    //       scrollController.position.maxScrollExtent) {
    //     int total_page = (_orderDAO.metaDataDTO.total / DEFAULT_SIZE).ceil();
    //     if (total_page > _orderDAO.metaDataDTO.page) {
    //       await getMoreOrders();
    //     }
    //   }
    // });
  }
}
