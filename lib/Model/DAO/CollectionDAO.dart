import 'package:fine/Model/DTO/CollectionDTO.dart';
import 'package:fine/Utils/request.dart';

class CollectionDAO {
  Future<List<CollectionDTO>> getCollectionsOfSupplier(
      int storeId, int supplierId, int menuId,
      {Map<String, dynamic> params = const {}}) async {
    final res = await request.get(
      'stores/$storeId/suppliers/$supplierId/collections?menu-id=${menuId}',
      queryParameters: params,
    );
    //final res = await Dio().get("http://api.dominos.reso.vn/api/v1/products");
    final categories = CollectionDTO.fromList(res.data["data"]);
    return categories;
  }

  Future<List<CollectionDTO>> getCollections(int menuId,
      {Map<String, dynamic> params = const {}}) async {
    final res = await request.get(
      'collections?menu-id=${menuId}',
      queryParameters: params,
    );
    final collections = CollectionDTO.fromList(res.data["data"]);
    return collections;
  }
}
