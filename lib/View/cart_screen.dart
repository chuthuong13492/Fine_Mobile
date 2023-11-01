import 'package:fine/Accessories/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/ViewModel/cart_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../Utils/format_price.dart';
import '../widgets/cache_image.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  CartViewModel? cartViewModel = Get.find<CartViewModel>();
  AutoScrollController? controller;
  final scrollDirection = Axis.vertical;
  bool onInit = true;

  @override
  void initState() {
    super.initState();
    prepareCart();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
  }

  void prepareCart() async {
    await cartViewModel?.getCurrentCart();
    setState(() {
      onInit = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: Get.find<CartViewModel>(),
      child: ScopedModelDescendant<CartViewModel>(
        builder: (context, child, model) {
          final cart = model.currentCart;
          List<CartItem>? items;
          if (cart != null) {
            items = cart.items;
          }
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: FineTheme.palettes.neutral200,
              appBar: AppBar(
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Column(
                    children: [
                      const Divider(
                        color: Colors.black,
                        height: 0.5,
                      ),
                      TabBar(
                        indicatorColor: FineTheme.palettes.primary100,
                        overlayColor: MaterialStateColor.resolveWith(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.focused)) {
                            return FineTheme.palettes.primary100;
                          }
                          if (states.contains(MaterialState.error)) {
                            return Colors.red;
                          }
                          return FineTheme.palettes.primary100;
                        }),
                        tabs: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 12),
                            child: Text(
                                cart != null
                                    ? "Tất cả ${model.currentCart!.itemQuantity()}"
                                    : "Tất cả 0",
                                style: FineTheme.typograhpy.body1.copyWith(
                                  color: FineTheme.palettes.emerald25,
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 12),
                            child: Text("Mua lại",
                                style: FineTheme.typograhpy.body1.copyWith(
                                  color: FineTheme.palettes.emerald25,
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 0.6,
                centerTitle: true,
                leading: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(Icons.arrow_back_ios,
                          size: 20, color: FineTheme.palettes.primary100),
                    ),
                  ),
                ),
                title: Text("Giỏ hàng của bạn".toUpperCase(),
                    style: FineTheme.typograhpy.h2
                        .copyWith(color: FineTheme.palettes.primary100)),
              ),
              bottomNavigationBar:
                  onInit ? const SizedBox.shrink() : bottomBar(model),
              body: TabBarView(children: [
                items != null
                    ? ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          bool checked = model.isCheckedList[index];
                          final item = items![index];
                          Color minusColor = FineTheme.palettes.neutral500;
                          if (item.quantity >= 1) {
                            minusColor = FineTheme.palettes.primary300;
                          }
                          Color plusColor = FineTheme.palettes.primary300;
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              color: FineTheme.palettes.shades100,
                              padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    activeColor: FineTheme.palettes.primary100,
                                    checkColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                    value: checked,
                                    onChanged: (value) {
                                      model.changeValueChecked(
                                          value!, index, item);
                                    },
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    width: 90,
                                    height: 90,
                                    child: CacheStoreImage(
                                      imageUrl: item.imgUrl ?? defaultImage,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 90,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.productName!,
                                                style: FineTheme
                                                    .typograhpy.subtitle2
                                                    .copyWith(
                                                  color: FineTheme
                                                      .palettes.shades200,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              item.size != null
                                                  ? Container(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(8, 4, 8, 4),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                            width: 1.5,
                                                            color: FineTheme
                                                                .palettes
                                                                .primary100),
                                                      ),
                                                      child: Text(
                                                        "Size ${item.size}",
                                                        style: FineTheme
                                                            .typograhpy
                                                            .subtitle2
                                                            .copyWith(
                                                                color: FineTheme
                                                                    .palettes
                                                                    .primary100),
                                                      ),
                                                    )
                                                  : Text(
                                                      "Ngon nhắm, hãy thử ngay nào",
                                                      style: FineTheme
                                                          .typograhpy.caption1
                                                          .copyWith(
                                                        color: FineTheme
                                                            .palettes
                                                            .neutral500,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                formatPrice(item.fixTotal!),
                                                style: const TextStyle(
                                                  fontFamily: "Montserrat",
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                    child: Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                      size: 25,
                                                      color: minusColor,
                                                    ),
                                                    onTap: () async {
                                                      if (item.quantity >= 1) {
                                                        if (item.quantity ==
                                                            1) {
                                                          await model
                                                              .deleteItem(
                                                                  item, index);
                                                        } else {
                                                          item.quantity--;
                                                          await model
                                                              .updateItem(item,
                                                                  index, false);
                                                        }
                                                      }
                                                    },
                                                  ),
                                                  // SizedBox(
                                                  //   width: 8,
                                                  // ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(12, 5, 12, 5),
                                                    decoration: BoxDecoration(
                                                        // border: Border.all(color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    child: Text(
                                                      item.quantity.toString(),
                                                      style: FineTheme
                                                          .typograhpy.h2
                                                          .copyWith(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  // SizedBox(
                                                  //   width: 1,
                                                  // ),
                                                  InkWell(
                                                    child: Icon(
                                                      Icons.add_circle_outline,
                                                      size: 25,
                                                      color: plusColor,
                                                    ),
                                                    onTap: () async {
                                                      item.quantity++;
                                                      await model.updateItem(
                                                          item, index, true);
                                                    },
                                                  )
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          "Giỏ hàng đang trống",
                          style: FineTheme.typograhpy.subtitle1,
                        ),
                      ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 12),
                            child: Text(
                              'Sản phẩm',
                              style: FineTheme.typograhpy.h2.copyWith(
                                color: FineTheme.palettes.emerald50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        // ignore: sort_child_properties_last
                        // child: _buildReportedProducts(),
                        color: const Color(0xffefefef),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
                // Tab1(),
                // Tab2(),
              ]),
            ),
          );
        },
      ),
    );
  }

  // Widget buildProduct() {
  //   bool isChecked = false;
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
  //     child: Container(
  //       width: Get.width,
  //       color: FineTheme.palettes.shades100,
  //       padding: const EdgeInsets.all(8),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Checkbox(
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(100)),
  //             value: isChecked,
  //             onChanged: (value) {
  //               isChecked = value!;
  //             },
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget cartSection() {
    return ScopedModelDescendant<CartViewModel>(
      builder: (context, child, model) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey,
            //     offset: Offset(0.0, 1.0), //(x,y)
            //     blurRadius: 6.0,
            //   ),
            // ],
          ),
          child: TabBar(
            indicatorColor: FineTheme.palettes.primary100,
            overlayColor:
                MaterialStateColor.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.focused)) {
                return FineTheme.palettes.primary100;
              }
              if (states.contains(MaterialState.error)) {
                return Colors.red;
              }
              return FineTheme.palettes.primary100;
            }),
            tabs: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Text("Tất cả ${model.currentCart!.itemQuantity()}",
                    style: FineTheme.typograhpy.body1.copyWith(
                      color: FineTheme.palettes.emerald25,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Text("Mua lại",
                    style: FineTheme.typograhpy.body1.copyWith(
                      color: FineTheme.palettes.emerald25,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget bottomBar(CartViewModel model) {
    bool isSelected = model.isCheckedList.any((element) => element == true);

    return Container(
      height: 120,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 60),
      decoration: BoxDecoration(
        color: FineTheme.palettes.shades100,
        border: Border(
          top: BorderSide(color: FineTheme.palettes.neutral400),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Tổng cộng: ",
                    style: FineTheme.typograhpy.body1,
                  ),
                  Text(
                    formatPrice(model.total),
                    style: FineTheme.typograhpy.h2
                        .copyWith(color: FineTheme.palettes.primary300),
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  Text(
                    "Số lượng: ",
                    style: FineTheme.typograhpy.body1.copyWith(),
                  ),
                  Text(
                    model.quantityChecked.toString(),
                    style: FineTheme.typograhpy.subtitle1
                        .copyWith(color: FineTheme.palettes.primary100),
                  ),
                ],
              )
            ],
          ),
          InkWell(
            onTap: isSelected
                ? () async {
                    await model.orderPayment();
                  }
                : null,
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? FineTheme.palettes.primary100
                      : FineTheme.palettes.neutral700,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? FineTheme.palettes.primary100
                        : FineTheme.palettes.neutral700,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isSelected ? "Thanh toán" : "Chưa chọn món",
                  style: FineTheme.typograhpy.subtitle1.copyWith(
                    color: isSelected
                        ? FineTheme.palettes.primary100
                        : FineTheme.palettes.neutral700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
