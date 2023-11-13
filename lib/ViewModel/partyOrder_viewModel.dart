import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/partyOrder_status.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/format_time.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/cart_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

import '../Model/DTO/ConfirmCartDTO.dart';

class PartyOrderViewModel extends BaseModel {
  final root = Get.find<RootViewModel>();
  final _orderViewModel = Get.find<OrderViewModel>();
  final _cartViewModel = Get.find<CartViewModel>();

  PartyStatus? partyStatus;
  PartyOrderDTO? partyOrderDTO;
  OrderDTO? orderDTO;
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
  bool? isCartRoute = false;

  final ValueNotifier<int> notifier = ValueNotifier(0);
  // bool? isPreCoOrder = false;
  late TwilioFlutter twilioFlutter;
  // bool? isPreCoOrder = false;

  PartyOrderViewModel() {
    _partyDAO = PartyOrderDAO();
    partyCode = null;
    partyStatus = null;
    // isPreCoOrder = false;
    // currentCart = null;
  }

  Future<void> createCoOrder(bool isLinkedMode) async {
    try {
      if (Get.isDialogOpen!) {
        setState(ViewStatus.Loading);
      }
      hideDialog();
      listError.clear();
      final cart = await getMart();
      if (root.isNextDay == false) {
        if (isLinkedMode == true) {
          isLinked = isLinkedMode;
        }
        if (cart != null) {
          if (root.isNextDay == true) {
            cart.addProperties(2, typeParty: isLinked == true ? 2 : 1);
          } else {
            cart.addProperties(1, typeParty: isLinked == true ? 2 : 1);
          }

          partyOrderDTO = await _partyDAO?.coOrder(cart);
          // partyCode = partyOrderDTO!.partyCode;
          await setPartyCode(partyOrderDTO!.partyCode!);
          await Get.find<RootViewModel>().checkHasParty();
        } else {
          ConfirmCart cart = ConfirmCart.get(
              orderType: 1,
              partyType: isLinked == true ? 2 : 1,
              timeSlotId: root.selectedTimeSlot!.id!,
              orderDetails: null);
          partyOrderDTO = await _partyDAO?.coOrder(cart);
          await setPartyCode(partyOrderDTO!.partyCode!);
          await Get.find<RootViewModel>().checkHasParty();
          errorMessage = null;
          hideDialog();
        }
      } else {
        showStatusDialog("assets/images/logo2.png", "Oops!",
            "Bạn chỉ có thể đặt đơn nhóm trong ngày thui nè !");
      }

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
          await createCoOrder(isLinked!);
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
      if (result!.statusCode == 404 && partyCode != null) {
        Get.back();
        await deletePartyCode();
        await deleteMart();
        partyCode = null;
        partyOrderDTO = null;
      }
      if (result.partyOrderDTO != null) {
        if (result.partyOrderDTO!.isPayment == true) {
          Get.back();
          await deletePartyCode();
          await deleteMart();
          partyCode = null;
          partyOrderDTO = null;
        }
      }
      if (result.statusCode == 200) {
        partyOrderDTO = result.partyOrderDTO;
        final list = partyOrderDTO!.partyOrder!
            .where((element) => element.customer!.id == acc.currentUser!.id)
            .toList();
        await deletePartCart();
        for (var item in list) {
          if (item.orderDetails != null) {
            for (var item in item.orderDetails!) {
              ConfirmCartItem cartItem =
                  ConfirmCartItem(item.productId, item.quantity, null);
              await addPartyItem(cartItem, root.selectedTimeSlot!.id!);
            }
          }
        }
        final cart = await getPartyCart();
        notifier.value = cart!.itemQuantity();
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      setState(ViewStatus.Completed);
    }
  }

  Future<void> joinPartyOrder({String? code}) async {
    final root = Get.find<RootViewModel>();
    try {
      setState(ViewStatus.Loading);
      hideDialog();
      if (root.isNextDay == false) {
        isJoinParty = true;
        await setPartyCode(code!);
        partyCode = await getPartyCode();
        PartyOrderStatus? result = await _partyDAO?.joinPartyOrder(
            partyCode, root.selectedTimeSlot?.id);
        if (partyCode!.contains("LPO")) {
          if (result?.code == 4007) {
            RegExp regex = RegExp(r'\b\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\b');
            Match? match = regex.firstMatch(result!.message!);
            String linkedTimeSlot = match!.group(0)!;
            if (root.selectedTimeSlot?.checkoutTime != linkedTimeSlot) {
              int option = await showOptionDialog(
                  "Mã đơn nhóm đang ở ${formatTime(linkedTimeSlot)}. Bạn có muốn đổi khung giờ hong?");
              if (option == 1) {
                final timeSlot = root.previousTimeSlotList
                    ?.firstWhere((element) => element.id == linkedTimeSlot);
                if (timeSlot != null) {
                  // Get.find<OrderViewModel>().removeCart();
                  root.selectedTimeSlot = timeSlot;
                  await root.refreshMenu();
                  Get.back();
                  notifyListeners();
                  return;
                }
              } else {
                await deletePartyCode();
                partyCode = null;
                return;
              }
            }
          } else {
            await Get.find<OrderViewModel>().prepareOrder();
            hideDialog();
            notifyListeners();
          }
        } else {
          await deleteMart();
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
              await getPartyOrder();
              Get.toNamed(RouteHandler.PARTY_ORDER_SCREEN);
              break;
            case 4004:
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
        }
      } else {
        showStatusDialog("assets/images/logo2.png", "Oops!",
            "Bạn chỉ có thể đặt đơn nhóm trong ngày thui nè !");
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
      // _orderViewModel.currentCart = await getCart();
      final cart = await getMart();
      if (cart != null) {
        partyOrderDTO =
            await _partyDAO?.addProductToParty(partyCode, cart: cart);
      }
      await getPartyOrder();
      Get.rawSnackbar(
          message: "Thêm thành công ✓",
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.only(left: 8, right: 8, bottom: 32),
          borderRadius: 8);
      // Get.toNamed(RouteHandler.PARTY_ORDER_SCREEN);
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
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
      orderDTO = await _partyDAO?.preparePartyOrder(
          root.selectedTimeSlot!.id!, partyCode);
      _orderViewModel.orderDTO = orderDTO;
      Get.toNamed(RouteHandler.PREPARE_CO_ORDER, arguments: orderDTO);
      notifyListeners();
      setState(ViewStatus.Completed);
    } catch (e) {
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
      // await _orderViewModel.getCurrentCart();
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
      int option = await showOptionDialog(
          "Hiện sđt này chưa đăng ký app. Bạn có muốn gửi lời mời tiếp hong 😚");

      if (option == 1) {
        twilioFlutter = TwilioFlutter(
            accountSid:
                'ACea4320db6513fa326dde35f7dd631a8d', // replace it with your account SID
            authToken:
                'ac55d174bc21d5f1c26f1b47d89e35d2', // replace it with your auth token
            twilioNumber:
                '+12562910363' // replace it with your purchased twilioNumber

            );
        twilioFlutter.sendSMS(
            toNumber: phone,
            messageBody:
                'Bạn có 1 lời mời tham gia đơn nhóm https://fine.smjle.vn/authentication');
      }
      // await showStatusDialog("assets/images/icon-success.png", 'Oops!!',
      //     'Hong có sđt này mất rùi');
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

  // Future<void> deleteItem(OrderDetails item) async {
  //   final _productViewModel = Get.find<ProductDetailViewModel>();
  //   // showLoadingDialog();
  //   print("Delete item...");
  //   bool result;
  //   ProductDTO product =
  //       ProductDTO(id: item.productId, productName: item.productName);
  //   ConfirmCartItem cartItem =
  //       ConfirmCartItem(item.productId, item.quantity, null);
  //   result = await removeItemFromCart(cartItem);
  //   await removeItemFromMart(cartItem);

  //   print("Result: $result");
  //   if (result) {
  //     await AnalyticsService.getInstance()
  //         ?.logChangeCart(product, item.quantity, false);
  //     // Get.back(result: true);
  //     _orderViewModel.currentCart = await getCart();
  //     ConfirmCartItem itemInCart = new ConfirmCartItem(
  //         _orderViewModel.currentCart!.orderDetails![0].productId,
  //         _orderViewModel.currentCart!.orderDetails![0].quantity - 1,
  //         null);
  //     await _productViewModel.processCart(
  //         _orderViewModel.currentCart!.orderDetails![0].productId,
  //         1,
  //         root.selectedTimeSlot!.id);
  //     await addProductToPartyOrder();
  //   } else {
  //     await removeItemFromCart(cartItem);
  //     _orderViewModel.currentCart = await getCart();
  //     await addProductToPartyOrder();
  //   }
  // }

  Future<void> getCustomerInParty({bool? isDelete = false}) async {
    if (partyOrderDTO != null) {
      List<Party> party = partyOrderDTO?.partyOrder
              ?.where((element) => element.customer?.isAdmin == false)
              .toList() ??
          [];
      listCustomer = party.map((e) => e.customer).toList();
    }
    if (isDelete == false) {
      if (listCustomer!.isEmpty) {
        await cancelCoOrder(true);
      } else {
        await showMemberDialog("Chọn new Leader!!!", false);
      }
    } else {
      if (listCustomer!.isEmpty) {
        await showStatusDialog("assets/images/logo2.png", "Oops!!",
            "Đơn nhóm hiện chưa có thành viên nào cả");
      } else {
        await showMemberDialog("Xóa thành viên!!!", true);
      }
    }
  }

  // Future<void> updateQuantity(OrderDetails item) async {
  //   final _productViewModel = Get.find<ProductDetailViewModel>();
  //   _orderViewModel.currentCart = await getCart();
  //   var checkCart = _orderViewModel.currentCart;
  //   // await deleteMart();
  //   final itemInCart = checkCart!.orderDetails!
  //       .firstWhere((element) => element.productId == item.productId);
  //   if (itemInCart.quantity > item.quantity) {
  //     ConfirmCartItem cartItem =
  //         new ConfirmCartItem(item.productId, item.quantity - 1, null);

  //     // await updateItemFromMart(cartItem);
  //     await updateItemFromMart(cartItem);
  //     // checkCart = await getCart();
  //     // await setMart(checkCart!);
  //     await _productViewModel.processCart(
  //         item.productId, 1, root.selectedTimeSlot!.id);
  //   } else {
  //     await setMart(checkCart);
  //     await _productViewModel.processCart(
  //         item.productId, 1, root.selectedTimeSlot!.id);
  //   }
  //   // CartItem cartItem = new CartItem(item.productId, item.quantity, null);
  //   // await updateItemFromCart(cartItem);
  //   await addProductToPartyOrder();
  // }

  Future<void> cancelCoOrder(bool isOrder, {String? id}) async {
    hideDialog();
    try {
      int? option;
      if (isOrder == true) {
        option = await showOptionDialog(
            "Bạn có chắc mún xóa mã khuyến mãi hong 😥.");
      } else {
        option = await showOptionDialog("Hãy thử những món khác bạn nhé 😥.");
      }
      if (option == 1) {
        partyCode = await getPartyCode();
        final success = await _partyDAO?.logoutCoOrder(
            partyCode!, id, isLinked == true ? 2 : 1);
        // await Future.delayed(const Duration(microseconds: 500));
        if (success!) {
          final cart = await getCart();
          if (cart != null) {
            final items = cart.items!
                .where((element) => element.isChecked == true)
                .toList();
            for (var i = 0; i < items.length; i++) {
              await updateCheckItemFromCart(items[i], false);
            }
          }

          notifier.value = 0;
          _cartViewModel.total = 0;
          _cartViewModel.quantityChecked = 0;
          await _cartViewModel.getCurrentCart();
          if (isOrder == true) {
          } else {
            Get.back();
          }
          deleteMart();
          deletePartCart();
          await deletePartyCode();
          await root.checkHasParty();

          await showStatusDialog("assets/images/icon-success.png", "Thành công",
              "Hãy xem thử các món khác bạn nhé 😓");
          partyCode = await getPartyCode();
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

  Future<void> removeMember({String? id}) async {
    hideDialog();
    try {
      setState(ViewStatus.Loading);
      int option = await showOptionDialog("Xác nhận xóa member khỏi nhóm!!");
      if (option == 1) {
        partyCode = await getPartyCode();
        final success = await _partyDAO?.removeMember(
          partyCode!,
          id,
        );
        if (success!) {
          notifyListeners();
          setState(ViewStatus.Completed);
        }
      }
    } catch (e) {
      await showStatusDialog(
        "assets/images/error.png",
        "Thất bại",
        "Chưa xóa được bạn vui lòng thử lại nhé 😓",
      );
      setState(ViewStatus.Completed);
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
      notifyListeners();
      setState(ViewStatus.Completed);
    } catch (e) {
      // partyStatus = null;
      setState(ViewStatus.Completed);
    }
  }
}
