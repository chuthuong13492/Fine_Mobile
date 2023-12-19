import 'package:dio/dio.dart';
import 'package:fine/Constant/productRecommend_status.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/product_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Accessories/dialog.dart';
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
  Cart? checkCart;
  List<ReOrderDTO>? reOrderList;
  List<ProductInCart>? listRecommend;
  // List<CheckFixBoxRequest>? card;
  double total = 0, fixTotal = 0, extraTotal = 0;
  int quantityChecked = 0;
  bool? isSelected = false;
  bool? isConfirm;
  String? code;
  BoxesResponse? boxes;
  DestinationDAO? _destinationDAO;
  ProductDAO? _productDAO;
  PartyOrderDAO? _partyDAO;
  final ValueNotifier<int> notifier = ValueNotifier(0);

  CartViewModel() {
    _storeDAO = StoreDAO();
    _destinationDAO = DestinationDAO();
    _productDAO = ProductDAO();
    _partyDAO = PartyOrderDAO();
    currentCart = null;
    checkCart = null;
  }

  Future<void> editProductParty(
      CartItem cartItem, int quantity, double editTotal) async {
    try {
      CartItem item = CartItem(
          cartItem.productId,
          cartItem.productName,
          cartItem.imgUrl,
          cartItem.size,
          cartItem.rotationType,
          cartItem.height,
          cartItem.width,
          cartItem.length,
          cartItem.price,
          editTotal,
          quantity,
          cartItem.isStackable,
          cartItem.isChecked,
          cartItem.isAddParty);
      bool? isAdded = await processCart(item);

      if (isAdded == true) {
        await updateItemFromCart(item);
        quantityChecked -= cartItem.quantity;
        total -= cartItem.fixTotal!;
        quantityChecked += quantity;
        total += editTotal;
        await addProductToPartyOrder();
      }
      currentCart = await getCart();
      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> changeValueChecked(bool value, CartItem cartItem) async {
    try {
      if (value == true) {
        // bool? isAdded = await Get.find<ProductDetailViewModel>()
        //     .processCart(cartItem.productId, cartItem.quantity);
        bool? isAdded = await processCart(cartItem);
        await updateCheckItemFromCart(cartItem, isAdded!);
        if (isAdded == true) {
          getTotalQuantity(isAdded, cartItem);
        }
      } else {
        ConfirmCartItem item =
            ConfirmCartItem(cartItem.productId, cartItem.quantity, "");
        await removeItemFromMart(item);
        await updateCheckItemFromCart(cartItem, value);
        await getTotalQuantity(value, cartItem);
        checkCart!.items!
            .removeWhere((element) => element.productId == cartItem.productId);
        if (checkCart!.items!.isEmpty) {
          listRecommend = null;
        } else {
          await getProductRecommend();
        }
        // await updateCheckItemFromCart(cartItem, value);
      }
      currentCart = await getCart();
      isSelected =
          currentCart!.items!.any((element) => element.isChecked == true);

      notifyListeners();
    } catch (e) {
      rethrow;
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
        // await getProductRecommend();
        await Future.delayed(const Duration(microseconds: 500));
        await Get.find<OrderViewModel>().prepareOrder();
        final error = Get.find<OrderViewModel>().errorMessage;
        if (error == null) {
          Get.toNamed(RouteHandler.ORDER);
        }
      }
    } catch (e) {
      rethrow;
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
      await deleteMart();
      currentCart = await getCart();

      checkCart = Cart(timeSlotId: root.selectedTimeSlot!.id);

      if (currentCart == null) {
        isConfirm = false;
        notifier.value = 0;
        quantityChecked = 0;
        total = 0;
      } else {
        final orderDetails = currentCart!.items!
            .where((element) => element.isChecked == true)
            .toList();
        for (var item in orderDetails) {
          checkCart!.items!.add(item);
        }
        if (checkCart!.items!.length == 5 || checkCart!.items!.isEmpty) {
          listRecommend = [];
        } else {
          await getProductRecommend();
        }
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
        if (isSelected == true) {
          final partyModel = Get.find<PartyOrderViewModel>();
          isConfirm = partyModel.isConfirm;
          List<ConfirmCartItem> martItem = [];
          final list = currentCart?.items
              ?.where((element) => element.isChecked == true)
              .toList();

          for (var e in list!) {
            ConfirmCartItem confirmCartItem =
                ConfirmCartItem(e.productId, e.quantity, "");
            martItem.add(confirmCartItem);
          }
          final mart = ConfirmCart.get(
            timeSlotId: root.selectedTimeSlot!.id,
            orderDetails: martItem,
          );
          await setMart(mart);
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

  Future<void> addProductToPartyOrder() async {
    try {
      // setState(ViewStatus.Loading);
      final partyCode = await getPartyCode();
      final cart = await getMart();
      if (cart != null) {
        final partyOrderDTO =
            await _partyDAO?.addProductToParty(partyCode, cart: cart);
        Get.rawSnackbar(
            message: "Thêm thành công ✓",
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.only(left: 8, right: 8, bottom: 32),
            borderRadius: 8);
        for (var item in cart.orderDetails!) {
          CartItem cartItem = CartItem(item.productId, "", "", "", 0, 0, 0, 0,
              0, 0, 0, false, false, true);
          await updateAddedItemtoCart(cartItem, true);
        }
        currentCart = await getCart();
      }
      Get.find<PartyOrderViewModel>().getPartyOrder();
      // setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      Get.rawSnackbar(
          message: "Thêm thất bại",
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.only(left: 8, right: 8, bottom: 32),
          borderRadius: 8);
      // setState(ViewStatus.Error);
    }
  }

  Future<void> removeProductInPartyOrder(String productId) async {
    try {
      // setState(ViewStatus.Loading);
      final partyCode = await getPartyCode();
      final cart = await getMart();
      if (cart != null) {
        bool hasProduct =
            cart.orderDetails!.any((element) => element.productId == productId);
        if (hasProduct == true) {
          ConfirmCartItem item = ConfirmCartItem(productId, 0, "");
          CartItem cartItem = CartItem(item.productId, "", "", "", 0, 0, 0, 0,
              0, 0, 0, false, false, false);
          await changeValueChecked(false, cartItem);
          // await removeItemFromMart(item);
          await removeItemFromParty(item);
          await updateAddedItemtoCart(cartItem, false);
        }
        final mart = await getMart();
        final partyOrderDTO =
            await _partyDAO?.addProductToParty(partyCode, cart: mart);
        currentCart = await getCart();
        await Get.find<PartyOrderViewModel>().getPartyOrder();
      }
      // await Get.find<PartyOrderViewModel>().getPartyOrder();

      // setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      Get.rawSnackbar(
          message: "Xóa thất bại",
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.only(left: 8, right: 8, bottom: 32),
          borderRadius: 8);
      // setState(ViewStatus.Error);
    }
  }

  Future<void> removeCart() async {
    checkCart = Cart(timeSlotId: root.selectedTimeSlot!.id);
    await deleteCart();
    await deleteMart();
    total = 0;
    quantityChecked = 0;
    notifier.value = 0;
    currentCart = await getCart();
    notifyListeners();
  }

  Future<void> updateItem(CartItem item, int index, bool isIncrease) async {
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
      false,
      item.isAddParty,
    );
    await updateItemFromCart(cartItem);
    ConfirmCartItem confirmCartItem =
        ConfirmCartItem(item.productId, item.quantity, "");
    await removeItemFromMart(confirmCartItem);
    if (checkCart != null && checkCart!.items!.isNotEmpty) {
      bool? hasCheckProd = checkCart?.items
          ?.any((element) => element.productId == item.productId);
      if (hasCheckProd == true) {
        checkCart!.items!
            .removeWhere((element) => element.productId == item.productId);
        await getProductRecommend();
      }
    }

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

  Future<bool?> processCart(CartItem cartItem) async {
    ConfirmCart? mart = await getMart();
    if (mart == null) {
      ConfirmCart preMart = ConfirmCart(timeSlotId: root.selectedTimeSlot!.id);
      await setMart(preMart);
    }
    mart = await getMart();
    if (checkCart!.items!.isEmpty) {
      checkCart!.items!.add(cartItem);
    } else {
      bool? hasItem = checkCart!.items!
          .any((element) => element.productId == cartItem.productId);
      if (hasItem == false) {
        checkCart!.items!.add(cartItem);
      } else {
        checkCart!.items!
            .removeWhere((element) => element.productId == cartItem.productId);
        checkCart!.items!.add(cartItem);
      }
    }
    if (checkCart!.itemQuantity() > 6) {
      checkCart!.items!
          .removeWhere((element) => element.productId == cartItem.productId);
      await showStatusDialog("assets/images/error.png", "Box đã đầy",
          "Box đã đầy ùi, Box chỉ chứa tối đa 6 món thui nè");
      return false;
    }

    final addToBoxResult = await checkProductFixTheBox(cartItem);
    if (addToBoxResult!.quantitySuccess == cartItem.quantity) {
      ConfirmCartItem martItem =
          ConfirmCartItem(cartItem.productId, cartItem.quantity, "");

      if (mart!.orderDetails != null || mart.orderDetails!.isNotEmpty) {
        bool hasMartItem = mart.orderDetails!
            .any((element) => element.productId == martItem.productId);
        if (hasMartItem == false) {
          await addItemToMart(martItem);
        } else {
          await updateItemFromMart(martItem);
        }
      }

      bool? isChecked = await getProductRecommend(cartItem: cartItem);
      return isChecked;
    } else if (addToBoxResult.quantitySuccess! < cartItem.quantity &&
        addToBoxResult.quantitySuccess != 0) {
      CartItem resultItem = CartItem(
          cartItem.productId,
          cartItem.productName,
          cartItem.imgUrl,
          cartItem.size,
          cartItem.rotationType,
          cartItem.height,
          cartItem.width,
          cartItem.length,
          cartItem.price,
          cartItem.fixTotal,
          addToBoxResult.quantitySuccess!,
          cartItem.isStackable,
          cartItem.isChecked,
          false);
      ConfirmCartItem martItem = ConfirmCartItem(
          cartItem.productId, addToBoxResult.quantitySuccess!, "");
      checkCart?.updateQuantity(resultItem);
      await updateItemFromCart(resultItem);
      await addItemToMart(martItem);
      bool? isChecked = await getProductRecommend(cartItem: cartItem);
      await showStatusDialog("assets/images/error.png", "Box đã đầy",
          "Box đã đầy rùi, bạn chỉ có thể thêm ${addToBoxResult.quantitySuccess} phần ${cartItem.productName}");
      return isChecked;
    } else {
      checkCart!.items!
          .removeWhere((element) => element.productId == cartItem.productId);
      await showStatusDialog("assets/images/error.png", "Box đã đầy",
          "Box đã đầy mất ùi, bạn hong thể thêm ${cartItem.productName}");
      listRecommend = [];
      Get.find<OrderViewModel>().productRecomend = listRecommend;
      return false;
    }
  }

  Future<bool?> getProductRecommend({CartItem? cartItem}) async {
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
    // tính thể tích bị chiếm bởi các product trong card trước
    if (checkCart != null && checkCart!.items!.isNotEmpty) {
      checkCart!.items!.sort((a, b) => (b.length! * b.width! * b.height!)
          .compareTo(a.length! * a.width! * a.height!));
      for (var item in checkCart!.items!) {
        // ghép product lên cho vừa họp dựa trên quantity yêu cầu
        ProductParingResponse? pairingCardResult =
            await productPairing(item.quantity, item, boxSize);

        var turnCard =
            (item.quantity / pairingCardResult!.quantityCanAdd!).ceilToDouble();
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
          } else {
            break;
          }
        }
      }
      if (checkCart!.itemQuantity() == 5) {
        listRecommend = [];
        Get.find<OrderViewModel>().productRecomend = listRecommend;
        return true;
      } else {
        ProductRecommendStatus? recommendStatus =
            await _productDAO?.getProductRecommend(
                root.isNextDay == true ? 2 : 1,
                root.selectedTimeSlot!.id!,
                spaceInBox,
                productId: cartItem != null ? cartItem.productId! : null);

        if (recommendStatus?.statusCode == 200) {
          listRecommend = recommendStatus?.recommend;
          Get.find<OrderViewModel>().productRecomend = listRecommend;
          return true;
        }
        switch (recommendStatus?.code) {
          case 4006:
            await showStatusDialog("assets/images/error.png", "Oops!!",
                "1 khung giờ chỉ được đặt tối đa 2 đơn thui nè!");
            return false;
          case 4002:
            await showStatusDialog("assets/images/error.png", "Oops!!",
                "Món này đã hết mất rùi 😢");
            await removeItemFromCart(cartItem!);
            ConfirmCartItem martItem =
                ConfirmCartItem(cartItem.productId, cartItem.quantity, "");
            await removeItemFromMart(martItem);
            checkCart?.removeItem(cartItem);
            currentCart = await getCart();
            return false;
          case 4001:
            await showStatusDialog("assets/images/error.png", "Oops!!",
                "Đã hết thời gian mất rùi 😢");
            await removeCart();

            return false;
          default:
            return false;
        }
      }
    }
    return false;
  }

  Future<FixBoxResponse?> checkProductFixTheBox(CartItem cartItem) async {
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
      // tính thể tích bị chiếm bởi các product trong card trước
      checkCart!.items!.sort((a, b) => (b.length! * b.width! * b.height!)
          .compareTo(a.length! * a.width! * a.height!));
      for (var item in checkCart!.items!) {
        // ghép product lên cho vừa họp dựa trên quantity yêu cầu
        ProductParingResponse? pairingCardResult =
            await productPairing(item.quantity, item, boxSize);

        var turnCard =
            (item.quantity / pairingCardResult!.quantityCanAdd!).ceilToDouble();
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

            if (cartItem != null) {
              if (item.productId == cartItem.productId) {
                if (successCase == turnCard) {
                  fillBoxResponse.quantitySuccess = cartItem.quantity;
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
      int quantity, CartItem cartItem, CubeDTO boxSize) async {
    ProductParingResponse paringResponse =
        ProductParingResponse(productSupplanted: null, quantityCanAdd: 1);
    switch (cartItem.rotationType) {
      case ProductRotationTypeEnum.BOTH:
        if (cartItem.length! < boxSize.height!) {
          if (cartItem.width! < cartItem.height!) {
            paringResponse.productSupplanted = CubeDTO(
              height: cartItem.length,
              width: cartItem.width,
              length: cartItem.height,
            );
          } else {
            paringResponse.productSupplanted = CubeDTO(
              height: cartItem.length,
              width: cartItem.height,
              length: cartItem.width,
            );
          }
        }
        break;
      // nếu product mặc định nằm ngang => product nằm chồng lên nhau => số lượng có thể add * product.h < product.h (tùy thuộc có thể chồng hay ko)
      case ProductRotationTypeEnum.HORIZONTAL:
        if (cartItem.isStackable == true) {
          paringResponse.quantityCanAdd =
              (boxSize.height! / cartItem.height!).floor();
          if (paringResponse.quantityCanAdd! > quantity) {
            paringResponse.quantityCanAdd = quantity;
          }

          paringResponse.productSupplanted = CubeDTO(
            height: cartItem.height! * paringResponse.quantityCanAdd!,
            width: cartItem.width,
            length: cartItem.length,
          );
        } else {
          paringResponse.productSupplanted = CubeDTO(
            height: cartItem.height,
            width: cartItem.width,
            length: cartItem.length,
          );
        }
        break;
      case ProductRotationTypeEnum.VERTICAL:
        paringResponse.productSupplanted = CubeDTO(
          height: cartItem.height,
          width: cartItem.width,
          length: cartItem.length,
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
      volumeOccupied: space.volumeOccupied,
    );
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
          length: box.length! - space.volumeOccupied!.width!,
        );
        //ưu tiên RemainingWidthSpace
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
          response.volumeLengthOccupied =
              CubeDTO(height: 0, width: 0, length: 0);
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

          response.volumeWidthOccupied =
              CubeDTO(height: 0, width: 0, length: 0);
        } else {
          response.success = false;
        }

        //disable thể tích box
        response.remainingSpaceBox = null;
      } else {
        response.success = false;
      }
    } else if (space.remainingSpaceBox == null) {
      var recoveryRemainingLengthSpace =
          CubeDTO(height: 0, width: 0, length: 0);
      var recoveryRemainingWidthSpace = CubeDTO(height: 0, width: 0, length: 0);
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
