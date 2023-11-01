import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/DestinationDAO.dart';
import 'package:fine/Model/DAO/ProductDAO.dart';
import 'package:fine/Model/DAO/StoreDAO.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/blogs_viewModel.dart';
import 'package:fine/ViewModel/cart_viewModel.dart';
import 'package:fine/ViewModel/category_viewModel.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/login_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/product_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../Model/DTO/ConfirmCartDTO.dart';

class RootViewModel extends BaseModel {
  Position? currentPosition;
  String? currentLocation;
  String? lat;
  String? long;
  AccountDTO? user;
  DestinationDTO? currentStore;
  List<DestinationDTO>? campusList;
  TimeSlotDTO? selectedTimeSlot;
  List<TimeSlotDTO>? listTimeSlot;
  List<TimeSlotDTO>? previousTimeSlotList;

  List<TimeSlotDTO>? listAvailableTimeSlot;
  ProductDAO? _productDAO;

  DestinationDAO? _destinationDAO;
  bool changeAddress = false;
  bool isNextDay = false;
  bool isOnClick = false;
  final ValueNotifier<bool> notifier = ValueNotifier(false);
  // final ValueNotifier<List<TimeSlotDTO>> notifier = ValueNotifier([]);

  RootViewModel() {
    _productDAO = ProductDAO();
    _destinationDAO = DestinationDAO();
    previousTimeSlotList = [];
    selectedTimeSlot = null;
  }
  Future refreshMenu() async {
    // fetchStore();
    await Get.find<HomeViewModel>().getMenus();
    await Get.find<HomeViewModel>().getProductListInTimeSlot();
    await Get.find<HomeViewModel>().getReOrder();
  }

  Future startUp() async {
    // await Get.find<RootViewModel>().getCurrentLocation();
    // liveLocation();
    // await Get.find<RootViewModel>().liveLocation();

    await Get.find<AccountViewModel>().fetchUser();
    await Get.find<RootViewModel>().getUserDestination();
    await Get.find<RootViewModel>().getListTimeSlot();
    await Get.find<HomeViewModel>().getMenus();
    await Get.find<HomeViewModel>().getProductListInTimeSlot();

    Get.find<HomeViewModel>().getReOrder();
    Get.find<PartyOrderViewModel>().getPartyOrder();
    Get.find<BlogsViewModel>().getBlogs();
    await checkCartAvailable();
    // await Get.find<RootViewModel>().getProductRecommend();
    Get.find<RootViewModel>().checkHasParty();
    Get.find<PartyOrderViewModel>().getCoOrderStatus();
  }

  Future<void> getProductRecommend() async {
    ConfirmCart? cart = await getMart();
    await deleteMart();
    if (cart != null) {
      if (cart.orderDetails!.isNotEmpty) {
        ConfirmCartItem itemInCart = new ConfirmCartItem(
            cart.orderDetails![0].productId,
            cart.orderDetails![0].quantity - 1,
            null);

        await updateItemFromMart(itemInCart);
        cart = await getMart();
        await setMart(cart!);
        await Get.find<ProductDetailViewModel>()
            .processCart(cart.orderDetails![0].productId, 1);
      } else {
        Get.find<OrderViewModel>().productRecomend = [];
      }
    }
  }

  Future<void> changeDay(int index) async {
    final cart = await getCart();
    // final cart = Get.find<OrderViewModel>().currentCart;
    int? option = 1;
    PartyOrderViewModel partyOrderViewModel = Get.find<PartyOrderViewModel>();
    if (partyOrderViewModel.partyOrderDTO != null) {
      option = await showOptionDialog("Đổi ngày sẽ xóa đơn nhóm á!!!");
    } else {
      if (cart != null) {
        option = await showOptionDialog("Đổi ngày sẽ xóa giỏ hàng á!!!");
      }
    }
    if (option == 1) {
      if (index == 0) {
        isNextDay = false;
      } else {
        isNextDay = true;
      }
      // option = 0;
      isOnClick = true;
      deletePartyCode();
      await deleteCart();
      Get.find<CartViewModel>().getCurrentCart();
      // await Get.find<OrderViewModel>().removeCart();
      await getListTimeSlot();
    }
  }

