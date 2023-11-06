import 'dart:async';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/order_status.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/stationList_status.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Service/analytic_service.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/cart_viewModel.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/orderHistory_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/product_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Model/DAO/index.dart';
import '../Model/DTO/ConfirmCartDTO.dart';

class OrderViewModel extends BaseModel {
  ConfirmCart? currentCart;
  OrderDAO? _dao;
  ProductDAO? _productDAO;
  StationDAO? _stationDAO;
  OrderDTO? orderDTO;
  OrderStatusDTO? orderStatusDTO;
  PartyOrderDTO? partyOrderDTO;
  PartyOrderDAO? _partyDAO;
  List<StationDTO>? stationList;
  List<ProductInCart>? productRecomend;
  bool? loadingUpsell;
  bool? isPartyOrder;
  bool? isLinked;
  String? codeParty;
  String? errorMessage;
  List<String> listError = <String>[];
  RootViewModel? root = Get.find<RootViewModel>();

  final ValueNotifier<int> notifierTimeRemaining = ValueNotifier(0);
  int? timeRemaining;

  OrderViewModel() {
    _dao = OrderDAO();
    _stationDAO = StationDAO();
    _partyDAO = PartyOrderDAO();
    _productDAO = ProductDAO();
    // promoDao = new PromotionDAO();
    // _collectionDAO = CollectionDAO();
    loadingUpsell = false;
    // isPartyOrder = false;
    currentCart = null;
    codeParty = null;
  }

  Future<void> prepareOrder() async {
    // final party = Get.find<PartyOrderViewModel>();
    try {
      if (!Get.isDialogOpen!) {
        setState(ViewStatus.Loading);
      }
      codeParty = await getPartyCode();
      isLinked = false;
      if (codeParty != null) {
        if (codeParty!.contains("LPO")) {
          isLinked = true;
        }
      }

      // if (codeParty != null && codeParty!.contains("LPO")) {
      //   await party.joinPartyOrder(code: codeParty);
      // }
      await getCurrentCart();
      if (currentCart != null) {
        if (currentCart!.orderDetails!.isEmpty &&
            currentCart?.partyType == null) {
          Get.back();
          Get.find<PartyOrderViewModel>().isLinked = false;
          isLinked = false;
          // await removeCart();
          if (notifierTimeRemaining.value > 0) {
            await delLockBox();
          }
          await deletePartyCode();
        }
      }
      // isPartyOrder = false;
      if (isPartyOrder == true && isPartyOrder != null) {
        productRecomend = [];
      }

      listError.clear();
      if (currentCart != null) {
        orderDTO = await _dao?.prepareOrder(currentCart!);

        // Get.back();
      } else {
        // await removeCart();
        // await getCurrentCart();
        Get.back();
      }

      errorMessage = null;
      hideDialog();
      setState(ViewStatus.Completed);
    } on DioError catch (e, stacktra) {
      RootViewModel root = Get.find<RootViewModel>();
      print(stacktra.toString());
      if (e.response?.data["statusCode"] == 400) {
        String errorMsg = e.response?.data["message"];
        errorMessage = errorMsg;
        Get.back;
        showStatusDialog("assets/images/error.png", "Khung giờ đã qua rồi",
            "Hiện tại khung giờ này đã đóng vào lúc ${root.selectedTimeSlot!.closeTime}, bạn hãy xem khung giờ khác nhé 😃.");
        // await removeCart();

        setState(ViewStatus.Completed);
      } else if (e.response?.data["statusCode"] == 404) {
        if (e.response?.data["error"] != null) {
          // setCart(currentCart!);
          setState(ViewStatus.Completed);
        }
      } else {
        bool result = await showErrorDialog();
        if (result) {
          await prepareOrder();
        } else {
          setState(ViewStatus.Error);
        }
      }
    }
  }

  Future<void> getListStation() async {
    try {
      setState(ViewStatus.Loading);
      StationStatus? station = await _stationDAO?.getStationList(
          DESTINATIONID, orderDTO!.boxQuantity!);
      if (station?.listStation != null) {
        stationList = station?.listStation;
      }
      notifierTimeRemaining.value = station!.countDown!;
      timeRemaining = station.countDown;
      Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (notifierTimeRemaining.value > 0) {
          notifierTimeRemaining.value--;
        } else {
          timer.cancel();
          if (orderDTO?.stationDTO != null) {
            await delLockBox();
          }
          if (Get.currentRoute == "/station_picker_screen") {
            Get.back();
          }
        }
      });

