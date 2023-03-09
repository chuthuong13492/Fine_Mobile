import 'package:fine/Model/DAO/BaseDAO.dart';
import 'package:fine/Model/DTO/BlogDTO.dart';
import 'package:fine/Model/DTO/MetaDataDTO.dart';
import 'package:fine/Utils/request.dart';

class StoreDAO extends BaseDAO {
  //   Future<List<CampusDTO>> getStores({int id}) async {
  //   Response res;
  //   if (id != null) {
  //     res = await request.get('stores', queryParameters: {
  //       "type": VIRTUAL_STORE_TYPE,
  //       "main-store": false,
  //       "has-menu": true,
  //       "id": id
  //     });
  //   } else {
  //     res = await request.get('stores', queryParameters: {
  //       "type": VIRTUAL_STORE_TYPE,
  //       "main-store": false,
  //       "has-menu": true,
  //     });
  //   }
  //   var jsonList = res.data["data"] as List;
  //   if (jsonList != null) {
  //     List<CampusDTO> list =
  //         jsonList.map((e) => CampusDTO.fromJson(e)).toList();
  //     return list;
  //   }
  //   return null;
  // }

  // Future<List<SupplierDTO>> getSuppliers(int storeId, int menuID,
  //     {int page, int size}) async {
  //   final res = await request.get('stores/$storeId/suppliers?menu-id=${menuID}',
  //       queryParameters: {"size": size ?? DEFAULT_SIZE, "page": page ?? 1});
  //   var jsonList = res.data["data"] as List;
  //   //metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
  //   if (jsonList != null) {
  //     List<SupplierDTO> list = jsonList
  //         .map((e) => SupplierDTO.fromJson(e))
  //         .where((element) => element.available)
  //         .toList();
  //     // list.where((element) => element.available == true).toList();
  //     return list;
  //   }
  //   return null;
  // }
  Future<List<BlogDTO>?> getBlogs() async {
    final res = await request.get(
      "/blog-post",
      // queryParameters: {"page": page, "size": size}..addAll(params),
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data['metadata']);
      return listJson.map((e) => BlogDTO.fromJson(e)).toList();
    }
    return null;
  }
  //   Future<List<LocationDTO>> getLocations(int storeId) async {
  //   final res = await request.get('stores/$storeId/locations');
  //   var jsonList = res.data["data"] as List;
  //   //metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
  //   if (jsonList != null) {
  //     List<LocationDTO> list =
  //         jsonList.map((e) => LocationDTO.fromJson(e)).toList();
  //     return list;
  //   }
  //   return null;
  // }
}
