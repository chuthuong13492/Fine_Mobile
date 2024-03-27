import 'package:fine/Model/DTO/index.dart';

class PartyOrderStatus {
  int? statusCode;
  int? code;
  String? message;
  PartyOrderDTO? partyOrderDTO;

  PartyOrderStatus({
    this.statusCode,
    this.code,
    this.message,
    this.partyOrderDTO,
  });
}

enum PartyOrderFilter { NEW, ORDERING, DONE }
