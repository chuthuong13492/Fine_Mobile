import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/partyOrder_status.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
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
  final _accModel = Get.find<AccountViewModel>();

  PartyStatus? partyStatus;
  PartyOrderDTO? partyOrderDTO;
  OrderDTO? orderDTO;
  PartyOrderDAO? _partyDAO;
  AccountDTO? acount;
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
  bool? isAdmin = false;
  bool? isConfirm = false;
  bool? isFinished = false;
  int adminQuantity = 0;

  final ValueNotifier<int> notifier = ValueNotifier(0);
  final ValueNotifier<int> notifierMemberTimeout = ValueNotifier(0);

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
        isFinished = false;
        isConfirm = false;
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
          for (var item in cart.orderDetails!) {
            CartItem cartItem = CartItem(item.productId, "", "", "", 0, 0, 0, 0,
                0, 0, 0, false, false, true);
            await updateAddedItemtoCart(cartItem, true);
          }
          await setPartyCode(partyOrderDTO!.partyCode!);
        } else {
          ConfirmCart cart = ConfirmCart.get(
              orderType: 1,
              partyType: isLinked == true ? 2 : 1,
              timeSlotId: root.selectedTimeSlot!.id!,
              orderDetails: null);
          partyOrderDTO = await _partyDAO?.coOrder(cart);
          await setPartyCode(partyOrderDTO!.partyCode!);
          notifierMemberTimeout.value = 0;
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
        if (e.response!.data['errorCode'] == 4002) {
          showStatusDialog("assets/images/error.png", "Hết món!!",
              "Món này đã hết mất rồiii");
        } else {
          showStatusDialog("assets/images/error.png", "Khung giờ đã qua rồi",
              "Hiện tại khung giờ này đã đóng vào lúc ${root.selectedTimeSlot!.checkoutTime}, bạn hãy xem khung giờ khác nhé 😃.");
        }

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

  Future<void> getPartyOrder({String? code}) async {
    AccountViewModel acc = Get.find<AccountViewModel>();
    try {
      partyCode = await getPartyCode();

      PartyOrderStatus? result =
          await _partyDAO?.getPartyOrder(code ?? partyCode);

      if (result != null && result.statusCode == 200) {
        bool? hasUser = result.partyOrderDTO?.partyOrder
            ?.any((element) => element.customer?.id == acc.currentUser?.id);
        if (hasUser == false) {
          deletePartCart();
          deletePartyCode();
          partyOrderDTO = null;
          partyCode = null;
          notifier.value = 0;
          Get.back();
          final cart = await getCart();
          if (cart != null) {
            final listItem = cart.items!
                .where((element) => element.isAddParty == true)
                .toList();
            for (var item in listItem) {
              await updateAddedItemtoCart(item, false);
            }
          }
          _cartViewModel.getCurrentCart();
          await showStatusDialog("assets/images/error.png", "Oops!",
              "Bạn hong có trong party này!!");
        } else {
          partyOrderDTO = result.partyOrderDTO;

          final userParty = partyOrderDTO?.partyOrder?.firstWhere(
              (element) => element.customer!.id == acc.currentUser!.id);
          await deletePartCart();
          if (userParty != null) {
            if (userParty.customer!.isAdmin == true) {
              isAdmin = true;
              adminQuantity = 0;
              for (var partyList in partyOrderDTO!.partyOrder!) {
                for (var item in partyList.orderDetails!) {
                  adminQuantity += item.quantity;
                }
              }
            } else {
              isAdmin = false;
              if (notifierMemberTimeout.value > 0) {
                notifierMemberTimeout.value--;
              } else {
                if (userParty.customer?.isConfirm == false) {
                  // await cancelCoOrder(false);
                  final success = await _partyDAO?.logoutCoOrder(
                      partyCode!, null, isLinked == true ? 2 : 1);
                  if (success!) {
                    await deletePartyCode();
                    partyCode = await getPartyCode();
                    final cart = await getCart();
                    if (cart != null) {
                      final listItem = cart.items!
                          .where((element) => element.isAddParty == true)
                          .toList();
                      for (var item in listItem) {
                        await updateAddedItemtoCart(item, false);
                      }
                    }
                    await _cartViewModel.getCurrentCart();
                    Get.back();
                    showStatusDialog("assets/images/logo2.png", "Oops!",
                        "Đã hết thời gian xác nhận mất rồi!");
                    return;
                  }
                }
              }
            }
            if (userParty.orderDetails != null) {
              for (var item in userParty.orderDetails!) {
                ConfirmCartItem cartItem =
                    ConfirmCartItem(item.productId, item.quantity, null);
                await addPartyItem(cartItem, root.selectedTimeSlot!.id!);
              }
            }
          }
          final cart = await getPartyCart();

          notifier.value = cart == null ? 0 : cart.itemQuantity();
        }
      } else if (result!.statusCode == 404) {
        deletePartCart();
        deletePartyCode();
        partyCode = null;
        partyOrderDTO = null;
        final cart = await getCart();
        if (cart != null) {
          final listItem = cart.items!
              .where((element) => element.isAddParty == true)
              .toList();
          for (var item in listItem) {
            await updateAddedItemtoCart(item, false);
          }
        }
        _cartViewModel.getCurrentCart();
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
        isFinished = false;
        isJoinParty = true;
        isConfirm = false;
        await setPartyCode(code!);
        partyCode = await getPartyCode();
        PartyOrderStatus? result = await _partyDAO?.joinPartyOrder(
            partyCode, root.selectedTimeSlot?.id);
        if (partyCode!.contains("LPO")) {
          if (result?.code == 4007) {
            isLinked = true;
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
            isLinked = true;
            await Get.find<OrderViewModel>().prepareOrder();
            hideDialog();
            notifyListeners();
          }
        } else {
          switch (result?.code) {
            case 0:
              final data = result?.partyOrderDTO;
              final cart = await getCart();
              if (cart != null) {
                if (data?.timeSlotDTO?.id != cart.timeSlotId) {
                  await Get.find<CartViewModel>().removeCart();
                }
              }
              root.checkCartAvailable();
              Get.find<CartViewModel>().getCurrentCart();
              notifierMemberTimeout.value = 300;
              await getPartyOrder();
              // Timer.periodic(const Duration(seconds: 1), (timer) async {
              //   if (notifierMemberTimeout.value > 0) {
              //     notifierMemberTimeout.value--;
              //   } else {
              //     timer.cancel();

              //   }
              // });
              await Get.toNamed(RouteHandler.PARTY_ORDER_SCREEN);

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
              String msg = result!.message!;
              RegExp regex = RegExp(r'CPO(\w+)');
              Match? match = regex.firstMatch(msg);
              String? previousCode = "CPO${match?.group(1)}";
              await getPartyOrder(code: previousCode);
              bool? success;
              int option = await showOptionDialog(
                  "Bạn đang trong đơn nhóm với mã code: $previousCode. Bạn muốn qua đơn nhóm mới hay ở lại nè!!",
                  firstOption: "Ở lại",
                  secondOption: "Chuyển Party");
              if (option == 1) {
                if (isAdmin == true) {
                  success = await _partyDAO?.logoutCoOrder(
                      previousCode, null, isLinked == true ? 2 : 1);
                } else {
                  success = await _partyDAO?.logoutCoOrder(previousCode,
                      _accModel.currentUser!.id, isLinked == true ? 2 : 1);
                }
                if (success == true) {
                  await joinPartyOrder(code: code);
                }
              } else {
                root.checkCartAvailable();
                Get.find<CartViewModel>().removeCart();
                Get.find<CartViewModel>().getCurrentCart();
                await getPartyOrder();
                await Get.toNamed(RouteHandler.PARTY_ORDER_SCREEN);
              }

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
      List<ConfirmCartItem>? detailList = [];
      for (var item in orderDTO!.orderDetails!) {
        detailList.add(ConfirmCartItem(item.productId, item.quantity, ""));
      }
      final cart = ConfirmCart.get(
        orderType: partyOrderDTO?.orderType,
        partyCode: partyOrderDTO?.partyCode,
        timeSlotId: partyOrderDTO?.timeSlotDTO?.id,
        orderDetails: detailList,
      );
      _orderViewModel.currentCart = cart;
      Get.offAndToNamed(RouteHandler.ORDER);
      // _orderViewModel.orderDTO = orderDTO;

      notifyListeners();
      setState(ViewStatus.Completed);
    } catch (e) {
      setState(ViewStatus.Error);
    }
  }

  Future<void> confirmationParty() async {
    try {
      setState(ViewStatus.Loading);
      int? option;
      final cart = await getMart();
      if (cart == null) {
        option = 0;
        await showStatusDialog("assets/images/logo2.png", 'Oops!!',
            'Giỏ hàng bạn đang trống ruìi!!');
      } else {
        option = await showOptionDialog(
            "Bạn vui lòng xác nhận lại giỏ hàng nha 😊.");
      }

      if (option != 1) {
        return;
      }
      // isFinished = true;
      isConfirm = true;
      final orderDetails = await _partyDAO?.confirmPartyOrder(partyCode);

      await getPartyOrder();
      // Get.toNamed(RouteHandler.CONFIRM_ORDER_SCREEN);
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
      acount = await _partyDAO?.getCustomerByPhone(numericPhoneNumber);
      setState(ViewStatus.Completed);
    } catch (e) {
      acount = null;
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
        await cancelCoOrder(false);
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
          if (isOrder == false) {
            await deletePartyCode();
            partyCode = await getPartyCode();
            final cart = await getCart();
            if (cart != null) {
              final listItem = cart.items!
                  .where((element) => element.isAddParty == true)
                  .toList();
              for (var item in listItem) {
                await updateAddedItemtoCart(item, false);
              }
            }
            await _cartViewModel.getCurrentCart();
            Get.back();
            showStatusDialog("assets/images/icon-success.png", "Thành công",
                "Hãy xem thử các món khác bạn nhé 😓");
          } else {
            await deletePartyCode();
            partyCode = await getPartyCode();

            await _orderViewModel.prepareOrder();
          }
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
      if (partyCode == null) {
        return;
      }
      if (partyCode!.contains("CPO")) {
        partyStatus = await _partyDAO?.getPartyStatus(partyCode!);
      }

      if (partyStatus != null) {
        if (partyStatus?.isFinish == true) {
          isFinished = true;
          final cart = await getCart();
          if (cart != null) {
            final listItem = cart.items!
                .where((element) => element.isAddParty == true)
                .toList();
            for (var item in listItem) {
              await removeItemFromCart(item);
            }
          }
          await _cartViewModel.getCurrentCart();
          deletePartyCode();
          deletePartCart();
          partyCode = null;
          partyOrderDTO = null;
          if (isAdmin == false) {
            if (Get.currentRoute == "/party_order_screen") {
              Get.back();
            }
            showStatusDialog("assets/images/logo2.png", "Đã thanh toán",
                "Đơn nhóm đã được thanh toán thành công");
          }
        }
      }

      notifyListeners();
      setState(ViewStatus.Completed);
    } catch (e) {
      // partyStatus = null;
      setState(ViewStatus.Completed);
    }
  }

  // Future<void> deleteParty() async {
  //   deletePartyCode();
  //   deletePartCart();
  //   partyCode = null;
  //   partyOrderDTO = null;
  //   notifyListeners();
  // }
}