  Future<void> checkHasParty() async {
    final party = Get.find<PartyOrderViewModel>();
    final partyCode = await getPartyCode();
    if (partyCode != null) {
      if (partyCode.contains("LPO")) {
        party.isLinked = true;
      } else {
        if (party.partyOrderDTO != null) {
          notifier.value = true;
          await Get.find<PartyOrderViewModel>().getCoOrderStatus();
        } else {
          notifier.value = false;
        }
      }
    } else {
      party.isLinked = false;
      notifier.value = false;
    }
    notifyListeners();
  }

  Future<ProductDTO?> openProductShowSheet(String productId) async {
    ProductDTO? item;
    try {
      item = await _productDAO?.getProductDetail(productId);
      return item;
    } catch (e) {
      item = null;
      await showErrorDialog(errorTitle: "Không tìm thấy sản phẩm");
      hideDialog();
    }
    return null;
  }

  Future<void> openProductDetail(String productID,
      {showOnHome = true, fetchDetail = false}) async {
    Get.put<bool>(
      showOnHome,
      tag: "showOnHome",
    );
    try {
      ProductDTO? item;
      if (fetchDetail) {
        showLoadingDialog();
        item = await _productDAO?.getProductDetail(productID);
      }

      await Get.toNamed(RouteHandler.PRODUCT_DETAIL, arguments: item);
      //
      hideDialog();
      await Get.delete<bool>(
        tag: "showOnHome",
      );

      notifyListeners();
    } catch (e) {
      await showErrorDialog(errorTitle: "Không tìm thấy sản phẩm");
      hideDialog();
    }
  }

  Future<void> getListDestination() async {
    try {
      setState(ViewStatus.Loading);
      DestinationDAO campusDAO = DestinationDAO();
      campusList = await campusDAO.getDestinationIdList();
      setState(ViewStatus.Completed);
    } catch (e) {
      campusList = null;
      setState(ViewStatus.Error);
    }
  }

  Future<void> getUserDestination() async {
    try {
      setState(ViewStatus.Loading);
      final userDestination =
          await _destinationDAO!.getUserDestination(DESTINATIONID);
      currentStore = userDestination;
      await setStore(currentStore!);
      setState(ViewStatus.Completed);
    } catch (e) {
      setState(ViewStatus.Error);
    }
  }

  Future<void> setCurrentDestination(DestinationDTO destinationDTO) async {
    showLoadingDialog();
    currentStore = destinationDTO;
    await setStore(currentStore!);
    setState(ViewStatus.Completed);
    await startUp();
    hideDialog();
    Get.toNamed(RouteHandler.NAV);
  }

  Future<void> navParty() async {
    OrderViewModel orderViewModel = Get.find<OrderViewModel>();

    PartyOrderViewModel party = Get.find<PartyOrderViewModel>();
    await party.getPartyOrder();
    if (party.partyOrderDTO != null &&
        party.partyOrderDTO!.timeSlotDTO!.id == selectedTimeSlot!.id) {
      await party.getPartyOrder();
      await Future.delayed(const Duration(microseconds: 500));
      // if (party.isPreCoOrder == true && party.orderDTO != null) {
      //   Get.toNamed(RouteHandler.PREPARE_CO_ORDER, arguments: party.orderDTO);
      // } else {
      Get.toNamed(RouteHandler.PARTY_ORDER_SCREEN);
      // }

      // hideDialog();
    } else {
      if (party.partyOrderDTO != null) {
        if (party.partyOrderDTO!.timeSlotDTO!.id != selectedTimeSlot!.id) {
          int option = 0;
          if (isCurrentTimeSlotAvailable()) {
            option = await showOptionDialog(
                "Đơn nhóm của bạn đang ở khung giờ ${party.partyOrderDTO!.timeSlotDTO!.arriveTime} Bạn vui lòng đổi sang khung giờ này để tham gia đơn nhóm nhé");
          } else {
            await deletePartyCode();
            party.partyOrderDTO = null;
            // await orderViewModel.removeCart();
          }
          await Future.delayed(const Duration(microseconds: 500));

          if (option != 1) {
            return;
          }
          selectedTimeSlot = party.partyOrderDTO!.timeSlotDTO!;
          await refreshMenu();
          // if (party.isPreCoOrder == true && party.orderDTO != null) {
          //   Get.toNamed(RouteHandler.PREPARE_CO_ORDER,
          //       arguments: party.orderDTO);
          // } else {
          Get.toNamed(RouteHandler.PARTY_ORDER_SCREEN);
          // }
          notifyListeners();
        }
      }
    }
  }

