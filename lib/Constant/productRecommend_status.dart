import 'package:fine/Model/DTO/index.dart';

class ProductRecommendStatus {
  int? statusCode;
  int? code;
  String? message;
  List<ProductInCart>? recommend;

  ProductRecommendStatus({
    this.statusCode,
    this.code,
    this.message,
    this.recommend,
  });
}
