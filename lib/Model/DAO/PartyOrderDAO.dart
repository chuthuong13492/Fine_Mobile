import 'package:dio/dio.dart';
import 'package:fine/Constant/order_status.dart';
import 'package:fine/Constant/partyOrder_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/request.dart';

import '../DTO/ConfirmCartDTO.dart';

class PartyOrderDAO extends BaseDAO {
  Future<PartyStatus?> getPartyStatus(String code) async {
    final res = await request.get(
      '/order/coOrder/status/$code',
    );
    if (res.data["data"] != null) {
      return PartyStatus.fromJson(res.data["data"]);
    }
    return null;
  }

  Future<PartyOrderDTO?> coOrder(ConfirmCart cart) async {
    final res = await request.post(
      '/order/coOrder/active',
      data: cart.toJsonAPi(),
    );
    if (res.statusCode == 200) {
      return PartyOrderDTO.fromJson(res.data['data']);
    }
    return null;
  }

  Future<AccountDTO?> getCustomerByPhone(String phone) async {
    final res = await request.get('/customer/find?phoneNumber=${phone}');
    if (res.statusCode == 200) {
      return AccountDTO.fromJson(res.data['data']);
    }
    return null;
  }

  Future<bool> inviteToParty(String cusId, String partyCode) async {
    try {
      final res = await request.post(
        '/customer/invitation?customerId=${cusId}&partyCode=${partyCode}',
        // data: ORDER_CANCEL_STATUS,
      );
      return res.statusCode == 200;
    } catch (e) {
      throw e;
    }
  }

  Future<PartyOrderStatus?> getPartyOrder(String? codeParty) async {
    try {
      final res = await request.get(
        '/order/coOrder/$codeParty',
      );
      if (res.data['data'] != null) {
        return PartyOrderStatus(
          statusCode: res.statusCode,
          code: res.data['status']['errorCode'],
          message: res.data['status']['message'],
          partyOrderDTO: PartyOrderDTO.fromJson(res.data['data']),
        );
      } else {
        return PartyOrderStatus(
          statusCode: res.statusCode,
          code: res.data['status']['errorCode'],
          message: res.data['status']['message'],
          partyOrderDTO: null,
        );
      }
    } on DioError catch (e) {
      return PartyOrderStatus(
          statusCode: e.response!.data["statusCode"],
          code: e.response!.data['errorCode'],
          message: e.response!.data['message']);
    } catch (e) {
      throw e;
    }
    // print("Request Note: " + note);
  }

  Future<PartyOrderStatus?> joinPartyOrder(
      String? partyCode, String? timeSlotId) async {
    try {
      final res = await request.put(
        '/order/coOrder/party?partyCode=$partyCode&timeSlotId=$timeSlotId',
      );
      return PartyOrderStatus(
        statusCode: res.statusCode,
        code: res.data['status']['errorCode'],
        message: res.data['status']['message'],
        partyOrderDTO: res.data['data'],
      );
    } on DioError catch (e) {
      return PartyOrderStatus(
          statusCode: e.response!.data["statusCode"],
          code: e.response!.data['errorCode'],
          message: e.response!.data['message']);
    } catch (e) {
      throw e;
    }
  }

  Future<PartyOrderDTO?> addProductToParty(String? code,
      {ConfirmCart? cart}) async {
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
    final res = await request.put(
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

  Future<bool> logoutCoOrder(String code, String? memberId, int type) async {
    Response? res;
    if (memberId == null) {
      res = await request.put(
        '/order/coOrder/out?partyCode=$code&type=$type',
        // data: ORDER_CANCEL_STATUS,
      );
    } else {
      res = await request.put(
        '/order/coOrder/out?type=$type&partyCode=$code&memberId=$memberId',
        // data: ORDER_CANCEL_STATUS,
      );
    }

    return res.statusCode == 200;
  }

  Future<bool> removeMember(String code, String? memberId) async {
    final res = await request.put(
      '/order/coOrder/member?partyCode=$code&memberId=$memberId',
      // data: ORDER_CANCEL_STATUS,
    );

    return res.statusCode == 200;
  }
}
