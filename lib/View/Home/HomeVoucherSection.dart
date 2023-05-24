import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class HomeVoucherSection extends StatelessWidget {
  const HomeVoucherSection({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        color: FineTheme.palettes.primary50,
        height: 78,
        width: Get.width,
        child: Container(
          height: 50,
          padding: const EdgeInsets.only(top: 17, bottom: 17),
          color: FineTheme.palettes.primary100,
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/icons/voucher.png",
                  width: 20,
                  height: 16,
                ),
                const SizedBox(
                  width: 24,
                ),
                Text(
                  "Bạn ơi mã giảm giá đang vẫy gọi bạn nè !",
                  style: FineTheme.typograhpy.subtitle2
                      .copyWith(color: FineTheme.palettes.shades100),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
