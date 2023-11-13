import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/addProdcutToCart_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/ProductDTO.dart';
import 'package:fine/Service/analytic_service.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/cart_viewModel.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Constant/view_status.dart';
import '../Model/DTO/ConfirmCartDTO.dart';
import 'base_model.dart';

class ProductDetailViewModel extends BaseModel {
  final root = Get.find<RootViewModel>();
  Color minusColor = FineTheme.palettes.primary100;
  Color addColor = FineTheme.palettes.primary100;
  int? affectIndex = 0;
  //List product ảnh hưởng giá
  Map<String, List<String>>? affectPriceContent;

  Map<String, String>? selectedAttributes;
  int count = 1;
  int? quantity;
  double? total, fixTotal = 0, extraTotal = 0;
  bool? order = false;
  //List choice option
  Map<ProductDTO, bool>? extra;
  //Bật cờ để đổi radio thành checkbox
  bool? isExtra = false;
  //List size
  // List<ProductInCart>? productsRecomend;
  ProductAttributes? selectAttribute;
  ProductDTO? master;
  ProductDAO? _dao;
  ConfirmCart? checkCurrentCart;

  ProductDetailViewModel({ProductDTO? dto}) {
    master = dto;
    isExtra = false;
    _dao = ProductDAO();
    checkCurrentCart = null;
    selectAttribute = null;

    if (selectAttribute == null) {
      if (master != null) {
        selectAttribute = master!.attributes![0];
        fixTotal = (selectAttribute!.price ?? 0) * count;
        // // total = fixTotal + extraTotal;
        total = fixTotal;
      }
    }

    // verifyOrder();
    notifyListeners();
  }

  void selectedAttribute(ProductAttributes attributes) {
    selectAttribute = attributes;
    total = attributes.price;
    count = 1;
    notifyListeners();
  }

  void addQuantity() {
    if (addColor == FineTheme.palettes.primary100) {
      if (count == 1) {
        minusColor = FineTheme.palettes.primary100;
      }
      count++;

      fixTotal = (selectAttribute!.price ?? 0) * count;

      total = fixTotal;
      notifyListeners();
    }
  }

  void minusQuantity() {
    if (count > 1) {
      count--;
      if (count == 1) {
        minusColor = FineTheme.palettes.neutral700;
      }

      fixTotal = (selectAttribute!.price ?? 0) * count;

      total = fixTotal;
      notifyListeners();
    }
  }

  Future<bool?> addProductToCart({bool backToHome = true}) async {
    showLoadingDialog();
    final cart = await getCart();
    CartItem item = CartItem(selectAttribute?.id, master?.productName,
        master?.imageUrl, selectAttribute!.size, total, total, count, false);

    bool isInCart;
    if (cart == null) {
      isInCart = false;
    } else {
      isInCart =
          cart.items!.any((element) => element.productId == item.productId);
    }

    if (isInCart) {
      await showStatusDialog("assets/images/logo2.png", "Oops!",
          "Món này bạn đã thêm vô giỏ rồi!!");
      hideDialog();
      return false;
    } else {
      await addItemToCart(item, root.selectedTimeSlot!.id!, root.isNextDay);
      await AnalyticsService.getInstance()!
          .logChangeCart(master, item.quantity, true);
      await Get.find<CartViewModel>().getCurrentCart();
      hideDialog();
      return true;
    }
  }

  // Future<void> addProductToCart({bool backToHome = true}) async {
  //   final root = Get.find<RootViewModel>();
  //   final order = Get.find<OrderViewModel>();
  //   showLoadingDialog();
  //   bool isPartyMode = false;
  //   PartyOrderViewModel party = Get.find<PartyOrderViewModel>();
  //   if (party.partyCode != null) {
  //     isPartyMode = true;
  //   }
  //   String description = "";

  //   checkCurrentCart = await getMart();
  //   if (checkCurrentCart == null) {
  //     // checkCurrentCart = Cart.get(
  //     //   productId: master!.attributes![0].id,
  //     //   quantity: count,
  //     //   timeSlotId: root.selectedTimeSlot!.id,
  //     //   orderDetails: [],
  //     // );
  //     checkCurrentCart = ConfirmCart(
  //         productId: selectAttribute!.id,
  //         quantity: count,
  //         timeSlotId: root.selectedTimeSlot!.id);
  //     await setMart(checkCurrentCart!);
  //     checkCurrentCart = await getMart();
  //     AddProductToCartStatus? result =
  //         await _dao!.checkProductToCart(checkCurrentCart!);
  //     if (result?.code == 4006) {
  //       Get.back();
  //       order.removeCart();
  //       await showStatusDialog("assets/images/error.png", "Oops!",
  //           "Bạn chỉ có đặt 2 đơn trong 1 khung giờ thui!!");
  //       return;
  //     }
  //     switch (result?.addProduct!.status!.errorCode) {
  //       case "4002":
  //         await showStatusDialog("assets/images/error.png", "Box đã đầy",
  //             "Box đã đầy ùi, Box chỉ chứa tối đa 5 món thui nè");
  //         return;
  //       case "2001":
  //         await showStatusDialog("assets/images/error.png", "Box đã đầy",
  //             "Box đã đầy rùi, bạn chỉ có thể thêm ${result?.addProduct!.product!.quantity} phần ${result?.addProduct!.product!.name}");
  //         return;
  //       default:
  //         break;
  //     }
  //     if (result?.addProduct?.card != null &&
  //         result?.addProduct?.product != null) {
  //       if (result!.addProduct!.productsRecommend != null) {
  //         order.productRecomend = result.addProduct!.productsRecommend;
  //       }
  //       if (result.addProduct!.status!.success == false) {
  //         await showStatusDialog("assets/images/error.png", "Box đã đầy",
  //             "Box đã đầy mất ùi, bạn hong thể thêm ${result.addProduct!.product!.name}");
  //         return;
  //       }

