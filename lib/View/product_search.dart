import 'package:fine/Utils/format_price.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Model/DTO/index.dart';

class ProductSearchItem extends StatelessWidget {
  const ProductSearchItem({
    Key? key,
    this.product,
    this.index = -1,
    this.showOnHome = false,
  }) : super(key: key);

  final ProductDTO? product;
  final int index;
  final bool showOnHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: index == 0 ? 16 : 0),
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            RootViewModel root = Get.find<RootViewModel>();
            root.openProductDetail(product);
          },
          child: Container(
            height: 110,
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    // color: Colors.grey,
                  ),
                  // width: 110,
                  child: const AspectRatio(
                    aspectRatio: 1,
                    child: CacheImage(imageUrl: defaultImg),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product!.productName!,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: FineTheme.typograhpy.subtitle1.copyWith(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // if (product.minPrice != null) ...[
                              //   Container(
                              //     padding: EdgeInsets.fromLTRB(0, 6, 8, 4),
                              //     child: Text(
                              //       formatPrice(product.minPrice),
                              //       style: BeanOiTheme.typography.subtitle2
                              //           .copyWith(
                              //               color: BeanOiTheme
                              //                   .palettes.primary400),
                              //     ),
                              //   ),
                              // ] else ...[
                              Container(
                                padding: const EdgeInsets.fromLTRB(0, 6, 8, 4),
                                child: Text(
                                  formatPrice(product!.price!),
                                  style: FineTheme.typograhpy.subtitle2
                                      .copyWith(
                                          color: FineTheme.palettes.primary300),
                                ),
                              ),
                              // ],
                              const SizedBox(width: 8),
                              // Container(
                              //   padding: EdgeInsets.fromLTRB(0, 6, 8, 4),
                              //   child: Text.rich(TextSpan(children: [
                              //     TextSpan(
                              //       text: "+ ${product.bean}",
                              //       style: BeanOiTheme.typography.subtitle2
                              //           .copyWith(
                              //               color: BeanOiTheme
                              //                   .palettes.secondary1000),
                              //     ),
                              //     WidgetSpan(
                              //         child: Container(
                              //       margin: EdgeInsets.only(left: 5, bottom: 2),
                              //       child: ImageIcon(
                              //         AssetImage(
                              //             "assets/images/icons/bean_coin.png"),
                              //         color: Colors.orange,
                              //       ),
                              //       width: 15,
                              //       height: 15,
                              //     ))
                              //   ])),
                              // )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 50),
                  child: InkWell(
                    onTap: () {
                      RootViewModel root = Get.find<RootViewModel>();
                      root.openProductDetail(product, showOnHome: true);
                    },
                    child: Container(
                      width: 120,
                      height: 30,
                      decoration: BoxDecoration(
                          color: FineTheme.palettes.primary300.withOpacity(0.2),
                          border:
                              Border.all(color: FineTheme.palettes.primary300),
                          borderRadius: BorderRadius.circular(8)),
                      child: Center(
                          child: Text(
                        'Thêm',
                        style: FineTheme.typograhpy.subtitle2
                            .copyWith(color: FineTheme.palettes.primary300),
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
