import 'package:fine/ViewModel/base_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopUpViewModel extends BaseModel {
  // final ValueNotifier<double> notifier = ValueNotifier(0.0);
  double? amount;
  RxInt setAmountIndex = 0.obs;
  // TopUpViewModel({
  //   amount = 0,
  // });
  double? onChangeAmount;
  setOnChangeValue(int value) {
    onChangeAmount = value.toDouble();
    print(onChangeAmount);
  }

  setIndex(index) {
    print(index);
    setAmountIndex.value = index;
    // amount = null;
    amount = setAmountIndex.value.toDouble();
    notifyListeners();
    // if (amount != null) {
    //   notifier.value = amount!;
    // } else {
    //   notifier.value = setAmountIndex.value.toDouble();
    // }

    // setAmountIndex.value = amount as int;
    // update();
  }
}
