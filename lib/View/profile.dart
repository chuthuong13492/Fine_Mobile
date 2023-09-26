import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/format_price.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/cache_image.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AccountViewModel _accountViewModel = Get.find<AccountViewModel>();

  @override
  void initState() {
    super.initState();
    _accountViewModel.fetchUser();
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> _refresh() async {
    await Get.find<AccountViewModel>().fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FineTheme.palettes.shades100,
      body: SafeArea(
          child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refresh,
              child: userInfo())),
    );
  }

  Widget userInfo() {
    return ScopedModel(
      model: _accountViewModel,
      child: ScopedModelDescendant<AccountViewModel>(
        builder: (context, child, model) {
          final userDTO = model.currentUser;
          final status = model.status;
          if (status == ViewStatus.Loading) {
            return const Center(child: LoadingFine());
          } else if (status == ViewStatus.Error || model.currentUser == null) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/error.png',
                          fit: BoxFit.contain,
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Có gì đó sai sai..\n Vui lòng thử lại.",
                          // style: kTextPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                account(userDTO!),
                Container(
                  color: FineTheme.palettes.primary50,
                  height: 16,
                ),
                _buildWalletSection(userDTO),
                Container(
                  color: FineTheme.palettes.primary50,
                  height: 16,
                ),
                userAccount(model),
                Container(
                  color: FineTheme.palettes.primary50,
                  height: 16,
                ),
                Container(
                  width: Get.width,
                  height: 107,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/fine_profile_img.png"),
                        fit: BoxFit.fitHeight),
                  ),
                ),
                Container(
                  color: FineTheme.palettes.primary50,
                  height: 16,
                ),
                systemInfo(model)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget account(AccountDTO user) {
    String img = "";
    if (user.imageUrl == null) {
      img = "https://randomuser.me/api/portraits/thumb/men/75.jpg";
    } else {
      img = user.imageUrl!;
    }
    return Container(
      //color: Color(0xFFddf1ed),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                    color: FineTheme.palettes.primary100,
                    shape: BoxShape.circle),
                child: ClipOval(
                  child: CacheImage(
                    imageUrl: img,
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name! == null ? "" : user.name!,
                      style: FineTheme.typograhpy.h2
                          .copyWith(color: FineTheme.palettes.primary100),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    infoDetail("Email: ", color: Colors.grey, list: [
                      TextSpan(
                          text: user.email ?? "...",
                          style: FineTheme.typograhpy.subtitle2
                              .copyWith(color: FineTheme.palettes.primary100))
                    ]),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // infoDetail("Điểm Bean: ", color: Colors.grey, list: [
                        //   TextSpan(
                        // text: formatPriceWithoutUnit(
                        //     model.currentUser.balance),
                        //       style: Get.theme.textTheme.headline4),
                        //   WidgetSpan(
                        //       alignment: PlaceholderAlignment.middle,
                        //       child: Image(
                        //         image: AssetImage(
                        //             "assets/images/icons/bean_coin.png"),
                        //         width: 20,
                        //         height: 20,
                        //       ))
                        // ]),
                        infoDetail("Số điện thoại: ",
                            color: Colors.black,
                            list: [
                              TextSpan(
                                  text: user.phone ?? "-",
                                  style: FineTheme.typograhpy.subtitle2
                                      .copyWith(
                                          color: FineTheme.palettes.primary100))
                            ]),
                        const SizedBox(
                          height: 4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: InkWell(
                            onTap: () async {
                              // showLoadingDialog();
                              // AccountViewModel accountViewModel =
                              //     Get.find<AccountViewModel>();
                              // await accountViewModel.fetchUser(isRefetch: true);
                              // hideDialog();
                            },
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: FineTheme.palettes.primary100,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Container(
                      width: 120,
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: FineTheme.palettes.primary100),
                        color: const Color(0xFFD5F5FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo2.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          const Text(
                            'Thành viên',
                            style: TextStyle(
                                color: Color(0xFF238E9C),
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    // infoDetail("Số điện thoại: ", color: Colors.grey, list: [
                    //   TextSpan(
                    //       text: user.phone ?? "-",
                    //       style: FineTheme.typograhpy.subtitle2
                    //           .copyWith(color: FineTheme.palettes.primary300))
                    // ]),
                  ],
                ),
              )
            ],
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 24, right: 24, top: 8),
          //   child: Container(
          //     child: Row(
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       mainAxisAlignment: MainAxisAlignment.spaceAround,
          //       children: [
          //         // Column(
          //         //   crossAxisAlignment: CrossAxisAlignment.center,
          //         //   mainAxisAlignment: MainAxisAlignment.center,
          //         //   children: [
          //         //     Row(
          //         //       crossAxisAlignment: CrossAxisAlignment.center,
          //         //       mainAxisAlignment: MainAxisAlignment.center,
          //         //       children: [
          //         //         Image.asset(
          //         //           'assets/images/icons/bean_coin.png',
          //         //           width: 20,
          //         //           height: 20,
          //         //         ),
          //         //         SizedBox(
          //         //           width: 2,
          //         //         ),
          //         //         Text(
          //         //           'Bean của bạn',
          //         //           style: TextStyle(
          //         //               color: Colors.orange,
          //         //               fontSize: 14,
          //         //               fontWeight: FontWeight.bold),
          //         //         ),
          //         //         // RichText(
          //         //         //   text: TextSpan(
          //         //         //       text: 'BEAN: ',
          //         //         //       style: TextStyle(
          //         //         //           color: Colors.orange,
          //         //         //           fontWeight: FontWeight.bold),
          //         //         //       children: [
          //         //         //         TextSpan(
          //         //         //           text: formatPriceWithoutUnit(
          //         //         //               model.currentUser.balance),
          //         //         //         ),
          //         //         //       ]),
          //         //         // ),
          //         //       ],
          //         //     ),
          //         //     Text(
          //         //       formatPriceWithoutUnit(model.currentUser.balance),
          //         //       style: TextStyle(color: Colors.orange),
          //         //     ),
          //         //   ],
          //         // ),
          //         Container(
          //           height: 40,
          //           width: 10,
          //           child: VerticalDivider(
          //             color:
          //                 BeanOiTheme.palettes.neutral400, //color of divider
          //             width: 10, //width space of divider
          //             //Spacing at the bottom of divider.
          //             thickness: 2, //thickness of divier line
          //             indent: 8, //Spacing at the top of divider.
          //             endIndent: 8,
          //           ),
          //         ),
          //         InkWell(
          //           onTap: () {
          //             Get.toNamed(RouteHandler.VOUCHER_WALLET);
          //           },
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               Row(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 children: [
          //                   Image.asset(
          //                     'assets/images/icons/voucher_icon.png',
          //                     width: 20,
          //                     height: 20,
          //                   ),
          //                   SizedBox(
          //                     width: 2,
          //                   ),
          //                   Text(
          //                     'Quà và khuyến mãi',
          //                     style: TextStyle(
          //                         color: BeanOiTheme.palettes.neutral700,
          //                         fontSize: 14,
          //                         fontWeight: FontWeight.bold),
          //                   ),
          //                 ],
          //               ),
          //               Text(
          //                 // '$model.vouchers.length',
          //                 '$vouchers',
          //                 style: TextStyle(color: kPrimary),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildWalletSection(AccountDTO acc) {
    return Container(
      color: FineTheme.palettes.shades100,
      width: Get.width,
      // height: 220,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Center(
        child: Container(
          height: 207,
          child: Stack(
            children: [
              Container(
                // padding: const EdgeInsets.fromLTRB(16, 19, 19, 0),
                height: 105,
                width: Get.width,
                child: Stack(
                  children: [
                    Image.asset(
                      "assets/images/fine_wallet_img.png",
                      width: Get.width,
                      height: 105,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 19, 19, 19),
                      width: Get.width,
                      height: 105,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ví fine".toUpperCase(),
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        fontStyle: FontStyle.normal,
                                        color: FineTheme.palettes.shades100),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "(đã kích hoạt)",
                                    style: FineTheme.typograhpy.subtitle2
                                        .copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                              Text(
                                formatPrice(acc.balance!),
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    fontStyle: FontStyle.normal,
                                    color: FineTheme.palettes.shades100),
                              ),
                            ],
                          ),
                          IconButton(
                              onPressed: () {
                                Get.toNamed(RouteHandler.TOP_UP_SCREEN);
                              },
                              icon: const Icon(
                                Icons.chevron_right_outlined,
                                size: 34,
                                color: Colors.white,
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                transform: Matrix4.translationValues(0, -5, 0),
                alignment: Alignment.bottomCenter,
                child: Stack(
                  children: [
                    Image.asset(
                      "assets/images/fine_point_img.png",
                      width: Get.width,
                      height: 105,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 19, 19, 19),
                      width: Get.width,
                      height: 105,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Mầm non sành ăn",
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    fontStyle: FontStyle.normal,
                                    color: FineTheme.palettes.shades100),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "20",
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        fontStyle: FontStyle.normal,
                                        color: FineTheme.palettes.shades100),
                                  ),
                                  const SizedBox(width: 4),
                                  Image.asset(
                                    "assets/icons/Grape.png",
                                    width: 24,
                                    height: 24,
                                  )
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.chevron_right_outlined,
                                size: 34,
                                color: Colors.white,
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoDetail(String title,
      {int? size, Color? color, List<InlineSpan>? list}) {
    return RichText(
        text: TextSpan(
            text: title,
            style:
                FineTheme.typograhpy.subtitle2.copyWith(color: Colors.black) ??
                    TextStyle(color: color),
            children: list ?? []));
  }

  Widget userAccount(AccountViewModel model) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 8,
            ),
            // const Divider(),
            // section(
            //     icon: const Icon(Icons.person, color: Colors.black54),
            //     title: Text("Cập nhật thông tin",
            //         style: FineTheme.typograhpy.subtitle2
            //             .copyWith(color: Colors.black54)),
            //     function: () async {
            //       // bool result = await Get.toNamed(RouteHandler.UPDATE,
            //       //     arguments: model.currentUser);
            //       // if (result != null) {
            //       //   if (result) {
            //       //     await model.fetchUser();
            //       //   }
            //       // }
            //     }),
            // const Divider(),
            section(
                icon: const Icon(Icons.shopping_bag, color: Color(0xFF238E9C)),
                title: Text("Đơn hàng",
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: Colors.black54)),
                function: () {
                  Get.toNamed(RouteHandler.ORDER_HISTORY);
                }),
            const Divider(),
            section(
                icon: const Icon(Icons.history, color: Color(0xFF238E9C)),
                title: Text("Lịch sử giao dịch",
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: Colors.black54)),
                function: () {
                  // Get.toNamed(RouteHandler.TRANSACTION);
                }),
            const Divider(),
            // section(
            //     icon: const Icon(Icons.credit_card_outlined, color: Colors.black54),
            //     title: Text("Nhập mã giới thiệu",
            //         style: FineTheme.typograhpy.subtitle2
            //             .copyWith(color: Colors.black54)),
            //     function: () async {
            //       await model.showRefferalMessage();
            //     }),
            // const Divider(),
            section(
                icon: const Icon(
                  AntDesign.facebook_square,
                  color: Color(0xFF238E9C),
                ),
                title: Text("Theo dõi FINE",
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: Colors.black54)),
                function: () {
                  _launchUrl("https://www.facebook.com/finefnb", isFB: true);
                }),
            const Divider(),
            // section(
            //     icon: const Icon(Icons.feedback_outlined, color: Colors.black54),
            //     title: Text("Góp ý",
            //         style: FineTheme.typograhpy.subtitle2
            //             .copyWith(color: Colors.black54)),
            //     function: () async {
            //       await model.sendFeedback();
            //     }),
            // const Divider(),
            section(
                icon: const Icon(Icons.help_outline, color: Color(0xFF238E9C)),
                title: Text("Hỗ trợ",
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: Colors.black54)),
                function: () async {
                  int option = await showOptionDialog(
                      "Vui lòng liên hệ FanPage",
                      firstOption: "Quay lại",
                      secondOption: "Liên hệ");
                  if (option == 1) {
                    _launchUrl(
                        "https://www.facebook.com/Bean-%C6%A0i-103238875095890",
                        isFB: true);
                  }
                }),
            const Divider(),
            section(
                icon: const Icon(Icons.logout, color: Colors.black54),
                title: Text(
                  "Đăng xuất",
                  style: FineTheme.typograhpy.subtitle2
                      .copyWith(color: Colors.red),
                ),
                function: () async {
                  await model.processSignout();
                }),
            // const Divider(),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget systemInfo(AccountViewModel model) {
    return Container(
      margin: const EdgeInsets.only(left: 32, right: 32, bottom: 0, top: 8),
      padding: const EdgeInsets.only(left: 32, right: 32),
      // decoration: BoxDecoration(
      //   border: Border(top: BorderSide(color: kBackgroundGrey[3], width: 1)),
      // ),

      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              "Version ${model.version} by Smjle Team",
              style: FineTheme.typograhpy.body2.copyWith(color: Colors.black54),
            ),
            const SizedBox(
              height: 4,
            ),
            Container(
              // height: 40,
              child: RichText(
                text: TextSpan(
                  text: "Fine delivery ",
                  style: FineTheme.typograhpy.body1,
                  // children: <TextSpan>[
                  //   TextSpan(
                  //     text: "UniTeam",
                  //     style: TextStyle(
                  //       fontSize: 14,
                  //       fontStyle: FontStyle.italic,
                  //     ),
                  //   )
                  // ],
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            )
          ],
        ),
      ),
    );
  }

  Widget section({Icon? icon, Text? title, VoidCallback? function}) {
    return InkWell(
      onTap: function ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon ?? const SizedBox.shrink(),
                const SizedBox(
                  width: 10,
                ),
                title ?? const Text("Mặc định"),
              ],
            ),
            // const Icon(
            //   Icons.arrow_forward_ios,
            //   color: Colors.grey,
            // )
          ],
        ),
      ),
    );
  }

  void _launchUrl(String url, {bool isFB = false, forceWebView = false}) {
    Get.toNamed(RouteHandler.WEBVIEW, arguments: url);
  }
}
