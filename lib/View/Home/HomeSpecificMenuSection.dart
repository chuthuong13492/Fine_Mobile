import 'package:cached_network_image/cached_network_image.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/MenuDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/cache_image.dart';
import 'package:fine/widgets/shimmer_block.dart';
import 'package:fine/widgets/touchopacity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../Accessories/index.dart';

class HomeSpecifiHomeSection extends StatefulWidget {
  const HomeSpecifiHomeSection({super.key});

  @override
  State<HomeSpecifiHomeSection> createState() => _HomeSpecifiHomeSectionState();
}

class _HomeSpecifiHomeSectionState extends State<HomeSpecifiHomeSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: Get.find<HomeViewModel>(),
        child: ScopedModelDescendant<HomeViewModel>(
          builder: (context, child, model) {
            final menu = model.homeMenu;
            if (model.status == ViewStatus.Loading || menu == null) {
              return _buildLoading();
            }
            return Container(
              width: Get.width,
              // padding: const EdgeInsets.only(
              //   top: 2,
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: menu
                    .where((element) =>
                        element.products!
                            .where((e) => e.isActive == true)
                            .isNotEmpty &&
                        element.isActive == true)
                    .map((c) => Container(
                        color: FineTheme.palettes.primary50,
                        padding: const EdgeInsets.only(
                          bottom: 8,
                        ),
                        margin: const EdgeInsets.only(top: 16),
                        child: buildHomeCollection(c)))
                    .toList(),
              ),
            );
          },
        ));
  }

  Widget buildHomeCollection(MenuDTO menu) {
    return Container(
      color: FineTheme.palettes.shades100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(
              menu.menuName!,
              style:
                  FineTheme.typograhpy.buttonLg.copyWith(color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(
              "Áp dụng từ 2 voucher mỗi đơn",
              style: FineTheme.typograhpy.caption2,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          ScopedModel(
            model: Get.find<HomeViewModel>(),
            child: ScopedModelDescendant<HomeViewModel>(
              builder: (context, child, model) {
                var list = menu.products!
                    .where((element) => element.isActive == true)
                    .toList();
                return Container(
                  color: FineTheme.palettes.shades100,
                  width: Get.width,
                  height: 270,
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      var product = list[index];
                      return Material(
                        color: Colors.white,
                        child: TouchOpacity(
                          onTap: () {
                            RootViewModel root = Get.find<RootViewModel>();
                            // root.openProductDetail(product, fetchDetail: true);
                            if (!root.isCurrentTimeSlotAvailable()) {
                              showStatusDialog(
                                  "assets/images/error.png",
                                  "Opps",
                                  "Hiện tại khung giờ bạn chọn đã chốt đơn. Bạn vui lòng xem khung giờ khác nhé 😓 ");
                            } else {
                              // if (product.type == ProductType.MASTER_PRODUCT) {}
                              root.openProductDetail(product,
                                  fetchDetail: true);
                            }
                          },
                          child: buildProductInMenu(product),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(width: FineTheme.spacing.xs),
                    itemCount: list.length,
                    scrollDirection: Axis.horizontal,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductInMenu(ProductDTO product) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Container(
        padding: const EdgeInsets.only(bottom: 16),
        // height: 270,
        width: 188,
        // decoration: BoxDecoration(
        //   color: Color,
        // ),
        child: Stack(
          children: [
            Positioned(
              bottom: 2,
              child: Container(
                width: 188,
                height: 206,
                decoration: BoxDecoration(
                  color: FineTheme.palettes.shades100,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(8),
                  ),
                  image: const DecorationImage(
                    image: AssetImage(
                      "assets/images/menu.png",
                    ),
                    fit: BoxFit.fill,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: FineTheme.palettes.shades200.withOpacity(0.1),
                      offset: const Offset(
                        -4.0,
                        -5.0,
                      ),
                      blurRadius: 10.0,
                      spreadRadius: -3.0,
                    ),
                    BoxShadow(
                      color: FineTheme.palettes.shades200.withOpacity(0.1),
                      offset: const Offset(
                        0.0,
                        10.0,
                      ),
                      blurRadius: 20.0,
                      spreadRadius: -14.0,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 120),
              child: SizedBox(
                width: 188,
                height: 40,
                child: Center(
                  child: Container(
                    width: 120,
                    child: Text(
                      product.productName!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 11, top: 175),
              child: SizedBox(
                width: 90,
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Get.width,
                      height: 12,
                      child: const Text(
                        "0.2km",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    SizedBox(
                      width: Get.width,
                      height: 12,
                      child: const Text(
                        "Đại Học FPT, phườngbjhbhjbjhbjh",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    SizedBox(
                      width: Get.width,
                      height: 14,
                      child: Text(
                        formatPrice(product.attributes![0].price!),
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            color: Get.find<RootViewModel>()
                                    .isCurrentTimeSlotAvailable()
                                ? Colors.red
                                : Colors.grey),
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    SizedBox(
                        width: Get.width,
                        height: 12,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FaIcon(
                              Icons.star_half,
                              color: Get.find<RootViewModel>()
                                      .isCurrentTimeSlotAvailable()
                                  ? FineTheme.palettes.primary300
                                  : Colors.grey,
                              size: 14,
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              "4.3",
                              style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              "(500+)",
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: FineTheme.palettes.neutral400),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 29,
              child: InkWell(
                onTap: () {},
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color:
                        Get.find<RootViewModel>().isCurrentTimeSlotAvailable()
                            ? FineTheme.palettes.primary100
                            : Colors.grey,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        image: DecorationImage(
                            image:
                                AssetImage("assets/icons/shopping-bag-02.png"),
                            fit: BoxFit.fill),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 35,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: 122,
                  height: 122,
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.circular(50),
                  // ),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Get.find<RootViewModel>().isCurrentTimeSlotAvailable()
                          ? Colors.transparent
                          : Colors.grey,
                      BlendMode.saturation,
                    ),
                    child: CacheImage(
                        imageUrl: product.imageUrl == null
                            ? 'https://firebasestorage.googleapis.com/v0/b/finedelivery-880b6.appspot.com/o/no-image.png?alt=media&token=b3efcf6b-b4b6-498b-aad7-2009389dd908'
                            : product.imageUrl!),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
            // child: Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: const [
            //     ShimmerBlock(
            //       height: 110,
            //       width: 110,
            //       borderRadius: 16,
            //     ),
            //     SizedBox(width: 8),
            //     ShimmerBlock(
            //       height: 110,
            //       width: 110,
            //       borderRadius: 16,
            //     ),
            //     SizedBox(width: 8),
            //     ShimmerBlock(
            //       height: 110,
            //       width: 110,
            //       borderRadius: 16,
            //     ),
            //   ],
            // ),
          ),
        ],
      ),
    );
  }
}
