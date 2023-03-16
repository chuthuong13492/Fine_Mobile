import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/shimmer_block.dart';
import 'package:flutter/material.dart';
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
    _homeCollectionViewModel = HomeViewModel();
    Get.find<HomeViewModel>().getListSupplier();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: Get.find<HomeViewModel>(),
        child: ScopedModelDescendant<HomeViewModel>(
          builder: (context, child, model) {
            var suppliers = model.supplierList;
            if (suppliers != null) {
              final status = model.status;
              if (status == ViewStatus.Loading) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ignore: sized_box_for_whitespace
                    Container(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      // alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 8),
                      width: Get.width,
                      height: 70,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          // return const Padding(
                          //   padding: EdgeInsets.only(right: 8.0),
                          //   child: ShimmerBlock(
                          //     width: 80,
                          //     height: 32,
                          //     borderRadius: 8,
                          //   ),
                          // );
                          return Container(
                            width: 120,
                            margin: const EdgeInsets.only(left: 16),
                            child: Container(
                              color: FineTheme.palettes.shades100,
                              child: ShimmerBlock(
                                width: Get.width,
                                height: Get.height,
                              ),
                            ),
                          );
                        },
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
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
                      'Cửa hàng',
                      style:
                          FineTheme.typograhpy.h2.copyWith(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 8),
                    width: Get.width,
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
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
                          child: Container(
                            width: 120,
                            margin: index != 0
                                ? const EdgeInsets.only(left: 16)
                                : null,
                            decoration: BoxDecoration(
                              color: FineTheme.palettes.shades100,
                              border: Border.all(
                                  color: FineTheme.palettes.primary300,
                                  width: 1),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 6,
                                    color: FineTheme.palettes.primary300),
                              ],
                            ),
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Get.find<RootViewModel>()
                                        .isCurrentTimeSlotAvailable()
                                    ? Colors.transparent
                                    : Colors.grey,
                                BlendMode.saturation,
                              ),
                              child: Container(
                                padding: isLaha
                                    ? const EdgeInsets.all(12)
                                    : const EdgeInsets.all(8),
                                child: Image.network(
                                  imageUrl,
                                  fit: isLaha ? BoxFit.fitHeight : BoxFit.cover,
                                ),
                              ),
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
        ));
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
