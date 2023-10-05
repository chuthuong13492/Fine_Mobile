import 'package:fine/Accessories/custom_button_switch.dart';
import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';

Future<void> showStatusDialog(
    String imageUrl, String status, String content) async {
  bool shouldPop = false;
  hideDialog();
  await Get.dialog(WillPopScope(
    onWillPop: () async {
      return shouldPop;
    },
    child: Dialog(
      backgroundColor: Colors.white,
      elevation: 8.0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 8,
            ),
            Image(
              image: AssetImage(imageUrl),
              width: 96,
              height: 96,
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Text(
                status ?? "",
                style: FineTheme.typograhpy.h2,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                content,
                style: FineTheme.typograhpy.subtitle2,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FineTheme.palettes.primary100,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16))),
                ),
                // color: FineTheme.palettes.primary300,
                // shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.only(
                //         bottomRight: Radius.circular(16),
                //         bottomLeft: Radius.circular(16))),
                onPressed: () {
                  hideDialog();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(
                    "Đồng ý",
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ));
}

void showLoadingDialog() {
  bool shouldPop = false;
  hideDialog();
  Get.defaultDialog(
      barrierDismissible: true,
      title: "Chờ mình xý nha...",
      content: WillPopScope(
        onWillPop: () async {
          return shouldPop;
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              Image(
                width: 120,
                height: 120,
                image: AssetImage("assets/images/loading_fine.gif"),
              ),
            ],
          ),
        ),
      ),
      titleStyle: FineTheme.typograhpy.h2);
}

Future<bool> showErrorDialog(
    {String errorTitle = "Có một chút trục trặc nhỏ!!"}) async {
  hideDialog();
  bool result = false;
  await Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 8.0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(
                  AntDesign.closecircleo,
                  color: Colors.red,
                ),
                onPressed: () {
                  hideDialog();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(1, 0, 1, 0),
              child: Text(
                errorTitle,
                textAlign: TextAlign.center,
                style: FineTheme.typograhpy.h2,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Image(
              width: 96,
              height: 96,
              image: AssetImage("assets/images/error.png"),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FineTheme.palettes.primary100,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16))),
                ),
                onPressed: () {
                  result = true;
                  hideDialog();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(
                    "Thử lại",
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true);
  return result;
}

Future<int> showOptionDialog(String text,
    {String? firstOption, String? secondOption}) async {
  // hideDialog();
  int? option;
  bool shouldPop = false;
  await Get.dialog(
    WillPopScope(
      onWillPop: () async {
        return shouldPop;
      },
      child: Dialog(
        backgroundColor: Colors.white,
        elevation: 8.0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      AntDesign.closecircleo,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      option = 0;
                      hideDialog();
                    },
                  ),
                ),
                const SizedBox(
                  height: 54,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    text,
                    style: FineTheme.typograhpy.body2
                        .copyWith(color: FineTheme.palettes.neutral600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border(
                    top: BorderSide(
                      color: FineTheme.palettes.neutral500,
                    ),
                  )),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          // color: Colors.grey,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              // bottomRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            )),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 16.0, bottom: 16.0),
                            child: Center(
                              child: Text(
                                firstOption ?? "Hủy",
                                style: FineTheme.typograhpy.subtitle1.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            option = 0;
                            hideDialog();
                          },
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          // color: kPrimary,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FineTheme.palettes.primary200,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(16),
                                // bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 16.0, bottom: 16.0),
                            child: Center(
                              child: Text(
                                secondOption ?? "Đồng ý",
                                style: FineTheme.typograhpy.subtitle1.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            option = 1;
                            hideDialog();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Positioned(
              top: -30,
              right: 95,
              child: Image(
                image: AssetImage("assets/images/logo.png"),
                width: 160,
                height: 160,
              ),
            )
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
  return option!;
}

Future<int> showInputVoucherDialog(
    {String? firstOption, String? secondOption}) async {
  TextEditingController controller = TextEditingController(text: '');
  // hideDialog();
  int? option;
  bool shouldPop = false;
  await Get.dialog(
    WillPopScope(
      onWillPop: () async {
        return shouldPop;
      },
      child: Dialog(
        backgroundColor: Colors.white,
        elevation: 8.0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Expanded(
              child: Container(
                height: 120,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/party_img.png'),
                        fit: BoxFit.fill),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0))),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      FontAwesome.close,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      option = 0;
                      PartyOrderViewModel party =
                          Get.find<PartyOrderViewModel>();
                      party.acc = null;
                      hideDialog();
                    },
                  ),
                ),
                const SizedBox(
                  height: 84,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 7,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              border: Border.all(
                                  color: FineTheme.palettes.primary100)),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                            child: TextField(
                              onChanged: (input) {},
                              controller: controller,
                              decoration: InputDecoration(
                                  hintText: 'Nhập voucher',
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      controller.clear();
                                    },
                                  )),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                fontStyle: FontStyle.normal,
                                color: FineTheme.palettes.neutral500,
                              ),
                              keyboardType: TextInputType.multiline,
                              maxLines: 1,
                              autofocus: true,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        fit: FlexFit.tight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                color: FineTheme.palettes.primary100,
                                border: Border.all(
                                  color: FineTheme.palettes.primary100,
                                )),
                            child: TextButton(
                                onPressed: () async {
                                  PartyOrderViewModel party =
                                      Get.find<PartyOrderViewModel>();
                                  option = 1;
                                  if (controller.text.contains("LPO")) {
                                    await party.joinPartyOrder(
                                        code: controller.text);
                                    hideDialog();
                                  } else {
                                    await showStatusDialog(
                                        "assets/images/logo2.png",
                                        "Sai mã mất rùi",
                                        "Mã code hong đúng nè 😓");
                                  }
                                },
                                child: const Text('Tham gia',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Positioned(
            //   top: 0,
            //   right: 95,
            //   child: Image(
            //     image: AssetImage("assets/images/party_img.png"),
            //     width: Get.width,
            //     height: Get.height * 0.12,
            //   ),
            // )
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
  return option!;
}

Future<int> showInviteDialog(String text,
    {String? firstOption, String? secondOption}) async {
  // hideDialog();
  int? option;
  bool shouldPop = false;
  await Get.dialog(
    WillPopScope(
      onWillPop: () async {
        return shouldPop;
      },
      child: Dialog(
        backgroundColor: Colors.white,
        elevation: 8.0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Expanded(
              child: Container(
                height: 120,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/party_img.png'),
                        fit: BoxFit.fill),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0))),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      FontAwesome.close,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      option = 0;
                      PartyOrderViewModel party =
                          Get.find<PartyOrderViewModel>();
                      party.isInvited = false;
                      party.acc = null;
                      hideDialog();
                    },
                  ),
                ),
                const SizedBox(
                  height: 84,
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CustomInviteParty(),
                ),
              ],
            ),
            // Positioned(
            //   top: 0,
            //   right: 95,
            //   child: Image(
            //     image: AssetImage("assets/images/party_img.png"),
            //     width: Get.width,
            //     height: Get.height * 0.12,
            //   ),
            // )
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
  return option!;
}

