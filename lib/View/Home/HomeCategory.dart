import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/ViewModel/category_viewModel.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
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

class HomeCategory extends StatefulWidget {
  const HomeCategory({super.key});

  @override
  State<HomeCategory> createState() => _HomeCategoryState();
}

class _HomeCategoryState extends State<HomeCategory> {
  CategoryViewModel? _categoryViewModel;

  HomeViewModel? _homeViewModal;

  @override
  void initState() {
    // _categoryViewModel?.getCategories();
    Get.find<CategoryViewModel>().getCategories();
    _homeViewModal = HomeViewModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: Get.find<CategoryViewModel>(),
        child: ScopedModelDescendant<CategoryViewModel>(
          builder: (context, child, model) {
            var categories =
                model.categories?.where((element) => element.showOnHome!);
            if (model.status == ViewStatus.Loading) {
              return _buildLoading();
            }
            if (categories == null || categories.length == 0) {
              return Text("Khong co cate");
            }
            // return ScopedModelDescendant<HomeViewModel>(
            //   builder: (context, child, model) {
            //     //   if (model.suppliers == null ||
            //     //     model.suppliers.isEmpty ||
            //     //     model.suppliers
            //     //             .where((supplier) => supplier.available)
            //     //             .length ==
            //     //         0) {
            //     //   return SizedBox();
            //     // }
            //     return Section(
            //       child: Column(
            //         children: [
            //           Container(
            //             padding: EdgeInsets.all(8),
            //             width: Get.width,
            //             child: Wrap(
            //               alignment: WrapAlignment.spaceBetween,
            //               spacing: 8,
            //               children: categories
            //                   .map((category) => buildCategoryItem(category))
            //                   .toList(),
            //             ),
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            // );
            return Section(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    width: Get.width,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 8,
                      children: categories
                          .map((category) => buildCategoryItem(category))
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }

  Widget buildCategoryItem(CategoryDTO category) {
    return TouchOpacity(
      onTap: () {
        // if (!root.isCurrentMenuAvailable()) {
        //   showStatusDialog("assets/images/global_error.png", "Opps",
        //       "Hiện tại khung giờ bạn chọn đã chốt đơn.Bạn vui lòng xem khung giờ khác nhé 😓. ");
        // } else {
        //   Get.toNamed(RouteHandler.PRODUCT_FILTER_LIST,
        //       arguments: {"category-id": category.id});
        // }
      },
      child: Container(
        padding: EdgeInsets.all(4),
        width: Get.width / 4 - 20,
        child: Column(
          children: [
            Container(
              width: Get.width / 4 - 40,
              height: Get.width / 4 - 40,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              // child: ColorFiltered(
              //   colorFilter: ColorFilter.mode(
              //     root.isCurrentMenuAvailable()
              //         ? Colors.transparent
              //         : Colors.grey,
              //     BlendMode.saturation,
              //   ),
              //   child: CacheImage(
              //     imageUrl: category.imgURL,
              //   ),
              // ),
              child: CacheImage(
                imageUrl: category.picUrl.toString(),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              category.categoryName ?? "",
              style: TextStyle(
                  fontStyle: FontStyle.normal,
                  // fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: FineTheme.palettes.neutral1000),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(8),
      //   border: Border.all(
      //     color: Color(0xff333333),
      //   ),
      // ),
      width: Get.width,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        children: List.filled(
          8,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ShimmerBlock(
              width: Get.width / 4 - 30,
              height: Get.width / 4 - 30,
              borderRadius: 8,
            ),
          ),
        ),
      ),
    );
  }
}
