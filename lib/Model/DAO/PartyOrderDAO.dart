import 'package:dio/dio.dart';
import 'package:fine/Constant/order_status.dart';
import 'package:fine/Constant/partyOrder_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/request.dart';

class PartyOrderDAO extends BaseDAO {
  Future<PartyOrderDTO?> coOrder(Cart cart) async {
    if (cart != null) {
      // print("Request Note: " + note);
      final res = await request.post(
        '/order/coOrder/active',
        data: cart.toJsonAPi(),
      );
      if (res.statusCode == 200) {
        return PartyOrderDTO.fromJson(res.data['data']);
      }
      return null;
    }
    return null;
  }

  Future<PartyOrderStatus?> getPartyOrder(String? code) async {
    try {
      final res = await request.get(
        '/order/coOrder/$code',
      );
      return PartyOrderStatus(
        statusCode: res.statusCode,
        code: res.data['code'],
        message: res.data['message'],
        partyOrderDTO: PartyOrderDTO.fromJson(res.data['data']),
      );
    } on DioError catch (e) {
      return PartyOrderStatus(
          statusCode: e.response!.statusCode,
          code: e.response!.data['code'],
          message: e.response!.data['message']);
    } catch (e) {
      throw e;
    }
    return null;
    // print("Request Note: " + note);
  }

  Future<PartyOrderDTO?> joinPartyOrder(String? code) async {
    final res = await request.put(
      '/order/coOrder/party?partyCode=$code',
    );
    if (res.statusCode == 200) {
      return PartyOrderDTO.fromJson(res.data['data']);
    }
    return null;
  }

  Future<PartyOrderDTO?> addProductToParty(String? code, {Cart? cart}) async {
    // print("Request Note: " + note);
    final res = await request.post(
      '/order/coOrder/card?partyCode=$code',
      data: cart!.toJsonAPi(),
    );
    if (res.statusCode == 200) {
      if (res.data["data"] != null) {
        return PartyOrderDTO.fromJson(res.data['data']);
      }
    }
    return null;
  }

  Future<OrderDetails?> confirmPartyOrder(String? code) async {
    // print("Request Note: " + note);
    final res = await request.post(
      '/order/coOrder/confirmation?partyCode=$code',
    );
    if (res.statusCode == 200) {
      return OrderDetails.fromJson(res.data['data']);
    }
    return null;
  }

  Future<OrderDTO?> preparePartyOrder(String? timeSlotId, String? code) async {
    // print("Request Note: " + note);
    final res = await request.post(
      '/order/coOrder/preOrder?timeSlot=$timeSlotId&partyCode=$code',
    );
    if (res.statusCode == 200) {
      return OrderDTO.fromJson(res.data['data']);
    }

    return null;
  }

  Future<bool> logoutCoOrder(String code) async {
    final res = await request.put(
      '/order/coOrder/out?partyCode=$code',
      // data: ORDER_CANCEL_STATUS,
    );
    return res.statusCode == 200;
  }
}
