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
import 'package:fine/ViewModel/orderHistory_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:get/get.dart';

import '../Model/DAO/index.dart';

class OrderViewModel extends BaseModel {
  Cart? currentCart;
  OrderDAO? _dao;
  StationDAO? _stationDAO;
  OrderDTO? orderDTO;
  PartyOrderDTO? partyOrderDTO;
  PartyOrderDAO? _partyDAO;
  List<StationDTO>? stationList;
  bool? loadingUpsell;
  String? errorMessage;
  List<String> listError = <String>[];
  RootViewModel root = Get.find<RootViewModel>();

  OrderViewModel() {
    _dao = OrderDAO();
    _stationDAO = StationDAO();
    _partyDAO = PartyOrderDAO();
    // promoDao = new PromotionDAO();
    // _collectionDAO = CollectionDAO();
    loadingUpsell = false;
    currentCart = null;
  }

  Future<void> prepareOrder() async {
    try {
      if (Get.isDialogOpen!) {
        setState(ViewStatus.Loading);
      }
      // if (campusDTO == null) {
      //   RootViewModel root = Get.find<RootViewModel>();
      //   campusDTO = root.currentStore;
      // }

      currentCart = await getCart();

      currentCart?.addProperties(root.selectedTimeSlot!.id!);
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
        Get.back();
      }

      errorMessage = null;
      hideDialog();
      setState(ViewStatus.Completed);
    } on DioError catch (e, stacktra) {
      print(stacktra.toString());
      if (e.response?.statusCode == 400) {
        String errorMsg = e.response?.data["message"];
        errorMessage = errorMsg;
        showStatusDialog("assets/images/error.png", "Khung giờ đã qua rồi",
            "Hiện tại khung giờ này đã đóng vào lúc ${root.selectedTimeSlot!.checkoutTime}, bạn hãy xem khung giờ khác nhé 😃.");
        deleteCart();
        deleteMart();
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

  Future<void> getCurrentCart() async {
    try {
      currentCart = await getCart();
      currentCart?.addProperties(root.selectedTimeSlot!.id!);
      setState(ViewStatus.Completed);

      notifyListeners();
    } catch (e) {
      currentCart = null;
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
        int option = await showOptionDialog(
            "Bạn vui lòng xác nhận lại giỏ hàng nha 😊.");

        if (option != 1) {
          return;
        }
        showLoadingDialog();
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
          await removeCart();
          await deletePartyCode();
          final partyModel = Get.find<PartyOrderViewModel>();
          await partyModel.isLinkedParty(false);
          hideDialog();
          await showStatusDialog("assets/images/icon-success.png", 'Success',
              'Bạn đã đặt hàng thành công');
          // await Get.find<OrderHistoryViewModel>().getOrders();
          //////////
          // await Get.find<OrderHistoryViewModel>().getNewOrder();
          //////////
          PartyOrderViewModel party = Get.find<PartyOrderViewModel>();
          orderDTO = null;
          party.partyOrderDTO = null;
          party.partyCode = null;
          Get.toNamed(
            RoutHandler.ORDER_HISTORY_DETAIL,
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

  Future<void> navOrder() async {
    RootViewModel root = Get.find<RootViewModel>();
    PartyOrderViewModel party = Get.find<PartyOrderViewModel>();
    await party.getPartyOrder();
    if (root.isCurrentTimeSlotAvailable()) {
      if (party.partyOrderDTO != null &&
          root.isTimeSlotAvailable(party.partyOrderDTO!.timeSlotDTO) &&
          party.partyOrderDTO!.timeSlotDTO!.id == root.selectedTimeSlot!.id) {
        Get.toNamed(RoutHandler.PARTY_ORDER_SCREEN);
      } else if (party.partyOrderDTO != null) {
        if (party.partyOrderDTO!.timeSlotDTO!.id != root.selectedTimeSlot!.id) {
          int option = await showOptionDialog(
              "Đơn nhóm của bạn đang ở khung giờ ${party.partyOrderDTO!.timeSlotDTO!.checkoutTime} Bạn vui lòng đổi sang khung giờ này để tham gia đơn nhóm nhé");

          if (option != 1) {
            return;
          }
          root.selectedTimeSlot = party.partyOrderDTO!.timeSlotDTO!;
          await root.refreshMenu();
          notifyListeners();
        }
      } else {
        if (currentCart != null) {
          await Get.toNamed(RoutHandler.ORDER);
        } else {
          await getCurrentCart();
          showStatusDialog(
              "assets/images/error.png",
              "Giỏ hàng đang trống kìaaa",
              "Hiện tại giỏ của bạn đang trống , bạn hãy thêm sản phẩm vào nhé 😃.");
        }
      }
    } else {
      party.partyOrderDTO == null;
      await removeCart();
      await getCurrentCart();
      showStatusDialog("assets/images/error.png", "Khung giờ đã qua rồi",
          "Hiện tại khung giờ này đã đóng vào lúc ${root.selectedTimeSlot!.checkoutTime}, bạn hãy xem khung giờ khác nhé 😃.");
    }
  }

  Future<void> deleteItem(OrderDetails item) async {
    // showLoadingDialog();
    print("Delete item...");
    bool result;
    ProductDTO product =
        new ProductDTO(id: item.productId, productName: item.productName);
    CartItem cartItem = new CartItem(item.productId, item.quantity, null);
    result = await removeItemFromCart(cartItem);
    print("Result: $result");
    if (result) {
      await AnalyticsService.getInstance()
          ?.logChangeCart(product, item.quantity, false);
      // Get.back(result: true);
      await prepareOrder();
    } else {
      await removeItemFromCart(cartItem);
      currentCart = await getCart();
      await prepareOrder();
    }
  }

  Future<void> updateQuantity(OrderDetails item) async {
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
    CartItem cartItem = new CartItem(item.productId, item.quantity, null);
    await updateItemFromCart(cartItem);
    await prepareOrder();
    // notifyListeners();
  }

  Future removeCart() async {
    await deleteCart();
    await deleteMart();
    currentCart = null;
    notifyListeners();
  }
}
