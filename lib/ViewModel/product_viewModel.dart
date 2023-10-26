import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/addProdcutToCart_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/ProductDTO.dart';
import 'package:fine/Service/analytic_service.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Constant/view_status.dart';
import 'base_model.dart';

class ProductDetailViewModel extends BaseModel {
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
  Cart? checkCurrentCart;

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
      // total = (extraTotal + fixTotal) * count;
      // notifyListeners();
    }
  }

  void minusQuantity() {
    if (count > 1) {
      count--;
      if (count == 1) {
        minusColor = FineTheme.palettes.neutral700;
      }
      // if (master.type == ProductType.MASTER_PRODUCT) {
      //   Map choice = new Map();
      //   for (int i = 0; i < affectPriceContent.keys.toList().length; i++) {
      //     choice[affectPriceContent.keys.elementAt(i)] =
      //         selectedAttributes[affectPriceContent.keys.elementAt(i)];
      //   }

      //   ProductDTO dto = master.getChildByAttributes(choice);
      //   fixTotal = dto.price * count;
      // } else {
      //   fixTotal = master.price * count;
      // }

      // if (this.extra != null) {
      //   extraTotal = 0;
      //   for (int i = 0; i < extra.keys.length; i++) {
      //     if (extra[extra.keys.elementAt(i)]) {
      //       double price = extra.keys.elementAt(i).price * count;
      //       extraTotal += price;
      //     }
      //   }
      // }
      fixTotal = (selectAttribute!.price ?? 0) * count;

      // // total = fixTotal + extraTotal;
      total = fixTotal;
      notifyListeners();
      // total = (extraTotal + fixTotal) * count;
      // notifyListeners();
    }
  }

  // void changeAffectPriceAtrribute(String attributeValue) {
  //   String attributeKey = affectPriceContent.keys.elementAt(affectIndex);
  //   selectedAttributes[attributeKey] = attributeValue;

  //   verifyOrder();

  //   if (order) {
  //     if (master.type == ProductType.MASTER_PRODUCT) {
  //       try {
  //         ProductDTO dto = master.getChildByAttributes(selectedAttributes);
  //         fixTotal = dto.price * count;
  //         extraTotal = 0;
  //         if (dto.hasExtra != null && dto.hasExtra) {
  //           getExtra(dto);
  //         } else {
  //           this.extra = null;
  //         }
  //       } catch (e) {
  //         showStatusDialog("assets/images/global_error.png",
  //             "Sản phẩm không tồn tại", selectedAttributes.toString());
  //         selectedAttributes[attributeKey] = null;
  //         verifyOrder();
  //       }
  //     }
  //     total = fixTotal + extraTotal;
  //   }

  //   notifyListeners();
  // }

  // void changeAffectIndex(int index) {
  //   this.affectIndex = index;
  //   if (index == affectPriceContent?.keys.toList().length) {
  //     isExtra = true;
  //   } else
  //     isExtra = false;
  //   notifyListeners();
  // }

  // void verifyOrder() {
  //   order = true;

  //   for (int i = 0; i < affectPriceContent!.keys.toList().length; i++) {
  //     if (selectedAttributes![affectPriceContent!.keys.elementAt(i)] == null) {
  //       order = false;
  //     }
  //   }

  //   if (order!) {
  //     addColor = FineTheme.palettes.primary100;
  //   }
  //   // setState(ViewStatus.Completed);
  // }

  // void changExtra(bool value, int i) {
  //   extraTotal = 0;
  //   extra[extra.keys.elementAt(i)] = value;
  //   for (int j = 0; j < extra.keys.toList().length; j++) {
  //     if (extra[extra.keys.elementAt(j)]) {
  //       double price = extra.keys.elementAt(j).price * count;
  //       extraTotal += price;
  //     }
  //   }
  //   total = fixTotal + extraTotal;
  //   notifyListeners();
  // }

  Future<void> addProductToCart({bool backToHome = true}) async {
    final root = Get.find<RootViewModel>();
    final order = Get.find<OrderViewModel>();
    showLoadingDialog();
    bool isPartyMode = false;
    PartyOrderViewModel party = Get.find<PartyOrderViewModel>();
    if (party.partyCode != null) {
      isPartyMode = true;
    }
    String description = "";

    checkCurrentCart = await getMart();
    if (checkCurrentCart == null) {
      // checkCurrentCart = Cart.get(
      //   productId: master!.attributes![0].id,
      //   quantity: count,
      //   timeSlotId: root.selectedTimeSlot!.id,
      //   orderDetails: [],
      // );
      checkCurrentCart = Cart(
          productId: selectAttribute!.id,
          quantity: count,
          timeSlotId: root.selectedTimeSlot!.id);
      await setMart(checkCurrentCart!);
      checkCurrentCart = await getMart();
      AddProductToCartStatus? result =
          await _dao!.checkProductToCart(checkCurrentCart!);
      if (result?.code == 4006) {
        Get.back();
        await showStatusDialog("assets/images/error.png", "Oops!",
            "Bạn chỉ có đặt 2 đơn trong 1 khung giờ thui!!");
        return;
      }
      if (result?.addProduct != null) {
        if (result!.addProduct!.productsRecommend != null) {
          order.productRecomend = result.addProduct!.productsRecommend;
        }
        if (result.addProduct!.status!.success == false) {
          await showStatusDialog("assets/images/error.png", "Box đã đầy",
              "Box đã đầy mất ùi, bạn hong thể thêm ${result.addProduct!.product!.name}");
        }
        if (result.addProduct!.status!.errorCode == '2001') {
          await showStatusDialog("assets/images/error.png", "Box đã đầy",
              "Box đã đầy ùi, bạn chỉ có thể thêm ${result.addProduct!.product!.quantity} phần ${result.addProduct!.product!.name}");
        }
        final productList = result.addProduct!.card;
        if (productList != null) {
          for (var item in productList) {
            CartItem cartItem = new CartItem(item.id, item.quantity!, null);
            await addItemToCart(cartItem, root.selectedTimeSlot!.id!);
            await addItemToMart(cartItem, root.selectedTimeSlot!.id!);
            if (item.id == checkCurrentCart!.productId) {
              await AnalyticsService.getInstance()!.logChangeCart(
                  null, item.quantity!, true,
                  productInCart: item);
            }
          }
        }
        checkCurrentCart = await getMart();
        if (checkCurrentCart!.productId != null) {
          checkCurrentCart!.productId = null;
          checkCurrentCart!.quantity = 0;
        }
        if (checkCurrentCart!.orderDetails != null &&
            checkCurrentCart!.productId == null) {
          await setCart(checkCurrentCart!);
        }
      }
    } else {
      await processCart(selectAttribute!.id, count, root.selectedTimeSlot!.id);
    }

    hideDialog();
    if (backToHome) {
      if (isPartyMode) {
        Get.find<PartyOrderViewModel>().addProductToPartyOrder();
      } else {
        order.isPartyOrder = false;
        Get.find<OrderViewModel>().prepareOrder();
      }

      // Get.back(result: true);
    } else {
      if (isPartyMode) {
        Get.find<PartyOrderViewModel>().addProductToPartyOrder();
      } else {
        order.isPartyOrder = false;
        Get.find<OrderViewModel>().prepareOrder();
      }
    }
  }

  Future<void> processCart(
      String? productId, int? quantity, String? timeSlotId) async {
    OrderViewModel order = Get.find<OrderViewModel>();
    if (productId != null && quantity != null) {
      checkCurrentCart = await getMart();
      checkCurrentCart!.productId = productId;
      checkCurrentCart!.quantity = quantity;
      await setMart(checkCurrentCart!);
      checkCurrentCart = await getMart();
      AddProductToCartStatus? result =
          await _dao!.checkProductToCart(checkCurrentCart!);
      if (result?.code == 4006) {
        Get.back();
        await showStatusDialog("assets/images/error.png", "Oops!",
            "Bạn chỉ có đặt 2 đơn trong 1 khung giờ thui!!");
      }
      if (result?.addProduct?.status?.errorCode == "400" &&
          result?.addProduct?.card == null) {
        await showStatusDialog("assets/images/error.png", "Oops!",
            "1 Đơn hàng chỉ được tối đa 6 món thui!!");
      }
      if (result?.addProduct?.card != null &&
          result?.addProduct?.product != null) {
        if (result!.addProduct!.productsRecommend != null) {
          order.productRecomend = result.addProduct!.productsRecommend;
        }
        if (result.addProduct!.status!.success == false) {
          await showStatusDialog("assets/images/error.png", "Box đã đầy",
              "Box đã đầy mất ùi, bạn hong thể thêm ${result.addProduct!.product!.name}");
        }
        if (result.addProduct!.status!.errorCode == '2001') {
          await showStatusDialog("assets/images/error.png", "Box đã đầy",
              "Box đã đầy rùi, bạn chỉ có thể thêm ${result.addProduct!.product!.quantity} phần ${result.addProduct!.product!.name}");
        }
        final productList = result.addProduct!.card!;
        if (productList != null) {
          for (var item in productList) {
            CartItem cartItem = new CartItem(item.id, item.quantity!, null);
            // await removeItemFromCart(cartItem);
            await removeItemFromMart(cartItem);
            // await addItemToCart(cartItem, timeSlotId!);
            await addItemToMart(cartItem, timeSlotId!);
          }
        }
        checkCurrentCart = await getMart();

        if (checkCurrentCart!.productId != null) {
          checkCurrentCart!.productId = null;
          checkCurrentCart!.quantity = 0;
        }
        if (checkCurrentCart!.orderDetails != null &&
            checkCurrentCart!.productId == null) {
          await setCart(checkCurrentCart!);
        }
      }
    }
  }
}
