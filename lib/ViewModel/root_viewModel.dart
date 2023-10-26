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
    Get.find<OrderViewModel>().getCurrentCart();
    Get.find<RootViewModel>().getProductRecommend();
    Get.find<RootViewModel>().checkHasParty();
    Get.find<PartyOrderViewModel>().getCoOrderStatus();
  }

  Future<void> getProductRecommend() async {
    Cart? cart = await getCart();
    await deleteMart();
    if (cart != null) {
      if (cart.orderDetails!.length != 0) {
        CartItem itemInCart = new CartItem(cart!.orderDetails![0].productId,
            cart.orderDetails![0].quantity - 1, null);

        await updateItemFromCart(itemInCart);
        cart = await getCart();
        await setMart(cart!);
        await Get.find<ProductDetailViewModel>().processCart(
            cart.orderDetails![0].productId, 1, selectedTimeSlot!.id);
      } else {
        Get.find<OrderViewModel>().productRecomend = [];
      }
    }
  }

  Future<void> changeDay(int index) async {
    Get.find<OrderViewModel>().currentCart = await getCart();
    final cart = Get.find<OrderViewModel>().currentCart;
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
      await deletePartyCode();
      await Get.find<OrderViewModel>().removeCart();
      await getListTimeSlot();
    }
  }

  Future<void> checkHasParty() async {
    final party = Get.find<PartyOrderViewModel>();
    party.partyCode = await getPartyCode();
    if (party.partyCode != null) {
      if (party.partyCode!.contains("LPO")) {
        party.isLinked = true;
      } else {
        if (party.partyOrderDTO != null) {
          notifier.value = true;
          await Get.find<PartyOrderViewModel>().getCoOrderStatus();
          // _timer = Timer.periodic(const Duration(seconds: 5),
          //     (timer) => Get.find<PartyOrderViewModel>().getCoOrderStatus());
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
        // CampusDTO store = await getStore();
        // product = await _productDAO.getProductDetail(
        //     product.id, store.id, selectedMenu.menuId);
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

  Future<Position?> getCurrentLocation() async {
    bool isServicEnabked = await Geolocator.isLocationServiceEnabled();
    if (!isServicEnabked) {
      return Future.error('Location service are disabled');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permission are permanently denied, we cannot request permission');
    }
    // return await Geolocator.getCurrentPosition();
  }

  Future<void> liveLocation() async {
    late LocationSettings locationSettings;
    await getCurrentLocation();

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          //(Optional) Set foreground notification config to keep the app alive
          //when going to the background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
                "Example app will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock: true,
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      currentPosition = position;
      // lat = position.latitude.toString();
      // long = position.longitude.toString();
      getAddressFromLatLng(position.longitude, position.latitude);
    });
    print("$currentPosition");
  }

  Future<void> getAddressFromLatLng(long, lat) async {
    try {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, long);

      Placemark place = placemark[0];

      currentLocation =
          "${place.locality}, ${place.street}, ${place.subLocality}, ${place.administrativeArea}, ${place.country}";
    } catch (e) {
      print(e);
    }
  }

  Future<void> getLocation() async {
    try {
      currentPosition = await getCurrentLocation();
      getAddressFromLatLng(
          currentPosition!.longitude, currentPosition!.latitude);
    } catch (e) {
      print(e);
    }
  }

  // Future<void> liveLocation() async {
  //   try {
  //     if (currentPosition == null) {

  //     }
  //     print("Lat: $lat, Long: $long");
  //   } catch (e) {
  //     currentPosition = null;
  //   }
  // }

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
      AccountViewModel accountViewModel = Get.find<AccountViewModel>();
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
    // Function eq = const ListEquality().equals;
    // StoreDAO _storeDAO = new StoreDAO();
    currentStore = destinationDTO;
    // List<LocationDTO> locations = await _storeDAO.getLocations(currentStore.id);
    // if (!eq(locations, currentStore.locations)) {
    //   currentStore.locations.forEach((location) {
    //     if (location.isSelected) {
    //       DestinationDTO destination = location.destinations
    //           .where(
    //             (element) => element.isSelected,
    //           )
    //           .first;
    //       locations.forEach((element) {
    //         if (element.id == location.id) {
    //           element.isSelected = true;
    //           element.destinations.forEach((des) {
    //             if (des.id == destination.id) des.isSelected = true;
    //           });
    //         }
    //       });
    //     }
    //   });

    //   currentStore.locations = locations;
    await setStore(currentStore!);
    setState(ViewStatus.Completed);
    // await getListTimeSlot(currentStore.id);
    // await getListTimeSlot();
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
            await orderViewModel.removeCart();
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

  Future<void> navOrder() async {
    OrderViewModel orderViewModel = Get.find<OrderViewModel>();
    await orderViewModel.getCurrentCart();
    int option = 1;
    if (orderViewModel.currentCart != null) {
      if (orderViewModel.currentCart!.timeSlotId != selectedTimeSlot!.id) {
        bool isTimeSlotInList = previousTimeSlotList!.any(
            (element) => element.id == orderViewModel.currentCart!.timeSlotId);
        TimeSlotDTO? cartTimeSlot;
        if (isTimeSlotInList) {
          cartTimeSlot = previousTimeSlotList?.firstWhere((element) =>
              element.id!.contains(orderViewModel.currentCart!.timeSlotId!));
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
            cartTimeSlot = previousTimeSlotList?.firstWhere((element) =>
                element.id!.contains(orderViewModel.currentCart!.timeSlotId!));
            selectedTimeSlot = cartTimeSlot;
            notifyListeners();
            // await orderViewModel.prepareOrder();
            // await Future.delayed(const Duration(microseconds: 500));

            // await Get.toNamed(RouteHandler.ORDER);
            // hideDialog();
            return;
          }
        }

        if (option != 1) {
          return;
        }
        selectedTimeSlot = cartTimeSlot;
        await refreshMenu();
        notifyListeners();

        // await orderViewModel.prepareOrder();
        await Future.delayed(const Duration(microseconds: 500));
        hideDialog();
        await Get.toNamed(RouteHandler.ORDER);
      } else {
        // await orderViewModel.prepareOrder();

        await Future.delayed(const Duration(microseconds: 500));
        // hideDialog();
        await Get.toNamed(RouteHandler.ORDER);
      }
    } else {
      await orderViewModel.getCurrentCart();
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
    bool found = false;
    if (isNextDay == false) {
      for (int i = 0; i < listTimeSlot!.length; i++) {
        TimeSlotDTO element = listTimeSlot![i];
        if (isListTimeSlotAvailable(element)) {
          listTimeSlot!.removeAt(i);
          i--;
        }
      }

      if (previousTimeSlotList?.length == 0) {
        previousTimeSlotList = listTimeSlot!;
        selectedTimeSlot = listTimeSlot![0];
        await refreshMenu();
        notifyListeners();
      } else {
        if (listsAreEqual(listTimeSlot!, previousTimeSlotList!)) {
          previousTimeSlotList = listTimeSlot!;
          selectedTimeSlot = listTimeSlot![0];
          print("noti:");
          await refreshMenu();
          notifyListeners();
        } else {
          previousTimeSlotList = listTimeSlot;
          if (isOnClick == true) {
            isOnClick = false;
            selectedTimeSlot = listTimeSlot![0];
            await refreshMenu();
            notifyListeners();
          }
        }
      }

      // await Get.find<HomeViewModel>().getMenus();
    } else {
      if (isOnClick == true) {
        isOnClick = false;
        final firstTimeSlot = listTimeSlot![0];
        // listTimeSlot?.clear();
        // listTimeSlot!.add(firstTimeSlot);
        previousTimeSlotList?.clear();
        previousTimeSlotList?.add(firstTimeSlot);
        selectedTimeSlot = listTimeSlot![0];
        // if (selectedTimeSlot == null) {
        //   selectedTimeSlot = listTimeSlot![0];
        //   for (TimeSlotDTO element in listTimeSlot!) {
        //     if (isTimeSlotAvailable(element)) {
        //       selectedTimeSlot = element;

        //       found = true;
        //       break;
        //     }
        //   }
        // } else {
        //   for (TimeSlotDTO element in listTimeSlot!) {
        //     if (selectedTimeSlot?.id == element.id) {
        //       selectedTimeSlot = element;
        //       // listAvailableTimeSlots = selectedMenu.timeSlots
        //       //     .where((element) => isTimeSlotAvailable(element.checkoutTime))
        //       //     .toList();
        //       found = true;
        //       break;
        //     }
        //   }
        // }
        await refreshMenu();
        notifyListeners();
      }
    }

    // if (found == false) {
    //   Cart cart = await getCart();
    //   if (cart != null) {
    //     await showStatusDialog(
    //         "assets/images/global_error.png",
    //         "Khung giờ đã thay đổi",
    //         "Các sản phẩm trong giỏ hàng đã bị xóa, còn nhiều món ngon đang chờ bạn nhé");
    //     Get.find<OrderViewModel>().removeCart();
    //   }
    // } else {
    //   if (!isCurrentMenuAvailable()) {
    //     await showStatusDialog(
    //       "assets/images/global_error.png",
    //       "Đã hết giờ chốt đơn cho ${selectedMenu.menuName}",
    //       "Bạn vui lòng chọn menu khác nhé.",
    //     );
    //     await fetchStore();
    //     // remove cart
    //     Get.find<OrderViewModel>().removeCart();
    //   }
    // }
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
        // CampusDTO store = await getStore();
        // product = await _productDAO.getProductDetail(
        //     product.id, store.id, selectedMenu.menuId);
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
      // TimeSlotOptionResult result = await checkTimeSlotOption(
      //     timeSlot,
      //     selectedTimeSlot,
      //     "Hiện tại khung giờ này đã đóng vào lúc ${timeSlot?.arriveTime} trong ngày hôm nay, bạn có muốn chuyển sang khung giờ này vào ngày hôm sau hong ^^.");
      // isNextDay = result.isNextDay;
      // option = result.option;

      OrderViewModel orderViewModel = Get.find<OrderViewModel>();
      orderViewModel.currentCart = await getCart();
      PartyOrderViewModel party = Get.find<PartyOrderViewModel>();

      if (party.partyOrderDTO != null) {
        showStatusDialog('assets/images/logo2.png', "Đơn nhóm",
            "Bạn đang trong đơn nhóm nên hong thể đổi được khung giờ nè!");
        option = 0;
        // option = await showOptionDialog(
        //     "Bạn có chắc không? Đổi khung giờ rồi là đơn nhóm bị xóa đó!!");
      } else {
        if (orderViewModel.currentCart != null) {
          option = await showOptionDialog(
              "Bạn có chắc không? Đổi khung giờ rồi là giỏ hàng bị xóa đó!!");
        }
      }

      if (option == 1) {
        // showLoadingDialog();
        selectedTimeSlot = timeSlot;
        await Get.find<OrderViewModel>().removeCart();
        // await Get.find<OrderViewModel>().getCurrentCart();
        await deletePartyCode();
        party.partyOrderDTO = null;
        // await setStore(currentStore);
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
