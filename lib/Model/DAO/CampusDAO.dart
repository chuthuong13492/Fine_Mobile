import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/request.dart';

class CampusDAO extends BaseDAO {
  Future<List<TimeSlotDTO>?> getTimeSlot() async {
    final res = await request.get(
      "/timeslot",
      // queryParameters: {"page": page, "size": size}..addAll(params),
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      // metaDataDTO = MetaDataDTO.fromJson(res.data['metadata']);
      return listJson.map((e) => TimeSlotDTO.fromJson(e)).toList();
    }
    return null;
  }
}
