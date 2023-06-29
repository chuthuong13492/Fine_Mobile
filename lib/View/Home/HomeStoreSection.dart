import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/cache_image.dart';
import 'package:fine/widgets/shimmer_block.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../Accessories/index.dart';

class HomeStoreSection extends StatefulWidget {
  const HomeStoreSection({super.key});

  @override
  State<HomeStoreSection> createState() => _HomeStoreSectionState();
}

class _HomeStoreSectionState extends State<HomeStoreSection> {
  HomeViewModel? _homeCollectionViewModel;

  @override
  void initState() {
    super.initState();
    _homeCollectionViewModel = Get.find<HomeViewModel>();
    Get.find<HomeViewModel>().getListSupplier();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: Get.find<HomeViewModel>(),
        child: ScopedModelDescendant<HomeViewModel>(
          builder: (context, child, model) {
            var suppliers = model.supplierList!
                .where((element) => element.imageUrl != null)
                .toList();
            if (suppliers != null) {
              final status = model.status;
              if (status == ViewStatus.Loading) {
                return _buildLoading();
              }
              if (status == ViewStatus.Error) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Quanh đây có gì ngon?',
                      style: FineTheme.typograhpy.buttonLg
                          .copyWith(color: Colors.black),
                    ),
                    Container(
                      // padding: const EdgeInsets.only(left: 12, right: 12),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 8, bottom: 42),
                      width: Get.width,
                      // height: 70,
                      child: ListView.separated(
                        separatorBuilder: (context, index) => SizedBox(
                          height: FineTheme.spacing.m,
                        ),
                        physics: const ScrollPhysics(
                            parent: NeverScrollableScrollPhysics()),
                        // scrollDirection: Axis.vertical,
                        itemCount: suppliers.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          bool isLaha = suppliers[index].storeName == 'Laha';
                          String imageUrl = suppliers[index].imageUrl!;
                          return InkWell(
                            onTap: () {
                              RootViewModel root = Get.find<RootViewModel>();
                              // // var firstTimeSlot = root.currentStore.timeSlots?.first;
                              if (!root.isCurrentTimeSlotAvailable()) {
                                showStatusDialog(
                                    "assets/images/error.png",
                                    "Opps",
                                    "Hiện tại khung giờ bạn chọn đã chốt đơn. Bạn vui lòng xem khung giờ khác nhé 😓 ");
                              } else {
                                // if (product.type == ProductType.MASTER_PRODUCT) {}
                                Get.toNamed(RoutHandler.PRODUCT_FILTER_LIST,
                                    arguments: {
                                      'store': suppliers[index].toJson()
                                    });
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        width: 112,
                                        height: 112,
                                        child: CacheStoreImage(
                                          imageUrl: imageUrl,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 2, 8, 2),
                                          width: 46,
                                          height: 13,
                                          decoration: BoxDecoration(
                                            color:
                                                FineTheme.palettes.primary300,
                                            borderRadius:
                                                const BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(10)),
                                          ),
                                          child: Text(
                                            "PROMO".toUpperCase(),
                                            style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 7,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white),
                                          ),
                                        )),
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 5),
                                    // width: Get.width,
                                    height: 113,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            FaIcon(
                                              Icons.check_circle,
                                              size: 16,
                                              color:
                                                  FineTheme.palettes.primary100,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: Text(
                                                "${suppliers[index].storeName!} - Đại học FPT",
                                                style: FineTheme
                                                    .typograhpy.caption1
                                                    .copyWith(fontSize: 16),
                                                overflow: TextOverflow.ellipsis,
                                                // maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            FaIcon(
                                              Icons.star_half,
                                              size: 16,
                                              color:
                                                  FineTheme.palettes.primary300,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              '4.3',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              '(500+)',
                                              style: TextStyle(
                                                  color: FineTheme
                                                      .palettes.neutral400,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ));
  }

  Widget _buildLoading() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      decoration: BoxDecoration(
        color: FineTheme.palettes.shades100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBlock(width: Get.width * 0.4, height: 30),
              // ShimmerBlock(width: Get.width * 0.2, height: 30),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            width: Get.width,
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return const ShimmerBlock(
                  height: 110,
                  width: 110,
                  borderRadius: 16,
                );
              },
              separatorBuilder: (context, index) =>
                  SizedBox(width: FineTheme.spacing.xs),
              itemCount: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class MyClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, 300, 300);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}
