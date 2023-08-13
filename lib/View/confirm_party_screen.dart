import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';

class PartyConfirmScreen extends StatelessWidget {
  const PartyConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FineTheme.palettes.neutral200,
      appBar: DefaultAppBar(
        title: "Đơn nhóm",
        backButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () {
                Get.offAllNamed(RoutHandler.NAV);
              },
              child: Icon(Icons.arrow_back_ios,
                  size: 20, color: FineTheme.palettes.primary100),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              width: Get.width,
              height: 350,
              decoration: BoxDecoration(
                  color: FineTheme.palettes.shades100,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/confirm_img.png'),
                    fit: BoxFit.fill,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
