// ignore_for_file: avoid_unnecessary_containers

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fine/Accessories/draggable_bottom_sheet.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/View/Home/HomeCategorySection.dart';
import 'package:fine/View/Home/HomeCollectionSection.dart';
import 'package:fine/View/Home/HomeSpecificMenuSection.dart';
import 'package:fine/View/Home/HomeStoreSection.dart';
import 'package:fine/View/Home/HomeMenuSection.dart';
import 'package:fine/View/Home/HomeVoucherSection.dart';
import 'package:fine/ViewModel/blogs_viewModel.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/orderHistory_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/fixed_app_bar.dart';
import 'package:fine/widgets/shimmer_block.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../Accessories/dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final double HEIGHT = 48;
  final ValueNotifier<double> notifier = ValueNotifier(0);
  final PageController controller = PageController();
  Future<void> _refresh() async {
    await Get.find<RootViewModel>().startUp();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: FineTheme.palettes.shades100,
      body: SafeArea(
        // ignore: sized_box_for_whitespace
        child: Container(
          // color: FineTheme.palettes.primary100,
          height: Get.height,
          child: ScopedModel(
            model: Get.find<HomeViewModel>(),
            child: Stack(
              children: [
                Column(
                  children: [
                    FixedAppBar(
                      // notifier: notifier,
                      height: HEIGHT,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(top: 0),
                        child: RefreshIndicator(
                          key: _refreshIndicatorKey,
                          onRefresh: _refresh,
                          child: ScopedModelDescendant<HomeViewModel>(
                              builder: (context, child, model) {
                            if (model.status == ViewStatus.Error) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Center(
                                    child: Text(
                                      "Fine đã cố gắng hết sức ..\nNhưng vẫn bị con quỷ Bug đánh bại.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // ignore: sized_box_for_whitespace
                                  Container(
                                    width: 300,
                                    height: 300,
                                    child: Image.asset(
                                      'assets/images/error-loading.gif',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Center(
                                    child: Text(
                                      "Bạn vui lòng thử một số cách sau nhé!",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Center(
                                    child: Text(
                                      "1. Tắt ứng dụng và mở lại",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Center(
                                    child: InkWell(
                                      child: Text(
                                        "2. Đặt hàng qua Fanpage ",
                                        textAlign: TextAlign.center,
                                      ),
                                      // onTap: () =>
                                      //     launch('fb://page/103238875095890'),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Container(
                                // color: FineTheme.palettes.neutral200,
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: (n) {
                                    if (n.metrics.pixels <= HEIGHT) {
                                      notifier.value = n.metrics.pixels;
                                    }
                                    return false;
                                  },
                                  child: SingleChildScrollView(
                                    child: Column(
                                      // addAutomaticKeepAlives: true,
                                      children: [
                                        ...renderHomeSections().toList(),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                // Positioned(
                //   left: 0,
                //   bottom: 0,
                //   child: buildNewOrder(),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> renderHomeSections() {
    return [
      banner(),
      const SizedBox(height: 18),
      const HomeMenuSection(),
      // interalBanner(),
      buildVoucherSection(),

      // Container(
      //   color: FineTheme.palettes.primary50,
      //   height: 8,
      // ),
      const HomeSpecifiHomeSection(),
      // buildVoucherSection(),
      // const HomeStoreSection(),
    ];
  }

  Widget buildVoucherSection() {
    return ScopedModel(
        model: Get.find<HomeViewModel>(),
        child: ScopedModelDescendant<HomeViewModel>(
          builder: (context, child, model) {
            ViewStatus status = model.status;
            if (status == ViewStatus.Loading) {
              return const SizedBox.shrink();
            }
            return InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                color: FineTheme.palettes.primary50,
                height: 78,
                width: Get.width,
                child: Container(
                  height: 55,
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  color: FineTheme.palettes.primary100,
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100)),
                            child: SvgPicture.asset(
                              "assets/icons/Party.svg",
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Tạo đơn nhóm để được hưởng nhiều ưu đãiii !",
                            style: FineTheme.typograhpy.subtitle2
                                .copyWith(color: FineTheme.palettes.shades100),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }

  Widget interalBanner() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
      decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(20),
          color: FineTheme.palettes.primary50),
      child: Container(
        height: (Get.width) * (700 / 1914),
        width: (Get.width),
        child: CachedNetworkImage(
          imageUrl:
              'https://st4.depositphotos.com/4590583/30886/i/450/depositphotos_308863366-stock-photo-cooking-banner-food-top-view.jpg',
          imageBuilder: (context, imageProvider) {
            return InkWell(
              onTap: () {
                // Get.toNamed(RouteHandler.BANNER_DETAIL,
                //     arguments: model.blogs[index]);
              },
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  margin: const EdgeInsets.only(left: 8, right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget banner() {
    return ScopedModel<BlogsViewModel>(
        model: Get.find<BlogsViewModel>(),
        child: Container(
          // color: Colors.white,
          // padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
          // padding: EdgeInsets.only(bottom: 8),
          child: ScopedModelDescendant<BlogsViewModel>(
            builder: (context, child, model) {
              ViewStatus status = model.status;
              switch (status) {
                case ViewStatus.Loading:
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ShimmerBlock(
                      height: (Get.width) * (817 / 1914),
                      width: (Get.width),
                    ),
                  );
                case ViewStatus.Empty:
                case ViewStatus.Error:
                  return const SizedBox.shrink();
                default:
                  if (model.blogs == null || model.blogs!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  var listBlog = model.blogs!
                      .where((element) => element.active == true)
                      .toList();
                  // ignore: sized_box_for_whitespace
                  return Container(
                    height: (Get.width) * (747 / 2000),
                    width: (Get.width),
                    // margin: EdgeInsets.only(bottom: 8, top: 8),
                    child: Swiper(
                        onTap: (index) async {
                          // await launch(
                          //     "https://www.youtube.com/embed/wu32Wj_Uix4");
                        },
                        autoplay: model.blogs!.length > 1 ? true : false,
                        autoplayDelay: 5000,
                        viewportFraction: 0.9,
                        pagination: const SwiperPagination(
                            alignment: Alignment.bottomCenter),
                        itemCount: listBlog.length,
                        itemBuilder: (context, index) {
                          if (listBlog[index].imageUrl == null ||
                              listBlog[index].imageUrl == "")
                            // ignore: curly_braces_in_flow_control_structures
                            return Icon(
                              MaterialIcons.broken_image,
                              color: FineTheme.palettes.primary200
                                  .withOpacity(0.5),
                            );

                          return CachedNetworkImage(
                            imageUrl: listBlog[index].imageUrl!,
                            imageBuilder: (context, imageProvider) => InkWell(
                              onTap: () {
                                // Get.toNamed(RouteHandler.BANNER_DETAIL,
                                //     arguments: model.blogs[index]);
                              },
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(35),
                                    color: Colors.blue,
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              enabled: true,
                              child: Container(
                                color: Colors.grey,
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              MaterialIcons.broken_image,
                              color: FineTheme.palettes.primary200
                                  .withOpacity(0.5),
                            ),
                          );
                        }),
                  );
              }
            },
          ),
        ));
  }

  void _onTapOrderHistory(order) async {
    // get orderDetail
    await Get.find<OrderHistoryViewModel>().getOrders();
    await Get.toNamed(RouteHandler.ORDER_HISTORY_DETAIL, arguments: order);
  }

  Widget buildNewOrder() {
    RootViewModel root = Get.find<RootViewModel>();
    final campus = root.currentStore;
    return ScopedModel<OrderHistoryViewModel>(
      model: Get.find<OrderHistoryViewModel>(),
      child: ScopedModelDescendant<OrderHistoryViewModel>(
          builder: (context, child, model) {
        if (model.status == ViewStatus.Loading ||
            model.newTodayOrders == null) {
          return const SizedBox();
        }
        return Container(
          width: Get.width,
          height: 80,
          child: Card(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            elevation: 3,
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                          color: FineTheme.palettes.primary300, width: 3))),
              width: Get.width * 0.95,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _onTapOrderHistory(model.newTodayOrders);
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Text(
                                  //   model.newTodayOrders!.id!.toString(),
                                  //   style: FineTheme.typograhpy.subtitle2,
                                  // ),
                                  // const SizedBox(height: 8),
                                  Text('Đơn hàng mới',
                                      style: FineTheme.typograhpy.caption1)
                                ],
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      campus!.name!,
                                      style: FineTheme.typograhpy.caption1,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Nhận đơn tại',
                                        style: FineTheme.typograhpy.caption1)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        // Get.find<OrderHistoryViewModel>()
                        //     .closeNewOrder(model.newTodayOrders!.id);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
