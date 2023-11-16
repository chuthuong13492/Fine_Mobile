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
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../Model/DTO/index.dart';
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
              List<Widget>? checkedList = [];
              List<Widget>? unCheckedList = [];
              if (cart != null) {
                itemsChecked = cart.items
                    ?.where((element) => element.isChecked == true)
                    .toList();
                itemsUnChecked = cart.items
                    ?.where((element) => element.isChecked == false)
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
                        buildProduct(
                            itemsChecked[i], i, minusColor, plusColor));
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
                      buildProduct(itemsUnChecked[i], i, minusColor, plusColor),
                    );
                  }
                } else {
                  unCheckedList = [];
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
                                    checkedList.isNotEmpty
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8, top: 0),
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
                  borderRadius: BorderRadius.circular(100)),
              value: item.isChecked,
              onChanged: (value) {
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
                                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      width: 1.5,
                                      color: FineTheme.palettes.primary100),
                                ),
                                child: Text(
                                  "Size ${item.size}",
                                  style: FineTheme.typograhpy.subtitle2
                                      .copyWith(
                                          color: FineTheme.palettes.primary100),
                                ),
                              )
                            : Text(
                                "Ngon nhắm, hãy thử ngay nào",
                                style: FineTheme.typograhpy.caption1.copyWith(
                                  color: FineTheme.palettes.neutral500,
                                ),
                              ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              child: Icon(
                                Icons.remove_circle_outline,
                                size: 25,
                                color: minusColor,
                              ),
                              onTap: () async {
                                if (item.quantity >= 1) {
                                  if (item.quantity == 1) {
                                    await cartViewModel!.deleteItem(item, i);
                                  } else {
                                    item.quantity--;
                                    await cartViewModel!
                                        .updateItem(item, i, false);
                                  }
                                }
                              },
                            ),
                            // SizedBox(
                            //   width: 8,
                            // ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
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
                                await cartViewModel!.updateItem(item, i, true);
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Center(
                      child: InkWell(
                        onTap: () async {
                          await showPartyDialog(isHome: true);
                        },
                        child: Text(
                          "Tạo phòng",
                          style: FineTheme.typograhpy.body2
                              .copyWith(color: FineTheme.palettes.primary100),
                        ),
                      ),
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
                              color: model.isSelected!
                                  ? FineTheme.palettes.primary100
                                  : FineTheme.palettes.neutral700,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: model.isSelected!
                                    ? FineTheme.palettes.primary100
                                    : FineTheme.palettes.neutral700,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              model.isSelected!
                                  ? hasParty
                                      ? "Thêm vào Party"
                                      : "Thanh toán"
                                  : "Chưa chọn món",
                              style: FineTheme.typograhpy.subtitle1.copyWith(
                                color: model.isSelected!
                                    ? FineTheme.palettes.primary100
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
