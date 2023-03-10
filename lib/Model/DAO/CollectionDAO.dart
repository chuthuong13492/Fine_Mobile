import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CollectionDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/request.dart';

class CollectionDAO extends BaseDAO {
  // Future<List<CollectionDTO>> getCollectionsOfSupplier(
  //     int storeId, int supplierId, int menuId,
  //     {Map<String, dynamic> params = const {}}) async {
  //   final res = await request.get(
  //     'stores/$storeId/suppliers/$supplierId/collections?menu-id=${menuId}',
  //     queryParameters: params,
  //   );
  //   //final res = await Dio().get("http://api.dominos.reso.vn/api/v1/products");
  //   final categories = CollectionDTO.fromList(res.data["data"]);
  //   return categories;
  // }

  // Future<List<CollectionDTO>?> getCollections(int? timeSlotId,
  //     {Map<String, dynamic> params = const {}}) async {
  //   final res = await request.get(
  //     // 'collections?menu-id=${menuId}',
  //     '/menu/timeslot/${timeSlotId}/product',
  //     queryParameters: params,
  //   );
  //   if (res.data["data"] != null) {
  //     var listJson = res.data['data'] as List;
  //     return listJson.map((e) => CollectionDTO.fromJson(e)).toList();
  //   }
  //   // final collections = CollectionDTO.fromJson(res.data["data"]);
  //   return null;
  // }
}
