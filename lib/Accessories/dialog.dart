import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
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
                  backgroundColor: FineTheme.palettes.primary300,
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
                  padding: EdgeInsets.only(top: 16, bottom: 16),
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

void hideDialog() {
  if (Get.isDialogOpen!) {
    Get.back();
  }
}
