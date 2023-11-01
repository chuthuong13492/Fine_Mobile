import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/product_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:get/get.dart';

import '../Constant/view_status.dart';

import '../Model/DTO/ConfirmCartDTO.dart';
import '../Service/analytic_service.dart';
import '../Utils/shared_pref.dart';
import 'order_viewModel.dart';

class CartViewModel extends BaseModel {
  final root = Get.find<RootViewModel>();
  Cart? currentCart;
  List<bool> isCheckedList = List.generate(0, (index) => false);
  double total = 0, fixTotal = 0, extraTotal = 0;
  int quantityChecked = 0;

  CartViewModel() {
    currentCart = null;
  }

  Future<void> changeValueChecked(
      bool value, int index, CartItem cartItem) async {
    try {
      if (value == true) {
        bool? isAdded = await Get.find<ProductDetailViewModel>()
            .processCart(cartItem.productId, cartItem.quantity);
        isCheckedList[index] = isAdded!;
        if (isAdded != false) {
          getTotalQuantity(isAdded, cartItem);
        }
      } else {
        ConfirmCartItem item =
            ConfirmCartItem(cartItem.productId, cartItem.quantity, "");
        await removeItemFromMart(item);
        isCheckedList[index] = value;
        getTotalQuantity(value, cartItem);
      }

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  void getTotalQuantity(bool value, CartItem cartItem) {
    bool isTrue = isCheckedList.any((element) => element == true);
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
        Get.toNamed(RouteHandler.ORDER);
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> getProductRecommend() async {
    ConfirmCart? cart = await getMart();
    if (cart != null) {
      if (cart.orderDetails!.isNotEmpty) {
        ConfirmCartItem itemInCart = new ConfirmCartItem(
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

  Future<void> getCurrentCart() async {
    try {
      setState(ViewStatus.Loading);
      currentCart = await getCart();
      if (isCheckedList.isEmpty) {
        isCheckedList =
            List.generate(currentCart!.items!.length, (index) => false);
        await deleteMart();
      } else {
        if (currentCart!.items!.length > isCheckedList.length) {
          isCheckedList.add(false);
        }
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
    isCheckedList = List.generate(0, (index) => false);
    currentCart = await getCart();
    notifyListeners();
  }

  Future<void> updateItem(CartItem item, int index, bool isIncrease) async {
    if (isCheckedList[index] == true) {
      if (isIncrease == true) {
        total -= item.fixTotal!;
        quantityChecked -= (item.quantity - 1);
      } else {
        total -= item.fixTotal!;
        quantityChecked -= (item.quantity + 1);
      }
    }
    isCheckedList[index] = false;

    fixTotal = item.price! * item.quantity;
    final cartItem = CartItem(item.productId, item.productName, item.imgUrl,
        item.size, item.price, fixTotal, item.quantity);
    await updateItemFromCart(cartItem);
    ConfirmCartItem confirmCartItem =
        ConfirmCartItem(item.productId, item.quantity, "");
    await removeItemFromMart(confirmCartItem);
    currentCart = await getCart();

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
      }
      isCheckedList = [];
    } else {
      currentCart = await getCart();
      if (currentCart == null) {
        total = 0;
        quantityChecked = 0;
      }
      isCheckedList.removeAt(index);
    }

    notifyListeners();
  }
}
