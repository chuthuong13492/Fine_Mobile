import 'package:dio/dio.dart';
import 'package:fine/Constant/order_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/MetaDataDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/request.dart';

import '../DTO/ConfirmCartDTO.dart';

class OrderDAO extends BaseDAO {
  Future<OrderDTO?> getOrderById(String? orderId) async {
    // data["destination_location_id"] = destinationId;
    final res = await request.get(
      '/order/$orderId',
    );
    if (res.data['data'] != null) {
      return OrderDTO.fromJson(res.data['data']);
    }
    return null;
  }

  Future<List<OrderDTO>?> getOrders({int? page, int? size}) async {
    final res = await request.get(
      '/customer/orders',
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
      '/customer/orders',
      queryParameters: {
        "Page": page,
      },
    );
    // List<OrderDTO>? orderSummaryList;
    if (res.statusCode == 200) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => OrderDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<OrderDTO?> prepareOrder(ConfirmCart cart) async {
    final res = await request.post(
      '/order/preOrder',
      data: cart.toJsonAPi(),
    );
    if (res.statusCode == 200) {
      return OrderDTO.fromJson(res.data['data']);
    }

    return null;
  }

  Future<OrderDTO?> prepareReOrder(String orderId, int orderType) async {
    final res = await request.post('/order/reOrder', queryParameters: {
      'orderId': orderId,
      'orderType': orderType,
    });
    if (res.statusCode == 200) {
      return OrderDTO.fromJson(res.data['data']['orderResponse']);
    }

    return null;
  }

  Future<OrderStatusDTO?> fetchOrderStatus(String orderCode) async {
    final res = await request.get(
      'order/status/$orderCode',
    );
    if (res.statusCode == 200) {
      return OrderStatusDTO.fromJson(res.data['data']);
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
      Map data = orderDTO.toJsonAPi();
      // data["destination_location_id"] = destinationId;
      final res = await request.post(
        '/order',
        data: data,
      );
      if (res.statusCode == 200) {
        return OrderStatus(
          statusCode: res.statusCode,
          code: res.data['status']['errorCode'],
          message: res.data['status']['message'],
          order: OrderDTO.fromJson(res.data['data']),
        );
      }
      return null;
    } on DioError catch (e) {
      return OrderStatus(
          statusCode: e.response!.data["statusCode"],
          code: e.response!.data['errorCode'],
          message: e.response!.data['message']);
    }
  }
}
