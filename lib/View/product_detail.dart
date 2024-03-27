import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Model/DTO/ProductDTO.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/productFilter_viewModel.dart';
import 'package:fine/ViewModel/product_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/cache_image.dart';
import 'package:fine/widgets/touchopacity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import '../ViewModel/order_viewModel.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductDTO dto;

  const ProductDetailScreen({super.key, required this.dto});

  @override
  // ignore: library_private_types_in_public_api
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<String>? affectPriceTabs;

  ProductDetailViewModel? _productDetailViewModel;

  @override
  void initState() {
    super.initState();
    _productDetailViewModel = ProductDetailViewModel(dto: widget.dto);
    _productDetailViewModel = Get.find<ProductDetailViewModel>();
    // if (widget.dto.type == ProductType.MASTER_PRODUCT ||
    //     widget.dto.type == ProductType.COMPLEX_PRODUCT) {
    //   affectPriceTabs = new List<String>();
    // List<String> affectkeys =
    //     productDetailViewModel.affectPriceContent.keys.toList();
    // for (int i = 0; i < affectkeys.length; i++) {
    //   affectPriceTabs.add(affectkeys[i].toUpperCase());
    // }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: ProductDetailViewModel(dto: widget.dto),
      child: Scaffold(
        backgroundColor: FineTheme.palettes.shades100,
        bottomNavigationBar: bottomBar(),
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              delegate: CustomSliverAppBarDelegate(
                  expandedHeight: 520, dto: widget.dto),
              pinned: true,
            ),
            SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Container(),
                      productTitle(),

                      // _buidProductRecomend(),
                      // tabCompination()
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget productTitle() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 4),
      // transform: Matrix4.translationValues(0.0, -50.0, 0.0),
      // color: kBackgroundGrey[0],
      // padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Row(
          //       children: [
          //         SvgPicture.asset(
          //           "assets/icons/box_icon.svg",
          //           width: 20,
          //           height: 20,
          //         ),
          //         const SizedBox(
          //           width: 10,
          //         ),
          //         Text(
          //           "Giao tại box",
          //           style: FineTheme.typograhpy.body1,
          //         ),
          //       ],
          //     ),
          //     InkWell(
          //       onTap: () {},
          //       child: Text(
          //         "Thay đổi",
          //         style: FineTheme.typograhpy.body2
          //             .copyWith(color: FineTheme.palettes.primary100),
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(
          //   height: 8,
          // ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/Party.svg",
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Vào Party",
                    style: FineTheme.typograhpy.body1,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 30,
                    height: 16,
                    color: Colors.red,
                    child: Center(
                      child: Text(
                        "Mới",
                        style: FineTheme.typograhpy.caption1.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () async {
                  await showPartyDialog(false, isHome: false);
                },
                child: Text(
                  "Tạo phòng",
                  style: FineTheme.typograhpy.body2
                      .copyWith(color: FineTheme.palettes.primary100),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/Voucher.svg",
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 220,
                    child: Text(
                      "Hoàn tiền cho đơn nhóm nè",
                      style: FineTheme.typograhpy.body1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // InkWell(
              //   onTap: () {},
              //   child: Text(
              //     "Xem thêm",
              //     style: FineTheme.typograhpy.body2
              //         .copyWith(color: FineTheme.palettes.primary100),
              //   ),
              // ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    Icons.star_outlined,
                    size: 24,
                    color: FineTheme.palettes.primary300,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "4.9",
                    style:
                        FineTheme.typograhpy.h2.copyWith(color: Colors.black),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "(+100)",
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: FineTheme.palettes.neutral500),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Image.asset(
                    "assets/icons/shopping-bag-black.png",
                    width: 18,
                    height: 20,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "500+ đã bán",
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: FineTheme.palettes.neutral500),
                  ),
                ],
              ),
              // InkWell(
              //   onTap: () {},
              //   child: Text(
              //     "Xem đánh giá",
              //     style: FineTheme.typograhpy.body2
              //         .copyWith(color: FineTheme.palettes.primary100),
              //   ),
              // ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),

          // orderButton(),
        ],
      ),
    );
  }

  Widget bottomBar() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        color: FineTheme.palettes.shades100,
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 6.0,
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(
            height: 16,
          ),
          // Center(child: selectQuantity()),
          // const SizedBox(
          //   height: 8,
          // ),
          orderButton(),
          const SizedBox(
            height: 8,
          )
        ],
      ),
    );
  }

  Widget orderButton() {
    return ScopedModelDescendant<ProductDetailViewModel>(
      builder: (context, child, model) {
        final quantity = model.count;
        return Container(
          height: 40,
          width: Get.width,
          // padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FineTheme.palettes.primary200,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              textStyle: TextStyle(color: FineTheme.palettes.neutral100),
            ),
            // padding: const EdgeInsets.all(8),
            onPressed: () async {
              await model.addProductToCart();
              // Get.back();
            },
            // textColor: kBackgroundGrey[0],
            child: Text(
              "Thêm vào giỏ hàng",
              style: FineTheme.typograhpy.h2.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget selectQuantity() {
    return ScopedModelDescendant<ProductDetailViewModel>(
      builder: (context, child, model) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                size: 30,
                color: model.minusColor,
              ),
              onPressed: () {
                model.minusQuantity();
              },
            ),
            // SizedBox(
            //   width: 8,
            // ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                model.count.toString(),
                style: FineTheme.typograhpy.subtitle1
                    .copyWith(color: Colors.black, fontWeight: FontWeight.w700),
              ),
            ),
            // SizedBox(
            //   width: 1,
            // ),
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                size: 30,
                color: model.addColor,
              ),
              onPressed: () {
                model.addQuantity();
              },
            )
          ],
        );
      },
    );
  }
}

class CustomSliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final ProductDTO dto;
  final double expandedHeight;

  const CustomSliverAppBarDelegate(
      {required this.expandedHeight, required this.dto});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final size = 60;
    final top = expandedHeight - shrinkOffset - size / 2;

    return Stack(
      fit: StackFit.expand,
      children: [
        buildBackground(shrinkOffset),
        // buildAppBar(shrinkOffset),
        Positioned(
          top: 230,
          left: 20,
          right: 20,
          child: buildFloating(shrinkOffset),
        ),
        Positioned(
          left: 100,
          right: 100,
          top: 100,
          child: Opacity(
            opacity: disappear(shrinkOffset),
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                color: Colors.white,
                image: DecorationImage(
                  image:
                      CachedNetworkImageProvider(dto.imageUrl ?? defaultImage),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.white, width: 3.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0.0, 4.0),
                    blurRadius: 10,
                    blurStyle: BlurStyle.normal,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  double appear(double shrinkOffset) => shrinkOffset / expandedHeight;

  double disappear(double shrinkOffset) => 1 - shrinkOffset / expandedHeight;
  Widget buildBackground(double shrinkOffset) => Opacity(
        opacity: disappear(shrinkOffset),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 235),
          child: Stack(
            children: [
              Container(
                // height: 275,
                // padding: EdgeInsets.only(bottom: 100),
                width: Get.width,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(
                            dto.imageUrl ?? defaultImage),
                        fit: BoxFit.cover)),
              ),
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Container(
                  width: Get.width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        // margin: const EdgeInsets.only(left: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(56.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                            child: Container(
                                height: 40.0,
                                width: 40.0,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // color: Colors.white.withOpacity(0.20),
                                  color: FineTheme.palettes.primary100,
                                  border: Border.all(color: Colors.white),
                                ),
                                child: Center(
                                  child: IconButton(
                                    padding: const EdgeInsets.all(0),
                                    onPressed: () async {
                                      Get.back();
                                    },
                                    icon: const Icon(
                                      Icons.chevron_left_outlined,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
  Widget buildFloating(double shrinkOffset) => Opacity(
        opacity: disappear(shrinkOffset),
        child: Container(
          // height: 275,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: FineTheme.palettes.shades100,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0.0, 5),
                  blurRadius: 10),
            ],
          ),
          child: Container(
            padding:
                const EdgeInsets.only(top: 90, left: 16, right: 16, bottom: 16),
            child: ScopedModelDescendant<ProductDetailViewModel>(
              builder: (context, child, model) {
                bool? isSelect;

                List<Widget> listWidget = [];
                List<ProductAttributes>? attributeList =
                    model.master!.attributes;
                if (dto.attributes!.length > 1) {
                  model.isExtra = true;
                }
                if (model.isExtra == true) {
                  for (var i = 0; i < attributeList!.length; i++) {
                    isSelect = model.selectAttribute!.id == attributeList[i].id;
                    listWidget.add(
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              model.selectedAttribute(attributeList[i]);
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: isSelect
                                        ? FineTheme.palettes.primary100
                                        : FineTheme.palettes.neutral700,
                                    width: 1.5),
                              ),
                              child: Text(
                                "Size ${attributeList[i].size!}",
                                style: FineTheme.typograhpy.subtitle1.copyWith(
                                    color: isSelect
                                        ? FineTheme.palettes.primary100
                                        : FineTheme.palettes.neutral700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    );
                  }
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 55,
                        // width: 280,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                dto.productName!,
                                overflow: TextOverflow.ellipsis,
                                style: FineTheme.typograhpy.h1.copyWith(
                                    color: Colors.black, fontSize: 20),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  Icons.star_outlined,
                                  size: 24,
                                  color: FineTheme.palettes.primary300,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "4.9",
                                  style: FineTheme.typograhpy.h2
                                      .copyWith(color: Colors.black),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "(+100)",
                                  style: FineTheme.typograhpy.subtitle2
                                      .copyWith(
                                          color: FineTheme.palettes.neutral500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // const SizedBox(
                    //   height: 8,
                    // ),
                    Container(
                      height: 48,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Center(
                            child: Text(
                              formatPrice(model.total!),
                              style: const TextStyle(
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  size: 30,
                                  color: model.minusColor,
                                ),
                                onPressed: () {
                                  model.minusQuantity();
                                },
                              ),
                              // SizedBox(
                              //   width: 8,
                              // ),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 5, 12, 5),
                                decoration: BoxDecoration(
                                    // border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  model.count.toString(),
                                  style: FineTheme.typograhpy.h2.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   width: 1,
                              // ),
                              IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  size: 30,
                                  color: model.addColor,
                                ),
                                onPressed: () {
                                  model.addQuantity();
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),

                    Container(
                      width: 295,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          model.isExtra == true
                              ? Row(
                                  children: [
                                    ...listWidget.toList(),
                                  ],
                                )
                              : const SizedBox.shrink(),
                          // Text(
                          //   "Mô Tả",
                          //   style: FineTheme.typograhpy.subtitle1,
                          // ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            "Ngon nhắm, hãy thử ngay nào",
                            style: FineTheme.typograhpy.body2,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            // dto.storeName!,
                            "Đại học FPT",
                            style: FineTheme.typograhpy.subtitle1,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 30;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