  //       final productList = result.addProduct!.card;
  //       if (productList != null) {
  //         for (var item in productList) {
  //           ConfirmCartItem cartItem =
  //               new ConfirmCartItem(item.id, item.quantity!, null);
  //           await addItemToCart(cartItem, root.selectedTimeSlot!.id!);
  //           await addItemToMart(cartItem, root.selectedTimeSlot!.id!);
  //           if (item.id == checkCurrentCart!.productId) {
  //             await AnalyticsService.getInstance()!.logChangeCart(
  //                 null, item.quantity!, true,
  //                 productInCart: item);
  //           }
  //         }
  //       }
  //       checkCurrentCart = await getMart();
  //       if (checkCurrentCart!.productId != null) {
  //         checkCurrentCart!.productId = null;
  //         checkCurrentCart!.quantity = 0;
  //       }
  //       if (checkCurrentCart!.orderDetails != null &&
  //           checkCurrentCart!.productId == null) {
  //         await setCart(checkCurrentCart!);
  //       }
  //     }
  //   } else {
  //     await processCart(selectAttribute!.id, count, root.selectedTimeSlot!.id);
  //   }

  //   hideDialog();
  //   if (backToHome) {
  //     if (isPartyMode) {
  //       Get.find<PartyOrderViewModel>().addProductToPartyOrder();
  //     } else {
  //       order.isPartyOrder = false;
  //       Get.find<OrderViewModel>().prepareOrder();
  //     }

  //     // Get.back(result: true);
  //   } else {
  //     if (isPartyMode) {
  //       Get.find<PartyOrderViewModel>().addProductToPartyOrder();
  //     } else {
  //       order.isPartyOrder = false;
  //       Get.find<OrderViewModel>().prepareOrder();
  //     }
  //   }
  // }

  Future<bool?> processCart(String? productId, int? quantity) async {
    OrderViewModel order = Get.find<OrderViewModel>();
    if (productId != null && quantity != null) {
      checkCurrentCart = await getMart();
      if (checkCurrentCart == null) {
        checkCurrentCart = ConfirmCart(
            productId: productId,
            quantity: quantity,
            timeSlotId: root.selectedTimeSlot!.id);
        await setMart(checkCurrentCart!);
      } else {
        checkCurrentCart!.productId = productId;
        checkCurrentCart!.quantity = quantity;
        await setMart(checkCurrentCart!);
        checkCurrentCart = await getMart();
      }

      AddProductToCartStatus? result =
          await _dao!.checkProductToCart(checkCurrentCart!);
      if (result?.code == 4006) {
        Get.back();
        await showStatusDialog("assets/images/error.png", "Oops!",
            "Bạn chỉ có đặt 2 đơn trong 1 khung giờ thui!!");
        return false;
      }
      switch (result?.addProduct!.status!.errorCode) {
        case "4002":
          await showStatusDialog("assets/images/error.png", "Box đã đầy",
              "Box đã đầy ùi, Box chỉ chứa tối đa 5 món thui nè");
          return false;
        case "2001":
          await showStatusDialog("assets/images/error.png", "Box đã đầy",
              "Box đã đầy rùi, bạn chỉ có thể thêm ${result?.addProduct!.product!.quantity} phần ${result?.addProduct!.product!.name}");
          return false;
        default:
          break;
      }
      if (result?.addProduct?.card != null &&
          result?.addProduct?.product != null) {
        if (result!.addProduct!.productsRecommend != null) {
          order.productRecomend = result.addProduct!.productsRecommend;
        }

        if (result.addProduct!.status!.success == false) {
          await showStatusDialog("assets/images/error.png", "Box đã đầy",
              "Box đã đầy mất ùi, bạn hong thể thêm ${result.addProduct!.product!.name}");
          return false;
        }

        final productList = result.addProduct!.card!;
        if (productList != null) {
          for (var item in productList) {
            ConfirmCartItem cartItem =
                new ConfirmCartItem(item.id, item.quantity!, null);
            // await removeItemFromCart(cartItem);
            await removeItemFromMart(cartItem);
            // await addItemToCart(cartItem, timeSlotId!);
            await addItemToMart(cartItem);
          }
        }
        checkCurrentCart = await getMart();

        if (checkCurrentCart!.productId != null) {
          checkCurrentCart!.productId = null;
          checkCurrentCart!.quantity = 0;
        }
        if (checkCurrentCart!.orderDetails != null &&
            checkCurrentCart!.productId == null) {
          await setMart(checkCurrentCart!);
        }
        checkCurrentCart = await getMart();

        return true;
      }
    }
    return false;
  }
}
