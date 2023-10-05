import 'dart:async';

import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/productFilter_viewModel.dart';
import 'package:fine/ViewModel/product_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class CartButton extends StatefulWidget {
  // final bool isMart;
  CartButton({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _CartButtonState();
  }
}

class _CartButtonState extends State<CartButton> {
  RootViewModel? root = Get.find<RootViewModel>();
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    // root = Get.find<RootViewModel>();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (timer) => root?.checkHasParty());
    // getRoot();
  }

  void getRoot() async {
    // await root?.checkHasParty();
    if (root?.notifier.value == true) {}
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: Get.find<RootViewModel>(),
        child: ScopedModelDescendant<RootViewModel>(
            builder: (context, child, model) {
          if (model.status == ViewStatus.Loading) {
            return const SizedBox.shrink();
          }
          return model.notifier.value == false
              ? ValueListenableBuilder(
                  valueListenable: Get.find<OrderViewModel>().notifier,
                  builder: (context, value, child) {
                    if (value == 0) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        elevation: 4,
                        heroTag: CART_TAG,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          // side: BorderSide(color: Colors.red),
                        ),
                        onPressed: () async {
                          await Get.find<RootViewModel>().navOrder();
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: FineTheme.palettes.primary100),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: FineTheme.palettes.primary100,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Image.asset(
                                  "assets/icons/shopping-bag-02.png",
                                  height: 16,
                                  width: 16,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -8,
                              left: 35,
                              child: AnimatedContainer(
                                duration: const Duration(microseconds: 300),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.red,
                                  //border: Border.all(color: Colors.grey),
                                ),
                                child: Center(
                                  child: Text(
                                    value.toString(),
                                    style: FineTheme.typograhpy.subtitle1
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : ScopedModel(
                  model: Get.find<PartyOrderViewModel>(),
                  child: ScopedModelDescendant<PartyOrderViewModel>(
                    builder: (context, child, model) {
                      int? quantity;
                      if (model.partyStatus != null) {
                        quantity = model.partyStatus!.numberOfMember!;
                      }

                      if (model.partyStatus != null) {
                        if (model.partyStatus?.isReady == true) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 40),
                            child: FloatingActionButton(
                              backgroundColor: Colors.transparent,
                              elevation: 4,
                              heroTag: CART_TAG,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                                // side: BorderSide(color: Colors.red),
                              ),
                              onPressed: () async {
                                await Get.find<RootViewModel>().navParty();
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: FineTheme.palettes.primary100),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: FineTheme.palettes.primary100,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/icons/Party.svg",
                                        width: 16,
                                        height: 16,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -8,
                                    left: 35,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(microseconds: 300),
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.green,
                                        //border: Border.all(color: Colors.grey),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }
                      return model.partyStatus != null
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 40),
                              child: FloatingActionButton(
                                backgroundColor: Colors.transparent,
                                elevation: 4,
                                heroTag: CART_TAG,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  // side: BorderSide(color: Colors.red),
                                ),
                                onPressed: () async {
                                  await Get.find<RootViewModel>().navParty();
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color:
                                                FineTheme.palettes.primary100),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: FineTheme.palettes.primary100,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/icons/Party.svg",
                                          width: 16,
                                          height: 16,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -8,
                                      left: 35,
                                      child: AnimatedContainer(
                                        padding: const EdgeInsets.fromLTRB(
                                            4, 0, 4, 0),
                                        duration:
                                            const Duration(microseconds: 300),
                                        // width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          color: FineTheme.palettes.primary300,
                                          //border: Border.all(color: Colors.grey),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              quantity.toString(),
                                              style: FineTheme
                                                  .typograhpy.subtitle1
                                                  .copyWith(
                                                      color: Colors.white),
                                            ),
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            Icon(
                                              Icons.person,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ));
        }));
  }
}
