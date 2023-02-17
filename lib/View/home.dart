import 'package:cached_network_image/cached_network_image.dart';
import 'package:fine/Accessories/draggable_bottom_sheet.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/View/Home/HomeCategory.dart';
import 'package:fine/ViewModel/blogs_viewModel.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: DraggableBottomSheet(
        minExtent: Get.height * 0.45,
        useSafeArea: false,
        curve: Curves.easeIn,
        previewWidget: _previewWidget(),
        expandedWidget: _previewWidget(),
        backgroundWidget: _backgroundWidget(),
        maxExtent: MediaQuery.of(context).size.height * 0.8,
        onDragging: (pos) {},
      ),
      // backgroundColor: FineTheme.palettes.primary100,
      // body: SafeArea(
      //   child: Container(
      //     height: Get.height,
      //     child: ScopedModel(
      //       model: HomeViewModel(),
      //       child: Stack(
      //         children: [
      //           Column(
      //             children: [
      //               // FixedAppBar(
      //               //   notifier: notifier,
      //               //   height: HEIGHT,
      //               // ),
      //               Expanded(
      //                 child: Container(
      //                   decoration: BoxDecoration(
      //                     gradient: LinearGradient(
      //                         begin: Alignment.topCenter,
      //                         end: Alignment.bottomCenter,
      //                         colors: [
      //                           // FineTheme.palettes.primary200,
      //                           FineTheme.palettes.primary100,
      //                           FineTheme.palettes.neutral200,
      //                           FineTheme.palettes.neutral200,
      //                           FineTheme.palettes.neutral200
      //                         ]),
      //                   ),
      //                   // color: FineTheme.palettes.neutral200,
      //                   padding: EdgeInsets.only(top: 0),
      //                   child: RefreshIndicator(
      //                     key: _refreshIndicatorKey,
      //                     onRefresh: _refresh,
      //                     child: ScopedModelDescendant<HomeViewModel>(
      //                         builder: (context, child, model) {
      //                       if (model.status == ViewStatus.Error) {
      //                         return Column(
      //                           crossAxisAlignment: CrossAxisAlignment.center,
      //                           children: [
      //                             Center(
      //                               child: Text(
      //                                 "Fine đã cố gắng hết sức ..\nNhưng vẫn bị con quỷ Bug đánh bại.",
      //                                 textAlign: TextAlign.center,
      //                                 style: TextStyle(
      //                                     fontStyle: FontStyle.normal,
      //                                     fontFamily: 'Montserrat',
      //                                     fontWeight: FontWeight.w500,
      //                                     fontSize: 14),
      //                               ),
      //                             ),
      //                             SizedBox(height: 8),
      //                             Container(
      //                               width: 300,
      //                               height: 300,
      //                               child: Image.asset(
      //                                 'assets/images/global_error.png',
      //                                 fit: BoxFit.contain,
      //                               ),
      //                             ),
      //                             SizedBox(height: 8),
      //                             Center(
      //                               child: Text(
      //                                 "Bạn vui lòng thử một số cách sau nhé!",
      //                                 textAlign: TextAlign.center,
      //                               ),
      //                             ),
      //                             SizedBox(height: 8),
      //                             Center(
      //                               child: Text(
      //                                 "1. Tắt ứng dụng và mở lại",
      //                                 textAlign: TextAlign.center,
      //                               ),
      //                             ),
      //                             SizedBox(height: 8),
      //                             Center(
      //                               child: InkWell(
      //                                 child: Text(
      //                                   "2. Đặt hàng qua Fanpage ",
      //                                   textAlign: TextAlign.center,
      //                                 ),
      //                                 // onTap: () =>
      //                                 //     launch('fb://page/103238875095890'),
      //                               ),
      //                             ),
      //                           ],
      //                         );
      //                       } else {
      //                         return Container(
      //                           // color: FineTheme.palettes.neutral200,
      //                           child: NotificationListener<ScrollNotification>(
      //                             onNotification: (n) {
      //                               if (n.metrics.pixels <= HEIGHT) {
      //                                 notifier.value = n.metrics.pixels;
      //                               }
      //                               return false;
      //                             },
      //                             child: SingleChildScrollView(
      //                               child: Column(
      //                                 // addAutomaticKeepAlives: true,
      //                                 children: [
      //                                   ...renderHomeSections().toList(),
      //                                 ],
      //                               ),
      //                             ),
      //                           ),
      //                         );
      //                       }
      //                     }),
      //                   ),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  Widget _backgroundWidget() {
    return Scaffold(
      backgroundColor: FineTheme.palettes.primary100,
      body: SafeArea(
        child: Container(
          height: Get.height,
          child: ScopedModel(
            model: HomeViewModel(),
            child: Stack(
              children: [
                Column(
                  children: [
                    // FixedAppBar(
                    //   notifier: notifier,
                    //   height: HEIGHT,
                    // ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                // FineTheme.palettes.primary200,
                                FineTheme.palettes.primary100,
                                FineTheme.palettes.neutral200,
                                FineTheme.palettes.neutral200,
                                FineTheme.palettes.neutral200
                              ]),
                        ),
                        // color: FineTheme.palettes.neutral200,
                        padding: EdgeInsets.only(top: 0),
                        child: RefreshIndicator(
                          key: _refreshIndicatorKey,
                          onRefresh: _refresh,
                          child: ScopedModelDescendant<HomeViewModel>(
                              builder: (context, child, model) {
                            if (model.status == ViewStatus.Error) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
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
                                  SizedBox(height: 8),
                                  Container(
                                    width: 300,
                                    height: 300,
                                    child: Image.asset(
                                      'assets/images/global_error.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Center(
                                    child: Text(
                                      "Bạn vui lòng thử một số cách sau nhé!",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Center(
                                    child: Text(
                                      "1. Tắt ứng dụng và mở lại",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Center(
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
      SizedBox(height: 8),
      HomeCategory(),
      // timeRecieve(),
    ];
  }

  Widget banner() {
    return ScopedModel<BlogsViewModel>(
        model: BlogsViewModel(),
        child: Container(
          // color: Colors.white,
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
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
                  return SizedBox.shrink();
                default:
                  if (model.blogs == null || model.blogs.isEmpty) {
                    return SizedBox.shrink();
                  }
                  return Container(
                    height: (Get.width) * (747 / 1914),
                    width: (Get.width),
                    // margin: EdgeInsets.only(bottom: 8, top: 8),
                    child: Swiper(
                        onTap: (index) async {
                          // await launch(
                          //     "https://www.youtube.com/embed/wu32Wj_Uix4");
                        },
                        autoplay: model.blogs.length > 1 ? true : false,
                        autoplayDelay: 5000,
                        viewportFraction: 0.9,
                        pagination: new SwiperPagination(
                            alignment: Alignment.bottomCenter),
                        itemCount: model.blogs.length,
                        itemBuilder: (context, index) {
                          if (model.blogs[index]['images'] == null ||
                              model.blogs[index]['images'] == "")
                            return Icon(
                              MaterialIcons.broken_image,
                              color: FineTheme.palettes.primary200
                                  .withOpacity(0.5),
                            );

                          return CachedNetworkImage(
                            imageUrl: model.blogs[index]['images'],
                            imageBuilder: (context, imageProvider) => InkWell(
                              onTap: () {
                                // Get.toNamed(RouteHandler.BANNER_DETAIL,
                                //     arguments: model.blogs[index]);
                              },
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  margin: EdgeInsets.only(left: 8, right: 8),
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

  // Widget _previewWidget(){

  // }

  Widget _previewWidget() {
    return ScopedModel<RootViewModel>(
      model: RootViewModel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ScopedModelDescendant<RootViewModel>(
            builder: (context, child, model) {
              final status = model.status;

              if (status == ViewStatus.Loading) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: [
                    //     ShimmerBlock(width: 150, height: 28),
                    //   ],
                    // ),
                    Container(
                      height: 32,
                      width: Get.width,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ShimmerBlock(
                              width: 80,
                              height: 32,
                              borderRadius: 8,
                            ),
                          );
                        },
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                );
              }
              return Container(
                height: 120,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 80,
                        width: Get.width,
                        // margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                            color: FineTheme.palettes.primary200),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        // height: 120,
                        // width: Get.width,
                        // margin: EdgeInsets.only(bottom: 8),
                        // padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.only(
                        //       topLeft: Radius.circular(28),
                        //       topRight: Radius.circular(28),
                        //     ),
                        //     color: FineTheme.palettes.primary200),
                        height: 100,
                        margin: EdgeInsets.only(left: 20, right: 20),

                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 80,
                                width: Get.width,
                                padding: EdgeInsets.fromLTRB(12, 20, 12, 0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.white),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: model.TimeSlot.length,
                                  itemBuilder: (context, index) {
                                    bool isSelect = true;
                                    return AnimatedContainer(
                                      padding: EdgeInsets.only(
                                        left: 8,
                                        right: 8,
                                      ),
                                      margin: EdgeInsets.only(
                                          right: 8, top: 20, bottom: 20),
                                      duration: Duration(milliseconds: 300),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            isSelect ? 8 : 0),
                                        color: isSelect
                                            ? FineTheme.palettes.primary200
                                            : Colors.transparent,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            isSelect = true;
                                          });
                                        },
                                        child: Center(
                                          child: Text(
                                              model.TimeSlot[index]['timeSlot'],
                                              style: isSelect
                                                  ? TextStyle(
                                                      color: Colors.white,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      // fontFamily: 'Montserrat',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14)
                                                  : TextStyle(
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      fontFamily: 'Montserrat',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14)),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                height: 50,
                                width: Get.width,
                                margin: EdgeInsets.only(left: 20, right: 20),
                                padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                                decoration: BoxDecoration(
                                  color: FineTheme.palettes.primary100,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                      bottomRight: Radius.circular(26),
                                      bottomLeft: Radius.circular(26)),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Center(
                                        child: Text(
                                      'Chọn khung giờ giao hàng'.toUpperCase(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ],
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
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
