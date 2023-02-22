import 'package:fine/Constant/view_status.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/shimmer_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class HomeTimeSlotsSection extends StatelessWidget {
  const HomeTimeSlotsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: RootViewModel(),
      child: ScopedModelDescendant<RootViewModel>(
        builder: (context, child, model) {
          if (model.currentStore == null) {
            final status = model.status;
            if (status == ViewStatus.Loading) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 32,
                    width: Get.width,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: ShimmerBlock(
                            width: 80,
                            height: 32,
                            borderRadius: 8,
                          ),
                        );
                      },
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Chọn khung giờ giao',
                    style:
                        FineTheme.typograhpy.h2.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: Get.width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: model.TimeSlot.length,
                    itemBuilder: (context, index) {
                      // bool isSelect = model.selectedMenu.menuId ==
                      //         model.listMenu[index].menuId;
                      bool isSelect = false;
                      return Neumorphic(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        margin: const EdgeInsets.only(right: 8),
                        curve: Neumorphic.DEFAULT_CURVE,
                        style: NeumorphicStyle(
                          lightSource: const LightSource(-4, -4),
                          depth: -16,
                          shadowDarkColor: FineTheme.palettes.secondary200,
                          color: isSelect
                              // ignore: dead_code
                              ? FineTheme.palettes.secondary200
                              : Colors.white,
                        ),
                        duration: const Duration(milliseconds: 300),
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            alignment: Alignment.center,
                            // padding: const EdgeInsets.only(top: 4, bottom: 4),
                            child: Text(model.TimeSlot[index]['timeSlot'],
                                style: isSelect
                                    ? FineTheme.typograhpy.subtitle2
                                        .copyWith(color: Colors.white)
                                    // ignore: dead_code
                                    : FineTheme.typograhpy.subtitle2.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: FineTheme.palettes.shades200)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
