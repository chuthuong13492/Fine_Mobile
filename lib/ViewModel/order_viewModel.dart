import 'package:dio/dio.dart';
import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/base_model.dart';

import '../Model/DAO/index.dart';

class OrderViewModel extends BaseModel {
  Cart? currentCart;
  OrderDAO? _dao;
  bool? loadingUpsell;
  String? errorMessage;

  OrderViewModel() {
    _dao = new OrderDAO();
    // promoDao = new PromotionDAO();
    // _collectionDAO = CollectionDAO();
    loadingUpsell = false;
    currentCart = null;
  }

  Future<void> prepareOrder() async {
    try {} on DioError catch (e, stacktra) {
      print(stacktra.toString());
      if (e.response?.statusCode == 400) {
        String errorMsg = e.response?.data["message"];
        errorMessage = errorMsg;
        if (e.response?.data['data'] != null) {
          // orderAmount = OrderAmountDTO.fromJson(e.response.data['data']);
        }
        setState(ViewStatus.Completed);
      } else if (e.response?.statusCode == 404) {
        if (e.response?.data["error"] != null) {
          setCart(currentCart!);
          setState(ViewStatus.Completed);
        }
      } else {
        bool result = await showErrorDialog();
        if (result) {
          await prepareOrder();
        } else {
          setState(ViewStatus.Error);
        }
      }
    }
  }
}