  Future<void> checkCartAvailable() async {
    DestinationDAO campusDAO = DestinationDAO();
    final _cartViewModel = Get.find<CartViewModel>();
    try {
      await _cartViewModel.getCurrentCart();
      final cart = _cartViewModel.currentCart;
      if (cart != null) {
        if (cart.isNextDay == false) {
          isNextDay = false;
          if (selectedTimeSlot!.id == cart.timeSlotId) {
            selectedTimeSlot = previousTimeSlotList
                ?.firstWhere((element) => element.id == cart.timeSlotId);
          } else {
            bool isCartTimeSlotAvailable = previousTimeSlotList!
                .any((element) => element.id == cart.timeSlotId);
            if (isCartTimeSlotAvailable) {
              selectedTimeSlot = previousTimeSlotList
                  ?.firstWhere((element) => element.id == cart.timeSlotId);
            } else {
              selectedTimeSlot = previousTimeSlotList![0];
              await deleteCart();
              await _cartViewModel.getCurrentCart();
            }
          }
          await refreshMenu();
          notifyListeners();
        } else {
          isNextDay = true;
          isOnClick = true;
          await getListTimeSlot();
        }
      }
      notifyListeners();
    } catch (e) {
      await deleteCart();
      await _cartViewModel.getCurrentCart();
    }
  }

  Future<void> navOrder() async {
    final cart = await getCart();
    // await orderViewModel.getCurrentCart();
    int option = 1;
    if (cart != null) {
      if (cart.timeSlotId != selectedTimeSlot!.id) {
        bool isTimeSlotInList = previousTimeSlotList!
            .any((element) => element.id == cart.timeSlotId);
        TimeSlotDTO? cartTimeSlot;
        if (isTimeSlotInList) {
          cartTimeSlot = previousTimeSlotList
              ?.firstWhere((element) => element.id!.contains(cart.timeSlotId!));
          if (cartTimeSlot != null) {
            option = await showOptionDialog(
                "Giỏ hàng của bạn đang ở khung giờ ${cartTimeSlot.arriveTime} Bạn vui lòng đổi sang khung giờ này để đặt hàng nhé");
          }
        } else {
          // hideDialog();

          option = await showOptionDialog(
              "Giỏ hàng đang ở ngày khác. Bạn vui lòng đổi sang Hôm Sau này để đặt hàng nhé");
          if (option == 1) {
            // showLoadingDialog();
            isNextDay = true;
            isOnClick = true;

            await getListTimeSlot();
            cartTimeSlot = previousTimeSlotList?.firstWhere(
                (element) => element.id!.contains(cart.timeSlotId!));
            selectedTimeSlot = cartTimeSlot;
            notifyListeners();
            return;
          }
        }

        if (option != 1) {
          return;
        }
        selectedTimeSlot = cartTimeSlot;
        await refreshMenu();
        notifyListeners();
        await Future.delayed(const Duration(microseconds: 500));
        hideDialog();
        await Get.toNamed(RouteHandler.CART_SCREEN);
      } else {
        // await orderViewModel.prepareOrder();

        await Future.delayed(const Duration(microseconds: 500));
        // hideDialog();
        await Get.toNamed(RouteHandler.CART_SCREEN);
      }
    } else {
      showStatusDialog(
          "assets/images/empty-cart-ipack.png",
          "Giỏ hàng đang trống kìaaa",
          "Hiện tại giỏ của bạn đang trống , bạn hãy thêm sản phẩm vào nhé 😃.");
    }
  }

