import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/cart_viewModel.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../Model/DTO/index.dart';
import '../Utils/format_price.dart';
import '../ViewModel/product_viewModel.dart';
import '../widgets/cache_image.dart';
import '../widgets/shimmer_block.dart';
import '../widgets/touchopacity.dart';

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
  final root = Get.find<RootViewModel>();
  final orderViewModel = Get.find<OrderViewModel>();
  AutoScrollController? controller;
  TabController? _tabController;
  final scrollDirection = Axis.vertical;
  bool onInit = true;
  bool onTapBar = true;
  bool hasParty = false;
  String? partyCode;

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

  @override
  void dispose() {
    super.dispose();
    Get.find<PartyOrderViewModel>().isCartRoute = false;
  }

  void _handleTabChange() async {
    int selectedIndex = _tabController!.index;
    if (selectedIndex == 0) {
      Get.find<PartyOrderViewModel>().isCartRoute = true;
      await cartViewModel?.getCurrentCart();
      setState(() {
        onTapBar = true;
      });
    } else {
      Get.find<PartyOrderViewModel>().isCartRoute = false;
      await cartViewModel?.getReOrder();
      setState(() {
        onTapBar = false;
      });
    }
  }

  void prepareCart() async {
    if (Get.currentRoute == "/nav_screen") {
      Get.find<PartyOrderViewModel>().isCartRoute = true;
    }
    partyCode = await getPartyCode();
    if (partyCode != null) {
      if (partyCode!.contains("CPO")) {
        hasParty = true;
      }
    } else {
      hasParty = false;
    }
    await cartViewModel?.getCurrentCart();
    setState(() {
      onInit = false;
    });
  }

  Future<void> refreshFetch() async {
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
            // leading: Container(
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(32),
            //   ),
            //   child: Material(
            //     color: Colors.white,
            //     child: InkWell(
            //       onTap: () {
            //         Get.back();
            //       },
            //       child: Icon(Icons.arrow_back_ios,
            //           size: 20, color: FineTheme.palettes.primary100),
            //     ),
            //   ),
            // ),
            title: Text("Giỏ hàng của bạn".toUpperCase(),
                style: FineTheme.typograhpy.h2
                    .copyWith(color: FineTheme.palettes.primary100)),
          ),
          body: ScopedModelDescendant<CartViewModel>(
            builder: (context, child, model) {
              DateFormat inputFormat = DateFormat('HH:mm:ss');
              DateTime arrive =
                  inputFormat.parse(root.selectedTimeSlot!.arriveTime!);
              DateTime checkout =
                  inputFormat.parse(root.selectedTimeSlot!.checkoutTime!);
              DateFormat outputFormat = DateFormat('HH:mm');
              String arriveTime = outputFormat.format(arrive);
              String checkoutTime = outputFormat.format(checkout);
              final cart = model.currentCart;
              final reOrderList = model.reOrderList;
              List<CartItem>? itemsChecked;
              List<CartItem>? itemsUnChecked;
              List<CartItem>? itemParty;

              List<Widget>? checkedList = [];
              List<Widget>? unCheckedList = [];
              List<Widget>? prodPartyList = [];

              if (cart != null) {
                itemsChecked = cart.items
                    ?.where((element) =>
                        element.isChecked == true &&
                        element.isAddParty == false)
                    .toList();
                itemsUnChecked = cart.items
                    ?.where((element) => element.isChecked == false)
                    .toList();
                itemParty = cart.items
                    ?.where((element) => element.isAddParty == true)
                    .toList();
                if (itemsChecked!.isNotEmpty) {
                  itemsChecked
                      .sort((a, b) => a.productName!.compareTo(b.productName!));
                  for (var i = 0; i < itemsChecked.length; i++) {
                    Color minusColor = FineTheme.palettes.neutral500;
                    if (itemsChecked[i].quantity >= 1) {
                      minusColor = FineTheme.palettes.primary300;
                    }
                    Color plusColor = FineTheme.palettes.primary300;
                    checkedList.insert(
                        i,
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: buildProduct(
                              itemsChecked[i], i, minusColor, plusColor),
                        ));
                  }
                } else {
                  checkedList = [];
                }

                if (itemsUnChecked!.isNotEmpty) {
                  itemsUnChecked
                      .sort((a, b) => a.productName!.compareTo(b.productName!));
                  for (var i = 0; i < itemsUnChecked.length; i++) {
                    Color minusColor = FineTheme.palettes.neutral500;
                    if (itemsUnChecked[i].quantity >= 1) {
                      minusColor = FineTheme.palettes.primary300;
                    }
                    Color plusColor = FineTheme.palettes.primary300;
                    unCheckedList.insert(
                      i,
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: buildProduct(
                            itemsUnChecked[i], i, minusColor, plusColor),
                      ),
                    );
                  }
                } else {
                  unCheckedList = [];
                }

                if (itemParty!.isNotEmpty) {
                  itemParty
                      .sort((a, b) => a.productName!.compareTo(b.productName!));
                  for (var i = 0; i < itemParty.length; i++) {
                    Color minusColor = FineTheme.palettes.neutral500;
                    if (itemParty[i].quantity >= 1) {
                      minusColor = FineTheme.palettes.primary300;
                    }
                    Color plusColor = FineTheme.palettes.primary300;
                    prodPartyList.insert(
                      i,
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Slidable(
                            endActionPane: ActionPane(
                                extentRatio: 0.2,
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) async {
                                      await Get.find<CartViewModel>()
                                          .removeProductInPartyOrder(
                                              itemParty![i].productId!);
                                    },
                                    backgroundColor:
                                        FineTheme.palettes.shades100,
                                    foregroundColor: Colors.red,
                                    icon: Icons.delete_outline,
                                    // label: 'Xóa',
                                  ),
                                ]),
                            child: buildProduct(
                                itemParty[i], i, minusColor, plusColor)),
                      ),
                    );
                  }
                } else {
                  prodPartyList = [];
                }
              }

              bool hasVoucher = false;
              if (model.code != null) {
                if (model.code!.contains("LPO")) {
                  hasVoucher = true;
                } else {
                  hasParty = true;
                }
              } else {
                hasParty = false;
              }

              if (model.status == ViewStatus.Loading) {
                // return _buildLoading();
                return const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 95),
                  child: Center(
                    child: LoadingFine(),
                  ),
                );
              }
              if (model.status == ViewStatus.Completed) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    cart != null
                        ? Column(
                            children: [
                              hasVoucher
                                  ? Container(
                                      width: Get.width,
                                      color: FineTheme.palettes.primary50,
                                      padding: const EdgeInsets.only(
                                          top: 8, bottom: 8),
                                      child: Center(
                                        child: Text(
                                          "Mã voucher nhóm: ${model.code}",
                                          style: FineTheme.typograhpy.subtitle2
                                              .copyWith(
                                                  color: FineTheme
                                                      .palettes.primary100),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              const SizedBox(height: 4),
                              Expanded(
                                child: ListView(
                                  children: [
                                    prodPartyList.isNotEmpty
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8, top: 4),
                                                child: Text(
                                                  "Đã thêm vào 🎉Party🎉",
                                                  style: FineTheme
                                                      .typograhpy.subtitle1,
                                                ),
                                              ),
                                              ...prodPartyList.toList(),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                    checkedList.isNotEmpty
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8, top: 4),
                                                child: Text(
                                                  "Đang chọn...",
                                                  style: FineTheme
                                                      .typograhpy.subtitle1,
                                                ),
                                              ),
                                              ...checkedList.toList(),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                    // model.listRecommend != null &&
                                    //         model.listRecommend!.isNotEmpty
                                    //     ? Container(
                                    //         padding: const EdgeInsets.fromLTRB(
                                    //             0, 10, 0, 0),
                                    //         child: _buidProductRecomend(
                                    //             model.listRecommend))
                                    //     : const SizedBox.shrink(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, top: 16),
                                          child: Text(
                                            "Món trong 🛒",
                                            style:
                                                FineTheme.typograhpy.subtitle1,
                                          ),
                                        ),
                                        ...unCheckedList.toList(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTapBar == true
                                  ? bottomBar()
                                  : const SizedBox.shrink(),
                            ],
                          )
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 95),
                            child: Center(
                              child: Text(
                                "Giỏ hàng đang trống",
                                style: FineTheme.typograhpy.subtitle2,
                              ),
                            ),
                          ),
                    reOrderList != null
                        ? buildReOrder(reOrderList, arriveTime, checkoutTime)
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 95),
                            child: Center(
                              child: Text(
                                "Bạn chưa đặt đơn nào trong hôm nay 🥺",
                                style: FineTheme.typograhpy.subtitle2,
                              ),
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

  Widget buildProduct(CartItem item, int i, Color minusColor, Color plusColor) {
    return Container(
      color: FineTheme.palettes.shades100,
      padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Checkbox(
            activeColor: item.isAddParty == false
                ? FineTheme.palettes.primary100
                : FineTheme.palettes.neutral500,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
            value: item.isChecked,
            onChanged: item.isAddParty == true
                ? (value) {
                    showStatusDialog("assets/images/logo2.png", "Oops!!",
                        "Bạn phải xóa món trong đơn nhóm đã nè thì mới chỉnh món thêm vô nhaa");
                  }
                : (value) {
                    cartViewModel!.changeValueChecked(value!, item);
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
              // height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName!,
                                style: FineTheme.typograhpy.subtitle2.copyWith(
                                  color: FineTheme.palettes.shades200,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              item.size != null
                                  ? Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            width: 1.5,
                                            color:
                                                FineTheme.palettes.primary100),
                                      ),
                                      child: Text(
                                        "Size ${item.size}",
                                        style: FineTheme.typograhpy.subtitle2
                                            .copyWith(
                                                color: FineTheme
                                                    .palettes.primary100),
                                      ),
                                    )
                                  : Text(
                                      "Hãy thử ngay nào",
                                      style: FineTheme.typograhpy.caption1
                                          .copyWith(
                                        color: FineTheme.palettes.neutral500,
                                      ),
                                    ),
                            ],
                          ),
                          Text(
                            formatPrice(item.price!),
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              overflow: TextOverflow.ellipsis,
                              color: FineTheme.palettes.primary100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 90,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: item.isAddParty == true
                              ? () async {
                                  await editProduct(context, item);
                                }
                              : null,
                          child: Text(
                            "Thay đổi",
                            style: FineTheme.typograhpy.caption1.copyWith(
                                color: item.isAddParty == true
                                    ? FineTheme.palettes.primary400
                                    : FineTheme.palettes.shades100),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: item.isAddParty == false
                                  ? () async {
                                      if (item.quantity >= 1) {
                                        if (item.quantity == 1) {
                                          await cartViewModel!
                                              .deleteItem(item, i);
                                        } else {
                                          item.quantity--;
                                          await cartViewModel!
                                              .updateItem(item, i, false);
                                        }
                                      }
                                    }
                                  : null,
                              child: Icon(
                                Icons.remove_circle_outline,
                                size: 25,
                                color: item.isAddParty == true
                                    ? FineTheme.palettes.shades100
                                    : minusColor,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                              decoration: BoxDecoration(
                                  // border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                item.quantity.toString(),
                                style: FineTheme.typograhpy.h2.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: item.isAddParty == false
                                  ? () async {
                                      item.quantity++;
                                      await cartViewModel!
                                          .updateItem(item, i, true);
                                    }
                                  : null,
                              child: Icon(
                                Icons.add_circle_outline,
                                size: 25,
                                color: item.isAddParty == true
                                    ? FineTheme.palettes.shades100
                                    : plusColor,
                              ),
                            )
                          ],
                        ),
                        // const SizedBox(height: 16),
                        Text(
                          formatPrice(item.fixTotal!),
                          style: const TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReOrder(
      List<ReOrderDTO> list, String arriveTime, String checkoutTime) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        String dayFormat = DateFormat('dd').format(list[index].checkInDate!);
        String dateFormat =
            DateFormat('MM y, HH:mm').format(list[index].checkInDate!);
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: InkWell(
            onTap: () {},
            child: Container(
              color: FineTheme.palettes.shades100,
              padding: const EdgeInsets.fromLTRB(16, 12, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: const SizedBox(
                          width: 31,
                          height: 31,
                          child: CacheImage(imageUrl: defaultImage),
                        ),
                      ),
                      const SizedBox(width: 19),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Trạm: ${list[index].stationName}",
                              style: FineTheme.typograhpy.body1,
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
                                  "$arriveTime - $checkoutTime",
                                  style: FineTheme.typograhpy.caption1,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$dayFormat thg $dateFormat",
                              style: FineTheme.typograhpy.caption1.copyWith(
                                color: FineTheme.palettes.neutral500,
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
                          onTap: () async {
                            await Get.find<OrderViewModel>()
                                .createReOrder(list[index].id!);
                            Get.toNamed(RouteHandler.RE_ORDER_SCREEN);
                          },
                          child: Row(
                            children: [
                              Text(
                                "Đặt lại",
                                style: FineTheme.typograhpy.subtitle1.copyWith(
                                    color: FineTheme.palettes.primary100),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    color: FineTheme.palettes.primary50,
                                    borderRadius: BorderRadius.circular(100)),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  size: 12,
                                  color: FineTheme.palettes.primary100,
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
    );
  }

  Widget _buidProductRecomend(List<ProductInCart>? list) {
    return Container(
      color: FineTheme.palettes.shades100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Text(
              'Món ăn đề xuất',
              style:
                  FineTheme.typograhpy.buttonLg.copyWith(color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(
              "Tủ của bạn vẫn còn chỗ nè 😚",
              style: FineTheme.typograhpy.caption2,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              color: FineTheme.palettes.shades100,
              width: Get.width,
              height: 155,
              child: ListView.separated(
                itemBuilder: (context, index) {
                  var product = list![index];
                  return Material(
                    color: Colors.white,
                    child: TouchOpacity(
                      onTap: () async {
                        RootViewModel root = Get.find<RootViewModel>();
                        ProductDTO? item =
                            await root.openProductShowSheet(product.productId!);
                        if (item != null) {
                          // ignore: use_build_context_synchronously
                          await showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12))),
                            builder: (context) => buidProductPicker(item),
                          );
                        }
                      },
                      child: _buildProduct(product),
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    SizedBox(width: FineTheme.spacing.xs),
                itemCount: list!.length,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buidProductPicker(ProductDTO prod) {
    return ScopedModel(
        model: ProductDetailViewModel(dto: prod),
        child: ScopedModelDescendant<ProductDetailViewModel>(
          builder: (context, child, model) {
            bool? isSelect;

            List<Widget> listWidget = [];
            List<ProductAttributes>? attributeList = model.master!.attributes;
            if (prod.attributes!.length > 1) {
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
            return Container(
              height: Get.height * 0.15,
              // width: Get.width,

              // color: FineTheme.palettes.shades100,
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CacheImage(
                          imageUrl: prod.imageUrl == null
                              ? 'https://firebasestorage.googleapis.com/v0/b/finedelivery-880b6.appspot.com/o/no-image.png?alt=media&token=b3efcf6b-b4b6-498b-aad7-2009389dd908'
                              : prod.imageUrl!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                          child: Text(
                            formatPrice(model.total!),
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                              color: FineTheme.palettes.primary300,
                            ),
                          ),
                        ),
                        model.isExtra == true
                            ? Row(
                                children: [
                                  ...listWidget.toList(),
                                ],
                              )
                            : Text(
                                "Ngon nhắm, hãy thử ngay nào",
                                style: FineTheme.typograhpy.body2,
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            child: Icon(
                              Icons.remove_circle_outline,
                              size: 30,
                              color: model.minusColor,
                            ),
                            onTap: () {
                              model.minusQuantity();
                            },
                          ),
                          // SizedBox(
                          //   width: 8,
                          // ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
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
                          InkWell(
                            child: Icon(
                              Icons.add_circle_outline,
                              size: 30,
                              color: model.addColor,
                            ),
                            onTap: () {
                              model.addQuantity();
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          await model.addProductToCart();
                          Get.back();
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: FineTheme.palettes.primary100,
                          ),
                          child: Center(
                            child: Text(
                              "Thêm",
                              style: FineTheme.typograhpy.subtitle1
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ));
  }

  Widget _buildProduct(ProductInCart product) {
    return SizedBox(
      width: 110,
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 110,
                  height: 110,
                  child: CacheStoreImage(
                    imageUrl: product.imageUrl ?? defaultImage,
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                    width: 46,
                    height: 13,
                    decoration: BoxDecoration(
                      color: FineTheme.palettes.primary300,
                      borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(10)),
                    ),
                    child: Text(
                      "PROMO".toUpperCase(),
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  )),
            ],
          ),
          SizedBox(height: FineTheme.spacing.xxs),
          Text(
            product.name!,
            style: FineTheme.typograhpy.subtitle2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            // height: 40,
            child: Text(
              formatPrice(product.price!),
              style: FineTheme.typograhpy.caption1
                  .copyWith(color: FineTheme.palettes.primary100),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomBar() {
    return ScopedModelDescendant<CartViewModel>(
      builder: (context, child, model) {
        return Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
          decoration: BoxDecoration(
              color: FineTheme.palettes.shades100,
              // border: Border(
              //   top: BorderSide(color: FineTheme.palettes.neutral400),
              // ),
              boxShadow: [
                BoxShadow(
                  color: FineTheme.palettes.shades200.withOpacity(0.2),
                  blurRadius: 6,
                )
              ]),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 20, 0),
                    child: InkWell(
                      onTap: () async {
                        await showPartyDialog(isHome: true);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: FineTheme.palettes.primary100,
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: FineTheme.palettes.primary100,
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: FineTheme.palettes.primary100,
                          ),
                        ],
                      ),
                      // child: Text(
                      //   "Tạo phòng",
                      //   style: FineTheme.typograhpy.body2
                      //       .copyWith(color: FineTheme.palettes.primary100),
                      // ),
                    ),
                  ),
                ],
              ),
              MySeparator(
                color: FineTheme.palettes.neutral500,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                                style: FineTheme.typograhpy.h2.copyWith(
                                    color: FineTheme.palettes.primary300),
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
                                style: FineTheme.typograhpy.subtitle1.copyWith(
                                    color: FineTheme.palettes.primary100),
                              ),
                            ],
                          )
                        ],
                      ),
                      InkWell(
                        onTap: model.isSelected!
                            ? hasParty
                                ? party.isConfirm == false
                                    ? () async {
                                        await Get.find<CartViewModel>()
                                            .addProductToPartyOrder();
                                      }
                                    : null
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
                              color: model.isSelected!
                                  ? party.isConfirm == false
                                      ? FineTheme.palettes.primary100
                                      : FineTheme.palettes.neutral700
                                  : FineTheme.palettes.neutral700,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: model.isSelected!
                                    ? party.isConfirm == false
                                        ? FineTheme.palettes.primary100
                                        : FineTheme.palettes.neutral700
                                    : FineTheme.palettes.neutral700,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              model.isSelected!
                                  ? hasParty
                                      ? party.isConfirm == false
                                          ? "Cập nhật Party"
                                          : "Đã chốt đơn"
                                      : "Thanh toán"
                                  : "Chưa chọn món",
                              style: FineTheme.typograhpy.subtitle1.copyWith(
                                color: model.isSelected!
                                    ? party.isConfirm == false
                                        ? FineTheme.palettes.primary100
                                        : FineTheme.palettes.neutral700
                                    : FineTheme.palettes.neutral700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
