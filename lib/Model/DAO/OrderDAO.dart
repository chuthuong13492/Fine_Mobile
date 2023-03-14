import 'package:dio/dio.dart';
import 'package:fine/Constant/order_status.dart';
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

  Future<OrderStatus?> createOrders(OrderDTO orderDTO) async {
    try {
      if (orderDTO != null) {
        Map data = orderDTO.toJsonAPi();
        // data["destination_location_id"] = destinationId;
        final res = await request.post(
          '/order',
          data: data,
        );
        return OrderStatus(
          statusCode: res.statusCode,
          code: res.data['code'],
          message: res.data['message'],
          order: OrderDTO.fromJson(res.data['data']),
        );
      }
    } on DioError catch (e) {
      return OrderStatus(
          statusCode: e.response!.statusCode,
          code: e.response!.data['code'],
          message: e.response!.data['message']);
    } catch (e) {
      throw e;
    }
    return null;
  }
}
