import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/request.dart';

class MenuDAO extends BaseDAO {
  Future<List<MenuDTO>?> getMenus(String? timeSlotId,
      {Map<String, dynamic> params = const {}}) async {
    final res = await request.get(
      // 'collections?menu-id=${menuId}',
      '/menu/timeslot/${timeSlotId}',
      queryParameters: params,
    );
    var listJson = res.data['data']["menus"] as List;
    if (listJson.length != 0) {
      return listJson.map((e) => MenuDTO.fromJson(e)).toList();
    }
    // final collections = CollectionDTO.fromJson(res.data["data"]);
    return null;
  }
}
