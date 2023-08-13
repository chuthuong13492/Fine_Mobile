import 'package:fine/Model/DAO/index.dart';
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
      queryParameters: {"page": page, "size": size}..addAll(params),
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