      setState(ViewStatus.Completed);
    } catch (e) {
      stationList = null;
      setState(ViewStatus.Error);
    }
  }

  Future<void> addStationToCart(StationDTO? dto) async {
    try {
      if (orderDTO!.stationDTO != null) {
        if (notifierTimeRemaining.value > 0) {
          orderDTO!.stationDTO = null;
          orderDTO!.stationDTO = dto;
          await _stationDAO?.changeStation(orderDTO!.orderCode!, 2,
              stationId: orderDTO!.stationDTO!.id!);
        } else {
          showStatusDialog("assets/images/logo2.png", "Đã lố thời gian",
              "Thời gian giao dịch đã hết!");
          await delLockBox();
          orderDTO!.stationDTO = null;

          Get.back();
        }
      } else {
        orderDTO!.stationDTO = dto;
        final isLockBox = await _stationDAO?.lockBoxOrder(
            orderDTO!.stationDTO!.id!,
            orderDTO!.orderCode!,
            orderDTO!.boxQuantity!);
      }
      notifyListeners();
    } catch (e) {
      orderDTO?.stationDTO = null;
    }
  }

  Future<void> delLockBox() async {
    try {
      timeRemaining = 0;
      notifierTimeRemaining.value = 0;
      orderDTO!.stationDTO = null;
      await _stationDAO?.changeStation(orderDTO!.orderCode!, 1,
          stationId:
              orderDTO!.stationDTO != null ? orderDTO!.stationDTO?.id : null);
      notifyListeners();
    } catch (e) {
      orderDTO!.stationDTO = null;
      throw e;
    }
  }

  Future<void> orderCart() async {
    try {
      if (orderDTO!.stationDTO == null) {
        showStatusDialog("assets/icons/box_icon.png", "Opps",
            "Bạn chưa chọn nơi nhận kìa 🥹");
      } else {
        final otherAmounts =
            orderDTO!.otherAmounts!.firstWhere((element) => element.type == 1);
        int option = await showConfirmOrderDialog(
            orderDTO!.itemQuantity!,
            orderDTO!.totalAmount!,
            otherAmounts.amount!,
            orderDTO!.finalAmount!);

        if (option != 1) {
          return;
        }
        // showLoadingDialog();
        final code = await getPartyCode();
        if (code != null) {
          orderDTO!.addProperties(code);
        }
        OrderStatus? result;
        if (orderDTO!.stationDTO != null && notifierTimeRemaining.value != 0) {
          result = await _dao?.createOrders(orderDTO!);
        } else {
          showStatusDialog("assets/images/logo2.png", "Quá thời gian",
              "Đã quá thời gian đặt đơn hàng 🥺");
          return;
        }

        if (result!.statusCode == 200) {
          // await delLockBox();
          timeRemaining = 0;
          notifierTimeRemaining.value = 0;
          await fetchStatus(result.order!.id!);
          final orderHistoryViewModel = Get.find<OrderHistoryViewModel>();
          orderHistoryViewModel.orderDTO = result.order;
          // await orderHistoryViewModel.getOrderByOrderId(id: result.order!.id);
          await showStatusDialog("assets/images/icon-success.png", 'Success',
              'Bạn đã đặt hàng thành công');

          Get.offAndToNamed(RouteHandler.CHECKING_ORDER_SCREEN,
              arguments: {"order": result.order});
          if (Get.currentRoute == "/party_order_screen") {
            Get.back();
          }
          final cart = await getMart();
          if (cart != null) {
            for (var item in cart.orderDetails!) {
              CartItem cartItem = CartItem(
                  item.productId, "", "", "", 0, 0, item.quantity, false);
              await removeItemFromCart(cartItem);
            }
          }
          deleteMart();
          final cartModel = Get.find<CartViewModel>();
          cartModel.total = 0;
          cartModel.quantityChecked = 0;
          cartModel.notifier.value = 0;
          await cartModel.getCurrentCart();
          deletePartyCode();
          final partyModel = Get.find<PartyOrderViewModel>();
          partyModel.partyOrderDTO = null;
          partyModel.partyCode = null;
          partyModel.isLinked = false;
        }
        if (result.statusCode == 400) {
          orderDTO!.stationDTO = null;
          await delLockBox();
          Get.back();
          String errorMsg = result.message!;
          errorMessage = errorMsg;
          await showStatusDialog(
              "assets/images/error.png", "Oops!", "Số dư trong ví hong đủ!!");
          setState(ViewStatus.Completed);
        } else if (result.statusCode == 404) {
          orderDTO!.stationDTO = null;
          await delLockBox();
          String errorMsg = result.message!;
          errorMessage = errorMsg;
          await showStatusDialog(
              "assets/images/error.png", "Oops!", errorMessage!);
        }
        notifyListeners();
      }
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await prepareOrder();
      } else {
        setState(ViewStatus.Error);
      }
    }
  }

  Future<void> createReOrder(String orderId) async {
    try {
      setState(ViewStatus.Loading);
      orderDTO =
          await _dao?.prepareReOrder(orderId, root!.isNextDay == true ? 2 : 1);
      setState(ViewStatus.Completed);
    } catch (e) {
      setState(ViewStatus.Error);
    }
  }

  Future<void> fetchStatus(String orderId) async {
    try {
      setState(ViewStatus.Loading);
      orderStatusDTO = await _dao!.fetchOrderStatus(orderId);
      if (orderStatusDTO != null) {
        if (orderStatusDTO?.orderStatus == 13) {
          if (Get.currentRoute == "/checking_order_screen" ||
              Get.currentRoute == "/order_detail") {
            Get.back();
          }
          await showStatusDialog(
              "assets/images/logo2.png", "Oops!", "Đơn hàng đã bị hủy mất rùi");
        }
      }
      setState(ViewStatus.Completed);
    } catch (e) {
      // orderStatusDTO = null;
      setState(ViewStatus.Completed);
    }
  }

  // Future<void> deleteItem(OrderDetails item) async {
  //   print("Delete item...");
  //   bool result;
  //   ProductDTO product =
  //       new ProductDTO(id: item.productId, productName: item.productName);
  //   ConfirmCartItem cartItem =
  //       new ConfirmCartItem(item.productId, item.quantity, null);
  //   result = await removeItemFromCart(cartItem);
  //   await removeItemFromMart(cartItem);
  //   print("Result: $result");
  //   if (result) {
  //     await AnalyticsService.getInstance()
  //         ?.logChangeCart(product, item.quantity, false);

  //     await prepareOrder();
  //   } else {
  //     await removeItemFromCart(cartItem);
  //     currentCart = await getCart();
  //     await prepareOrder();
  //   }
  // }

  // Future<void> updateQuantity(OrderDetails item) async {
  //   final productViewModel = Get.find<ProductDetailViewModel>();
  //   ConfirmCart? mart = await getMart();
  //   final itemInCart = mart!.orderDetails!
  //       .firstWhere((element) => element.productId == item.productId);
  //   if (itemInCart.quantity > item.quantity) {
  //     ConfirmCartItem cartItem =
  //         new ConfirmCartItem(item.productId, item.quantity - 1, null);

  //     await updateItemFromMart(cartItem);
  //     // await updateItemFromCart(cartItem);
  //     await productViewModel.processCart(
  //         item.productId, 1, root!.selectedTimeSlot!.id);
  //   } else {
  //     await productViewModel.processCart(
  //         item.productId, 1, root!.selectedTimeSlot!.id);
  //   }

  //   // await updateItemFromCart(cartItem);
  //   await prepareOrder();
  //   notifyListeners();
  // }

  Future<void> getCurrentCart() async {
    try {
      setState(ViewStatus.Loading);
      RootViewModel root = Get.find<RootViewModel>();
      currentCart = await getMart();
      currentCart?.addProperties(root.isNextDay == true ? 2 : 1);
      // Cart? cart = await getMart();
      // if (currentCart == null) {
      //   notifier.value = 0;
      // }
      // notifier.value = currentCart!.itemQuantity();

      setState(ViewStatus.Completed);

      notifyListeners();
    } catch (e) {
      // currentCart = null;
      setState(ViewStatus.Completed);
    }
  }
}
