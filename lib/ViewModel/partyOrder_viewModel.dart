import 'package:dio/dio.dart';
import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Service/analytic_service.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:get/get.dart';

class PartyOrderViewModel extends BaseModel {
  RootViewModel root = Get.find<RootViewModel>();
  PartyOrderDTO? partyOrderDTO;
  PartyOrderDAO? _partyDAO;
  Cart? currentCart;
  String? errorMessage;
  List<OrderDetails>? listOrderDetail;
  List<String> listError = <String>[];
  String? partyCode;

  PartyOrderViewModel() {
    _partyDAO = PartyOrderDAO();
    currentCart = null;
  }

  Future<void> coOrder() async {
    try {
      if (Get.isDialogOpen!) {
        setState(ViewStatus.Loading);
      }
      currentCart = await getCart();
      currentCart?.addProperties(root.selectedTimeSlot!.id!);
      listError.clear();
      if (currentCart != null) {
        partyOrderDTO = await _partyDAO?.coOrder(currentCart!);
        partyCode = partyOrderDTO!.partyCode;
        // Get.back();
      } else {
        Cart cart = Cart.get(
            orderType: 1,
            timeSlotId: root.selectedTimeSlot!.id!,
            orderDetails: null);
        partyOrderDTO = await _partyDAO?.coOrder(cart);
        partyCode = partyOrderDTO!.partyCode;
        // await deleteCart();
        // await deleteMart();
        // Get.back();
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
        setState(ViewStatus.Completed);
      } else if (e.response?.statusCode == 404) {
        if (e.response?.data["error"] != null) {
          setCart(currentCart!);
          setState(ViewStatus.Completed);
        }
      } else {
        bool result = await showErrorDialog();
        if (result) {
          await coOrder();
        } else {
          setState(ViewStatus.Error);
        }
      }
    }
  }

  Future<void> getPartyOrder() async {
    try {
      setState(ViewStatus.Loading);
      partyOrderDTO = await _partyDAO?.getPartyOrder(partyCode);
      setState(ViewStatus.Completed);
    } catch (e) {
      partyOrderDTO = null;
      setState(ViewStatus.Error);
    }
  }

  Future<void> joinPartyOrder({String? code}) async {
    AccountViewModel acc = Get.find<AccountViewModel>();
    try {
      setState(ViewStatus.Loading);

      await getPartyOrder();
      bool isMatchingCustomerId = false;
      if (partyOrderDTO == null) {
        partyOrderDTO = await _partyDAO?.joinPartyOrder(code);
        partyCode = code;
        hideDialog();
        Get.toNamed(RoutHandler.PARTY_ORDER_SCREEN);
      }
      for (var partyOrder in partyOrderDTO!.partyOrder!) {
        String customerId = partyOrder.customer!.id!;
        if (customerId == acc.currentUser!.id) {
          isMatchingCustomerId = true;
          break;
        }
      }
      if (!isMatchingCustomerId) {
        partyOrderDTO = await _partyDAO?.joinPartyOrder(code);
        partyCode = code;
        hideDialog();
        Get.toNamed(RoutHandler.PARTY_ORDER_SCREEN);
      } else {
        if (code != null) {
          await getPartyOrder();
          hideDialog();
          Get.toNamed(RoutHandler.PARTY_ORDER_SCREEN);
        }
      }

      setState(ViewStatus.Completed);
    } catch (e) {
      partyOrderDTO = null;
      setState(ViewStatus.Error);
    }
  }

  Future<void> addProductToPartyOrder() async {
    try {
      setState(ViewStatus.Loading);
      currentCart = await getCart();
      currentCart?.addProperties(root.selectedTimeSlot!.id!);
      partyOrderDTO =
          await _partyDAO?.addProductToParty(partyCode, cart: currentCart);

      await getPartyOrder();
      setState(ViewStatus.Completed);
    } catch (e) {
      await deleteCart();
      // partyOrderDTO = null;
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
      currentCart = await getCart();
      final order = await _partyDAO?.preparePartyOrder(
          root.selectedTimeSlot!.id!, partyCode);
      for (var item in order!.orderDetails!) {
        CartItem cartItem = new CartItem(item.productId, item.quantity, null);
        await addItemToCart(cartItem);
      }
      setState(ViewStatus.Completed);
    } catch (e) {
      // partyOrderDTO = null;
      setState(ViewStatus.Error);
    }
  }

  Future<void> confirmationParty() async {
    try {
      setState(ViewStatus.Loading);
      AccountViewModel acc = Get.find<AccountViewModel>();
      // final listParty = partyOrderDTO!.partyOrder!
      //     .where((element) => element.customer!.id == acc.currentUser!.id)
      //     .toList();
      // final listOrderDetail =
      int option =
          await showOptionDialog("Bạn vui lòng xác nhận lại giỏ hàng nha 😊.");

      if (option != 1) {
        return;
      }
      final orderDetails = await _partyDAO?.confirmPartyOrder(partyCode);
      // CartItem item =
      //     new CartItem(orderDetails!.productId, orderDetails.quantity, null);
      // await addItemToCart(item);
      // listOrderDetail!.add(orderDetails!);
      await getPartyOrder();
      setState(ViewStatus.Completed);
    } catch (e) {
      // partyOrderDTO = null;
      setState(ViewStatus.Error);
    }
  }

  Future<void> deleteItem(OrderDetails item) async {
    // showLoadingDialog();
    print("Delete item...");
    bool result;
    ProductDTO product =
        ProductDTO(id: item.productId, productName: item.productName);
    CartItem cartItem = CartItem(item.productId, item.quantity, null);
    result = await removeItemFromCart(cartItem);
    print("Result: $result");
    if (result) {
      await AnalyticsService.getInstance()
          ?.logChangeCart(product, item.quantity, false);
      // Get.back(result: true);
      await addProductToPartyOrder();
    } else {
      currentCart = await getCart();
      await addProductToPartyOrder();
    }
  }

  Future<void> updateQuantity(OrderDetails item) async {
    CartItem cartItem = new CartItem(item.productId, item.quantity, null);
    await updateItemFromCart(cartItem);
    await addProductToPartyOrder();
  }
}
