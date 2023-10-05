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
import 'package:fine/ViewModel/product_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PartyOrderViewModel extends BaseModel {
  final root = Get.find<RootViewModel>();
  final _orderViewModel = Get.find<OrderViewModel>();
  PartyStatus? partyStatus;
  PartyOrderDTO? partyOrderDTO;
  PartyOrderDAO? _partyDAO;
  AccountDTO? acc;
  Customer? customer;
  // Cart? currentCart;
  String? errorMessage;
  List<OrderDetails>? listOrderDetail;
  List<String> listError = <String>[];
  List<Customer?>? listCustomer;
  String? partyCode;
  bool? isLinked = false;
  bool? isJoinParty = false;
  bool? isInvited = false;

  PartyOrderViewModel() {
    _partyDAO = PartyOrderDAO();
    partyCode = null;
    partyStatus = null;
    // currentCart = null;
  }

  Future<void> createCoOrder() async {
    try {
      if (Get.isDialogOpen!) {
        setState(ViewStatus.Loading);
      }
      hideDialog();
      listError.clear();
      _orderViewModel.currentCart = await getCart();
      // _orderViewModel.currentCart!.addProperties(root.selectedTimeSlot!.id!);
      if (_orderViewModel.currentCart != null) {
        if (root.isNextDay == true) {
          _orderViewModel.currentCart!
              .addProperties(2, typeParty: isLinked == true ? 2 : 1);
        } else {
          _orderViewModel.currentCart!
              .addProperties(1, typeParty: isLinked == true ? 2 : 1);
        }
        if (isLinked == true) {
          _orderViewModel.isLinked = true;
        }
        partyOrderDTO = await _partyDAO?.coOrder(_orderViewModel.currentCart!);
        // partyCode = partyOrderDTO!.partyCode;
        await setPartyCode(partyOrderDTO!.partyCode!);
        await Get.find<RootViewModel>().checkHasParty();
      } else {
        Cart cart = Cart.get(
            orderType: 1,
            partyType: isLinked == true ? 2 : 1,
            timeSlotId: root.selectedTimeSlot!.id!,
            orderDetails: null);
        partyOrderDTO = await _partyDAO?.coOrder(cart);
        // partyCode = partyOrderDTO!.partyCode;
        await setPartyCode(partyOrderDTO!.partyCode!);
        await Get.find<RootViewModel>().checkHasParty();
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
          await createCoOrder();
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
      if (result!.statusCode == 404) {
        Get.back();
        await deletePartyCode();
        partyCode = null;
        // await showStatusDialog(
        //     "assets/images/error.png", result.code!, result.message!);
      }
      if (result.partyOrderDTO != null) {
        if (result.partyOrderDTO!.isPayment == true) {
          Get.back();
          await deletePartyCode();
          await _orderViewModel.removeCart();
          partyCode = null;
        }
      }

      if (result.statusCode == 200) {
        if (result.partyOrderDTO != null) {
          if ((result.partyOrderDTO?.orderType == 1 &&
                  root.isNextDay == false) ||
              (result.partyOrderDTO?.orderType == 2 &&
                  root.isNextDay == true)) {
            final isPartyAvailable = root.previousTimeSlotList?.firstWhere(
                (element) =>
                    element.id == result.partyOrderDTO?.timeSlotDTO?.id);
            if (isPartyAvailable == null) {
              await deletePartyCode();
            } else {
              partyOrderDTO = result.partyOrderDTO;
              final list = partyOrderDTO!.partyOrder!
                  .where(
                      (element) => element.customer!.id == acc.currentUser!.id)
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
              _orderViewModel.currentCart
                  ?.addProperties(root.isNextDay == true ? 2 : 1, typeParty: 1);
            }
          } else {
            int option = 1;
            if (isJoinParty == true) {
              hideDialog();
              option = await showOptionDialog(
                  "Bạn có muốn chuyển sang ngày Hôm Sau để tham gia đơn nhóm này hong!!!");
              isJoinParty = false;
            }

            if (option == 1) {
              if (result.partyOrderDTO!.orderType == 1) {
                root.isNextDay = false;
                root.isOnClick = true;
                await root.getListTimeSlot();
                final isPartyAvailable = root.previousTimeSlotList?.firstWhere(
                    (element) =>
                        element.id == result.partyOrderDTO?.timeSlotDTO?.id);
                if (isPartyAvailable == null) {
                  await deletePartyCode();
                } else {
                  partyOrderDTO = result.partyOrderDTO;
                  final list = partyOrderDTO!.partyOrder!
                      .where((element) =>
                          element.customer!.id == acc.currentUser!.id)
                      .toList();
                  await deleteCart();
                  for (var item in list) {
                    if (item.orderDetails != null) {
                      for (var item in item.orderDetails!) {
                        CartItem cartItem =
                            new CartItem(item.productId, item.quantity, null);
                        await addItemToCart(
                            cartItem, root.selectedTimeSlot!.id!);
                      }
                    }
                  }
                  _orderViewModel.getCurrentCart();
                  _orderViewModel.currentCart?.addProperties(
                      root.isNextDay == true ? 2 : 1,
                      typeParty: 1);
                }
              } else {
                root.isNextDay = true;
                root.isOnClick = true;
                await root.getListTimeSlot();
                final isPartyAvailable = root.previousTimeSlotList?.firstWhere(
                    (element) =>
                        element.id == result.partyOrderDTO?.timeSlotDTO?.id);
                if (isPartyAvailable == null) {
                  await deletePartyCode();
                } else {
                  partyOrderDTO = result.partyOrderDTO;
                  final list = partyOrderDTO!.partyOrder!
                      .where((element) =>
                          element.customer!.id == acc.currentUser!.id)
                      .toList();
                  await deleteCart();
                  for (var item in list) {
                    if (item.orderDetails != null) {
                      for (var item in item.orderDetails!) {
                        CartItem cartItem =
                            new CartItem(item.productId, item.quantity, null);
                        await addItemToCart(
                            cartItem, root.selectedTimeSlot!.id!);
                      }
                    }
                  }
                  _orderViewModel.getCurrentCart();
                  _orderViewModel.currentCart?.addProperties(
                      root.isNextDay == true ? 2 : 1,
                      typeParty: 1);
                }
              }
            } else {
              await deletePartyCode();
            }
          }
        } else {
          partyOrderDTO = result.partyOrderDTO;
        }
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      // partyOrderDTO = null;
      setState(ViewStatus.Completed);

      // setState(ViewStatus.Error);
    }
  }

  Future<void> joinPartyOrder({String? code}) async {
    AccountViewModel acc = Get.find<AccountViewModel>();
    try {
      setState(ViewStatus.Loading);
      isJoinParty = true;
      await setPartyCode(code!);
      partyCode = await getPartyCode();
      PartyOrderStatus? result = await _partyDAO?.joinPartyOrder(partyCode);
      // partyOrderDTO = result!.partyOrderDTO;
      switch (result?.code) {
        case 0:
          await getPartyOrder();
          Get.toNamed(RouteHandler.PARTY_ORDER_SCREEN);
          break;
        case 4001:
          await deletePartyCode();
          showStatusDialog(
              "assets/images/error.png", "Oops!!", "Mã code hong đúng!!!");
          break;
        case 4002:
          await deletePartyCode();
          showStatusDialog("assets/images/error.png", "Oops!!",
              "Nhóm này đã đóng mất rùi!!!");
          break;
        case 4003:
          // await setPartyCode(code!);
          await getPartyOrder();
          Get.toNamed(RouteHandler.PARTY_ORDER_SCREEN);
          break;
        case 4004:
          // await deletePartyCode();
          showStatusDialog("assets/images/error.png", "Oops!!",
              "Bạn đang trong đơn Linked!!!");
          break;
        case 4005:
          await deletePartyCode();
          showStatusDialog("assets/images/error.png", "Oops!!",
              "Nhóm này đã quá khung giờ rùi!!!");
          break;
        case 4006:
          await deletePartyCode();
          showStatusDialog("assets/images/error.png", "Oops!!",
              "Nhóm này đã xóa mất rùi!!!");
          break;
        default:
          break;
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
      _orderViewModel.currentCart
          ?.addProperties(root.isNextDay == true ? 2 : 1, typeParty: 1);
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
      await _orderViewModel.removeCart();
      for (var item in order!.orderDetails!) {
        CartItem cartItem = new CartItem(item.productId, item.quantity, null);
        await addItemToCart(cartItem, root.selectedTimeSlot!.id!);
      }
      _orderViewModel.isPartyOrder = true;
      await _orderViewModel.prepareOrder();
      Get.offAndToNamed(RouteHandler.ORDER);
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
      int? option;
      await _orderViewModel.getCurrentCart();
      if (_orderViewModel.currentCart == null) {
        await showStatusDialog("assets/images/logo2.png", 'Oops!!',
            'Giỏ hàng bạn đang trống ruìi!!');
      } else {
        option = await showOptionDialog(
            "Bạn vui lòng xác nhận lại giỏ hàng nha 😊.");
      }

      if (option != 1) {
        return;
      }
      final orderDetails = await _partyDAO?.confirmPartyOrder(partyCode);
      // CartItem item =
      //     new CartItem(orderDetails!.productId, orderDetails.quantity, null);
      // await addItemToCart(item);
      // listOrderDetail!.add(orderDetails!);
      await getPartyOrder();
      Get.toNamed(RouteHandler.CONFIRM_ORDER_SCREEN);
      setState(ViewStatus.Completed);
    } catch (e) {
      // partyOrderDTO = null;
      setState(ViewStatus.Error);
    }
  }

  Future<void> getCustomerByPhone(String phone) async {
    try {
      setState(ViewStatus.Loading);
      String numericPhoneNumber = Uri.encodeComponent(phone);
      acc = await _partyDAO?.getCustomerByPhone(numericPhoneNumber);
      setState(ViewStatus.Completed);
    } catch (e) {
      acc = null;
      await showStatusDialog("assets/images/icon-success.png", 'Oops!!',
          'Hong có sđt này mất rùi');
      setState(ViewStatus.Completed);
    }
  }

  Future<void> inviteParty(String cusId, String partyCode) async {
    try {
      setState(ViewStatus.Loading);
      isInvited = await _partyDAO?.inviteToParty(cusId, partyCode);
      setState(ViewStatus.Completed);
    } catch (e) {
      setState(ViewStatus.Completed);
    }
  }

  Future<void> deleteItem(OrderDetails item) async {
    final _productViewModel = Get.find<ProductDetailViewModel>();
    // showLoadingDialog();
    print("Delete item...");
    bool result;
    ProductDTO product =
        ProductDTO(id: item.productId, productName: item.productName);
    CartItem cartItem = CartItem(item.productId, item.quantity, null);
    result = await removeItemFromCart(cartItem);
    await removeItemFromMart(cartItem);

    print("Result: $result");
    if (result) {
      await AnalyticsService.getInstance()
          ?.logChangeCart(product, item.quantity, false);
      // Get.back(result: true);
      _orderViewModel.currentCart = await getCart();
      CartItem itemInCart = new CartItem(
          _orderViewModel.currentCart!.orderDetails![0].productId,
          _orderViewModel.currentCart!.orderDetails![0].quantity - 1,
          null);
      await _productViewModel.processCart(
          _orderViewModel.currentCart!.orderDetails![0].productId,
          1,
          root.selectedTimeSlot!.id);
      await addProductToPartyOrder();
    } else {
      await removeItemFromCart(cartItem);
      _orderViewModel.currentCart = await getCart();
      await addProductToPartyOrder();
    }
  }

  Future<void> getCustomerInParty() async {
    if (partyOrderDTO != null) {
      List<Party> party = partyOrderDTO?.partyOrder
              ?.where((element) => element.customer?.isAdmin == false)
              .toList() ??
          [];
      listCustomer = party.map((e) => e.customer).toList();
    }
    if (listCustomer?.length == 0) {
      await cancelCoOrder();
    } else {
      await showLeaderDialog();
    }
  }

  Future<void> updateQuantity(OrderDetails item) async {
    final _productViewModel = Get.find<ProductDetailViewModel>();
    _orderViewModel.currentCart = await getCart();
    var checkCart = _orderViewModel.currentCart;
    final itemInCart = checkCart!.orderDetails!
        .firstWhere((element) => element.productId == item.productId);
    if (itemInCart.quantity > item.quantity) {
      CartItem cartItem = new CartItem(item.productId, item.quantity - 1, null);

      await updateItemFromMart(cartItem);
      await updateItemFromCart(cartItem);
      await _productViewModel.processCart(
          item.productId, 1, root.selectedTimeSlot!.id);
    } else {
      await _productViewModel.processCart(
          item.productId, 1, root.selectedTimeSlot!.id);
    }
    // CartItem cartItem = new CartItem(item.productId, item.quantity, null);
    // await updateItemFromCart(cartItem);
    await addProductToPartyOrder();
  }

  Future<void> cancelCoOrder({String? id}) async {
    hideDialog();
    try {
      int option = await showOptionDialog("Hãy thử những món khác bạn nhé 😥.");
      if (option == 1) {
        // Get.back();
        // showLoadingDialog();
        // CampusDTO storeDTO = await getStore();
        partyCode = await getPartyCode();
        final success = await _partyDAO?.logoutCoOrder(
            partyCode!, id, isLinked == true ? 2 : 1);
        // await Future.delayed(const Duration(microseconds: 500));
        if (success!) {
          Get.back();
          await deletePartyCode();
          await _orderViewModel.removeCart();
          isLinked = false;
          _orderViewModel.isPartyOrder = false;
          // await Get.find<RootViewModel>().checkHasParty();

          // clearNewOrder(orderId);
          await showStatusDialog("assets/images/icon-success.png", "Thành công",
              "Hãy xem thử các món khác bạn nhé 😓");
          partyOrderDTO = null;
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

  Future<void> getCoOrderStatus() async {
    try {
      setState(ViewStatus.Loading);
      partyCode = await getPartyCode();
      partyStatus = await _partyDAO?.getPartyStatus(partyCode!);
      if (partyStatus != null) {
        if (partyStatus?.isFinish == true) {
          // Get.back();
          await deletePartyCode();
          partyCode = null;
        }
        if (partyStatus?.isDelete == true) {
          // Get.back();
          await deletePartyCode();
          partyCode = null;
        }
      }
      setState(ViewStatus.Completed);
    } catch (e) {
      // partyStatus = null;
      setState(ViewStatus.Completed);
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
