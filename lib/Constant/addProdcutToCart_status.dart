import 'package:fine/Model/DTO/index.dart';

class AddProductToCartStatus {
  int? statusCode;
  String? code;
  String? message;
  List<AddProductToCartResponse>? product;

  AddProductToCartStatus({
    this.statusCode,
    this.code,
    this.message,
    this.product,
  });
}

enum PartyOrderFilter { NEW, ORDERING, DONE }
