import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/product_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Constant/boxes_response.dart';
import '../Constant/view_status.dart';

import '../Model/DAO/StoreDAO.dart';
import '../Model/DAO/index.dart';
import '../Model/DTO/ConfirmCartDTO.dart';
import '../Model/DTO/CubeModel.dart';
import '../Model/DTO/OrderDTO.dart';
import '../Service/analytic_service.dart';
import '../Utils/constrant.dart';
import '../Utils/shared_pref.dart';
import 'order_viewModel.dart';

class CartViewModel extends BaseModel {
  StoreDAO? _storeDAO;
  final root = Get.find<RootViewModel>();
  Cart? currentCart;
  List<ReOrderDTO>? reOrderList;
  List<CheckFixBoxRequest>? card;
  double total = 0, fixTotal = 0, extraTotal = 0;
  int quantityChecked = 0;
  bool? isSelected = false;
  String? code;
  BoxesResponse? boxes;
  DestinationDAO? _destinationDAO;
  final ValueNotifier<int> notifier = ValueNotifier(0);

  CartViewModel() {
    _storeDAO = StoreDAO();
    _destinationDAO = DestinationDAO();
    currentCart = null;
  }

  Future<void> changeValueChecked(bool value, CartItem cartItem) async {
    try {
      if (value == true) {
        bool? isAdded = await Get.find<ProductDetailViewModel>()
            .processCart(cartItem.productId, cartItem.quantity);

        await updateCheckItemFromCart(cartItem, isAdded!);
        if (isAdded == true) {
          getTotalQuantity(isAdded, cartItem);
        }
        // final mart = await getMart();
        // if (mart == null) {
        //   // await checkProductFixTheBox(card, attr, quantity);
        // }
        // await updateCheckItemFromCart(cartItem, value);
      } else {
        ConfirmCartItem item =
            ConfirmCartItem(cartItem.productId, cartItem.quantity, "");
        await removeItemFromMart(item);
        await updateCheckItemFromCart(cartItem, value);
        await getTotalQuantity(value, cartItem);

        // await updateCheckItemFromCart(cartItem, value);
      }
      currentCart = await getCart();
      isSelected =
          currentCart!.items!.any((element) => element.isChecked == true);

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> getTotalQuantity(bool value, CartItem cartItem) async {
    currentCart = await getCart();
    bool isTrue =
        currentCart!.items!.any((element) => element.isChecked == true);
    if (isTrue) {
      if (total == null) {
        quantityChecked = cartItem.quantity;
        total = cartItem.fixTotal!;
      } else {
        if (value == false) {
          quantityChecked -= cartItem.quantity;

          total -= cartItem.fixTotal!;
        } else {
          quantityChecked += cartItem.quantity;

          total += cartItem.fixTotal!;
        }
      }
    } else {
      quantityChecked = 0;
      total = 0;
    }
  }

  Future<void> orderPayment() async {
    try {
      ConfirmCart? confirmCart = await getMart();
      if (confirmCart != null) {
        await getProductRecommend();
        await Future.delayed(const Duration(microseconds: 500));
        await Get.find<OrderViewModel>().prepareOrder();
        final error = Get.find<OrderViewModel>().errorMessage;
        if (error == null) {
          Get.toNamed(RouteHandler.ORDER);
        }
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> getProductRecommend() async {
    ConfirmCart? cart = await getMart();
    if (cart != null) {
      if (cart.orderDetails!.isNotEmpty) {
        ConfirmCartItem itemInCart = ConfirmCartItem(
            cart.orderDetails![0].productId,
            cart.orderDetails![0].quantity - 1,
            null);

        await updateItemFromMart(itemInCart);
        cart = await getMart();
        await Get.find<ProductDetailViewModel>()
            .processCart(cart!.orderDetails![0].productId, 1);
      } else {
        Get.find<OrderViewModel>().productRecomend = [];
      }
    }
  }

  Future<void> getReOrder() async {
    try {
      setState(ViewStatus.Loading);
      RootViewModel root = Get.find<RootViewModel>();
      var currentTimeSlot = root.selectedTimeSlot;
      // var currentMenu = root.selectedMenu;
      if (root.status == ViewStatus.Error) {
        setState(ViewStatus.Error);
        return;
      }
      if (currentTimeSlot != null) {
        reOrderList = await _storeDAO?.getReOrder(currentTimeSlot.id);
      }

      await Future.delayed(const Duration(milliseconds: 500));
      setState(ViewStatus.Completed);
    } catch (e) {
      setState(ViewStatus.Completed);
    }
  }

  Future<void> getCurrentCart() async {
    try {
      setState(ViewStatus.Loading);
      await Future.delayed(const Duration(milliseconds: 500));
      currentCart = await getCart();

      if (currentCart == null) {
        notifier.value = 0;
        quantityChecked = 0;
        total = 0;
      } else {
        notifier.value = currentCart!.itemQuantity();
        final listChecked = currentCart?.items
            ?.where((element) => element.isChecked == true)
            .toList();
        quantityChecked = 0;
        total = 0;
        for (var item in listChecked!) {
          total += item.fixTotal!;
          quantityChecked += item.quantity;
        }
        isSelected =
            currentCart!.items!.any((element) => element.isChecked == true);
        if (isSelected == false) {
          await deleteMart();
        }
      }
      code = await getPartyCode();

      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      deleteCart();
      currentCart = await getCart();
      setState(ViewStatus.Completed);
    }
  }

  Future<void> removeCart() async {
    await deleteCart();
    await deleteMart();
    total = 0;
    quantityChecked = 0;
    notifier.value = 0;
    currentCart = await getCart();
    notifyListeners();
  }

  Future<void> updateItem(CartItem item, int index, bool isIncrease) async {
    // if (item.isChecked == true) {
    //   if (isIncrease == true) {
    //     total -= item.fixTotal!;
    //     quantityChecked -= (item.quantity - 1);
    //   } else {
    //     total -= item.fixTotal!;
    //     quantityChecked -= (item.quantity + 1);
    //   }
    // }

    fixTotal = item.price! * item.quantity;
    final cartItem = CartItem(
        item.productId,
        item.productName,
        item.imgUrl,
        item.size,
        item.rotationType,
        item.height,
        item.width,
        item.length,
        item.price,
        fixTotal,
        item.quantity,
        item.isStackable,
        false);
    await updateItemFromCart(cartItem);
    ConfirmCartItem confirmCartItem =
        ConfirmCartItem(item.productId, item.quantity, "");
    await removeItemFromMart(confirmCartItem);
    currentCart = await getCart();
    notifier.value = currentCart!.itemQuantity();
    if (currentCart == null) {
      notifier.value = 0;
      quantityChecked = 0;
      total = 0;
    } else {
      final listChecked = currentCart?.items
          ?.where((element) => element.isChecked == true)
          .toList();
      quantityChecked = 0;
      total = 0;
      for (var item in listChecked!) {
        total += item.fixTotal!;
        quantityChecked += item.quantity;
      }
    }
    notifyListeners();
  }

  Future<void> deleteItem(CartItem item, int index) async {
    // showLoadingDialog();
    print("Delete item...");
    bool result;

    result = await removeItemFromCart(item);
    print("Result: $result");
    if (result) {
      currentCart = await getCart();
      if (currentCart == null) {
        total = 0;
        quantityChecked = 0;
        notifier.value = 0;
      } else {
        notifier.value = currentCart!.itemQuantity();
      }
      quantityChecked -= item.quantity;
      total -= item.fixTotal!;
      ConfirmCartItem cartItem =
          ConfirmCartItem(item.productId, item.quantity, "");
      await removeItemFromMart(cartItem);
    } else {
      currentCart = await getCart();
      if (currentCart == null) {
        total = 0;
        quantityChecked = 0;
        notifier.value = 0;
      } else {
        notifier.value = currentCart!.itemQuantity();
      }
      quantityChecked -= item.quantity;
      total -= item.fixTotal!;
      ConfirmCartItem cartItem =
          ConfirmCartItem(item.productId, item.quantity, "");
      await removeItemFromMart(cartItem);
    }
    notifyListeners();
  }

  Future<void> getBoxes() async {
    try {
      setState(ViewStatus.Loading);
      boxes = await _destinationDAO?.getBoxesResponse(DESTINATIONID);
      setState(ViewStatus.Completed);
    } catch (e) {
      setState(ViewStatus.Error);
    }
  }

  Future<FixBoxResponse?> checkProductFixTheBox(
      CartItem attr, int quantity) async {
    try {
      FixBoxResponse fillBoxResponse = FixBoxResponse(quantitySuccess: 0);

      var boxSize = CubeDTO(
        height: boxes?.cube?.height,
        width: boxes?.cube?.width,
        length: boxes?.cube?.length,
      );

      var spaceInBox = SpaceInBoxMode(
        remainingSpaceBox: boxSize,
        remainingLengthSpace: boxSize,
        remainingWidthSpace: boxSize,
        volumeOccupied: null,
      );
      if (card == null) {
        card?.add(CheckFixBoxRequest(product: attr, quantity: quantity));
      }
      // tính thể tích bị chiếm bởi các product trong card trước
      card?.sort((a, b) =>
          (b.product!.length! * b.product!.width! * b.product!.height!)
              .compareTo(
                  a.product!.length! * a.product!.width! * a.product!.height!));
      for (var item in card!) {
        // ghép product lên cho vừa họp dựa trên quantity yêu cầu
        ProductParingResponse? pairingCardResult =
            await productPairing(item.quantity!, item.product!, boxSize);

        var turnCard = (item.quantity! / pairingCardResult!.quantityCanAdd!)
            .ceilToDouble();
        for (var successCase = 1; successCase <= turnCard; successCase++) {
          // đem đi bỏ vào tủ
          final calculateCardResult = await calculateRemainingSpace(
              boxSize, spaceInBox, pairingCardResult.productSupplanted!);

          if (calculateCardResult!.success == true) {
            spaceInBox = SpaceInBoxMode(
              remainingSpaceBox: calculateCardResult.remainingSpaceBox,
              volumeOccupied: calculateCardResult.volumeOccupied,
              remainingLengthSpace: calculateCardResult.remainingLengthSpace,
              remainingWidthSpace: calculateCardResult.remainingWidthSpace,
              volumeLengthOccupied: calculateCardResult.volumeLengthOccupied,
              volumeWidthOccupied: calculateCardResult.volumeWidthOccupied,
            );

            if (attr != null) {
              if (item.product!.productId == attr.productId) {
                if (successCase == turnCard) {
                  fillBoxResponse.quantitySuccess = quantity;
                } else {
                  fillBoxResponse.quantitySuccess =
                      pairingCardResult.quantityCanAdd! * successCase;
                }
              }
            }
          } else {
            break;
          }
        }
      }
      fillBoxResponse.remainingWidthSpace = spaceInBox.remainingWidthSpace;
      fillBoxResponse.remainingLengthSpace = spaceInBox.remainingLengthSpace;
      return fillBoxResponse;
    } catch (e) {
      throw e;
    }
  }

  Future<ProductParingResponse?> productPairing(
      int quantity, CartItem attr, CubeDTO boxSize) async {
    ProductParingResponse paringResponse =
        ProductParingResponse(productSupplanted: null, quantityCanAdd: 1);
    switch (attr.rotationType) {
      case ProductRotationTypeEnum.BOTH:
        if (attr.length! < boxSize.height!) {
          if (attr.width! < attr.height!) {
            paringResponse.productSupplanted = CubeDTO(
              height: attr.length,
              width: attr.width,
              length: attr.height,
            );
          } else {
            paringResponse.productSupplanted = CubeDTO(
              height: attr.length,
              width: attr.height,
              length: attr.width,
            );
          }
        }
        break;
      // nếu product mặc định nằm ngang => product nằm chồng lên nhau => số lượng có thể add * product.h < product.h (tùy thuộc có thể chồng hay ko)
      case ProductRotationTypeEnum.HORIZONTAL:
        if (attr.isStackable == true) {
          paringResponse.quantityCanAdd =
              (boxSize.height! / attr.height!).floor();
          if (paringResponse.quantityCanAdd! > quantity) {
            paringResponse.quantityCanAdd = quantity;
          }

          paringResponse.productSupplanted = CubeDTO(
            height: attr.height! * paringResponse.quantityCanAdd!,
            width: attr.width,
            length: attr.length,
          );
        } else {
          paringResponse.productSupplanted = CubeDTO(
            height: attr.height,
            width: attr.width,
            length: attr.length,
          );
        }
        break;
      case ProductRotationTypeEnum.VERTICAL:
        paringResponse.productSupplanted = CubeDTO(
          height: attr.height,
          width: attr.width,
          length: attr.length,
        );
        break;
      default:
    }
    var temp = paringResponse.productSupplanted!.length;
    paringResponse.productSupplanted!.length =
        paringResponse.productSupplanted!.length! >
                paringResponse.productSupplanted!.width!
            ? paringResponse.productSupplanted!.length
            : paringResponse.productSupplanted!.width;
    paringResponse.productSupplanted!.width =
        paringResponse.productSupplanted!.length! >
                paringResponse.productSupplanted!.width!
            ? paringResponse.productSupplanted!.width
            : temp;

    return paringResponse;
  }

  Future<SpaceInBoxMode?> calculateRemainingSpace(
      CubeDTO box, SpaceInBoxMode space, CubeDTO productOccupied) async {
    var response = SpaceInBoxMode(
        success: true,
        remainingSpaceBox: space.remainingSpaceBox,
        remainingLengthSpace: space.remainingLengthSpace,
        remainingWidthSpace: space.remainingWidthSpace,
        volumeOccupied: space.volumeOccupied);
    if (space.volumeOccupied == null) {
      response.volumeOccupied = CubeDTO(
        height: productOccupied.height,
        width: productOccupied.width,
        length: productOccupied.length,
      );
      response.remainingLengthSpace = CubeDTO(
        height: box.height,
        width: box.width! - response.volumeOccupied!.length!,
        length: box.length,
      );
      response.remainingWidthSpace = CubeDTO(
        height: box.height,
        width: box.width,
        length: box.length! - response.volumeOccupied!.width!,
      );
    } else if (space.remainingSpaceBox != null) {
      if (space.volumeOccupied!.width! + productOccupied.width! <=
          box.length!) {
        response.volumeOccupied = CubeDTO(
          height: space.volumeOccupied!.height! < productOccupied.height!
              ? productOccupied.height
              : space.volumeOccupied!.height,
          width: space.volumeOccupied!.width! + productOccupied.width!,
          length: space.volumeOccupied!.length! < productOccupied.length!
              ? productOccupied.length
              : space.volumeOccupied!.length,
        );

        response.remainingLengthSpace = CubeDTO(
          height: box.height,
          width: box.width! - response.volumeOccupied!.length!,
          length: box.length,
        );

        response.remainingWidthSpace = CubeDTO(
          height: box.height,
          width: box.width,
          length: box.length! - response.volumeOccupied!.width!,
        );
      } else if (space.volumeOccupied!.width! + productOccupied.width! >
              box.length! &&
          space.volumeOccupied!.length! + productOccupied.length! <=
              box.width!) {
        response.remainingLengthSpace = CubeDTO(
          height: box.height,
          width: box.width! - space.volumeOccupied!.length!,
          length: box.length,
        );

        response.remainingWidthSpace = CubeDTO(
          height: box.height,
          width: box.width,
          length: box.length! - space.volumeOccupied!.length!,
        );

        if (productOccupied.width! < response.remainingWidthSpace!.length!) {
          response.volumeWidthOccupied = CubeDTO(
            height: productOccupied.height,
            width: productOccupied.width,
            length: productOccupied.length,
          );

          response.remainingWidthSpace = CubeDTO(
            height: box.height,
            width: response.remainingWidthSpace!.width,
            length: response.remainingWidthSpace!.length! -
                response.volumeWidthOccupied!.width!,
          );
          response.volumeLengthOccupied = CubeDTO();
        } else if (productOccupied.width! <
            response.remainingLengthSpace!.width!) {
          response.volumeLengthOccupied = CubeDTO(
            height: productOccupied.height,
            width: productOccupied.width,
            length: productOccupied.length,
          );

          response.remainingLengthSpace = CubeDTO(
            height: box.height,
            width: response.remainingLengthSpace!.width! -
                response.volumeLengthOccupied!.width!,
            length: response.remainingLengthSpace!.length,
          );

          response.volumeWidthOccupied = CubeDTO();
        } else {
          response.success = false;
        }

        //disable thể tích box
        response.remainingSpaceBox = null;
      } else {
        response.success = false;
      }
    } else if (space.remainingSpaceBox == null) {
      var recoveryRemainingLengthSpace = CubeDTO();
      var recoveryRemainingWidthSpace = CubeDTO();
      //khôi phục lại remainingWidth và length space
      //ưu tiên đặt phần remainingWidth trước

      if (space.volumeWidthOccupied != null &&
          space.volumeWidthOccupied!.length != 0) {
        recoveryRemainingWidthSpace = CubeDTO(
          height: box.height,
          width: space.remainingWidthSpace!.width,
          length: space.remainingWidthSpace!.length! +
              space.volumeWidthOccupied!.width!,
        );

        if (space.volumeWidthOccupied!.length! + productOccupied.length! <=
            response.remainingWidthSpace!.width!) {
          response.volumeWidthOccupied = CubeDTO(
            height: space.volumeWidthOccupied!.height! < productOccupied.height!
                ? productOccupied.height
                : space.volumeWidthOccupied!.height,
            width: space.volumeWidthOccupied!.width! < productOccupied.width!
                ? productOccupied.width
                : space.volumeWidthOccupied!.width,
            length:
                space.volumeWidthOccupied!.length! + productOccupied.length!,
          );

          response.remainingWidthSpace = CubeDTO(
            height: box.height,
            width: recoveryRemainingWidthSpace.width,
            length: recoveryRemainingWidthSpace.length! -
                response.volumeWidthOccupied!.width!,
          );
        } else if (space.volumeWidthOccupied!.width! + productOccupied.width! <=
            response.remainingWidthSpace!.length!) {
          response.volumeWidthOccupied = CubeDTO(
            height: space.volumeWidthOccupied!.height! < productOccupied.height!
                ? productOccupied.height
                : space.volumeWidthOccupied!.height,
            width: space.volumeWidthOccupied!.width! + productOccupied.width!,
            length: space.volumeWidthOccupied!.length! < productOccupied.length!
                ? productOccupied.length
                : space.volumeWidthOccupied!.length,
          );

          response.remainingWidthSpace = CubeDTO(
            height: box.height,
            width: recoveryRemainingWidthSpace.width,
            length: recoveryRemainingWidthSpace.length! -
                response.volumeWidthOccupied!.width!,
          );
        }
      }
      if (space.volumeLengthOccupied != null &&
          space.volumeLengthOccupied!.length != 0) {
        recoveryRemainingLengthSpace = CubeDTO(
          height: box.height,
          width: space.remainingLengthSpace!.width! +
              space.volumeLengthOccupied!.length!,
          length: space.remainingLengthSpace!.length,
        );

        if (space.volumeLengthOccupied != null &&
            (space.volumeLengthOccupied!.width! + productOccupied.width! <=
                response.remainingLengthSpace!.width!)) {
          response.volumeLengthOccupied = CubeDTO(
            height:
                space.volumeLengthOccupied!.height! < productOccupied.height!
                    ? productOccupied.height
                    : space.volumeLengthOccupied!.height,
            width: space.volumeLengthOccupied!.width! + productOccupied.width!,
            length:
                space.volumeLengthOccupied!.length! < productOccupied.length!
                    ? productOccupied.length
                    : space.volumeLengthOccupied!.length!,
          );

          response.remainingLengthSpace = CubeDTO(
            height: box.height,
            width: recoveryRemainingLengthSpace.width,
            length: recoveryRemainingLengthSpace.length! -
                response.volumeLengthOccupied!.length!,
          );
        } else if (space.volumeLengthOccupied != null &&
            (space.volumeLengthOccupied!.length! + productOccupied.length! <=
                response.remainingLengthSpace!.length!)) {
          response.volumeLengthOccupied = CubeDTO(
            height:
                space.volumeLengthOccupied!.height! < productOccupied.height!
                    ? productOccupied.height
                    : space.volumeLengthOccupied!.height,
            width: space.volumeLengthOccupied!.width! < productOccupied.width!
                ? productOccupied.width
                : space.volumeLengthOccupied!.width,
            length:
                space.volumeLengthOccupied!.length! + productOccupied.length!,
          );

          recoveryRemainingLengthSpace = CubeDTO(
            height: box.height,
            width: recoveryRemainingLengthSpace.width,
            length: recoveryRemainingLengthSpace.length! -
                response.volumeLengthOccupied!.length!,
          );
        } else {
          response.success = false;
        }
      } else {
        response.success = false;
      }
    } else {
      response.success = false;
    }
    return response;
  }
}
