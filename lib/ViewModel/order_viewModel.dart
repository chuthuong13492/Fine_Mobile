import 'package:dio/dio.dart';
import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Service/analytic_service.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/login_viewModel.dart';
import 'package:fine/ViewModel/product_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:get/get.dart';

import '../Model/DAO/index.dart';

class OrderViewModel extends BaseModel {
  Cart? currentCart;
  OrderDAO? _dao;
  OrderDTO? orderDTO;
  bool? loadingUpsell;
  String? errorMessage;
  List<String> listError = <String>[];

  OrderViewModel() {
    _dao = new OrderDAO();
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
      currentCart?.addProperties(5, '0902915671', 4);
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
      } else {
        await deleteCart();
        await deleteMart();
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
        if (e.response?.data['data'] != null) {
          // orderAmount = OrderAmountDTO.fromJson(e.response.data['data']);
        }
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

  Future<void> deleteItem(OrderDetails item) async {
    // showLoadingDialog();
    print("Delete item...");
    bool result;
    ProductDTO product =
        new ProductDTO(id: item.productInMenuId, productName: item.productName);
    CartItem cartItem =
        new CartItem(item.productInMenuId, 0, item.quantity, null);
    result = await removeItemFromCart(cartItem);
    print("Result: $result");
    if (result) {
      await AnalyticsService.getInstance()
          ?.logChangeCart(product, item.quantity, false);
      Get.back(result: false);
      await prepareOrder();
    } else {
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
    CartItem cartItem =
        new CartItem(item.productInMenuId, 0, item.quantity, null);
    await updateItemFromCart(cartItem);
    await prepareOrder();
    // notifyListeners();
  }
}