import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/cart_viewModel.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../Utils/format_price.dart';
import '../widgets/cache_image.dart';
import '../widgets/shimmer_block.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  CartViewModel? cartViewModel = Get.find<CartViewModel>();
  final party = Get.find<PartyOrderViewModel>();
  AutoScrollController? controller;
  TabController? _tabController;
  final scrollDirection = Axis.vertical;
  bool onInit = true;
  bool onTapBar = true;

  @override
  void initState() {
    super.initState();
    prepareCart();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(_handleTabChange);
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
  }

  void _handleTabChange() async {
    int selectedIndex = _tabController!.index;
    if (selectedIndex == 0) {
      await cartViewModel?.getCurrentCart();
      setState(() {
        onTapBar = true;
      });
    } else {
      await cartViewModel?.getReOrder();
      setState(() {
        onTapBar = false;
      });
    }
  }

  void prepareCart() async {
    await cartViewModel?.getCurrentCart();
    setState(() {
      onInit = false;
    });
  }

  Future<void> refreshFetchOrder() async {
    await cartViewModel?.getCurrentCart();
    await cartViewModel?.getReOrder();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: Get.find<CartViewModel>(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: FineTheme.palettes.neutral200,
          appBar: AppBar(
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: ScopedModelDescendant<CartViewModel>(
                builder: (context, child, model) {
                  final cart = model.currentCart;

                  return Column(
                    children: [
                      const Divider(
                        thickness: 0.2,
                        color: Colors.black,
                        height: 0.5,
                      ),
                      IgnorePointer(
                        ignoring: true,
                        child: TabBar(
                          controller: _tabController,
                          onTap: (value) async {
                            if (value == 0) {
                              setState(() {
                                onTapBar = true;
                              });
                              await model.getCurrentCart();
                            } else {
                              setState(() {
                                onTapBar = false;
                              });
                              await model.getReOrder();
                            }
                          },
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
                              padding:
                                  const EdgeInsets.only(top: 12, bottom: 12),
                              child: Text(
                                  cart != null
                                      ? "Tất cả ${model.currentCart!.itemQuantity()}"
                                      : "Tất cả 0",
                                  style: FineTheme.typograhpy.body1.copyWith(
                                    color: FineTheme.palettes.emerald25,
                                  )),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 12, bottom: 12),
                              child: Text("Đặt lại",
                                  style: FineTheme.typograhpy.body1.copyWith(
                                    color: FineTheme.palettes.emerald25,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
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
          bottomNavigationBar: onInit
              ? const SizedBox.shrink()
              : onTapBar == true
                  ? bottomBar()
                  : const SizedBox.shrink(),
          body: ScopedModelDescendant<CartViewModel>(
            builder: (context, child, model) {
              final cart = model.currentCart;
              final reOrderList = model.reOrderList;
              List<CartItem>? items;
              if (cart != null) {
                items = cart.items;
              }

              if (model.status == ViewStatus.Loading) {
                return _buildLoading();
              }
              if (model.status == ViewStatus.Completed) {
                return TabBarView(
                  controller: _tabController,
                  children: [
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
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 12, 16, 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                        activeColor:
                                            FineTheme.palettes.primary100,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(
                                                    height: 2,
                                                  ),
                                                  item.size != null
                                                      ? Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  8, 4, 8, 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
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
                                                              .typograhpy
                                                              .caption1
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    formatPrice(item.fixTotal!),
                                                    style: const TextStyle(
                                                      fontFamily: "Montserrat",
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      InkWell(
                                                        child: Icon(
                                                          Icons
                                                              .remove_circle_outline,
                                                          size: 25,
                                                          color: minusColor,
                                                        ),
                                                        onTap: () async {
                                                          if (item.quantity >=
                                                              1) {
                                                            if (item.quantity ==
                                                                1) {
                                                              await model
                                                                  .deleteItem(
                                                                      item,
                                                                      index);
                                                            } else {
                                                              item.quantity--;
                                                              await model
                                                                  .updateItem(
                                                                      item,
                                                                      index,
                                                                      false);
                                                            }
                                                          }
                                                        },
                                                      ),
                                                      // SizedBox(
                                                      //   width: 8,
                                                      // ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                12, 5, 12, 5),
                                                        decoration:
                                                            BoxDecoration(
                                                                // border: Border.all(color: Colors.grey),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                        child: Text(
                                                          item.quantity
                                                              .toString(),
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
                                                          Icons
                                                              .add_circle_outline,
                                                          size: 25,
                                                          color: plusColor,
                                                        ),
                                                        onTap: () async {
                                                          item.quantity++;
                                                          await model
                                                              .updateItem(item,
                                                                  index, true);
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
                    reOrderList == null
                        ? ListView.builder(
                            itemCount: 2,
                            itemBuilder: (context, index) {
                              String inputDate = "2023-11-02T10:42:03.155Z";
                              DateTime dateTime =
                                  DateTime.parse(inputDate).toLocal();
                              String dayFormat =
                                  DateFormat('dd').format(dateTime);
                              String dateFormat =
                                  DateFormat('MM y, HH:mm').format(dateTime);
                              return Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    color: FineTheme.palettes.shades100,
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 12, 24, 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: const SizedBox(
                                                width: 31,
                                                height: 31,
                                                child: CacheImage(
                                                    imageUrl: defaultImage),
                                              ),
                                            ),
                                            const SizedBox(width: 19),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Trạm: Passio lầu 2",
                                                    style: FineTheme
                                                        .typograhpy.body1,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        "assets/icons/clock_icon.png",
                                                        width: 16,
                                                        height: 16,
                                                      ),
                                                      const SizedBox(
                                                        width: 4,
                                                      ),
                                                      Text(
                                                        "12:00 - 12:00",
                                                        style: FineTheme
                                                            .typograhpy
                                                            .caption1,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "${dayFormat} thg ${dateFormat}",
                                                    style: FineTheme
                                                        .typograhpy.caption1
                                                        .copyWith(
                                                      color: FineTheme
                                                          .palettes.neutral500,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Text(
                                              formatPrice(78000.00),
                                              style: FineTheme.typograhpy.body1,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Expanded(
                                              child: SizedBox(
                                                width: 50,
                                              ),
                                            ),
                                            InkWell(
                                                onTap: () {},
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Đặt lại",
                                                      style: FineTheme
                                                          .typograhpy.subtitle1
                                                          .copyWith(
                                                              color: FineTheme
                                                                  .palettes
                                                                  .primary100),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
                                                      decoration: BoxDecoration(
                                                          color: FineTheme
                                                              .palettes
                                                              .primary50,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100)),
                                                      child: Icon(
                                                        Icons
                                                            .chevron_right_rounded,
                                                        size: 12,
                                                        color: FineTheme
                                                            .palettes
                                                            .primary100,
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              "Bạn chưa đặt đơn nào trong hôm nay 🥺",
                              style: FineTheme.typograhpy.subtitle1,
                            ),
                          ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget bottomBar() {
    return ScopedModelDescendant<CartViewModel>(
      builder: (context, child, model) {
        bool isSelected = model.isCheckedList.any((element) => element == true);
        bool hasParty = false;
        if (party.partyCode != null) {
          hasParty = true;
        } else {
          hasParty = false;
        }
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
                    ? hasParty
                        ? () async {
                            await party.addProductToPartyOrder();
                          }
                        : () async {
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
                      isSelected
                          ? hasParty
                              ? "Thêm vào Party"
                              : "Thanh toán"
                          : "Chưa chọn món",
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
      },
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Container(
            color: FineTheme.palettes.shades100,
            padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const ShimmerBlock(
                    width: 20,
                    height: 20,
                    borderRadius: 100,
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                const ShimmerBlock(
                  width: 90,
                  height: 90,
                  borderRadius: 10,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: SizedBox(
                    height: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        ShimmerBlock(height: 10, width: 100),
                        ShimmerBlock(height: 10, width: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
