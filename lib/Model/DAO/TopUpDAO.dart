import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/Transaction.dart';
import 'package:fine/Utils/request.dart';

import '../DTO/MetaDataDTO.dart';

class TopUpDAO extends BaseDAO {
  Future<String?> getTopUpUrl(String amount) async {
    final res = await request.get("/customer/topupUrl?amount=$amount");
    if (res.data["data"] != null) {
      return res.data["data"];
    }
    return null;
  }

  Future<List<TransactionDTO>?> getTransaction() async {
    final res = await request.get(
      '/customer/transaction',
    );
    if (res.statusCode == 200) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);

      return listJson.map((e) => TransactionDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<List<TransactionDTO>?> getMoreTransaction(
      {int? page, int? size}) async {
    final res = await request.get(
      '/customer/transaction?Page=${page}',
    );
    // List<OrderDTO>? orderSummaryList;
    if (res.statusCode == 200) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      return listJson.map((e) => TransactionDTO.fromJson(e)).toList();
    }
    return null;
  }
}
