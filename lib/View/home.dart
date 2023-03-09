// ignore_for_file: avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fine/Accessories/draggable_bottom_sheet.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/View/Home/HomeCategorySection.dart';
import 'package:fine/View/Home/HomeTimeSlotsSection.dart';
import 'package:fine/ViewModel/blogs_viewModel.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/fixed_app_bar.dart';
import 'package:fine/widgets/shimmer_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shimmer/shimmer.dart';

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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FineTheme.palettes.primary200,
              FineTheme.palettes.primary200.withOpacity(0.7),
              // FineTheme.palettes.primary200.withOpacity(0.2),
              // FineTheme.palettes.primary200.withOpacity(0.1),

              // FineTheme.palettes.primary200.withOpacity(0.7),
              // FineTheme.palettes.primary200.withOpacity(0.6),
              // FineTheme.palettes.primary200.withOpacity(0.5),
              // FineTheme.palettes.primary200.withOpacity(0.4),
              // FineTheme.palettes.primary200.withOpacity(0.3),
              // FineTheme.palettes.primary200.withOpacity(0.2),
              // FineTheme.palettes.primary200.withOpacity(0.1),

              // FineTheme.palettes.primary200,

              // FineTheme.palettes.primary200.withOpacity(0.4),

              FineTheme.palettes.shades100,
              // FineTheme.palettes.shades100,
            ]),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
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
                        notifier: notifier,
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
                                        'assets/images/global_error.png',
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
                                  child:
                                      NotificationListener<ScrollNotification>(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> renderHomeSections() {
    return [
      banner(),
      const SizedBox(height: 8),
      // ignore: prefer_const_constructors
      HomeTimeSlotsSection(),
      // const SizedBox(height: 8),
      // ignore: prefer_const_constructors
      HomeCategorySection(),
      // HomeCategory(),
      // timeRecieve(),
    ];
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
                      height: (Get.width) * (747 / 1914),
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
                  // ignore: sized_box_for_whitespace
                  return Container(
                    height: (Get.width) * (747 / 1914),
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
                        itemCount: model.blogs!.length,
                        itemBuilder: (context, index) {
                          if (model.blogs![index].imageUrl == null ||
                              model.blogs![index].imageUrl == "")
                            // ignore: curly_braces_in_flow_control_structures
                            return Icon(
                              MaterialIcons.broken_image,
                              color: FineTheme.palettes.primary200
                                  .withOpacity(0.5),
                            );

                          return CachedNetworkImage(
                            imageUrl: model.blogs![index].imageUrl!,
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
                                    borderRadius: BorderRadius.circular(8),
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
}
