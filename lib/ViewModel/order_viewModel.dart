import 'package:dio/dio.dart';
import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/order_status.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Service/analytic_service.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/orderHistory_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/product_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Model/DAO/index.dart';

class OrderViewModel extends BaseModel {
  Cart? currentCart;
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
  String? errorMessage;
  List<String> listError = <String>[];
  RootViewModel? root = Get.find<RootViewModel>();

  final ValueNotifier<int> notifier = ValueNotifier(0);

  OrderViewModel() {
    _dao = OrderDAO();
    _stationDAO = StationDAO();
    _partyDAO = PartyOrderDAO();
    _productDAO = ProductDAO();
    // promoDao = new PromotionDAO();
    // _collectionDAO = CollectionDAO();
    loadingUpsell = false;
    currentCart = null;
  }

  Future<void> prepareOrder() async {
    ProductDetailViewModel? productViewModel =
        Get.find<ProductDetailViewModel>();
    try {
      if (!Get.isDialogOpen!) {
        setState(ViewStatus.Loading);
      }
      // if (campusDTO == null) {
      //   RootViewModel root = Get.find<RootViewModel>();
      //   campusDTO = root.currentStore;
      // }

      // currentCart = await getCart();
      await getCurrentCart();
      if (currentCart!.orderDetails!.length == 0) {
        Get.back();
        await removeCart();
      }
      CartItem itemInCart = new CartItem(
          currentCart!.orderDetails![0].productId,
          currentCart!.orderDetails![0].quantity - 1,
          null);
      await updateItemFromMart(itemInCart);

      await productViewModel.processCart(
          currentCart!.orderDetails![0].productId,
          1,
          root!.selectedTimeSlot!.id);
      // currentCart?.addProperties(root.selectedTimeSlot!.id!);
      // currentCart?.addProperties(5, '0902915671', root.selectedTimeSlot!.id!);
      // currentCart = await getCart();

      // await deleteCart();
      // await deleteMart();
      //       if (currentCart.payment == null) {
      //   if (listPayments.values.contains(1)) {
      //     currentCart.payment = PaymentTypeEnum.Cash;
      //   }
      // }
      // if (currentCart.timeSlotId == null) {
      //   if (Get.find<RootViewModel>().listAvailableTimeSlots.isNotEmpty) {
      //     currentCart.timeSlotId =
      //         Get.find<RootViewModel>().listAvailableTimeSlots[0].id;
      //   } else {
      //     errorMessage = "Hiện tại đã hết khung giờ giao hàng";
      //   }
      // }
      listError.clear();
      if (currentCart != null) {
        orderDTO = await _dao?.prepareOrder(currentCart!);

        // Get.back();
      } else {
        await removeCart();
        await getCurrentCart();
        Get.back();
      }

      errorMessage = null;
      hideDialog();
      setState(ViewStatus.Completed);
    } on DioError catch (e, stacktra) {
      RootViewModel root = Get.find<RootViewModel>();
      print(stacktra.toString());
      if (e.response?.statusCode == 400) {
        String errorMsg = e.response?.data["message"];
        errorMessage = errorMsg;
        showStatusDialog("assets/images/error.png", "Khung giờ đã qua rồi",
            "Hiện tại khung giờ này đã đóng vào lúc ${root.selectedTimeSlot!.closeTime}, bạn hãy xem khung giờ khác nhé 😃.");
        await removeCart();
        // if (e.response?.data['data'] != null) {
        //   // orderAmount = OrderAmountDTO.fromJson(e.response.data['data']);
        // }
        setState(ViewStatus.Completed);
      } else if (e.response?.statusCode == 404) {
        if (e.response?.data["error"] != null) {
          setCart(currentCart!);
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
      stationList = await _stationDAO?.getStationList(DESTINATIONID);
      setState(ViewStatus.Completed);
    } catch (e) {
      stationList = null;
      setState(ViewStatus.Error);
    }
  }

  Future<void> addStationToCart(StationDTO? dto) async {
    if (orderDTO!.stationDTO != null) {
      orderDTO!.stationDTO = null;
      orderDTO!.stationDTO = dto;
    } else {
      orderDTO!.stationDTO = dto;
    }
    notifyListeners();
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
        // LocationDTO location =
        //     campusDTO.locations.firstWhere((element) => element.isSelected);

        // DestinationDTO destination =
        //     location.destinations.firstWhere((element) => element.isSelected);
        OrderStatus? result = await _dao?.createOrders(orderDTO!);
        // await Get.find<AccountViewModel>().fetchUser();
        if (result!.statusCode == 200) {
          await fetchStatus(result.order!.id!);

          await removeCart();
          await deletePartyCode();
          final partyModel = Get.find<PartyOrderViewModel>();
          await partyModel.isLinkedParty(false);
          // hideDialog();
          await showStatusDialog("assets/images/icon-success.png", 'Success',
              'Bạn đã đặt hàng thành công');
          // await Get.find<OrderHistoryViewModel>().getOrders();
          //////////
          // await Future.delayed(const Duration(microseconds: 500));

          ///
          // await Get.find<OrderHistoryViewModel>().getNewOrder();
          //////////
          PartyOrderViewModel party = Get.find<PartyOrderViewModel>();
          productRecomend = null;
          orderDTO = null;
          party.partyOrderDTO = null;
          party.partyCode = null;
          // await setPartyCode(party.partyCode!);
          Get.offAndToNamed(
            RouteHandler.CHECKING_ORDER_SCREEN,
            arguments: result.order,
          );
          // Get.offAndToNamed(RoutHandler.NAV);
          // prepareOrder();
          // Get.back(result: true);
        } else {
          hideDialog();
          await showStatusDialog(
              "assets/images/error.png", result.code!, result.message!);
        }
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

  Future<void> fetchStatus(String orderId) async {
    try {
      setState(ViewStatus.Loading);
      orderStatusDTO = await _dao!.fetchOrderStatus(orderId);
      setState(ViewStatus.Completed);
    } catch (e) {
      orderStatusDTO = null;
      setState(ViewStatus.Completed);
    }
  }

  Future<void> deleteItem(OrderDetails item) async {
    HomeViewModel? home = Get.find<HomeViewModel>();
    ProductDetailViewModel? productViewModel =
        Get.find<ProductDetailViewModel>();

    // showLoadingDialog();
    print("Delete item...");
    bool result;
    ProductDTO product =
        new ProductDTO(id: item.productId, productName: item.productName);
    CartItem cartItem = new CartItem(item.productId, item.quantity, null);
    result = await removeItemFromCart(cartItem);
    await removeItemFromMart(cartItem);
    print("Result: $result");
    if (result) {
      await AnalyticsService.getInstance()
          ?.logChangeCart(product, item.quantity, false);
      // currentCart = await getCart();
      // CartItem itemInCart = new CartItem(
      //     currentCart!.orderDetails![0].productId,
      //     currentCart!.orderDetails![0].quantity - 1,
      //     null);
      // await productViewModel.processCart(
      //     currentCart!.orderDetails![0].productId,
      //     1,
      //     root!.selectedTimeSlot!.id);
      // Get.back(result: true);
      await prepareOrder();
    } else {
      await removeItemFromCart(cartItem);
      currentCart = await getCart();
      await prepareOrder();
    }
  }

  Future<void> updateQuantity(OrderDetails item) async {
    final home = Get.find<HomeViewModel>();
    final productViewModel = Get.find<ProductDetailViewModel>();
    // final root = Get.find<RootViewModel>();
    // showLoadingDialog();
    // if (item.master.type == ProductType.GIFT_PRODUCT) {
    //   int originalQuantity = 0;
    //   AccountViewModel account = Get.find<AccountViewModel>();
    //   if (account.currentUser == null) {
    //     await account.fetchUser();
    //   }
    //   double totalBean = account.currentUser.point;

    //   currentCart.items.forEach((element) {
    //     if (element.master.type == ProductType.GIFT_PRODUCT) {
    //       if (element.master.id != item.master.id) {
    //         totalBean -= (element.master.price * element.quantity);
    //       } else {
    //         originalQuantity = element.quantity;
    //       }
    //     }
    //   });

    //   if (totalBean < (item.master.price * item.quantity)) {
    //     await showStatusDialog("assets/images/global_error.png",
    //         "Không đủ bean", "Số bean hiện tại không đủ");
    //     item.quantity = originalQuantity;
    //     hideDialog();
    //     return;
    //   }
    // }
    final itemInCart = currentCart!.orderDetails!
        .firstWhere((element) => element.productId == item.productId);
    if (itemInCart.quantity > item.quantity) {
      CartItem cartItem = new CartItem(item.productId, item.quantity - 1, null);

      await updateItemFromMart(cartItem);
      await updateItemFromCart(cartItem);
      await productViewModel.processCart(
          item.productId, 1, root!.selectedTimeSlot!.id);
    } else {
      await productViewModel.processCart(
          item.productId, 1, root!.selectedTimeSlot!.id);
    }

    // await updateItemFromCart(cartItem);
    await prepareOrder();
    // notifyListeners();
  }

  Future<void> getCurrentCart() async {
    try {
      setState(ViewStatus.Loading);
      RootViewModel root = Get.find<RootViewModel>();
      currentCart = await getCart();
      currentCart?.addProperties(root.isNextDay == true ? 2 : 1);
      // currentCart?.addProperties(2);
      if (currentCart == null) {
        notifier.value = 0;
      }
      notifier.value = currentCart!.itemQuantity();

      setState(ViewStatus.Completed);

      notifyListeners();
    } catch (e) {
      currentCart = null;
      setState(ViewStatus.Completed);
    }
  }

  Future<void> removeCart() async {
    await deleteCart();
    await deleteMart();
    currentCart = await getCart();
    notifier.value = 0;

    setState(ViewStatus.Completed);
    notifyListeners();
  }
}
