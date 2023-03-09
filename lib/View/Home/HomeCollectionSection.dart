import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/CollectionDTO.dart';
import 'package:fine/Model/DTO/ProductDTO.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/cache_image.dart';
import 'package:fine/widgets/shimmer_block.dart';
import 'package:fine/widgets/touchopacity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class HomeCollectionSection extends StatefulWidget {
  const HomeCollectionSection({super.key});

  @override
  State<HomeCollectionSection> createState() => _HomeCollectionSectionState();
}

class _HomeCollectionSectionState extends State<HomeCollectionSection> {
  HomeViewModel? _homeCollectionViewModel;

  @override
  void initState() {
    super.initState();
    _homeCollectionViewModel = HomeViewModel();
    _homeCollectionViewModel?.getCollections();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: HomeViewModel(),
        child: ScopedModelDescendant<HomeViewModel>(
          builder: (context, child, model) {
            var collections = model.homeCollections;
            if (model.status == ViewStatus.Loading ||
                collections == null ||
                collections?.length == 0) {
              return _buildLoading();
            }
            return Column(
              children: collections
                  .where((element) =>
                      element.products != null && element.products?.length != 0)
                  .map(
                    (c) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: buildHomeCollection(c)),
                  )
                  .toList(),
            );
          },
        ));
  }

  Widget buildHomeCollection(CollectionDTO collection) {
    return TouchOpacity(
      onTap: () {
        // RootViewModel root = Get.find<RootViewModel>();
        // if (!root.isCurrentMenuAvailable()) {
        //   showStatusDialog("assets/images/global_error.png", "Opps",
        //       "Hiện tại khung giờ bạn chọn đã chốt đơn. Bạn vui lòng xem khung giờ khác nhé 😓 ");
        // } else {
        //   Get.toNamed(RouteHandler.PRODUCT_FILTER_LIST,
        //       arguments: {"collection-id": collection.id});
        // }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name!,
                    style: FineTheme.typograhpy.subtitle1
                        .copyWith(fontFamily: 'Inter'),
                  ),
                  collection.description != null
                      ? Text(
                          collection.description ?? "",
                          style: FineTheme.typograhpy.buttonSm
                              .copyWith(color: FineTheme.palettes.neutral600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox(
                          height: 0,
                        )
                ],
              ),
              Text(
                'Xem tất cả',
                style: FineTheme.typograhpy.buttonSm
                    .copyWith(color: FineTheme.palettes.primary300),
                // style: Get.find<RootViewModel>().isCurrentMenuAvailable()
                //     ? FineTheme.typograhpy.buttonSm
                //         .copyWith(color: FineTheme.palettes.primary300)
                //     : const TextStyle(color: Colors.grey),
              )
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: Get.width,
            height: 155,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) =>
                  SizedBox(width: FineTheme.spacing.xs),
              itemBuilder: (context, index) {
                var product = collection.products![index];
                return Material(
                  color: Colors.white,
                  child: TouchOpacity(
                    onTap: () {
                      // RootViewModel root = Get.find<RootViewModel>();
                      // // var firstTimeSlot = root.currentStore.timeSlots?.first;
                      // if (!root.isCurrentMenuAvailable()) {
                      //   showStatusDialog(
                      //       "assets/images/global_error.png",
                      //       "Opps",
                      //       "Hiện tại khung giờ bạn chọn đã chốt đơn. Bạn vui lòng xem khung giờ khác nhé 😓 ");
                      // } else {
                      //   if (product.type == ProductType.MASTER_PRODUCT) {}
                      //   root.openProductDetail(product, fetchDetail: true);
                      // }
                    },
                    child: buildProductInCollection(product),
                  ),
                );
              },
              itemCount: collection.products!.length,
            ),
          )
        ],
      ),
    );
  }

  Container buildProductInCollection(ProductDTO product) {
    return Container(
      width: 110,
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.transparent,
                BlendMode.saturation,
              ),
              // colorFilter: ColorFilter.mode(
              //   Get.find<RootViewModel>().isCurrentMenuAvailable()
              //       ? Colors.transparent
              //       : Colors.grey,
              //   BlendMode.saturation,
              // ),
              child: CacheImage(
                imageUrl: product.imageURL!,
              ),
            ),
          ),
          SizedBox(height: FineTheme.spacing.xxs),
          Text(
            product.name!,
            style: FineTheme.typograhpy.buttonSm
                .copyWith(color: FineTheme.palettes.shades200),
            // style: Get.find<RootViewModel>().isCurrentMenuAvailable()
            //     ? FineTheme.typograhpy.buttonSm
            //         .copyWith(color: FineTheme.palettes.shades200)
            //     : Get.theme.textTheme.headline5?.copyWith(
            //         color: Colors.grey,
            //       ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            // height: 40,
            child: Text(
              product.type != ProductType.MASTER_PRODUCT
                  ? '${formatPriceWithoutUnit(product.price!)} đ'
                  : 'từ ${formatPriceWithoutUnit(product.minPrice! ?? product.price!)} đ',
              style: FineTheme.typograhpy.caption1
                  .copyWith(color: FineTheme.palettes.primary300),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // SizedBox(height: 4),
          // Material(
          //   child: InkWell(
          //     onTap: () {
          //       print("ADD TO CART");
          //     },
          //     child: Container(
          //       width: kWitdthItem,
          //       padding: EdgeInsets.all(4),
          //       decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(16),
          //           border: Border.all(color: kPrimary)),
          //       child: Text(
          //         "Chọn",
          //         style: TextStyle(fontSize: 12),
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

Widget _buildLoading() {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerBlock(width: Get.width * 0.4, height: 30),
            ShimmerBlock(width: Get.width * 0.2, height: 30),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: Get.width,
          height: 155,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerBlock(
                height: 110,
                width: 110,
                borderRadius: 16,
              ),
              SizedBox(width: 8),
              ShimmerBlock(
                height: 110,
                width: 110,
                borderRadius: 16,
              ),
              SizedBox(width: 8),
              ShimmerBlock(
                height: 110,
                width: 110,
                borderRadius: 16,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
