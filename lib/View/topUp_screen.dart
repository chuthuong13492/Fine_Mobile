import 'package:fine/Accessories/index.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/topUp_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import '../widgets/payment_method_widget.dart';

// class TopUpScreen extends StatefulWidget {
//   const TopUpScreen({super.key});

//   @override
//   State<TopUpScreen> createState() => _TopUpScreenState();
// }

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final TopUpViewModel _topUpViewModel = Get.find<TopUpViewModel>();
  // final flutterWebViewPlugin = FlutterWebviewPlugin();
  // Future<void> urlListen() async {
  //   flutterWebViewPlugin.onUrlChanged.listen((String url) {
  //     if (url == 'https://prod.fine-api.smjle.vn/') {
  //       // Đã đến màn hình thành công, thực hiện các hành động cần thiết
  //       // (ví dụ: hiển thị thông báo thanh toán thành công)
  //       // Đóng trình duyệt web
  //       flutterWebViewPlugin.close();
  //       // Chuyển hướng trở lại màn hình chính hoặc màn hình thông báo thành công
  //       Get.back();
  //     }
  //   });
  // }

  final txt = TextEditingController();
  String formatVnd(double input) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(input);
  }

  int getNumericValue(String formattedVnd) {
    String cleanValue = formattedVnd.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(cleanValue) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    // urlListen();
  }

  @override
  void dispose() {
    super.dispose();
    _topUpViewModel.amount = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: DefaultAppBar(title: 'Ví Fine'),
      backgroundColor: FineTheme.palettes.shades100,
      bottomNavigationBar: bottomBar(),
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            leading: Container(
              margin: const EdgeInsets.only(left: 8),
              // padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: Container(
                  child: IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () async {
                        final acc = Get.find<AccountViewModel>();
                        await acc.fetchUser();
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: Color(0xFF238E9C),
                        size: 42,
                      )),
                ),
              ),
            ),
            backgroundColor: FineTheme.palettes.shades100,
          ),
          SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              ScopedModel(
                model: Get.find<TopUpViewModel>(),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(32, 4, 32, 0),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nạp tiền".toUpperCase(),
                        style: FineTheme.typograhpy.h1,
                      ),
                      Row(
                        children: [
                          Text(
                            "Vào ví ".toUpperCase(),
                            style: FineTheme.typograhpy.h1,
                          ),
                          Text(
                            "Fine ".toUpperCase(),
                            style: FineTheme.typograhpy.h1
                                .copyWith(color: FineTheme.palettes.primary100),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Nạp thấp nhất 10k nha 😚",
                        style: FineTheme.typograhpy.subtitle1
                            .copyWith(color: FineTheme.palettes.neutral500),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      ScopedModelDescendant<TopUpViewModel>(
                        builder: (context, child, model) {
                          final amountMoney = model.amount ?? 0;

                          txt.text = formatVnd(amountMoney);
                          return TextField(
                            onChanged: (input) {
                              String cleanValue =
                                  input.replaceAll(RegExp(r'[^\d]'), '');
                              if (cleanValue.isNotEmpty) {
                                String formattedVnd =
                                    formatVnd(double.parse(input));
                                if (formattedVnd != txt.text) {
                                  txt.value = txt.value.copyWith(
                                    text: formattedVnd,
                                    selection: TextSelection.collapsed(
                                        offset: formattedVnd.length),
                                  );
                                  int value = getNumericValue(txt.text);
                                  model.setOnChangeValue(value);
                                  // print(txt.text);
                                }
                              }
                            },
                            onEditingComplete: () {
                              int value = getNumericValue(txt.text);
                              print('Numeric Value: $value');
                            },
                            controller: txt,
                            autocorrect: false,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: FineTheme.palettes
                                        .primary100), // Color when not focused
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: FineTheme.palettes.primary100),
                              ),
                              prefixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      'Vnđ',
                                      style: FineTheme.typograhpy.h1.copyWith(
                                        fontSize: 18,
                                        color: FineTheme.palettes.neutral500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              hintText: formatPrice(0.0),
                              hintStyle: FineTheme.typograhpy.h1,
                            ),
                            textAlign: TextAlign.end,
                            style: FineTheme.typograhpy.h1,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          );
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Số tiền",
                        style: FineTheme.typograhpy.h1,
                      ),
                      Text(
                        "Thêm ngay nè",
                        style: FineTheme.typograhpy.subtitle1
                            .copyWith(color: FineTheme.palettes.neutral500),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ScopedModelDescendant<TopUpViewModel>(
                        builder: (context, child, model) {
                          return Obx(() => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      model.amount = null;
                                      model.setIndex(10000);
                                      // txt.text = formatVnd(amountMoney);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color:
                                            model.setAmountIndex.value == 10000
                                                ? FineTheme.palettes.primary100
                                                : Colors.transparent,
                                        border: Border.all(
                                          color: model.setAmountIndex.value ==
                                                  10000
                                              ? FineTheme.palettes.primary100
                                              : FineTheme.palettes.neutral500,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '10.000',
                                        style: FineTheme.typograhpy.subtitle1
                                            .copyWith(
                                          fontSize: 12,
                                          color: model.setAmountIndex.value ==
                                                  10000
                                              ? Colors.white
                                              : FineTheme.palettes.neutral500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      model.amount = null;
                                      model.setIndex(50000);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color:
                                            model.setAmountIndex.value == 50000
                                                ? FineTheme.palettes.primary100
                                                : Colors.transparent,
                                        border: Border.all(
                                          color: model.setAmountIndex.value ==
                                                  50000
                                              ? FineTheme.palettes.primary100
                                              : FineTheme.palettes.neutral500,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '50.000',
                                        style: FineTheme.typograhpy.subtitle1
                                            .copyWith(
                                          fontSize: 12,
                                          color: model.setAmountIndex.value ==
                                                  50000
                                              ? Colors.white
                                              : FineTheme.palettes.neutral500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      model.amount = null;
                                      model.setIndex(100000);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color:
                                            model.setAmountIndex.value == 100000
                                                ? FineTheme.palettes.primary100
                                                : Colors.transparent,
                                        border: Border.all(
                                          color: model.setAmountIndex.value ==
                                                  100000
                                              ? FineTheme.palettes.primary100
                                              : FineTheme.palettes.neutral500,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '100.000',
                                        style: FineTheme.typograhpy.subtitle1
                                            .copyWith(
                                          fontSize: 12,
                                          color: model.setAmountIndex.value ==
                                                  100000
                                              ? Colors.white
                                              : FineTheme.palettes.neutral500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      model.amount = null;
                                      model.setIndex(250000);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color:
                                            model.setAmountIndex.value == 250000
                                                ? FineTheme.palettes.primary100
                                                : Colors.transparent,
                                        border: Border.all(
                                          color: model.setAmountIndex.value ==
                                                  250000
                                              ? FineTheme.palettes.primary100
                                              : FineTheme.palettes.neutral500,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '250.000',
                                        style: FineTheme.typograhpy.subtitle1
                                            .copyWith(
                                          fontSize: 12,
                                          color: model.setAmountIndex.value ==
                                                  250000
                                              ? Colors.white
                                              : FineTheme.palettes.neutral500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ));
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ScopedModelDescendant<TopUpViewModel>(
                        builder: (context, child, model) {
                          return Obx(() => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      model.amount = null;
                                      model.setIndex(500000);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color:
                                            model.setAmountIndex.value == 500000
                                                ? FineTheme.palettes.primary100
                                                : Colors.transparent,
                                        border: Border.all(
                                          color: model.setAmountIndex.value ==
                                                  500000
                                              ? FineTheme.palettes.primary100
                                              : FineTheme.palettes.neutral500,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '500.000',
                                        style: FineTheme.typograhpy.subtitle1
                                            .copyWith(
                                          fontSize: 12,
                                          color: model.setAmountIndex.value ==
                                                  500000
                                              ? Colors.white
                                              : FineTheme.palettes.neutral500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      model.amount = null;
                                      model.setIndex(1000000);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: model.setAmountIndex.value ==
                                                1000000
                                            ? FineTheme.palettes.primary100
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: model.setAmountIndex.value ==
                                                  1000000
                                              ? FineTheme.palettes.primary100
                                              : FineTheme.palettes.neutral500,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '1.000.000',
                                        style: FineTheme.typograhpy.subtitle1
                                            .copyWith(
                                          fontSize: 12,
                                          color: model.setAmountIndex.value ==
                                                  1000000
                                              ? Colors.white
                                              : FineTheme.palettes.neutral500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      model.amount = null;
                                      model.setIndex(1500000);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: model.setAmountIndex.value ==
                                                1500000
                                            ? FineTheme.palettes.primary100
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: model.setAmountIndex.value ==
                                                  1500000
                                              ? FineTheme.palettes.primary100
                                              : FineTheme.palettes.neutral500,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '1.500.000',
                                        style: FineTheme.typograhpy.subtitle1
                                            .copyWith(
                                          fontSize: 12,
                                          color: model.setAmountIndex.value ==
                                                  1500000
                                              ? Colors.white
                                              : FineTheme.palettes.neutral500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget bottomBar() {
    return Container(
      height: 130,
      padding: const EdgeInsets.only(left: 32, right: 32, top: 22, bottom: 50),
      color: FineTheme.palettes.shades100,
      child: Container(
        height: 30,
        width: Get.width,
        decoration: BoxDecoration(
            color: FineTheme.palettes.primary100,
            borderRadius: const BorderRadius.all(
              Radius.circular(15),
            )),
        child: InkWell(
          onTap: () async {
            TopUpViewModel topUpViewModel = Get.find<TopUpViewModel>();
            await topUpViewModel.getUrl();
            // showModalBottomSheet(
            //     context: context,
            //     backgroundColor: Colors.transparent,
            //     builder: (BuildContext context) {
            //       return PaymentMethodWidgets();
            //     });
          },
          child: Center(
              child: Text(
            "Tiếp tục",
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                fontStyle: FontStyle.normal,
                color: FineTheme.palettes.shades100),
          )),
        ),
      ),
    );
  }
}