  Future<void> getListTimeSlot() async {
    DestinationDAO campusDAO = DestinationDAO();
    listTimeSlot = await campusDAO.getTimeSlot(DESTINATIONID);
    listAvailableTimeSlot = null;
    if (isNextDay == false) {
      for (int i = 0; i < listTimeSlot!.length; i++) {
        TimeSlotDTO element = listTimeSlot![i];
        if (isListTimeSlotAvailable(element)) {
          listTimeSlot!.removeAt(i);
          i--;
        }
      }

      if (previousTimeSlotList!.isEmpty) {
        previousTimeSlotList = listTimeSlot!;
        selectedTimeSlot = previousTimeSlotList![0];
        await refreshMenu();
        notifyListeners();
      } else {
        if (listsAreEqual(listTimeSlot!, previousTimeSlotList!)) {
          previousTimeSlotList = listTimeSlot!;
          selectedTimeSlot = previousTimeSlotList![0];
          await refreshMenu();
          // if (Get.currentRoute == "/order") {
          //   await showStatusDialog("assets/images/error.png", "Oops!",
          //       "Đã qua khung giờ mất ruìi");
          //   // await Get.find<OrderViewModel>().removeCart();
          //   Get.back();
          // } else {
          //   final cart = await getCart();
          //   if (cart != null) {
          //     // await Get.find<OrderViewModel>().removeCart();
          //   }
          // }
          notifyListeners();
        } else {
          previousTimeSlotList = listTimeSlot;
          if (isOnClick == true) {
            isOnClick = false;
            selectedTimeSlot = previousTimeSlotList![0];
            await refreshMenu();
            notifyListeners();
          }
        }
      }
    } else {
      if (isOnClick == true) {
        isOnClick = false;
        final firstTimeSlot = listTimeSlot![0];
        previousTimeSlotList?.clear();
        previousTimeSlotList?.add(firstTimeSlot);
        selectedTimeSlot = firstTimeSlot;
        await refreshMenu();
        notifyListeners();
      }
    }
  }

  Future<void> showProductByStore(SupplierDTO? supplierDTO,
      {showOnHome = true, fetchDetail = false}) async {
    Get.put<bool>(
      showOnHome,
      tag: "showOnHome",
    );
    try {
      if (fetchDetail) {
        showLoadingDialog();
        List<ProductDTO>? productDTO;
        productDTO =
            await _productDAO?.getProductsInMenuByStoreId(supplierDTO?.id);
      }
      await Get.toNamed(RouteHandler.PRODUCT_DETAIL, arguments: supplierDTO);
      //
      hideDialog();
      await Get.delete<bool>(
        tag: "showOnHome",
      );
      notifyListeners();
    } catch (e) {
      await showErrorDialog(errorTitle: "Không tìm thấy sản phẩm");
      hideDialog();
    }
  }

  Future<void> confirmTimeSlot(TimeSlotDTO? timeSlot) async {
    int option = 1;
    if (timeSlot?.id != selectedTimeSlot?.id) {
      final cart = await getCart();
      PartyOrderViewModel party = Get.find<PartyOrderViewModel>();

      if (party.partyOrderDTO != null) {
        showStatusDialog('assets/images/logo2.png', "Đơn nhóm",
            "Bạn đang trong đơn nhóm nên hong thể đổi được khung giờ nè!");
        option = 0;
      } else {
        if (cart != null) {
          option = await showOptionDialog(
              "Bạn có chắc không? Đổi khung giờ rồi là giỏ hàng bị xóa đó!!");
        }
      }

      if (option == 1) {
        // showLoadingDialog();
        selectedTimeSlot = timeSlot;
        deleteCart();
        deleteMart();
        Get.find<CartViewModel>().getCurrentCart();
        deletePartyCode();
        party.partyOrderDTO = null;
        await refreshMenu();
        // hideDialog();
        notifyListeners();
      }
    }
  }

