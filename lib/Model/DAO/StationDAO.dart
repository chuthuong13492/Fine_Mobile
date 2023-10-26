import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/request.dart';

import '../../Constant/stationList_status.dart';
import 'index.dart';

class StationDAO extends BaseDAO {
  Future<StationStatus?> getStationList(String destinationId, int quantity,
      {int? page, int? size}) async {
    final res = await request.get(
      '/station/order/',
      queryParameters: {
        "destinationId": destinationId,
        "numberBox": quantity,
      },
    );
    if (res.statusCode == 200) {
      var jsonList = res.data["data"]["listStation"] as List;
      return StationStatus(
        countDown: res.data["data"]["countDown"],
        listStation: jsonList.map((e) => StationDTO.fromJson(e)).toList(),
      );
      // return jsonList.map((e) => StationDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<Uint8List?> getBoxById(String boxId) async {
    final response = await request.get('/user-box/qrCode?boxId=$boxId',
        // queryParameters: {
        //   "boxId": boxId,
        // },
        options: Options(responseType: ResponseType.bytes));
    if (response.statusCode == 200) {
      Uint8List imageBytes = Uint8List.fromList(response.data);
      return imageBytes;
    }
    return null;
  }

  Future<bool?> lockBoxOrder(
      String stationId, String orderCode, int numberBox) async {
    final res = await request.post(
      '/station/orderBox/',
      queryParameters: {
        "stationId": stationId,
        "orderCode": orderCode,
        "numberBox": numberBox,
      },
    );
    if (res.data["data"] != null) {
      return true;
    }
  }

  Future<void> changeStation(String orderCode, int type,
      {String? stationId}) async {
    final res = await request.put(
      '/station/orderBox/',
      queryParameters: {
        "stationId": stationId,
        "orderCode": orderCode,
        "type": type,
      },
    );
    if (res.statusCode == 200) {
      return;
    }
  }
}
