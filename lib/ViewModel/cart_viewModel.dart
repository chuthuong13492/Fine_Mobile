import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/product_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Constant/view_status.dart';

import '../Model/DAO/StoreDAO.dart';
import '../Model/DTO/ConfirmCartDTO.dart';
import '../Model/DTO/OrderDTO.dart';
import '../Service/analytic_service.dart';
import '../Utils/shared_pref.dart';
import 'order_viewModel.dart';

class CartViewModel extends BaseModel {
  StoreDAO? _storeDAO;
  final root = Get.find<RootViewModel>();
  Cart? currentCart;
  // List<bool> isCheckedList = List.generate(0, (index) => false);
  List<ReOrderDTO>? reOrderList;
  double total = 0, fixTotal = 0, extraTotal = 0;
  int quantityChecked = 0;
  bool? isSelected = false;
  String? code;
  final ValueNotifier<int> notifier = ValueNotifier(0);

  CartViewModel() {
    _storeDAO = StoreDAO();
    currentCart = null;
  }

  Future<void> changeValueChecked(bool value, CartItem cartItem) async {
    try {
      if (value == true) {
        bool? isAdded = await Get.find<ProductDetailViewModel>()
            .processCart(cartItem.productId, cartItem.quantity);

        await updateCheckItemFromCart(cartItem, isAdded!);
        if (isAdded == true) {
          getTotalQuantity(isAdded, cartItem);
        }
      } else {
        ConfirmCartItem item =
            ConfirmCartItem(cartItem.productId, cartItem.quantity, "");
        await removeItemFromMart(item);
        await updateCheckItemFromCart(cartItem, value);
        await getTotalQuantity(value, cartItem);
      }
      currentCart = await getCart();
      isSelected =
          currentCart!.items!.any((element) => element.isChecked == true);

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> getTotalQuantity(bool value, CartItem cartItem) async {
    currentCart = await getCart();
    bool isTrue =
        currentCart!.items!.any((element) => element.isChecked == true);
    if (isTrue) {
      if (total == null) {
        quantityChecked = cartItem.quantity;
        total = cartItem.fixTotal!;
      } else {
        if (value == false) {
          quantityChecked -= cartItem.quantity;

          total -= cartItem.fixTotal!;
        } else {
          quantityChecked += cartItem.quantity;

          total += cartItem.fixTotal!;
        }
      }
    } else {
      quantityChecked = 0;
      total = 0;
    }
  }

  Future<void> orderPayment() async {
    try {
      ConfirmCart? confirmCart = await getMart();
      if (confirmCart != null) {
        await getProductRecommend();
        await Future.delayed(const Duration(microseconds: 500));
        await Get.find<OrderViewModel>().prepareOrder();
        final error = Get.find<OrderViewModel>().errorMessage;
        if (error == null) {
          Get.toNamed(RouteHandler.ORDER);
        }
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> getProductRecommend() async {
    ConfirmCart? cart = await getMart();
    if (cart != null) {
      if (cart.orderDetails!.isNotEmpty) {
        ConfirmCartItem itemInCart = ConfirmCartItem(
            cart.orderDetails![0].productId,
            cart.orderDetails![0].quantity - 1,
            null);

        await updateItemFromMart(itemInCart);
        cart = await getMart();
        await Get.find<ProductDetailViewModel>()
            .processCart(cart!.orderDetails![0].productId, 1);
      } else {
        Get.find<OrderViewModel>().productRecomend = [];
      }
    }
  }

  Future<void> getReOrder() async {
    try {
      setState(ViewStatus.Loading);
      RootViewModel root = Get.find<RootViewModel>();
      var currentTimeSlot = root.selectedTimeSlot;
      // var currentMenu = root.selectedMenu;
      if (root.status == ViewStatus.Error) {
        setState(ViewStatus.Error);
        return;
      }
      if (currentTimeSlot != null) {
        reOrderList = await _storeDAO?.getReOrder(currentTimeSlot.id);
      }

      await Future.delayed(const Duration(milliseconds: 500));
      setState(ViewStatus.Completed);
    } catch (e) {
      setState(ViewStatus.Completed);
    }
  }

  Future<void> getCurrentCart() async {
    try {
      setState(ViewStatus.Loading);
      await Future.delayed(const Duration(milliseconds: 500));
      currentCart = await getCart();

      if (currentCart == null) {
        notifier.value = 0;
        quantityChecked = 0;
        total = 0;
      } else {
        notifier.value = currentCart!.itemQuantity();
        final listChecked = currentCart?.items
            ?.where((element) => element.isChecked == true)
            .toList();
        quantityChecked = 0;
        total = 0;
        for (var item in listChecked!) {
          total += item.fixTotal!;
          quantityChecked += item.quantity;
        }
      }
      code = await getPartyCode();
      isSelected =
          currentCart!.items!.any((element) => element.isChecked == true);
      if (isSelected == false) {
        await deleteMart();
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      deleteCart();
      currentCart = await getCart();
      setState(ViewStatus.Completed);
    }
  }

  Future<void> removeCart() async {
    await deleteCart();
    await deleteMart();
    total = 0;
    quantityChecked = 0;
    notifier.value = 0;
    currentCart = await getCart();
    notifyListeners();
  }

  Future<void> updateItem(CartItem item, int index, bool isIncrease) async {
    // if (item.isChecked == true) {
    //   if (isIncrease == true) {
    //     total -= item.fixTotal!;
    //     quantityChecked -= (item.quantity - 1);
    //   } else {
    //     total -= item.fixTotal!;
    //     quantityChecked -= (item.quantity + 1);
    //   }
    // }

    fixTotal = item.price! * item.quantity;
    final cartItem = CartItem(item.productId, item.productName, item.imgUrl,
        item.size, item.price, fixTotal, item.quantity, false);
    await updateItemFromCart(cartItem);
    ConfirmCartItem confirmCartItem =
        ConfirmCartItem(item.productId, item.quantity, "");
    await removeItemFromMart(confirmCartItem);
    currentCart = await getCart();
    notifier.value = currentCart!.itemQuantity();
    if (currentCart == null) {
      notifier.value = 0;
      quantityChecked = 0;
      total = 0;
    } else {
      final listChecked = currentCart?.items
          ?.where((element) => element.isChecked == true)
          .toList();
      quantityChecked = 0;
      total = 0;
      for (var item in listChecked!) {
        total += item.fixTotal!;
        quantityChecked += item.quantity;
      }
    }
    notifyListeners();
  }

  Future<void> deleteItem(CartItem item, int index) async {
    // showLoadingDialog();
    print("Delete item...");
    bool result;

    result = await removeItemFromCart(item);
    print("Result: $result");
    if (result) {
      currentCart = await getCart();
      if (currentCart == null) {
        total = 0;
        quantityChecked = 0;
        notifier.value = 0;
      } else {
        notifier.value = currentCart!.itemQuantity();
      }
      quantityChecked -= item.quantity;
      total -= item.fixTotal!;
      ConfirmCartItem cartItem =
          ConfirmCartItem(item.productId, item.quantity, "");
      await removeItemFromMart(cartItem);
    } else {
      currentCart = await getCart();
      if (currentCart == null) {
        total = 0;
        quantityChecked = 0;
        notifier.value = 0;
      } else {
        notifier.value = currentCart!.itemQuantity();
      }
      quantityChecked -= item.quantity;
      total -= item.fixTotal!;
      ConfirmCartItem cartItem =
          ConfirmCartItem(item.productId, item.quantity, "");
      await removeItemFromMart(cartItem);
    }
    notifyListeners();
  }
}
