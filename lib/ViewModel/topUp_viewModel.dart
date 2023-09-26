import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
// import 'package:url_launcher/url_launcher.dart';

import '../Constant/route_constraint.dart';

class TopUpViewModel extends BaseModel {
  // final flutterWebviewPlugin = new FlutterWebviewPlugin();
  // final ValueNotifier<double> notifier = ValueNotifier(0.0);
  TopUpDAO? _dao;
  double? amount;
  RxInt setAmountIndex = 0.obs;
  String? topUpUrl;
  TopUpViewModel() {
    _dao = TopUpDAO();
    topUpUrl = null;
  }

  setOnChangeValue(int value) {
    amount = value.toDouble();
    print(amount);
  }

  setIndex(index) {
    setAmountIndex.value = index;
    // amount = null;
    amount = setAmountIndex.value.toDouble();
    print(amount);
    notifyListeners();
    // if (amount != null) {
    //   notifier.value = amount!;
    // } else {
    //   notifier.value = setAmountIndex.value.toDouble();
    // }

    // setAmountIndex.value = amount as int;
    // update();
  }

  Future<void> getUrl() async {
    try {
      setState(ViewStatus.Loading);
      if (amount == null) {
        showStatusDialog("assets/images/error.png", "Chưa chọn số tiền kìaa",
            "Bạn hãy chọn số tiền cần nạp nhé");
        return;
      }
      topUpUrl = await _dao?.getTopUpUrl(amount.toString());
      final Uri url = Uri.parse(topUpUrl!);
      Get.toNamed(RouteHandler.WEBVIEW, arguments: topUpUrl);

      // flutterWebviewPlugin.launch(topUpUrl!, hidden: true);
      // if (await canLaunchUrl(url)) {
      //   await launchUrl(url, mode: LaunchMode.inAppWebView);
      //   // Get.back();
      // }
      setState(ViewStatus.Completed);
    } catch (e) {
      topUpUrl = null;
      setState(ViewStatus.Error);
    }
  }
}
