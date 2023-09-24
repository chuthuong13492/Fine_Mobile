import 'package:fine/Utils/platform.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../Accessories/appbar.dart';

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
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse("${widget.url}"));
    // ..setNavigationDelegate(NavigationDelegate(

    // ));
    return Scaffold(
      appBar: DefaultAppBar(
        title: widget.url,
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
