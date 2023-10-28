import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/Transaction.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
// import 'package:url_launcher/url_launcher.dart';

import '../Constant/route_constraint.dart';
import '../Utils/constrant.dart';

class TopUpViewModel extends BaseModel {
  // final flutterWebviewPlugin = new FlutterWebviewPlugin();
  // final ValueNotifier<double> notifier = ValueNotifier(0.0);
  TopUpDAO? _dao;
  double? amount;
  RxInt setAmountIndex = 0.obs;
  String? topUpUrl;
  ScrollController? scrollController;
  List<TransactionDTO> listTransaction = [];
  List<bool> selections = [true, false];

  TopUpViewModel() {
    _dao = TopUpDAO();
    topUpUrl = null;
    scrollController = ScrollController();
    scrollController!.addListener(() async {
      if (scrollController!.position.pixels ==
          scrollController!.position.maxScrollExtent) {
        int total_page = (_dao!.metaDataDTO.total! / DEFAULT_SIZE).ceil();
        if (total_page > _dao!.metaDataDTO.page!) {}
      }
    });
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
  }

  Future<void> changeStatus(int index) async {
    selections = selections.map((e) => false).toList();
    selections[index] = true;
    notifyListeners();
    await getTransaction();
  }

  Future<void> getTransaction() async {
    try {
      setState(ViewStatus.Loading);
      if (selections[0] == true) {
        final data = await _dao?.getTransaction();
        listTransaction =
            data!.where((element) => element.status == 2).toList();
      }
      if (selections[1] == true) {
        final data = await _dao?.getTransaction();
        listTransaction = data!
            .where((element) => element.status == 1 || element.status == 3)
            .toList();
      }

      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getTransaction();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }

  Future<void> getMoreTransaction() async {
    try {
      setState(ViewStatus.LoadMore);
      final data =
          await _dao?.getMoreTransaction(page: _dao!.metaDataDTO.page! + 1);
      listTransaction += data!;
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(ViewStatus.Completed);
      // notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getMoreTransaction();
      } else {
        setState(ViewStatus.Error);
      }
    }
  }

  Future<void> getUrl() async {
    try {
      setState(ViewStatus.Loading);
      if (amount == null) {
        showStatusDialog("assets/images/error.png", "Chưa chọn số tiền kìaa",
            "Bạn hãy chọn số tiền cần nạp nhé");
        return;
      } else if (amount! < 10000) {
        showStatusDialog("assets/images/error-loading.gif", "Chưa đủ số tiền",
            "Nạp thấp nhất 10k nheee 😚");
        return;
      }
      topUpUrl = await _dao?.getTopUpUrl(amount.toString());
      // final Uri url = Uri.parse(topUpUrl!);
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
