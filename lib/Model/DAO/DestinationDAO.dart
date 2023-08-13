import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/request.dart';

class DestinationDAO extends BaseDAO {
  Future<List<TimeSlotDTO>?> getTimeSlot(String destinationId,
      {int? page, int? size}) async {
    final res = await request.get(
      "/timeslot/destination/$destinationId?PageSize=${size ?? 20}",
      // queryParameters: {"page": page, "size": size ?? 20},
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      // metaDataDTO = MetaDataDTO.fromJson(res.data['metadata']);
      return listJson.map((e) => TimeSlotDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<List<DestinationDTO>?> getDestinationIdList() async {
    final res = await request.get(
      "/destination",
      // queryParameters: {"page": page, "size": size}..addAll(params),
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      // metaDataDTO = MetaDataDTO.fromJson(res.data['metadata']);
      return listJson.map((e) => DestinationDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<DestinationDTO> getUserDestination(String destinationId) async {
    final res = await request.get(
      "/destination/${destinationId}",
      // queryParameters: {"page": page, "size": size}..addAll(params),
    );
    final destination = DestinationDTO.fromJson(res.data['data']);
    // metaDataDTO = MetaDataDTO.fromJson(res.data['metadata']);
    return destination;
  }
}
