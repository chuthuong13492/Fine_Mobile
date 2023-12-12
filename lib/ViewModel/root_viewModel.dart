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

  // List<TimeSlotDTO>? listAvailableTimeSlot;
  ProductDAO? _productDAO;

  DestinationDAO? _destinationDAO;
  bool changeAddress = false;
  bool isNextDay = false;
  bool isOnClick = false;
  final ValueNotifier<bool> notifier = ValueNotifier(false);
  // DateTime? now;
  final ValueNotifier<DateTime> now = ValueNotifier(DateTime(0));

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
    // await Get.find<CartViewModel>().getReOrder();
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

    Get.find<CartViewModel>().getReOrder();
    Get.find<BlogsViewModel>().getBlogs();
    await Get.find<CartViewModel>().getBoxes();
    await Get.find<RootViewModel>().checkCartAvailable();
    // Get.find<RootViewModel>().checkHasParty();
    Get.find<PartyOrderViewModel>().getCoOrderStatus();
  }

  Future<void> changeDay(int index) async {
    final cart = await getCart();
    // final cart = Get.find<OrderViewModel>().currentCart;
    int? option = 1;
    PartyOrderViewModel partyOrderViewModel = Get.find<PartyOrderViewModel>();
    if (partyOrderViewModel.partyOrderDTO != null) {
      showStatusDialog('assets/images/logo2.png', "Đơn nhóm",
          "Bạn đang trong đơn nhóm nên hong thể đổi ngày được nè!");
      option = 0;
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
      Get.find<CartViewModel>().removeCart();
      await getListTimeSlot();
    }
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

  Future<void> checkCartAvailable() async {
    DestinationDAO campusDAO = DestinationDAO();
    final _cartViewModel = Get.find<CartViewModel>();
    final partyOrderViewModel = Get.find<PartyOrderViewModel>();
    try {
      await _cartViewModel.getCurrentCart();
      final cart = _cartViewModel.currentCart;
      final partyCode = await getPartyCode();
      if (partyCode != null) {
        await partyOrderViewModel.getPartyOrder();
        final partyDTO = partyOrderViewModel.partyOrderDTO;
        if (partyDTO != null) {
          if (partyDTO.orderType == 1) {
            isNextDay = false;
            if (selectedTimeSlot == partyDTO.timeSlotDTO) {
              selectedTimeSlot = previousTimeSlotList?.firstWhere(
                  (element) => element.id == partyDTO.timeSlotDTO?.id);
              // await refreshMenu();
            } else {
              bool isCartTimeSlotAvailable = previousTimeSlotList!
                  .any((element) => element.id == partyDTO.timeSlotDTO?.id);
              if (isCartTimeSlotAvailable) {
                selectedTimeSlot = previousTimeSlotList?.firstWhere(
                    (element) => element.id == partyDTO.timeSlotDTO?.id);
                await refreshMenu();
              } else {
                selectedTimeSlot = previousTimeSlotList![0];
                await deletePartyCode();
                await _cartViewModel.removeCart();
                await refreshMenu();
              }
            }
          }
        }
      } else {
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
      }

      notifyListeners();
    } catch (e) {
      await deleteCart();
      await _cartViewModel.getCurrentCart();
    }
  }

  Future<void> navOrder() async {
    final cart = await getCart();
    if (cart != null) {
      await Get.toNamed(RouteHandler.CART_SCREEN);
    } else {
      showStatusDialog(
          "assets/images/empty-cart-ipack.png",
          "Giỏ hàng đang trống kìaaa",
          "Hiện tại giỏ của bạn đang trống , bạn hãy thêm sản phẩm vào nhé 😃.");
    }
  }

  Future<void> navParty() async {
    final party = Get.find<PartyOrderViewModel>();
    await party.getPartyOrder();
    final partyCode = await getPartyCode();
    if (party.partyOrderDTO != null && partyCode != null) {
      await party.confirmationTimeout();
      await Get.toNamed(RouteHandler.PARTY_ORDER_SCREEN);
    }
  }

  Future<void> getListTimeSlot() async {
    Timer.periodic(
        const Duration(seconds: 1), (timer) => now.value = DateTime.now());
    DestinationDAO campusDAO = DestinationDAO();
    listTimeSlot = await campusDAO.getTimeSlot(DESTINATIONID);
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
      } else {
        if (listsAreEqual(listTimeSlot!, previousTimeSlotList!)) {
          previousTimeSlotList = listTimeSlot!;
          selectedTimeSlot = previousTimeSlotList![0];
          await refreshMenu();
          final cart = await getCart();
          bool isCartAvailable = previousTimeSlotList!
              .any((element) => element.id == cart?.timeSlotId);
          if (isCartAvailable) {
            await Get.find<CartViewModel>().removeCart();
          }
        } else {
          previousTimeSlotList = listTimeSlot;
          final cart = await getCart();
          // if (cart == null) {
          //   selectedTimeSlot = previousTimeSlotList![0];
          //   await refreshMenu();
          // } else {
          //   bool? isCartAvailable = previousTimeSlotList
          //       ?.any((element) => element.id == cart.timeSlotId);
          //   if (isCartAvailable == false) {
          //     selectedTimeSlot = previousTimeSlotList![0];
          //     await refreshMenu();
          //   }
          // }
          if (isOnClick == true) {
            isOnClick = false;
            selectedTimeSlot = previousTimeSlotList![0];
            await refreshMenu();
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
        await Get.find<CartViewModel>().removeCart();
        await refreshMenu();
      }
    }
    notifyListeners();
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
      final partyCode = await getPartyCode();
      if (partyCode != null) {
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
        selectedTimeSlot = timeSlot;
        Get.find<CartViewModel>().removeCart();
        deletePartyCode();
        party.partyOrderDTO = null;
        await refreshMenu();
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
