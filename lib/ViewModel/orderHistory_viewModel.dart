import 'dart:typed_data';

import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Model/DAO/index.dart';
import '../Model/DTO/index.dart';

class OrderHistoryViewModel extends BaseModel {
  List<OrderDTO> orderThumbnail = [];
  OrderDAO? _orderDAO;
  dynamic error;
  OrderDTO? orderDTO;
  StationDAO? _stationDAO;
  ScrollController? scrollController;
  List<bool> selections = [true, false];
  OrderDTO? newTodayOrders;
  Uint8List? imageBytes;
  bool? isOrderCancel;

  OrderHistoryViewModel() {
    // orderDTO = dto;
    _orderDAO = OrderDAO();
    _stationDAO = StationDAO();
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

  Future<void> changeStatus(int index) async {
    selections = selections.map((e) => false).toList();
    selections[index] = true;
    notifyListeners();
    await getOrders();
  }

  Future<void> getOrders() async {
    try {
      setState(ViewStatus.Loading);

      if (selections[0] == true) {
        final data = await _orderDAO?.getOrders();
        orderThumbnail = data!
            .where((element) =>
                element.orderStatus != 10 && element.orderStatus != 11)
            .toList();
      }
      if (selections[1] == true) {
        final data = await _orderDAO?.getOrders();
        orderThumbnail = data!
            .where((element) =>
                element.orderStatus == 10 || element.orderStatus == 11)
            .toList();
      }

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

  Future<void> getOrderByOrderId({String? id}) async {
    try {
      setState(ViewStatus.Loading);

      orderDTO = await _orderDAO?.getOrderById(id);

      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      setState(ViewStatus.Error, e.toString());
    }
  }

  Future<void> getNewOrder() async {
    try {
      setState(ViewStatus.Loading);
      final data = await _orderDAO?.getOrders();
      final currentDateData = data?.firstWhere(
          (orderSummary) =>
              orderSummary.checkInDate!.difference(DateTime.now()).inDays == 0,
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

  Future<void> cancelOrder(int orderId) async {
    try {
      int option = await showOptionDialog("Hãy thử những món khác bạn nhé 😥.");
      if (option == 1) {
        showLoadingDialog();
        final success = await _orderDAO?.cancelOrder(orderId);
        if (success!) {
          clearNewOrder(orderId);
          await showStatusDialog("assets/images/icon-success.png", "Thành công",
              "Hãy xem thử các món khác bạn nhé 😓");
          Get.back();
          await getOrders();
        } else {
          await showStatusDialog(
            "assets/images/error.png",
            "Thất bại",
            "Chưa hủy đươc đơn bạn vui lòng thử lại nhé 😓",
          );
        }
      }
    } catch (e) {
      await showStatusDialog(
        "assets/images/global_error.png",
        "Thất bại",
        "Chưa hủy đươc đơn bạn vui lòng thử lại nhé 😓",
      );
    }
  }

  void clearNewOrder(int orderId) {
    newTodayOrders = null;
    notifyListeners();
  }

  Future<void> getBoxQrCode(String orderId) async {
    try {
      setState(ViewStatus.Loading);
      if (orderId != null) {
        final qrcode = await _stationDAO!.getBoxById(orderId);
        imageBytes = qrcode;
      }
      await Future.delayed(const Duration(milliseconds: 200));
      setState(ViewStatus.Completed);
    } catch (e) {
      imageBytes = null;
      print(e.toString());
      setState(ViewStatus.Completed);
    }
  }

  Future<void> getMoreOrders() async {
    try {
      setState(ViewStatus.LoadMore);
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
