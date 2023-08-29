import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/request.dart';

import 'index.dart';

class StationDAO extends BaseDAO {
  Future<List<StationDTO>?> getStationList(String destinationId,
      {int? page, int? size}) async {
    final res = await request.get(
      '/station/destination/$destinationId',
      // queryParameters: {"size": size ?? DEFAULT_SIZE, "page": page ?? 1},
    );
    var jsonList = res.data["data"] as List;
    //metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
    if (jsonList != null) {
      return jsonList.map((e) => StationDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<Uint8List?> getBoxById(String boxId) async {
    final response = await request.get('/user-box/qrCode?boxId=$boxId',
        options: Options(responseType: ResponseType.bytes));
    if (response.statusCode == 200) {
      Uint8List imageBytes = Uint8List.fromList(response.data);
      return imageBytes;
    }
    return null;
  }
}
