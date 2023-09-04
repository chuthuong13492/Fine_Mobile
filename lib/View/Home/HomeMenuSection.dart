import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/ViewModel/category_viewModel.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/cache_image.dart';
import 'package:fine/widgets/shimmer_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../Accessories/index.dart';
import '../../Model/DTO/index.dart';

class HomeMenuSection extends StatefulWidget {
  const HomeMenuSection({super.key});

  @override
  State<HomeMenuSection> createState() => _HomeMenuSectionState();
}

class _HomeMenuSectionState extends State<HomeMenuSection> {
  ScrollController scrollController = ScrollController();
  RootViewModel? _rootViewModel;
  @override
  void initState() {
    super.initState();
    // scrollController.dispose();
    _rootViewModel = Get.find<RootViewModel>();
    // Get.find<CategoryViewModel>().getCategories();
    Get.find<RootViewModel>().getListTimeSlot();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScopedModel(
              model: Get.find<RootViewModel>(),
              child: ScopedModelDescendant<RootViewModel>(
                builder: (context, child, model) {
                  String text = '';
                  if (model.isNextDay) {
                    text = 'HÔM SAU';
                  } else {
                    text = 'HÔM NAY';
                  }
                  return Text(
                    'Menu theo bữa ' + text,
                    style: FineTheme.typograhpy.buttonLg
                        .copyWith(color: Colors.black),
                  );
                },
              )),
          const SizedBox(
            height: 12,
          ),
          timeSlotesSelect(),
          const SizedBox(
            height: 16,
          ),
          menuList(),
        ],
      ),
    );
  }

  Widget timeSlotesSelect() {
    return ScopedModel(
      model: Get.find<RootViewModel>(),
      child: ScopedModelDescendant<RootViewModel>(
        builder: (context, child, model) {
          var list = model.listTimeSlot
              ?.where((element) => element.isActive == true)
              .toList();
          // bool isTimeSlotAvaible = model.isCurrentTimeSlotAvailable();
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
          return SizedBox(
            // alignment: Alignment.center,
            height: 60,
            width: Get.width,
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) =>
                  SizedBox(width: FineTheme.spacing.xs),
              itemCount: list!.length,
              itemBuilder: (context, index) {
                DateFormat inputFormat = DateFormat('HH:mm:ss');
                DateTime arrive = inputFormat.parse(list[index].arriveTime!);
                DateTime checkout =
                    inputFormat.parse(list[index].checkoutTime!);
                DateFormat outputFormat = DateFormat('HH:mm');
                String arriveTime = outputFormat.format(arrive);
                String checkoutTime = outputFormat.format(checkout);

                bool isSelect = model.selectedTimeSlot?.id == list[index].id;
                // bool isSelect = false;
                return Container(
                  // height: 30,
                  padding: const EdgeInsets.only(
                      top: 6, bottom: 6, left: 2, right: 2),
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
                        borderRadius: BorderRadius.circular(25),
                        color: isSelect
                            // ignore: dead_code
                            ? FineTheme.palettes.primary200
                            : Colors.white,
                        border:
                            Border.all(color: FineTheme.palettes.primary100),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black.withOpacity(0.4),
                        //     offset: const Offset(0, 3),
                        //     blurRadius: 4,
                        //   ),
                        // ],
                      ),
                      alignment: Alignment.center,
                      // padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text('$arriveTime - $checkoutTime',
                          style: isSelect
                              // ignore: dead_code
                              ? FineTheme.typograhpy.subtitle2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)
                              // ignore: dead_code
                              : FineTheme.typograhpy.subtitle2.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: FineTheme.palettes.primary100)),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget menuList() {
    return ScopedModel(
      model: Get.find<HomeViewModel>(),
      child: ScopedModelDescendant<HomeViewModel>(
        builder: (context, child, model) {
          ViewStatus status = model.status;
          // ViewStatus status = ViewStatus.Completed;
          var homeMenu = model.homeMenu
              ?.where((element) => element.isActive == true)
              .toList();

          switch (status) {
            case ViewStatus.Error:
              return Column(
                children: [
                  const Center(
                    child: Text(
                      "Có gì đó sai sai..\n Vui lòng thử lại.",
                      // style: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/images/global_error.png',
                    fit: BoxFit.contain,
                  ),
                ],
              );
            case ViewStatus.Loading:
            // return Container(
            //   margin: const EdgeInsets.only(bottom: 8),
            //   color: Colors.white,
            //   padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            //   child: Column(
            //     children: [
            //       ShimmerBlock(width: Get.width * 0.4, height: 40),
            //       const SizedBox(height: 8),
            //       buildSupplierSection(null, true),
            //     ],
            //   ),
            // );
            default:
              if (homeMenu == null || homeMenu.isEmpty) {
                return Container(
                  color: FineTheme.palettes.shades100,
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                  child: Column(
                    children: [
                      SizedBox(
                        child: AspectRatio(
                          aspectRatio: 1.5,
                          child: Image.asset(
                            'assets/images/empty-cart-ipack.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Text(
                        "Aaa, hiện tại các nhà hàng đang bận, bạn vui lòng quay lại sau nhé",
                        textAlign: TextAlign.center,
                        style: FineTheme.typograhpy.subtitle2
                            .copyWith(color: Colors.orange),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 180,
                    child: GridView.count(
                      physics: const ScrollPhysics(),
                      // padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      primary: false,
                      childAspectRatio: 1.1,
                      shrinkWrap: true,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 30,
                      crossAxisCount: 2,
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      children: List.generate(homeMenu.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            RootViewModel root = Get.find<RootViewModel>();
                            Get.toNamed(RouteHandler.PRODUCT_FILTER_LIST,
                                arguments: {'menu': homeMenu[index].toJson()});
                            // if (!root.isCurrentTimeSlotAvailable()) {
                            //   showStatusDialog(
                            //       "assets/images/error.png",
                            //       "Opps",
                            //       "Hiện tại khung giờ bạn chọn đã chốt đơn. Bạn vui lòng xem khung giờ khác nhé 😓 ");
                            // } else {

                            // }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 42,
                                width: 42,
                                child: homeMenu[index]
                                        .menuName!
                                        .contains('Danh mục')
                                    ? Image.asset(homeMenu[index].imgUrl!)
                                    : CacheImage(
                                        imageUrl: homeMenu[index].imgUrl!),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Expanded(
                                child: Text(
                                  homeMenu[index].menuName!,
                                  style: FineTheme.typograhpy.caption1,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  // const SizedBox(
                  //   height: 9,
                  // ),

                  ScrollIndicator(
                    scrollController: scrollController,
                    width: homeMenu.length <= 8 ? 0 : 30,
                    height: 4,
                    indicatorWidth: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: homeMenu.length <= 8
                          ? Colors.transparent
                          : Colors.grey[300],
                    ),
                    indicatorDecoration: BoxDecoration(
                        color: homeMenu.length <= 8
                            ? Colors.transparent
                            : FineTheme.palettes.primary100,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  homeMenu.length <= 8
                      ? const SizedBox.shrink()
                      : const SizedBox(
                          height: 14,
                        ),
                ],
              );
          }
        },
      ),
    );
  }
}
