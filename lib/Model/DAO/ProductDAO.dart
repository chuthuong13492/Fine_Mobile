import 'package:dio/dio.dart';
import 'package:fine/Constant/addProdcutToCart_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/request.dart';

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

  Future<AddProductToCartStatus?> checkProductToCart(Cart cart) async {
    try {
      if (cart != null) {
        // print("Request Note: " + note);
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
