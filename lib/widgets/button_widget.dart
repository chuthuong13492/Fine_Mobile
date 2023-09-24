import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ButtonWidgets extends StatelessWidget {
  final String? label;
  const ButtonWidgets({this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: Get.width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: FineTheme.palettes.primary100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${label}',
        style: FineTheme.typograhpy.h1.copyWith(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}
