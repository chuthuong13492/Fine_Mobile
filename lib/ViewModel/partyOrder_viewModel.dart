import 'package:dio/dio.dart';
import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/partyOrder_status.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Service/analytic_service.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PartyOrderViewModel extends BaseModel {
  final root = Get.find<RootViewModel>();
  final _orderViewModel = Get.find<OrderViewModel>();
  PartyOrderDTO? partyOrderDTO;
  PartyOrderDAO? _partyDAO;
  // Cart? currentCart;
  String? errorMessage;
  List<OrderDetails>? listOrderDetail;
  List<String> listError = <String>[];
  String? partyCode;
  bool? isLinked = false;

  PartyOrderViewModel() {
    _partyDAO = PartyOrderDAO();
    partyCode = null;
    // currentCart = null;
  }

  Future<void> coOrder() async {
    try {
      if (Get.isDialogOpen!) {
        setState(ViewStatus.Loading);
      }
      listError.clear();
      _orderViewModel.currentCart = await getCart();
      // _orderViewModel.currentCart!.addProperties(root.selectedTimeSlot!.id!);
      if (_orderViewModel.currentCart != null) {
        _orderViewModel.currentCart!
            .addProperties(type: isLinked == true ? 2 : 1);
        partyOrderDTO = await _partyDAO?.coOrder(_orderViewModel.currentCart!);
        // partyCode = partyOrderDTO!.partyCode;
        await setPartyCode(partyOrderDTO!.partyCode!);

        // Get.back();
      } else {
        Cart cart = Cart.get(
            orderType: 1,
            partyType: isLinked == true ? 2 : 1,
            timeSlotId: root.selectedTimeSlot!.id!,
            orderDetails: null);
        partyOrderDTO = await _partyDAO?.coOrder(cart);
        // partyCode = partyOrderDTO!.partyCode;
        await setPartyCode(partyOrderDTO!.partyCode!);
      }

      errorMessage = null;
      hideDialog();
      setState(ViewStatus.Completed);
    } on DioError catch (e, stacktra) {
      print(stacktra.toString());
      if (e.response?.statusCode == 400) {
        String errorMsg = e.response?.data["message"];
        errorMessage = errorMsg;
        showStatusDialog("assets/images/error.png", "Khung giờ đã qua rồi",
            "Hiện tại khung giờ này đã đóng vào lúc ${root.selectedTimeSlot!.checkoutTime}, bạn hãy xem khung giờ khác nhé 😃.");
        setState(ViewStatus.Completed);
      } else if (e.response?.statusCode == 404) {
        if (e.response?.data["error"] != null) {
          // setCart(currentCart!);
          setState(ViewStatus.Completed);
        }
      } else {
        bool result = await showErrorDialog();
        if (result) {
          await coOrder();
        } else {
          setState(ViewStatus.Error);
        }
      }
    }
  }

  Future<void> getPartyOrder() async {
    AccountViewModel acc = Get.find<AccountViewModel>();
    try {
      partyCode = await getPartyCode();
      PartyOrderStatus? result = await _partyDAO?.getPartyOrder(partyCode);
      if (result!.statusCode == 200) {
        partyOrderDTO = result.partyOrderDTO;
        final list = partyOrderDTO!.partyOrder!
            .where((element) => element.customer!.id == acc.currentUser!.id)
            .toList();
        await deleteCart();
        for (var item in list) {
          if (item.orderDetails != null) {
            for (var item in item.orderDetails!) {
              CartItem cartItem =
                  new CartItem(item.productId, item.quantity, null);
              await addItemToCart(cartItem, root.selectedTimeSlot!.id!);
            }
          }
        }
        _orderViewModel.getCurrentCart();
        _orderViewModel.currentCart?.addProperties(type: 1);
      } else {
        await showStatusDialog(
            "assets/images/error.png", result.code!, result.message!);
      }
      if (result.statusCode == 404) {
        await deletePartyCode();
        partyCode = null;
        await showStatusDialog(
            "assets/images/error.png", result.code!, result.message!);
      }

      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      partyOrderDTO = null;
      setState(ViewStatus.Completed);

      // setState(ViewStatus.Error);
    }
  }

  Future<void> joinPartyOrder({String? code}) async {
    AccountViewModel acc = Get.find<AccountViewModel>();
    try {
      setState(ViewStatus.Loading);
      partyCode = await getPartyCode();
      if (partyCode == null) {
        await setPartyCode(code!);
      }
      await getPartyOrder();
      bool isMatchingCustomerId = false;
      // if (partyOrderDTO == null) {
      //   partyOrderDTO = await _partyDAO?.join
      //   hideDialog();
      //   Get.toNamed(RoutHandler.PARTY_ORDER_SCREEN);
      // }
      int option = 1;
      if (partyOrderDTO != null) {
        DateFormat inputFormat = DateFormat('HH:mm:ss');
        DateTime arrive =
            inputFormat.parse(partyOrderDTO!.timeSlotDTO!.arriveTime!);
        DateTime checkout =
            inputFormat.parse(partyOrderDTO!.timeSlotDTO!.checkoutTime!);
        DateFormat outputFormat = DateFormat('HH:mm');
        String arriveTime = outputFormat.format(arrive);
        String checkoutTime = outputFormat.format(checkout);
        if (!root.isTimeSlotAvailable(partyOrderDTO!.timeSlotDTO)) {
          showStatusDialog(
              "assets/images/error.png",
              "Đơn nhóm đã lố khung giờ đặt rùi",
              "Hiện tại đơn nhóm này đã đóng vào lúc ${partyOrderDTO!.timeSlotDTO!.arriveTime}, bạn hãy đặt ở khung giờ khác nhé 😃.");
          return;
        }
        if (root.selectedTimeSlot!.id == partyOrderDTO!.timeSlotDTO!.id) {
          option = await showOptionDialog(
              "Chủ phòng đang ở khung giờ (${arriveTime} - ${checkoutTime}) 😚 Bạn hãy chuyển sang khung giờ này để tham gia đơn nhóm nhé!");
        }
      } else {
        option = 1;
      }

      if (option == 1) {
        partyCode = await getPartyCode();
        if (partyCode == null) {
          await setPartyCode(code!);
          partyCode = await getPartyCode();
        }
        await getPartyOrder();
        for (var partyOrder in partyOrderDTO!.partyOrder!) {
          String customerId = partyOrder.customer!.id!;
          if (customerId == acc.currentUser!.id) {
            isMatchingCustomerId = true;
            break;
          }
        }
        if (!isMatchingCustomerId) {
          PartyOrderStatus? result = await _partyDAO?.joinPartyOrder(partyCode);
          partyOrderDTO = result!.partyOrderDTO;
          if (result.statusCode == 400) {
            String errorMsg = result.message!;
            errorMessage = errorMsg;
            showStatusDialog(
                "assets/images/error.png",
                "Bạn đã tham gia đơn nhóm này dồi",
                "Bạn đang trong đơn nhóm với mã code ${partyCode}");
          }
          if (partyOrderDTO!.partyOrder != null) {
            await getPartyOrder();
            hideDialog();
            Get.toNamed(RouteHandler.PARTY_ORDER_SCREEN);
          } else {
            await _orderViewModel.prepareOrder();
          }
        } else {
          if (partyCode != null) {
            await getPartyOrder();
            hideDialog();
            Get.toNamed(RouteHandler.PARTY_ORDER_SCREEN);
          }
        }
      }

      setState(ViewStatus.Completed);
    } catch (e) {
      partyOrderDTO = null;
      setState(ViewStatus.Error);
    }
  }

  Future<void> addProductToPartyOrder() async {
    try {
      setState(ViewStatus.Loading);
      partyCode = await getPartyCode();
      _orderViewModel.currentCart = await getCart();
      _orderViewModel.currentCart?.addProperties(type: 1);
      if (_orderViewModel.currentCart != null) {
        partyOrderDTO = await _partyDAO?.addProductToParty(partyCode,
            cart: _orderViewModel.currentCart);
      } else {
        Cart cart = Cart.get(
            orderType: 1,
            timeSlotId: root.selectedTimeSlot!.id!,
            orderDetails: null);
        partyOrderDTO =
            await _partyDAO?.addProductToParty(partyCode, cart: cart);
        await getPartyOrder();

        // _orderViewModel.removeCart();
        _orderViewModel.getCurrentCart();
        // Get.back();
      }
      await getPartyOrder();
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      await deleteCart();
      // partyOrderDTO = null;
      setState(ViewStatus.Error);
    }
  }

  Future<void> preCoOrder() async {
    try {
      setState(ViewStatus.Loading);
      int option =
          await showOptionDialog("Bạn vui lòng xác nhận lại giỏ hàng nha 😊.");

      if (option != 1) {
        return;
      }
      partyCode = await getPartyCode();
      _orderViewModel.currentCart = await getCart();
      final order = await _partyDAO?.preparePartyOrder(
          root.selectedTimeSlot!.id!, partyCode);
      for (var item in order!.orderDetails!) {
        CartItem cartItem = new CartItem(item.productId, item.quantity, null);
        await addItemToCart(cartItem, root.selectedTimeSlot!.id!);
      }
      setState(ViewStatus.Completed);
    } catch (e) {
      // partyOrderDTO = null;
      setState(ViewStatus.Error);
    }
  }

  Future<void> confirmationParty() async {
    try {
      setState(ViewStatus.Loading);
      AccountViewModel acc = Get.find<AccountViewModel>();
      // final listParty = partyOrderDTO!.partyOrder!
      //     .where((element) => element.customer!.id == acc.currentUser!.id)
      //     .toList();
      // final listOrderDetail =
      int option =
          await showOptionDialog("Bạn vui lòng xác nhận lại giỏ hàng nha 😊.");

      if (option != 1) {
        return;
      }
      final orderDetails = await _partyDAO?.confirmPartyOrder(partyCode);
      // CartItem item =
      //     new CartItem(orderDetails!.productId, orderDetails.quantity, null);
      // await addItemToCart(item);
      // listOrderDetail!.add(orderDetails!);
      await getPartyOrder();
      setState(ViewStatus.Completed);
    } catch (e) {
      // partyOrderDTO = null;
      setState(ViewStatus.Error);
    }
  }

  Future<void> deleteItem(OrderDetails item) async {
    // showLoadingDialog();
    print("Delete item...");
    bool result;
    ProductDTO product =
        ProductDTO(id: item.productId, productName: item.productName);
    CartItem cartItem = CartItem(item.productId, item.quantity, null);
    result = await removeItemFromCart(cartItem);
    print("Result: $result");
    if (result) {
      await AnalyticsService.getInstance()
          ?.logChangeCart(product, item.quantity, false);
      // Get.back(result: true);
      await addProductToPartyOrder();
    } else {
      _orderViewModel.currentCart = await getCart();
      await addProductToPartyOrder();
    }
  }

  Future<void> updateQuantity(OrderDetails item) async {
    CartItem cartItem = new CartItem(item.productId, item.quantity, null);
    await updateItemFromCart(cartItem);
    await addProductToPartyOrder();
  }

  Future<void> cancelCoOrder(String code) async {
    try {
      int option = await showOptionDialog("Hãy thử những món khác bạn nhé 😥.");
      if (option == 1) {
        Get.back();
        // showLoadingDialog();
        // CampusDTO storeDTO = await getStore();

        final success = await _partyDAO?.logoutCoOrder(code);
        await Future.delayed(const Duration(microseconds: 500));
        if (success!) {
          // Get.back();
          await deletePartyCode();
          await _orderViewModel.removeCart();
          partyCode = await getPartyCode();
          partyOrderDTO = null;
          // clearNewOrder(orderId);
          await showStatusDialog("assets/images/icon-success.png", "Thành công",
              "Hãy xem thử các món khác bạn nhé 😓");

          // await getPartyOrder();
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
        "assets/images/error.png",
        "Thất bại",
        "Chưa hủy đươc đơn bạn vui lòng thử lại nhé 😓",
      );
    }
  }

  Future<void> isLinkedParty(bool? checkLinked) async {
    isLinked = checkLinked;
    // if (isLinked == true) {
    //   await coOrder();
    // }

    setState(ViewStatus.Completed);
    notifyListeners();
  }

  // bool isLinkedParty(bool? checkLinked) {
  //   isLinked = checkLinked;
  //   return isLinked!;
  //   setState(ViewStatus.Completed);
  // }
}
