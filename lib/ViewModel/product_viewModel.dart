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
  bool? isExtra;
  //List size
  // List<ProductInCart>? productsRecomend;
  ProductDTO? master;
  ProductDAO? _dao;
  Cart? checkCurrentCart;

  ProductDetailViewModel({ProductDTO? dto}) {
    master = dto;
    isExtra = false;
    _dao = ProductDAO();
    checkCurrentCart = null;
    // productsRecomend = null;
    this.affectPriceContent = new Map<String, List<String>>();

    this.selectedAttributes = new Map<String, String>();
    //

    // if (master.type == ProductType.MASTER_PRODUCT) {
    //   for (int i = 0; i < master.attributes.keys.length; i++) {
    //     String attributeKey = master.attributes.keys.elementAt(i);
    //     List<String> listAttributesName =
    //         master.attributes[attributeKey].split(",");
    //     listAttributesName.forEach((element) {
    //       element.trim();
    //     });
    //     affectPriceContent[attributeKey] = listAttributesName;
    //     selectedAttributes[attributeKey] = null;
    //   }
    // } else {
    //   if (dto.type == ProductType.COMPLEX_PRODUCT &&
    //       dto.extras != null &&
    //       dto.extras.isNotEmpty) {
    //     getExtra(dto);
    //     isExtra = true;
    //   } else {
    //     this.extra = null;
    //   }
    //   fixTotal = master.price * count;
    // }
    fixTotal = (master?.attributes![0].price ?? 0) * count;
    // // total = fixTotal + extraTotal;
    total = fixTotal;

    verifyOrder();
    notifyListeners();
  }

  // void getExtra(ProductDTO product) {
  //   this.extra = new Map<ProductDTO, bool>();
  //   for (ProductDTO dto in product.extras) {
  //     extra[dto] = false;
  //   }
  //   notifyListeners();
  // }

  void addQuantity() {
    if (addColor == FineTheme.palettes.primary100) {
      if (count == 1) {
        minusColor = FineTheme.palettes.primary100;
      }
      count++;
      // if (master.type == ProductType.MASTER_PRODUCT) {
      //   Map choice = new Map();
      //   for (int i = 0; i < affectPriceContent!.keys.toList().length; i++) {
      //     choice[affectPriceContent!.keys.elementAt(i)] =
      //         selectedAttributes?[affectPriceContent?.keys.elementAt(i)];
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

      // total = fixTotal + extraTotal;
      fixTotal = (master?.attributes![0].price ?? 0) * count;

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
      fixTotal = (master?.attributes![0].price ?? 0) * count;

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

  void changeAffectIndex(int index) {
    this.affectIndex = index;
    if (index == affectPriceContent?.keys.toList().length) {
      isExtra = true;
    } else
      isExtra = false;
    notifyListeners();
  }

  void verifyOrder() {
    order = true;

    for (int i = 0; i < affectPriceContent!.keys.toList().length; i++) {
      if (selectedAttributes![affectPriceContent!.keys.elementAt(i)] == null) {
        order = false;
      }
    }

    if (order!) {
      addColor = FineTheme.palettes.primary100;
    }
    // setState(ViewStatus.Completed);
  }

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
    // await deleteMart();
    Cart? cart = await getCart();
    showLoadingDialog();
    bool showOnHome = Get.find<bool>(tag: "showOnHome");
    // if (master.type == ProductType.MASTER_PRODUCT) {
    //   Map choice = new Map();
    //   for (int i = 0; i < affectPriceContent.keys.toList().length; i++) {
    //     choice[affectPriceContent.keys.elementAt(i)] =
    //         selectedAttributes[affectPriceContent.keys.elementAt(i)];
    //   }

    //   ProductDTO dto = master.getChildByAttributes(choice);
    //   listChoices.add(dto);
    // }

    // if (this.extra != null) {
    //   for (int i = 0; i < extra.keys.length; i++) {
    //     if (extra[extra.keys.elementAt(i)]) {
    //       print(extra.keys.elementAt(i).type);
    //       listChoices.add(extra.keys.elementAt(i));
    //     }
    //   }
    // }
    bool isPartyMode = false;
    PartyOrderViewModel party = Get.find<PartyOrderViewModel>();
    if (party.partyOrderDTO != null) {
      isPartyMode = true;
    }
    String description = "";
    // Cart newCart = Cart(5, '0902915671', 4);
    List<CartItem>? orderDetails = [];

    checkCurrentCart = await getMart();
    if (checkCurrentCart == null) {
      // checkCurrentCart = Cart.get(
      //   productId: master!.attributes![0].id,
      //   quantity: count,
      //   timeSlotId: root.selectedTimeSlot!.id,
      //   orderDetails: [],
      // );
      checkCurrentCart = Cart(
          productId: master!.attributes![0].id,
          quantity: count,
          timeSlotId: root.selectedTimeSlot!.id);
      await setMart(checkCurrentCart!);
      checkCurrentCart = await getMart();
      AddProductToCartResponse? result =
          await _dao!.checkProductToCart(checkCurrentCart!);
      if (result!.productsRecommend != null) {
        order.productRecomend = result.productsRecommend;
      }
      if (result.status!.success == false) {
        await showStatusDialog("assets/images/error.png", "Box đã đầy",
            "Box đã đầy mất ùi, bạn hong thể thêm ${result.product!.name}");
      }
      if (result.status!.errorCode == '2001') {
        await showStatusDialog("assets/images/error.png", "Box đã đầy",
            "Box đã đầy rùi, bạn chỉ có thể thêm ${result.product!.quantity} phần ${result.product!.name}");
      }
      final productList = result.card;
      if (productList != null) {
        for (var item in productList) {
          CartItem cartItem = new CartItem(item.id, item.quantity!, null);
          await addItemToCart(cartItem, root.selectedTimeSlot!.id!);
          await addItemToMart(cartItem, root.selectedTimeSlot!.id!);
          if (item.id == checkCurrentCart!.productId) {
            await AnalyticsService.getInstance()!
                .logChangeCart(null, item.quantity!, true, productInCart: item);
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
    } else {
      await processCart(
          master!.attributes![0].id, count, root.selectedTimeSlot!.id);
    }

    // await addItemToMart(item, root.selectedTimeSlot!.id!);
    // // if (checkCurrentCart == null) {
    // //   orderDetails.add(item);
    // //   checkCurrentCart = Cart.get(
    // //     orderType: 1,
    // //     timeSlotId: root.selectedTimeSlot!.id!,
    // //     orderDetails: orderDetails,
    // //   );
    // // } else {
    // //   checkCurrentCart!.addItem(item);
    // // }

    // // checkCurrentCart!.addItem(item);

    // // if (master.type == ProductType.GIFT_PRODUCT) {
    // //   AccountViewModel account = Get.find<AccountViewModel>();
    // //   if (account.currentUser == null) {
    // //     await account.fetchUser();
    // //   }

    // //   double totalBean = account.currentUser.point;

    // //   if (cart != null) {
    // //     cart.items.forEach((element) {
    // //       if (element.master.type == ProductType.GIFT_PRODUCT) {
    // //         totalBean -= (element.master.price * element.quantity);
    // //       }
    // //     });
    // //   }

    // //   if (totalBean < (master.price * count)) {
    // //     await showStatusDialog("assets/images/global_error.png",
    // //         "Không đủ Bean", "Số bean hiện tại không đủ");
    // //     return;
    // //   }
    // // }

    // // print("Item: " + item.master.productInMenuId.toString());

    // showOnHome
    //     ? await addItemToCart(item, root.selectedTimeSlot!.id!)
    //     : await addItemToMart(item, root.selectedTimeSlot!.id!);

    hideDialog();
    if (backToHome) {
      if (isPartyMode) {
        Get.find<PartyOrderViewModel>().addProductToPartyOrder();
      } else {
        Get.find<OrderViewModel>().prepareOrder();
      }

      // Get.back(result: true);
    } else {
      if (isPartyMode) {
        Get.find<PartyOrderViewModel>().addProductToPartyOrder();
      } else {
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
      AddProductToCartResponse? result =
          await _dao!.checkProductToCart(checkCurrentCart!);
      if (result!.productsRecommend != null) {
        order.productRecomend = result.productsRecommend;
      }
      if (result.status!.success == false) {
        await showStatusDialog("assets/images/error.png", "Box đã đầy",
            "Box đã đầy mất ùi, bạn hong thể thêm ${result.product!.name}");
      }
      if (result.status!.errorCode == '2001') {
        await showStatusDialog("assets/images/error.png", "Box đã đầy",
            "Box đã đầy rùi, bạn chỉ có thể thêm ${result.product!.quantity} phần ${result.product!.name}");
      }
      final productList = result.card!;
      if (productList != null) {
        for (var item in productList) {
          CartItem cartItem = new CartItem(item.id, item.quantity!, null);
          await removeItemFromCart(cartItem);
          await removeItemFromMart(cartItem);
          await addItemToCart(cartItem, timeSlotId!);
          await addItemToMart(cartItem, timeSlotId);
          if (item.id == checkCurrentCart!.productId) {
            await AnalyticsService.getInstance()!
                .logChangeCart(null, item.quantity!, true, productInCart: item);
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
  }
}
