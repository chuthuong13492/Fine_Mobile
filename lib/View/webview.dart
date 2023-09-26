import 'package:fine/Utils/platform.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../Accessories/appbar.dart';
import '../Accessories/dialog.dart';

class WebViewScreen extends StatefulWidget {
  final String? url;

  WebViewScreen({
    Key? key,
    this.url,
  }) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    // if ((defaultTargetPlatform == TargetPlatform.android)) {
    //   WebView.platform = SurfaceAndroidWebView();
    // }
  }

  @override
  Widget build(BuildContext context) {
    bool isVnPay = false;
    if (widget.url!.contains("https://sandbox.vnpayment.vn")) {
      isVnPay = true;
    }
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse("${widget.url}"))
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) async {
          if (request.url.startsWith(
              'https://firebasestorage.googleapis.com/v0/b/fine-mobile-21acd.appspot.com/o/images%2Fpayment-done.png?alt=media&token=c22ca308-9711-4ecf-afef-f79a60594acb')) {
            await showStatusDialog("assets/images/money-duck.gif", 'Success',
                'Bạn đã nạp tiền thành công');
            Get.back();
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.prevent;
          }
          if (request.url.startsWith(
              'https://firebasestorage.googleapis.com/v0/b/fine-mobile-21acd.appspot.com/o/images%2Fpayment-fail.png?alt=media&token=f9be174d-d5f4-4c67-8310-e8ff8bb6ee2b')) {
            await showStatusDialog("assets/images/error-loading.gif", 'Lỗi ùi',
                'Bạn nạp tiền hong thành công rùi');
            Get.back();
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.prevent;
          }
          debugPrint('blocking navigation to ${request.url}');
          return NavigationDecision.navigate;
        },
      ));
    return Scaffold(
      appBar: DefaultAppBar(
        title: isVnPay ? "VNPay" : widget.url,
        backButton: Container(
          child: IconButton(
            icon: Icon(
              AntDesign.close,
              size: 24,
              color: FineTheme.palettes.primary100,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