Future<int> showLeaderDialog(
    {String? firstOption, String? secondOption}) async {
  // hideDialog();
  int? option;
  bool shouldPop = false;
  await Get.dialog(
    WillPopScope(
      onWillPop: () async {
        return shouldPop;
      },
      child: Dialog(
        backgroundColor: Colors.white,
        elevation: 8.0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Expanded(
              child: Container(
                height: 120,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/party_img.png'),
                        fit: BoxFit.fill),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0))),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      FontAwesome.close,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      option = 0;
                      PartyOrderViewModel party =
                          Get.find<PartyOrderViewModel>();
                      party.acc = null;
                      hideDialog();
                    },
                  ),
                ),
                const SizedBox(
                  height: 84,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Center(
                    child: Text("Chọn new Leader!!!",
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            height: 1.2,
                            color: FineTheme.palettes.primary100)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: RadioList(),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
  return option!;
}

Future<int> showConfirmOrderDialog(
    int quantity, double totalAmount, double shippingFee, double finalAmount,
    {String? firstOption, String? secondOption}) async {
  // hideDialog();
  int? option;
  bool shouldPop = false;
  await Get.dialog(
    WillPopScope(
      onWillPop: () async {
        return shouldPop;
      },
      child: Dialog(
        backgroundColor: Colors.white,
        elevation: 8.0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      AntDesign.closecircleo,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      option = 0;
                      hideDialog();
                    },
                  ),
                ),
                const SizedBox(
                  height: 54,
                ),
                Text(
                  'Xác nhận đơn hàng',
                  style: FineTheme.typograhpy.h2
                      .copyWith(color: FineTheme.palettes.primary100),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              "Tạm tính",
                              style: FineTheme.typograhpy.subtitle1,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Icon(
                              Icons.circle,
                              size: 5,
                              color: FineTheme.palettes.shades200,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              "($quantity Món)",
                              style: FineTheme.typograhpy.subtitle1,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatPrice(totalAmount),
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Phí giao hàng",
                        style: FineTheme.typograhpy.subtitle1,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        formatPrice(shippingFee),
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Thanh toán bằng",
                        style: FineTheme.typograhpy.subtitle1,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Ví FINE',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            color: FineTheme.palettes.primary100),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tổng cộng",
                        style: FineTheme.typograhpy.subtitle1,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        formatPrice(finalAmount),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border(
                    top: BorderSide(
                      color: FineTheme.palettes.neutral500,
                    ),
                  )),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          // color: Colors.grey,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              // bottomRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            )),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 16.0, bottom: 16.0),
                            child: Center(
                              child: Text(
                                firstOption ?? "Hủy",
                                style: FineTheme.typograhpy.subtitle1.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            option = 0;
                            hideDialog();
                          },
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          // color: kPrimary,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FineTheme.palettes.primary200,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(16),
                                // bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 16.0, bottom: 16.0),
                            child: Center(
                              child: Text(
                                secondOption ?? "Đồng ý",
                                style: FineTheme.typograhpy.subtitle1.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            option = 1;
                            hideDialog();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Positioned(
              top: -30,
              right: 95,
              child: Image(
                image: AssetImage("assets/images/logo.png"),
                width: 160,
                height: 160,
              ),
            )
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
  return option!;
}

Future<int> showPartyDialog(PartyOrderViewModel model, {bool? isHome}) async {
  // PartyOrderViewModel model = Get.find<PartyOrderViewModel>();
  TextEditingController controller = TextEditingController(text: '');
  bool isErrorInput = false;
  // hideDialog();
  int? option;
  bool shouldPop = false;

  await Get.dialog(
    WillPopScope(
      onWillPop: () async {
        return shouldPop;
      },
      child: Dialog(
        backgroundColor: Colors.white,
        elevation: 8.0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Expanded(
              child: Container(
                height: 120,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/party_img.png'),
                        fit: BoxFit.fill),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0))),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      FontAwesome.close,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () async {
                      option = 0;
                      model.partyCode = await getPartyCode();
                      if (model.partyCode == null) {
                        model.isLinkedParty(false);
                      }
                      // if (model.isLinked == true) {
                      //   Get.find<OrderViewModel>().isPartyOrder =
                      //       model.isLinked;
                      // }
                      hideDialog();
                    },
                  ),
                ),
                const SizedBox(
                  height: 84,
                ),
                const Text(
                  'Mời tham gia đơn nhóm',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    fontStyle: FontStyle.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  width: Get.width,
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Text(
                    'Chia sẻ link tham gia đơn nhóm đến người bạn muốn mời nhé',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      color: FineTheme.palettes.neutral500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                model.partyCode == null
                    ? Column(
                        children: [
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Đơn liên kết',
                                    style: FineTheme.typograhpy.subtitle1,
                                  ),
                                ),
                                CustomCupertinoSwitch(
                                  value: model.isLinked!,
                                  onChanged: (value) {
                                    model.isLinkedParty(value);
                                  },
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 7,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
                                        border: Border.all(
                                            color:
                                                FineTheme.palettes.primary100)),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                      child: TextField(
                                        onChanged: (input) {},
                                        controller: controller,
                                        decoration: InputDecoration(
                                            hintText: 'Nhập code party',
                                            border: InputBorder.none,
                                            suffixIcon: IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () {
                                                controller.clear();
                                              },
                                            )),
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          fontStyle: FontStyle.normal,
                                          color: FineTheme.palettes.neutral500,
                                        ),
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 1,
                                        autofocus: true,
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 3,
                                  fit: FlexFit.tight,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(8)),
                                          color: FineTheme.palettes.primary100,
                                          border: Border.all(
                                            color:
                                                FineTheme.palettes.primary100,
                                          )),
                                      child: TextButton(
                                          onPressed: () async {
                                            PartyOrderViewModel party =
                                                Get.find<PartyOrderViewModel>();
                                            option = 1;
                                            if (controller.text
                                                .contains("CPO")) {
                                              await party.joinPartyOrder(
                                                  code: controller.text);
                                            } else {
                                              await showStatusDialog(
                                                  "assets/images/logo2.png",
                                                  "Sai mã mất rùi",
                                                  "Mã code hong đúng nè 😓");
                                            }
                                          },
                                          child: const Text('Tham gia',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15))),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      )
                    : const SizedBox.shrink(),
                Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: CustomeCreateParty(
                      model: model,
                      onChange: () async {
                        model.partyCode = await getPartyCode();
                        final order = Get.find<OrderViewModel>();
                        order.currentCart = await getCart();
                        if (order.currentCart != null) {
                          if (model.partyCode == null) {
                            await model.createCoOrder();
                            if (model.partyOrderDTO!.partyOrder != null) {
                              if (isHome == true) {
                                option = 1;
                                hideDialog();
                                Get.toNamed(RouteHandler.PARTY_ORDER_SCREEN);
                              } else {
                                option = 1;
                                hideDialog();
                                Get.offNamed(RouteHandler.PARTY_ORDER_SCREEN);
                              }
                            } else {
                              option = 1;
                              hideDialog();
                              await Get.find<OrderViewModel>().prepareOrder();
                              // hideDialog();
                            }
                          }
                        } else {
                          hideDialog();
                          await showStatusDialog(
                              'assets/images/logo2.png',
                              "Xin lũi nhe 🥹",
                              "Bạn phải có ít nhất 1 món mới tạo đc Party nè");
                        }
                      },
                    )),
              ],
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
  return option!;
}

void hideDialog() {
  if (Get.isDialogOpen!) {
    Get.back();
  }
}

void hideSnackbar() {
  if (Get.isSnackbarOpen) {
    Get.back();
  }
}
