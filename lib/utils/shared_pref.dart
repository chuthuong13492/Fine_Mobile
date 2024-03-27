import 'dart:convert';
import 'package:fine/Model/DTO/DestinationDTO.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/setup.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/DTO/ConfirmCartDTO.dart';

Future<bool> setIsFirstOnboard(bool isFirstOnboard) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setBool('isFirstOnBoard', isFirstOnboard);
}

Future<bool?> getIsFirstOnboard() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isFirstOnBoard');
}

Future<void> setStore(DestinationDTO dto) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (dto != null) {
    print(dto.toJson().toString());
    prefs.setString('STORE', jsonEncode(dto.toJson()));
  }
}

Future<DestinationDTO?> getStore() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? encodedCart = prefs.getString('STORE');
  if (encodedCart != null) {
    return DestinationDTO.fromJson(jsonDecode(encodedCart));
  }
  return null;
}

Future<void> setCart(Cart cart) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('CART', jsonEncode(cart.toJson()));
}

Future<void> setMart(ConfirmCart cart) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('MART', jsonEncode(cart.toCheckCartJsonAPi()));
}

Future<void> setPartyCart(ConfirmCart cart) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('PARTY_CART', jsonEncode(cart.toCheckCartJsonAPi()));
}

Future<bool> setPartyCode(String code) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString('PARTY_CODE', code);
}

Future<Cart?> getCart() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? encodedCart = prefs.getString('CART');
  if (encodedCart != null) {
    Cart cart = Cart.fromJson(jsonDecode(encodedCart));
    return cart;
  }
  return null;
}

Future<ConfirmCart?> getMart() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? encodedCart = prefs.getString('MART');
  if (encodedCart != null) {
    ConfirmCart cart = ConfirmCart.fromJson(jsonDecode(encodedCart));
    return cart;
  }
  return null;
}

Future<ConfirmCart?> getPartyCart() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? encodedCart = prefs.getString('PARTY_CART');
  if (encodedCart != null) {
    ConfirmCart cart = ConfirmCart.fromJson(jsonDecode(encodedCart));
    return cart;
  }
  return null;
}

Future<String?> getPartyCode() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('PARTY_CODE');
}

Future<void> addItemToCart(
    CartItem item, String timeSlotId, bool isNextDay) async {
  Cart? cart = await getCart();
  if (cart == null) {
    cart = new Cart(timeSlotId: timeSlotId, isNextDay: isNextDay);
  }
  cart.addItem(item);
  await setCart(cart);
}

Future<void> addItemToMart(ConfirmCartItem item) async {
  ConfirmCart? cart = await getMart();
  // if (cart != null) {
  //   cart = ConfirmCart(timeSlotId: timeSlotId);
  // }
  cart!.addItem(item);
  await setMart(cart);
}

Future<void> addPartyItem(ConfirmCartItem item, String timeSlotId) async {
  ConfirmCart? cart = await getPartyCart();
  if (cart == null) {
    cart = ConfirmCart(timeSlotId: timeSlotId);
  }
  cart.addItem(item);
  await setPartyCart(cart);
}

Future<bool> removeItemFromCart(CartItem item) async {
  Cart? cart = await getCart();
  if (cart == null) {
    return false;
  }
  cart.removeItem(item);
  print("Delete success!");
  print("Items: ${cart.items!.length.toString()}");
  if (cart.items!.isEmpty) {
    await deleteCart();
    return true;
  } else {
    await setCart(cart);
    return false;
  }
}

Future<bool> removeItemFromParty(ConfirmCartItem item) async {
  ConfirmCart? cart = await getPartyCart();
  if (cart == null) {
    return false;
  }
  cart.removeItem(item);
  await setPartyCart(cart);
  return false;
  // if (cart.orderDetails?.length == 0) {
  //   await deleteMart();
  //   return true;
  // } else {
  //   await setMart(cart);
  //   return false;
  // }
}

Future<bool> removeItemFromMart(ConfirmCartItem item) async {
  ConfirmCart? cart = await getMart();
  if (cart == null) {
    return false;
  }
  cart.removeItem(item);
  await setMart(cart);
  return false;
  // if (cart.orderDetails?.length == 0) {
  //   await deleteMart();
  //   return true;
  // } else {
  //   await setMart(cart);
  //   return false;
  // }
}

Future<void> deleteCart() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove("CART");
}

Future<void> deleteMart() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("MART");
}

Future<void> deletePartCart() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("PARTY_CART");
}

Future<void> deletePartyCode() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("PARTY_CODE");
}

Future<void> updateItemFromCart(CartItem item) async {
  Cart? cart = await getCart();
  if (cart == null) {
    return;
  }
  cart.updateQuantity(item);
  await setCart(cart);
  print("Save");
}

Future<void> updateCheckItemFromCart(CartItem item, bool check) async {
  Cart? cart = await getCart();
  if (cart == null) {
    return;
  }
  cart.updateCheck(item, check);
  await setCart(cart);
}

Future<void> updateAddedItemtoCart(CartItem item, bool add) async {
  Cart? cart = await getCart();
  if (cart == null) {
    return;
  }
  cart.updateIsAdded(item, add);
  await setCart(cart);
}

Future<void> updateItemFromMart(ConfirmCartItem item) async {
  ConfirmCart? cart = await getMart();
  if (cart == null) {
    return;
  }
  cart.updateQuantity(item);
  print(
      "Updated Quantity: ${cart.orderDetails?.firstWhere((element) => element.findCartItem(item)).quantity}");
  await setMart(cart);
}

Future<bool> setFCMToken(String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString('FCMToken', value);
}

Future<String?> getFCMToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('FCMToken');
}

Future<bool> setToken(String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String expireDate = DateFormat("yyyy-MM-dd hh:mm:ss")
      .format(DateTime.now().add(Duration(days: 30)));
  prefs.setString('expireDate', expireDate.toString());
  return prefs.setString('token', value);
}

Future<bool> expireToken() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime tempDate = new DateFormat("yyyy-MM-dd hh:mm:ss")
        .parse(prefs.getString('expireDate')!);
    return tempDate.compareTo(DateTime.now()) < 0;
  } catch (e) {
    return true;
  }
}

Future<String?> getToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<void> removeALL() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  // Get.reset(clearRouteBindings: true);
  // createRouteBindings();
  await setIsFirstOnboard(false);
}
// Future<bool> setUser(A value) async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.setString('token', value);
// }

// Future<String> getToken() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.getString('token');
// }
