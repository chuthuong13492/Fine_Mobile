import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/request.dart';

class MenuDAO extends BaseDAO {
  Future<List<MenuDTO>?> getCollections(int? timeSlotId,
      {Map<String, dynamic> params = const {}}) async {
    final res = await request.get(
      // 'collections?menu-id=${menuId}',
      '/menu/timeslot/${timeSlotId}/product',
      queryParameters: params,
    );
    if (res.data["data"] != null) {
      var listJson = res.data['data'] as List;
      return listJson.map((e) => MenuDTO.fromJson(e)).toList();
    }
    // final collections = CollectionDTO.fromJson(res.data["data"]);
    return null;
  }
}
