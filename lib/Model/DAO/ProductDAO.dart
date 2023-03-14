import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/request.dart';

class ProductDAO extends BaseDAO {
  Future<ProductDTO?> getProductDetail(
    int? productInMenuId, {
    int page = 1,
    int size = 10,
    int? total,
    Map<String, dynamic> params = const {},
  }) async {
    final res = await request.get(
      // 'collections?menu-id=${menuId}',
      '/product-in-menu/${productInMenuId}',
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
    int? menuId, {
    Map<String, dynamic>? params,
  }) async {
    final res = await request.get(
      '/menu/${menuId}',
      queryParameters: params,
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data']['products'] as List;
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
