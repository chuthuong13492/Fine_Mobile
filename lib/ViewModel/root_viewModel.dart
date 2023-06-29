import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/CampusDAO.dart';
import 'package:fine/Model/DAO/ProductDAO.dart';
import 'package:fine/Model/DAO/StoreDAO.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/blogs_viewModel.dart';
import 'package:fine/ViewModel/category_viewModel.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/login_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
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
  CampusDTO? currentStore;
  List<CampusDTO>? campusList;
  TimeSlotDTO? selectedTimeSlot;
  List<TimeSlotDTO>? listTimeSlot;
  ProductDAO? _productDAO;
  CampusDAO? _campusDAO;
  bool changeAddress = false;

  RootViewModel() {
    _productDAO = ProductDAO();
    _campusDAO = CampusDAO();
    selectedTimeSlot = null;
  }
  Future refreshMenu() async {
    // fetchStore();
    await Get.find<HomeViewModel>().getListSupplier();
    await Get.find<HomeViewModel>().getMenus();
    // await Get.find<OrderViewModel>().getUpSellCollections();
    // await Get.find<GiftViewModel>().getGifts();
  }

  Future startUp() async {
    // await Get.find<RootViewModel>().getCurrentLocation();
    // liveLocation();
    await Get.find<RootViewModel>().liveLocation();

    await Get.find<AccountViewModel>().fetchUser();
    await Get.find<RootViewModel>().getUserCampus();
    await Get.find<RootViewModel>().getListTimeSlot();
    await Get.find<HomeViewModel>().getMenus();
    await Get.find<HomeViewModel>().getListSupplier();
    // await Get.find<CategoryViewModel>().getCategories();
    await Get.find<BlogsViewModel>().getBlogs();
  }

  Future<void> openProductDetail(ProductDTO? product,
      {showOnHome = true, fetchDetail = false}) async {
    Get.put<bool>(
      showOnHome,
      tag: "showOnHome",
    );
    try {
      if (fetchDetail) {
        showLoadingDialog();
        // CampusDTO store = await getStore();
        // product = await _productDAO.getProductDetail(
        //     product.id, store.id, selectedMenu.menuId);
        product = await _productDAO?.getProductDetail(product?.id);
      }
      await Get.toNamed(RoutHandler.PRODUCT_DETAIL, arguments: product);
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

  Future<void> getListCampus() async {
    try {
      setState(ViewStatus.Loading);
      CampusDAO campusDAO = CampusDAO();
      campusList = await campusDAO.getCampusList();
      setState(ViewStatus.Completed);
    } catch (e) {
      campusList = null;
      setState(ViewStatus.Error);
    }
  }

  Future<void> getUserCampus() async {
    try {
      setState(ViewStatus.Loading);
      AccountViewModel accountViewModel = Get.find<AccountViewModel>();
      final userCampus = await _campusDAO!
          .getUserCampus(accountViewModel.currentUser!.universityId!);
      currentStore = userCampus;
      await setStore(currentStore!);
      setState(ViewStatus.Completed);
    } catch (e) {
      setState(ViewStatus.Error);
    }
  }

  Future<void> setCurrentCampus(CampusDTO campus) async {
    showLoadingDialog();
    // Function eq = const ListEquality().equals;
    // StoreDAO _storeDAO = new StoreDAO();
    currentStore = campus;
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
    Get.toNamed(RoutHandler.NAV);
  }

  Future<void> getListTimeSlot() async {
    CampusDAO campusDAO = CampusDAO();
    listTimeSlot = await campusDAO.getTimeSlot();
    bool found = false;
    if (selectedTimeSlot == null) {
      selectedTimeSlot = listTimeSlot![0];
      for (TimeSlotDTO element in listTimeSlot!) {
        if (isTimeSlotAvailable(element)) {
          selectedTimeSlot = element;
          found = true;
          break;
        }
      }
    } else {
      for (TimeSlotDTO element in listTimeSlot!) {
        if (selectedTimeSlot?.id == element.id) {
          selectedTimeSlot = element;
          // listAvailableTimeSlots = selectedMenu.timeSlots
          //     .where((element) => isTimeSlotAvailable(element.checkoutTime))
          //     .toList();
          found = true;
          break;
        }
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
      await Get.toNamed(RoutHandler.PRODUCT_DETAIL, arguments: supplierDTO);
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
    if (timeSlot?.id != selectedTimeSlot?.id) {
      if (!isTimeSlotAvailable(timeSlot)) {
        showStatusDialog("assets/images/error.png", "Khung giờ đã qua rồi",
            "Hiện tại khung giờ này đã đóng vào lúc ${timeSlot?.checkoutTime}, bạn hãy xem khung giờ khác nhé 😃.");
        return;
      }
      int option = 1;
      Cart? cart = Get.find<OrderViewModel>().currentCart;
      if (cart != null) {
        option = await showOptionDialog(
            "Bạn có chắc không? Đổi khung giờ rồi là giỏ hàng bị xóa đó!!");
      }

      if (option == 1) {
        // showLoadingDialog();
        selectedTimeSlot = timeSlot;
        await Get.find<OrderViewModel>().removeCart();
        // await setStore(currentStore);
        await refreshMenu();
        // hideDialog();
        notifyListeners();
      }
    }
  }

  bool isCurrentTimeSlotAvailable() {
    final currentDate = DateTime.now();
    String currentTimeSlot = selectedTimeSlot!.checkoutTime!;
    var beanTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      double.parse(currentTimeSlot.split(':')[0]).round(),
      double.parse(currentTimeSlot.split(':')[1]).round(),
    );
    int differentTime = beanTime.difference(currentDate).inMilliseconds;
    if (differentTime <= 0) {
      return false;
    } else {
      return true;
    }
  }

  bool isTimeSlotAvailable(TimeSlotDTO? timeSlot) {
    final currentDate = DateTime.now();
    String currentTimeSlot = timeSlot!.checkoutTime!;
    var beanTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      double.parse(currentTimeSlot.split(':')[0]).round(),
      double.parse(currentTimeSlot.split(':')[1]).round(),
    );
    int differentTime = beanTime.difference(currentDate).inMilliseconds;
    if (differentTime <= 0) {
      return false;
    } else {
      return true;
    }
  }
}
