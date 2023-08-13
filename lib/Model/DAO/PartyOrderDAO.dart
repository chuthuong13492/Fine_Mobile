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

  Future<PartyOrderDTO?> getPartyOrder(String? code) async {
    if (code != null) {
      // print("Request Note: " + note);
      final res = await request.get(
        '/order/coOrder/$code',
      );
      if (res.statusCode == 200) {
        return PartyOrderDTO.fromJson(res.data['data']);
      }
      return null;
    }
    return null;
  }

  Future<PartyOrderDTO?> joinPartyOrder(String? code) async {
    final res = await request.post(
      '/order/coOrder/party?partyCode=$code',
    );
    if (res.statusCode == 200) {
      return PartyOrderDTO.fromJson(res.data['data']);
    }
    return null;
  }

  Future<PartyOrderDTO?> addProductToParty(String? code, {Cart? cart}) async {
    if (cart != null) {
      // print("Request Note: " + note);
      final res = await request.post(
        '/order/coOrder/card?partyCode=$code',
        data: cart.toJsonAPi(),
      );
      if (res.statusCode == 200) {
        return PartyOrderDTO.fromJson(res.data['data']);
      }
      return null;
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
}
