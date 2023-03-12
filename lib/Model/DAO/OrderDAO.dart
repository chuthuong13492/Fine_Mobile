import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/request.dart';

class OrderDAO extends BaseDAO {
  Future<OrderDTO?> prepareOrder(Cart cart) async {
    if (cart != null) {
      // print("Request Note: " + note);
      final res = await request.post(
        '/order/preOrder',
        data: cart.toJsonAPi(),
      );
      if (res.statusCode == 200) {
        return OrderDTO.fromJson(res.data['data']);
      }

      return null;
    }
    return null;
  }
}
