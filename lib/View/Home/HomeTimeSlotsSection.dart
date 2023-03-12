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

class HomeTimeSlotsSection extends StatefulWidget {
  const HomeTimeSlotsSection({super.key});

  @override
  State<HomeTimeSlotsSection> createState() => _HomeTimeSlotsSectionState();
}

class _HomeTimeSlotsSectionState extends State<HomeTimeSlotsSection> {
  RootViewModel? _rootViewModel;
  @override
  void initState() {
    super.initState();
    _rootViewModel = RootViewModel();
    // Get.find<CategoryViewModel>().getCategories();
    _rootViewModel?.getListTimeSlot();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: Get.find<RootViewModel>(),
      child: ScopedModelDescendant<RootViewModel>(
        builder: (context, child, model) {
          var list = model.listTimeSlot
              ?.where((element) => element.isActive == true)
              .toList();
          if (model.currentStore == null) {
            final status = model.status;
            if (status == ViewStatus.Loading) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ignore: sized_box_for_whitespace
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
                  // alignment: Alignment.center,
                  height: 40,
                  width: Get.width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: list?.length,
                    itemBuilder: (context, index) {
                      bool isSelect =
                          model.selectedTimeSlot?.id == list?[index].id;
                      // bool isSelect = false;
                      return Container(
                        height: 40,
                        // padding: const EdgeInsets.only(left: 12, right: 12),
                        margin: const EdgeInsets.only(right: 8),
                        // curve: Neumorphic.DEFAULT_CURVE,
                        // style: NeumorphicStyle(
                        //   lightSource: LightSource.bottom,
                        //   disableDepth: true,
                        //   // depth: 4,
                        //   // shadowDarkColorEmboss: Colors.black,
                        //   color: isSelect
                        //       // ignore: dead_code
                        //       ? FineTheme.palettes.primary200
                        //       : Colors.white,
                        // ),

                        // duration: const Duration(milliseconds: 300),
                        child: InkWell(
                          onTap: () async {
                            if (model.selectedTimeSlot != null) {
                              model.confirmTimeSlot(model.listTimeSlot?[index]);
                            }
                          },
                          child: Container(
                            // height: 55,
                            padding: const EdgeInsets.only(left: 12, right: 12),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isSelect
                                  // ignore: dead_code
                                  ? FineTheme.palettes.primary200
                                  : Colors.white,
                              boxShadow: [
                                // BoxShadow(
                                //   color: Colors.black.withOpacity(0.4),
                                //   offset: const Offset(0, 3),
                                //   blurRadius: 4,
                                // ),
                              ],
                            ),
                            alignment: Alignment.center,
                            // padding: const EdgeInsets.only(top: 4, bottom: 4),
                            child: Text(
                                '${list?[index].arriveTime}' +
                                    ' - ' +
                                    '${list?[index].checkoutTime}',
                                style: isSelect
                                    // ignore: dead_code
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
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
