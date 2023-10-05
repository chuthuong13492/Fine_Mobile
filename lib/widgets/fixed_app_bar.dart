import 'dart:async';

import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/login_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../Model/DTO/index.dart';

class FixedAppBar extends StatefulWidget {
  final double height;

  const FixedAppBar({super.key, required this.height});

  @override
  State<FixedAppBar> createState() => _FixedAppBarState();
}

class _FixedAppBarState extends State<FixedAppBar> {
  PartyOrderViewModel? _partyOrderViewModel = Get.find<PartyOrderViewModel>();
  OrderViewModel? _orderViewModel = Get.find<OrderViewModel>();
  RootViewModel? root;
  final TextEditingController searchController = TextEditingController();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    root = Get.find<RootViewModel>();
    // _orderViewModel!.getCurrentCart();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      Get.find<RootViewModel>().getListTimeSlot();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      // color: FineTheme.palettes.shades100,
      width: Get.width,
      duration: const Duration(milliseconds: 300),
      // decoration: const BoxDecoration(
      //   boxShadow: [
      //     BoxShadow(
      //         color: Colors.grey,
      //         spreadRadius: -4,
      //         blurRadius: 4,
      //         offset: Offset(0, 5) // changes position of shadow
      //         ),
      //   ],
      // ),
      child: Container(
        color: Colors.white,
        padding:
            const EdgeInsets.only(left: 17, right: 17, top: 10, bottom: 10),
        // decoration: const BoxDecoration(
        //   boxShadow: [
        //                     BoxShadow(
        //         color: Colors.grey,
        //         spreadRadius: 3,
        //         // blurRadius: 6,
        //         offset: Offset(0, 25) // changes position of shadow
        //         ),
        //   ],
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            select(),
            const SizedBox(
              height: 8,
            ),
            search(),
          ],
        ),
      ),
    );
  }

  Widget search() {
    bool hasQuantity = false;
    int quantity = 0;
    return ScopedModel(
      model: Get.find<PartyOrderViewModel>(),
      child: ScopedModelDescendant<PartyOrderViewModel>(
        builder: (context, child, model) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 11, right: 11),
                  // color: Colors.transparent,
                  alignment: Alignment.center,
                  height: 54,
                  decoration: BoxDecoration(
                    color: FineTheme.palettes.shades100,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: FineTheme.palettes.shades200.withOpacity(0.1),
                        offset: const Offset(
                          4.0,
                          4.0,
                        ),
                        blurRadius: 8.0,
                        // spreadRadius: 2.0,
                      ), //BoxShadow
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: SvgPicture.asset(
                        "assets/icons/Search-home.svg",
                        width: 24,
                        height: 24,
                        color: FineTheme.palettes.primary100,
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Center(
                          child: TextFormField(
                            controller: searchController,
                            keyboardType: TextInputType.text,
                            obscureText: false,
                            decoration: const InputDecoration(
                              // hintText: text,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(0),
                              hintStyle: TextStyle(
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 25,
              ),
              InkWell(
                onTap: () async {
                  await showPartyDialog(model, isHome: true);
                  // final root = Get.find<RootViewModel>();
                  // await root.navOrder();
                },
                child: Container(
                  width: 50,
                  // height: 45,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: FineTheme.palettes.shades100,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: FineTheme.palettes.primary100)),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: FineTheme.palettes.shades100,
                            borderRadius: BorderRadius.circular(100)),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/icons/Party.svg",
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -10,
                        left: 30,
                        // right: 20,
                        child: AnimatedContainer(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          duration: const Duration(microseconds: 300),
                          // width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: FineTheme.palettes.primary300,
                            //border: Border.all(color: Colors.grey),
                          ),
                          child: Center(
                            child: Text(
                              "New",
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  fontStyle: FontStyle.normal,
                                  color: FineTheme.palettes.shades100),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget select() {
    // String dropdownDaysSelect = "Hôm nay";
    return ScopedModel(
        model: Get.find<RootViewModel>(),
        child: ScopedModelDescendant<RootViewModel>(
          builder: (context, child, model) {
            String text = "Đợi tý đang load...";
            final status = model.status;
            // if (model.changeAddress) {
            //   text = "Đang thay đổi...";
            // } else if (location != null) {
            //   // text = destinationDTO.name + " - " + location.address;
            //   text = model.currentStore!.name!;
            // } else {
            //   text = "Chưa chọn";
            // }
            if (model.currentStore != null) {
              text = model.currentStore!.name!;
            } else {
              text = 'Chưa chọn khu vực';
            }

            if (status == ViewStatus.Error) {
              text = "Có lỗi xảy ra...";
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      // Get.offAllNamed(RouteHandler.STORE_SELECT);

                      // AccountViewModel root = Get.find<AccountViewModel>();
                      // root.processSignout();
                    },
                    child: Container(
                      // color: Colors.transparent,
                      alignment: Alignment.center,
                      height: 29,
                      decoration: BoxDecoration(
                        color: FineTheme.palettes.shades100,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color:
                                FineTheme.palettes.shades200.withOpacity(0.1),
                            offset: const Offset(
                              4.0,
                              4.0,
                            ),
                            blurRadius: 8.0,
                            // spreadRadius: 2.0,
                          ), //BoxShadow
                        ],
                      ),
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Image.asset(
                                    "assets/icons/location_logo_primary.png",
                                    width: 16,
                                    height: 19,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Center(
                                  // width: 400,
                                  child: Text(
                                    text,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: FineTheme.typograhpy.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(right: 15),
                          //   child: Center(
                          //     child: Image.asset(
                          //       "assets/icons/chevron-down.png",
                          //       width: 18,
                          //       height: 18,
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 22,
                ),
                Center(
                  child: SizedBox(
                    height: 29,
                    child: DropdownButton<String>(
                      value: model.isNextDay == false ? "Hôm nay" : "Hôm sau",
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem<String>(
                            value: "Hôm nay",
                            child: Text(
                              "HÔM NAY",
                              style: model.isNextDay == false
                                  ? FineTheme.typograhpy.subtitle1.copyWith(
                                      color: FineTheme.palettes.primary200)
                                  : FineTheme.typograhpy.subtitle1.copyWith(
                                      color: FineTheme.palettes.neutral500),
                            )),
                        DropdownMenuItem<String>(
                            value: "Hôm sau",
                            child: Text("HÔM SAU",
                                style: model.isNextDay == true
                                    ? FineTheme.typograhpy.subtitle1.copyWith(
                                        color: FineTheme.palettes.primary200)
                                    : FineTheme.typograhpy.subtitle1.copyWith(
                                        color: FineTheme.palettes.neutral500))),
                      ],
                      style: FineTheme.typograhpy.subtitle1
                          .copyWith(color: FineTheme.palettes.primary300),
                      onChanged: (value) async {
                        // setState(() {
                        //   dropdownDaysSelect = value!;
                        // });
                        if (value!.contains("Hôm nay")) {
                          await model.changeDay(0);
                        } else {
                          await model.changeDay(1);
                        }
                      },
                    ),
                  ),
                )
                // InkWell(
                //   onTap: () {},
                //   child: Image.asset(
                //     "assets/icons/notification-message.png",
                //     width: 24,
                //     height: 24,
                //   ),
                // ),
                // const SizedBox(
                //   width: 8,
                // ),
                // InkWell(
                //   onTap: () {},
                //   child: Image.asset(
                //     "assets/icons/menu-02.png",
                //     width: 24,
                //     height: 24,
                //   ),
                // ),
              ],
            );
          },
        ));
  }
}
