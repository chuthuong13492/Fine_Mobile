import 'dart:async';

import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/MenuDTO.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/View/product_search.dart';
import 'package:fine/ViewModel/productFilter_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/cache_image.dart';
import 'package:fine/widgets/shimmer_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../Accessories/index.dart';
import '../ViewModel/root_viewModel.dart';

class ProductsFilterPage extends StatefulWidget {
  final Map<String, dynamic> params;
  const ProductsFilterPage({Key? key, this.params = const {}})
      : super(key: key);

  @override
  State<ProductsFilterPage> createState() => _ProductsFilterPageState();
}

class _ProductsFilterPageState extends State<ProductsFilterPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  ProductFilterViewModel? _prodFilterModel;

  Future<void> _refreshHandler() async {
    await Get.find<ProductFilterViewModel>().getProductsWithFilter();
  }

  @override
  void initState() {
    super.initState();
    _prodFilterModel = ProductFilterViewModel();
    Get.find<ProductFilterViewModel>().setParam(this.widget.params);
    // Timer.periodic(const Duration(seconds: 5), (_) {
    //   Get.find<ProductFilterViewModel>().getProductsWithFilter();
    // });
    Get.find<ProductFilterViewModel>().getProductsWithFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: widget.params["menu"]["menuName"],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshHandler,
        child: Column(
          children: [
            // _buildFilter(),
            _buildListProduct(),
          ],
        ),
      ),
    );
  }

  Widget _buildListProduct() {
    return ScopedModel(
      model: Get.find<ProductFilterViewModel>(),
      child: ScopedModelDescendant<ProductFilterViewModel>(
        builder: (context, child, model) {
          var list = model.listProducts!
              .where((element) => element.isAvailable!)
              .toList();

          if (model.status == ViewStatus.Loading) {
            return _buildLoading();
          }

          if (model.status == ViewStatus.Error) {
            return Flexible(
              child: Center(
                child: Text(model.msg ?? "Có gì đó sai sai",
                    style: FineTheme.typograhpy.subtitle1.copyWith(
                      color: Colors.red,
                    )),
              ),
            );
          }
          if (list == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Bạn đã xem hết rồi đấy 🐱‍👓",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Flexible(
            child: Container(
              width: Get.width,
              height: Get.height,
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 280),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final product = model.listProducts!.elementAt(index);
                  return Stack(
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
                                color: FineTheme.palettes.shades200
                                    .withOpacity(0.1),
                                offset: const Offset(
                                  -4.0,
                                  -5.0,
                                ),
                                blurRadius: 10.0,
                                spreadRadius: -3.0,
                              ),
                              BoxShadow(
                                color: FineTheme.palettes.shades200
                                    .withOpacity(0.1),
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
                                  formatPrice(product.price!),
                                  style: const TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.red),
                                ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              SizedBox(
                                  width: Get.width,
                                  height: 12,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FaIcon(
                                        Icons.star_half,
                                        color: FineTheme.palettes.primary300,
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
                                            color:
                                                FineTheme.palettes.neutral400),
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
                              color: FineTheme.palettes.primary100,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "assets/icons/shopping-bag-02.png"),
                                      fit: BoxFit.fill),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 35,
                        child: Container(
                          width: 122,
                          height: 122,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            // image: const DecorationImage(
                            //     fit: BoxFit.fill,
                            //     image: CachedNetworkImageProvider(
                            //         "https://static.tuoitre.vn/tto/i/s626/2011/10/05/AoGOfe8y.jpg")),
                          ),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Get.find<RootViewModel>()
                                      .isCurrentTimeSlotAvailable()
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
                    ],
                  );
                },
              ),
            ),
          );
          // return Flexible(
          //   child: ListView.separated(
          //     itemCount: model.listProducts!.length + 1,
          //     separatorBuilder: (context, index) => const SizedBox(height: 2),
          //     itemBuilder: (context, index) {
          //       if (index == model.listProducts!.length) {
          //         return const Center(
          //           child: Padding(
          //             padding: EdgeInsets.all(8.0),
          //             child: Text(
          //               "Bạn đã xem hết rồi đấy 🐱‍👓",
          //               textAlign: TextAlign.center,
          //             ),
          //           ),
          //         );
          //       }
          //       final product = model.listProducts!.elementAt(index);
          //       return ProductSearchItem(
          //         product: product,
          //         index: index,
          //       );
          //     },
          //   ),
          // );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Flexible(
      child: ListView.separated(
        itemCount: 10,
        itemBuilder: (context, index) => Container(
          height: 140,
          width: Get.width,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AspectRatio(
                  aspectRatio: 1, child: ShimmerBlock(width: 140, height: 140)),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBlock(width: 120, height: 20),
                    const SizedBox(height: 4),
                    const ShimmerBlock(width: 175, height: 20),
                    const SizedBox(height: 8),
                    Flexible(child: Container()),
                    Row(
                      children: const [
                        ShimmerBlock(width: 50, height: 20, borderRadius: 16),
                        SizedBox(width: 8),
                        ShimmerBlock(width: 50, height: 20, borderRadius: 16),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}
