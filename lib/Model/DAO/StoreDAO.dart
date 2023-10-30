import 'package:fine/Model/DAO/BaseDAO.dart';
import 'package:fine/Model/DTO/MetaDataDTO.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/request.dart';

import '../DTO/index.dart';

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

  Future<List<SupplierDTO>?> getSuppliers(String timeSlotId,
      {int? page, int? size}) async {
    final res = await request.get(
      '/store/timeslot/$timeSlotId',
      queryParameters: {"size": size ?? DEFAULT_SIZE, "page": page ?? 1},
    );
    var jsonList = res.data["data"] as List;
    //metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
    if (jsonList != null) {
      // List<SupplierDTO>? list = jsonList
      //     .map((e) => SupplierDTO.fromJson(e))
      //     .where((element) => element.active!)
      //     .toList();
      return jsonList.map((e) => SupplierDTO.fromJson(e)).toList();
      // list.where((element) => element.available == true).toList();
    }
    return null;
  }

  Future<List<BlogDTO>?> getBlogs() async {
    List listBlog = [
      {
        'active': true,
        'imageUrl':
            "https://img.freepik.com/premium-photo/set-organic-healthy-diet-food-superfoods-beans-legumes-nuts-seeds-greens-fruit-vegetables-dark-blue-background-copy-space-top-view_136595-12939.jpg",
      },
      {
        'active': true,
        'imageUrl':
            "https://img.freepik.com/premium-photo/food-background-set-food-old-black-background-concept-healthy-eating-top-view-free-space-text_187166-34662.jpg",
      },
      {
        'active': true,
        'imageUrl':
            "https://img.freepik.com/premium-photo/healthy-food-background-autumn-fresh-vegetables-dark-stone-table-with-copy-space-top-view_127032-1954.jpg",
      },
      {
        'active': true,
        'imageUrl':
            "https://t4.ftcdn.net/jpg/05/53/15/53/360_F_553155350_Oy6YtiH5ovW3SyInD94Pr3gKqI7YaL3V.webp",
      }
    ];
    // final res = await request.get(
    //   "/blog-post",
    //   // queryParameters: {"page": page, "size": size}..addAll(params),
    // );
    if (listBlog != null) {
      // var listJson = res.data['data'] as List;
      // metaDataDTO = MetaDataDTO.fromJson(res.data['metadata']);
      return listBlog.map((e) => BlogDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<List<ReOrderDTO>?> getReOrder(String? timeSlotId,
      {Map<String, dynamic> params = const {}}) async {
    final res = await request.get(
      // 'collections?menu-id=${menuId}',
      '/menu/timeslot/${timeSlotId}',
      queryParameters: params,
    );
    var listJson = res.data['data']["reOrders"] as List;
    if (listJson.isNotEmpty) {
      return listJson.map((e) => ReOrderDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<OrderDTO?> createReOrder(String id, int orderType) async {
    final res = await request.post(
      '/order/reOrder?orderId=$id&orderType=$orderType',
    );
    if (res.statusCode == 200) {
      return OrderDTO.fromJson(res.data["data"]["orderResponse"]);
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
