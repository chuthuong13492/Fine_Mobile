import 'package:dio/dio.dart';
import 'package:fine/Model/DTO/CategoryDTO.dart';
import 'package:fine/Model/DTO/MetaDataDTO.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/request.dart';
// import 'package:dio_http_cache/dio_http_cache.dart';

class CategoryDAO {
  MetaDataDTO? _metaDataDTO;

  MetaDataDTO get metaDataDTO => _metaDataDTO!;
  Future<List<CategoryDTO>?> getCategories({
    Map<String, dynamic>? params,
  }) async {
    final res = await request.get(
      '/system-category?PageSize=12',
      queryParameters: params,
      // queryParameters: {"page": page, "size": size}..addAll(params),

      // options: buildCacheOptions(Duration(minutes: 5)),
    );

    //final res = await Dio().get("http://api.dominos.reso.vn/api/v1/products");
    // final categories = CategoryDTO.fromJson(categoryList);
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      // metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      return listJson.map((e) => CategoryDTO.fromJson(e)).toList();
    }
    return null;
  }

  set metaDataDTO(MetaDataDTO value) {
    _metaDataDTO = value;
  }
}
