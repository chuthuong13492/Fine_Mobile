import 'package:dio/dio.dart';
import 'package:fine/Constant/order_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/MetaDataDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/request.dart';

class OrderDAO extends BaseDAO {
  Future<OrderDTO?> getOrderById(String? orderId) async {
    // data["destination_location_id"] = destinationId;
    final res = await request.get('/order/$orderId');
    if (res.data['data'] != null) {
      return OrderDTO.fromJson(res.data['data']);
    }
    return null;
  }

  Future<List<OrderDTO>?> getOrders({int? page, int? size}) async {
    final res = await request.get(
      '/customer/orders',
      queryParameters: {
        // "order-status":
        //     filter == OrderFilter.NEW ? ORDER_NEW_STATUS : ORDER_DONE_STATUS,
        "size": size ?? DEFAULT_SIZE,
        "page": page ?? 1,
      },
    );
    if (res.statusCode == 200) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => OrderDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<List<OrderDTO>?> getMoreOrders({int? page, int? size}) async {
    final res = await request.get(
      '/customer/orders?Page=$page',
      queryParameters: {
        // "order-status":
        //     filter == OrderFilter.NEW ? ORDER_NEW_STATUS : ORDER_DONE_STATUS,
        // "size": size ?? DEFAULT_SIZE,
        // "page": page ?? 1,
      },
    );
    List<OrderDTO>? orderSummaryList;
    if (res.statusCode == 200) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => OrderDTO.fromJson(e)).toList();
    }
    return null;
  }

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

  Future<bool> cancelOrder(int orderId) async {
    final res = await request.put(
      '/order/usercancel?orderId=$orderId',
      // data: ORDER_CANCEL_STATUS,
    );

    return res.statusCode == 200;
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
