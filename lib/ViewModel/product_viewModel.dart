import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/ProductDTO.dart';
import 'package:fine/Service/analytic_service.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'base_model.dart';

class ProductDetailViewModel extends BaseModel {
  Color minusColor = FineTheme.palettes.primary100;
  Color addColor = FineTheme.palettes.primary100;
  int? affectIndex = 0;
  //List product ảnh hưởng giá
  Map<String, List<String>>? affectPriceContent;

  Map<String, String>? selectedAttributes;
  int count = 1;

  double? total, fixTotal = 0, extraTotal = 0;
  bool? order = false;
  //List choice option
  Map<ProductDTO, bool>? extra;
  //Bật cờ để đổi radio thành checkbox
  bool? isExtra;
  //List size
  ProductDTO? master;
  Cart? currentCart;

  ProductDetailViewModel({ProductDTO? dto}) {
    master = dto;
    isExtra = false;

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
    fixTotal = (master?.price ?? 0) * count;
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
      fixTotal = (master?.price ?? 0) * count;

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
      fixTotal = (master?.price ?? 0) * count;

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

    String description = "";
    // Cart newCart = Cart(5, '0902915671', 4);

    CartItem item = new CartItem(master!.id, 0, count, null);

    // if (master.type == ProductType.GIFT_PRODUCT) {
    //   AccountViewModel account = Get.find<AccountViewModel>();
    //   if (account.currentUser == null) {
    //     await account.fetchUser();
    //   }

    //   double totalBean = account.currentUser.point;

    //   if (cart != null) {
    //     cart.items.forEach((element) {
    //       if (element.master.type == ProductType.GIFT_PRODUCT) {
    //         totalBean -= (element.master.price * element.quantity);
    //       }
    //     });
    //   }

    //   if (totalBean < (master.price * count)) {
    //     await showStatusDialog("assets/images/global_error.png",
    //         "Không đủ Bean", "Số bean hiện tại không đủ");
    //     return;
    //   }
    // }

    // print("Item: " + item.master.productInMenuId.toString());

    showOnHome ? await addItemToCart(item) : await addItemToMart(item);
    // Cart? currentCart = await getCart();
    // cart.addItem(item);
    await AnalyticsService.getInstance()!
        .logChangeCart(master!, item.quantity, true);
    hideDialog();
    if (backToHome) {
      Get.find<OrderViewModel>().prepareOrder();
      // Get.back(result: true);
    } else {
      Get.find<OrderViewModel>().prepareOrder();
    }
  }
}