  Future<TimeSlotOptionResult> checkTimeSlotOption(TimeSlotDTO? timeSlot,
      TimeSlotDTO? selectedTimeSlot, String? text) async {
    int option;
    bool isNextDay;

    bool isAvailableForNextDay =
        isTimeSlotAvailableForNextDay(timeSlot, selectedTimeSlot);
    bool isAvailableForCurrentDay = isTimeSlotAvailable(timeSlot);

    if (!isAvailableForNextDay) {
      if (isAvailableForCurrentDay) {
        option = 1;
        isNextDay = false;
      } else {
        if (timeSlot!.id! == "7d2b363a-18fa-45e5-bfc9-0f52ef705524") {
          option = await showOptionDialog(text!);
          isNextDay = true;
        } else {
          await showStatusDialog("assets/images/error.png", "Opps",
              "Hiện tại khung giờ bạn chọn đã chốt đơn. Bạn vui lòng xem khung giờ khác nhé 😓 ");
          option = 0;
          isNextDay = false;
        }
      }
    } else {
      if (!isAvailableForCurrentDay) {
        await showStatusDialog("assets/images/error.png", "Opps",
            "Hiện tại khung giờ bạn chọn đã chốt đơn. Bạn vui lòng xem khung giờ khác nhé 😓 ");
        isNextDay = false;
        option = 0;
      } else {
        isNextDay = false;
        option = 1;
      }
    }

    return TimeSlotOptionResult(isNextDay, option);
  }

  bool listsAreEqual(List<TimeSlotDTO> list1, List<TimeSlotDTO> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }

    return true;
  }

  bool isCurrentTimeSlotAvailable() {
    final currentDate = DateTime.now();

    String currentTimeSlot = selectedTimeSlot!.closeTime!;
    var beanTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      double.parse(currentTimeSlot.split(':')[0]).round(),
      double.parse(currentTimeSlot.split(':')[1]).round(),
    );
    // if (selectedTimeSlot!.id! == "7d2b363a-18fa-45e5-bfc9-0f52ef705524") {
    //   return true;
    // }
    int differentTime = beanTime.difference(currentDate).inMilliseconds;
    if (differentTime <= 0) {
      return false;
    } else {
      return true;
    }
  }

  bool isListTimeSlotAvailable(TimeSlotDTO timeslot) {
    final currentDate = DateTime.now();

    String currentTimeSlot = timeslot.closeTime!;
    var beanTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      double.parse(currentTimeSlot.split(':')[0]).round(),
      double.parse(currentTimeSlot.split(':')[1]).round(),
    );
    return beanTime.isBefore(currentDate);
  }

  bool isTimeSlotAvailable(TimeSlotDTO? timeSlot) {
    final currentDate = DateTime.now();
    String currentTimeSlot = timeSlot!.closeTime!;
    var beanTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      double.parse(currentTimeSlot.split(':')[0]).round(),
      double.parse(currentTimeSlot.split(':')[1]).round(),
    );
    return beanTime.isAfter(currentDate) ||
        beanTime.isAtSameMomentAs(currentDate);
  }

  bool isTimeSlotAvailableForNextDay(
      TimeSlotDTO? timeSlot, TimeSlotDTO? selected) {
    final currentDate = DateTime.now();
    String currentTimeSlot = timeSlot!.closeTime!;
    String selectedTime = selected!.closeTime!;
    var selectedTimeSlot = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      double.parse(selectedTime.split(':')[0]).round(),
      double.parse(selectedTime.split(':')[1]).round(),
    );
    var beanTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      double.parse(currentTimeSlot.split(':')[0]).round(),
      double.parse(currentTimeSlot.split(':')[1]).round(),
    );
    return beanTime.isAfter(selectedTimeSlot) ||
        beanTime.isAtSameMomentAs(selectedTimeSlot);
  }
}

class TimeSlotOptionResult {
  final bool isNextDay;
  final int option;

  TimeSlotOptionResult(this.isNextDay, this.option);
}
