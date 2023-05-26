import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DefaultAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  Widget? backButton;
  DefaultAppBar({Key? key, @required this.title, this.backButton})
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  _AppBarSate createState() {
    return new _AppBarSate();
  }
}

class _AppBarSate extends State<DefaultAppBar> {
  Icon actionIcon = const Icon(Icons.search);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2.0,
      centerTitle: true,
      // ignore: prefer_if_null_operators
      leading: widget.backButton != null
          ? widget.backButton
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
              ),
              child: Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(Icons.arrow_back_ios,
                      size: 20, color: FineTheme.palettes.primary300),
                ),
              ),
            ),
      title: Text(widget.title!.toUpperCase(),
          style: FineTheme.typograhpy.h2
              .copyWith(color: FineTheme.palettes.primary300)),
    );
  }
}
