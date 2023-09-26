import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Utils/request.dart';

class TopUpDAO extends BaseDAO {
  Future<String?> getTopUpUrl(String amount) async {
    final res = await request.get("/customer/topupUrl?amount=$amount");
    if (res.data["data"] != null) {
      return res.data["data"];
    }
    return null;
  }
}
