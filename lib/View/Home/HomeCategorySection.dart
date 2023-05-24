// ignore_for_file: sized_box_for_whitespace

import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/ViewModel/category_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/cache_image.dart';
import 'package:fine/widgets/section.dart';
import 'package:fine/widgets/shimmer_block.dart';
import 'package:fine/widgets/touchopacity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class HomeCategorySection extends StatefulWidget {
  const HomeCategorySection({super.key});

  @override
  State<HomeCategorySection> createState() => _HomeCategorySectionState();
}

class _HomeCategorySectionState extends State<HomeCategorySection> {
  CategoryViewModel? _categoryViewModel;
  @override
  void initState() {
    super.initState();
    _categoryViewModel = CategoryViewModel();
    // Get.find<CategoryViewModel>().getCategories();
    _categoryViewModel?.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: Get.find<CategoryViewModel>(),
        child: ScopedModelDescendant<CategoryViewModel>(
          builder: (context, child, model) {
            ViewStatus status = model.status;
            // ViewStatus status = ViewStatus.Completed;
            var categories = model.categories
                ?.where((element) => element.showOnHome!)
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
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Column(
                    children: [
                      ShimmerBlock(width: Get.width * 0.4, height: 40),
                      const SizedBox(height: 8),
                      buildSupplierSection(null, true),
                    ],
                  ),
                );
              default:
                if (categories == null || categories.isEmpty) {
                  return Container(
                    color: const Color.fromARGB(255, 219, 182, 182),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      children: [
                        SizedBox(
                          child: AspectRatio(
                            aspectRatio: 1.5,
                            child: Image.asset(
                              'assets/images/empty-product.png',
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                      child: Text(
                        'Danh mục',
                        style: FineTheme.typograhpy.h2
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: Colors.transparent,
                      // padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: buildSupplierSection(categories),
                    ),
                    // SizedBox(height: 8),

                    // SizedBox(height: 4),
                  ],
                );
            }
          },
        ));
  }

  Widget buildSupplierSection(List<CategoryDTO>? cateList,
      [bool loading = false]) {
    if (loading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          ShimmerBlock(
            height: 50,
            width: 50,
            borderRadius: 16,
          ),
          SizedBox(width: 8),
          ShimmerBlock(
            height: 50,
            width: 50,
            borderRadius: 16,
          ),
          SizedBox(width: 8),
          ShimmerBlock(
            height: 50,
            width: 50,
            borderRadius: 16,
          ),
          SizedBox(width: 8),
          ShimmerBlock(
            height: 50,
            width: 50,
            borderRadius: 16,
          ),
          SizedBox(width: 8),
          ShimmerBlock(
            height: 50,
            width: 50,
            borderRadius: 16,
          ),
        ],
      );
    }
    // ignore: sized_box_for_whitespace
    return Container(
      width: Get.width,
      height: 92,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var sup = cateList![index];
            return Material(
              color: Colors.transparent,
              child: TouchOpacity(
                onTap: () {
                  // HomeViewModel model = new HomeViewModel();
                  // model.selectSupplier(sup);
                },
                child: buildInSupplier(sup),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 14),
          itemCount: cateList!.length),
      // child: Text(sup.id),
    );
  }

  Container buildInSupplier(CategoryDTO? cate) {
    return Container(
      width: 56,
      // height: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            // color: Colors.white,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(0, 3),
                    blurRadius: 4),
              ],
            ),
            child: CacheImage(
              imageUrl: cate!.imageUrl!,
            ),
            // child: ColorFiltered(
            //   colorFilter: ColorFilter.mode(
            //     Get.find<RootViewModel>().isCurrentMenuAvailable()
            //         ? Colors.transparent
            //         : Colors.grey,
            //     BlendMode.saturation,
            //   ),
            //   child: CacheImage(
            //     imageUrl: sup.imageUrl,
            //   ),
            // ),
          ),
          SizedBox(height: FineTheme.spacing.xxs),
          Text(
            cate.categoryName!,
            style: FineTheme.typograhpy.caption2.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
