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

  Future<List<CampusDTO>?> getCampusList() async {
    final res = await request.get(
      "/campus",
      // queryParameters: {"page": page, "size": size}..addAll(params),
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      // metaDataDTO = MetaDataDTO.fromJson(res.data['metadata']);
      return listJson.map((e) => CampusDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<CampusDTO> getUserCampus(int campusId) async {
    final res = await request.get(
      "/campus/${campusId}",
      // queryParameters: {"page": page, "size": size}..addAll(params),
    );
    final campus = CampusDTO.fromJson(res.data['data']);
    // metaDataDTO = MetaDataDTO.fromJson(res.data['metadata']);
    return campus;
  }
}
