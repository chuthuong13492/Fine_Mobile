import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fine/Constant/addProdcutToCart_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/request.dart';

import '../../Constant/productRecommend_status.dart';
import '../DTO/ConfirmCartDTO.dart';
import '../DTO/CubeModel.dart';

class ProductDAO extends BaseDAO {
  Future<ProductDTO?> getProductDetail(
    String? productId, {
    int page = 1,
    int size = 10,
    int? total,
    Map<String, dynamic> params = const {},
  }) async {
    final res = await request.get(
      // 'collections?menu-id=${menuId}',
      '/product/${productId}',
      // queryParameters: {"page": page, "size": size}..addAll(params),
    );
    if (res.data["data"] != null) {
      var listJson = res.data['data'];
      final product = ProductDTO.fromJson(listJson);
      return product;
    }
    return null;
  }

  Future<ProductRecommendStatus?> getProductRecommend(
      int orderType, String timeSlotId, SpaceInBoxMode space,
      {String? productId}) async {
    Map map;
    if (productId != null) {
      map = {
        "orderType": orderType,
        "timeSlotId": timeSlotId,
        "productId": productId,
        "remainingLengthSpace": {
          "height": space.remainingLengthSpace!.height,
          "width": space.remainingLengthSpace!.width,
          "length": space.remainingLengthSpace!.length,
        },
        "remainingWidthSpace": {
          "height": space.remainingWidthSpace!.height,
          "width": space.remainingWidthSpace!.width,
          "length": space.remainingWidthSpace!.length,
        },
      };
    } else {
      map = {
        "orderType": orderType,
        "timeSlotId": timeSlotId,
        "remainingLengthSpace": {
          "height": space.remainingLengthSpace!.height,
          "width": space.remainingLengthSpace!.width,
          "length": space.remainingLengthSpace!.length,
        },
        "remainingWidthSpace": {
          "height": space.remainingWidthSpace!.height,
          "width": space.remainingWidthSpace!.width,
          "length": space.remainingWidthSpace!.length,
        },
      };
    }
    try {
      final res = await request.post("/order/cardV2", data: map);
      if (res.data["data"] != null) {
        var jsonList = res.data['data']['productsRecommend'] as List;
        // return jsonList.map((e) => ProductInCart.fromJson(e)).toList();
        return ProductRecommendStatus(
          statusCode: res.statusCode,
          code: res.data['status']['errorCode'],
          message: res.data['status']['message'],
          recommend: jsonList.map((e) => ProductInCart.fromJson(e)).toList(),
        );
      }
    } on DioError catch (e) {
      return ProductRecommendStatus(
        statusCode: e.response!.data["statusCode"],
        code: e.response!.data['errorCode'],
        message: e.response!.data['message'],
      );
    }
    return null;
  }

  Future<List<ProductDTO>?> getProductsByMenuId(
    String menuId, {
    int? page,
    int? size,
    int? type,
    Map<String, dynamic> params = const {},
  }) async {
    // final query = convertToQueryParams({
    //   "page": (page ?? 1).toString(),
    //   "size": (size ?? DEFAULT_SIZE).toString(),
    //   // "menu-id": menuID,
    //   // "fields": ['ChildProducts', 'CollectionId', 'Extras']
    // }..addAll(params));
    // var menuId = params["menu"]["id"];

    final res = await request.get(
      '/menu/$menuId',
      // queryParameters: params,
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data']['products'] as List;
      // metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      return listJson.map((e) => ProductDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<List<ProductDTO>?> getProductsInMenuByStoreId(
    int? storeId, {
    Map<String, dynamic>? params,
  }) async {
    final res = await request.get(
      '/product-in-menu/productInMenu/store/$storeId',
      queryParameters: params,
    );
    if (res.data != null) {
      var listJson = res.data as List;
      // metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      return listJson.map((e) => ProductDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<AddProductToCartStatus?> checkProductToCart(ConfirmCart cart) async {
    try {
      final res = await request.post(
        '/order/card',
        data: cart.toCheckCartJsonAPi(),
      );
      if (res.statusCode == 200) {
        return AddProductToCartStatus(
            statusCode: res.statusCode,
            code: res.data['status']['errorCode'],
            message: res.data['status']['message'],
            addProduct: AddProductToCartResponse.fromJson(res.data['data']));
        // return AddProductToCartResponse.fromJson(res.data['data']);
      }
      return null;
    } on DioError catch (e) {
      return AddProductToCartStatus(
          statusCode: e.response!.data["statusCode"],
          code: e.response!.data['errorCode'],
          message: e.response!.data['message']);
    } catch (e) {
      throw e;
    }
  }

  Future<List<ProductDTO>?> getListProductInTimeSlot(String timeSlotId) async {
    final res = await request.get('timeslot/listProduct', queryParameters: {
      'timeSlotId': timeSlotId,
    });
    if (res.data["data"] != null) {
      var listJson = res.data["data"] as List;
      return listJson.map((e) => ProductDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<int?> logError({required String messageBody}) async {
    try {
      const USER_MOBILE = 1;
      final response = await request.post('/log',
          data: jsonEncode(messageBody),
          queryParameters: {'appCatch': USER_MOBILE});
      if (response.statusCode != null) {
        return response.statusCode;
      }
      return null;
    } catch (e) {
      log(e.toString());
    }
  }

  // Future<ProductDTO>? getProductDetail(int? productId,
  //     {Map<String, dynamic> params = const {}}) async {
  //   final res = await request.get(
  //     // 'collections?menu-id=${menuId}',
  //     '/product/${productId}',
  //     queryParameters: params,
  //   );

  //   var listJson = res.data['data'];
  //   final product = ProductDTO.fromJson(listJson);
  //   return product;
  // }
}
