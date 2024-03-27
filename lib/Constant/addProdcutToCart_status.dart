import 'package:fine/Model/DTO/index.dart';

class AddProductToCartStatus {
  int? statusCode;
  int? code;
  String? message;
  AddProductToCartResponse? addProduct;

  AddProductToCartStatus({
    this.statusCode,
    this.code,
    this.message,
    this.addProduct,
  });
}

enum PartyOrderFilter { NEW, ORDERING, DONE }
