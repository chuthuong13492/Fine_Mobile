import 'dart:async';

import 'package:custom_clippers/custom_clippers.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/cart_viewModel.dart';
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
    _timer = Timer.periodic(const Duration(seconds: 1),
        (timer) async => await root?.checkHasParty());
    // getRoot();
  }

  void getRoot() async {
    // await root?.checkHasParty();
    if (root?.notifier.value == true) {}
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: Get.find<PartyOrderViewModel>(),
        child: ScopedModelDescendant<PartyOrderViewModel>(
          builder: (context, child, model) {
            int? quantity;
            if (model.partyStatus != null) {
              quantity = model.partyStatus!.numberOfMember!;
            }

            return model.partyCode != null
                ? AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    margin: model.isCartRoute == false
                        ? const EdgeInsets.only(bottom: 40, right: 5)
                        : const EdgeInsets.only(bottom: 120, right: 5),
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
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: SvgPicture.asset(
                                "assets/icons/Party.svg",
                                width: 16,
                                height: 16,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            left: 35,
                            child: ValueListenableBuilder(
                              valueListenable: model.notifier,
                              builder: (context, cartItem, child) {
                                return cartItem != 0
                                    ? AnimatedContainer(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 0, 5, 0),
                                        duration:
                                            const Duration(microseconds: 300),
                                        // width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          color: Colors.red,
                                          //border: Border.all(color: Colors.grey),
                                        ),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              Text(
                                                cartItem.toString(),
                                                style: FineTheme
                                                    .typograhpy.subtitle1
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              const Icon(
                                                FontAwesome.shopping_cart,
                                                size: 15,
                                              )
                                              // Image.asset(
                                              //   "assets/icons/shopping-bag-02.png",
                                              //   height: 15,
                                              //   width: 15,
                                              // ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              },
                            ),
                          ),
                          Positioned(
                            // top: -8,
                            bottom: -25,
                            right: 40,
                            // left: 35,
                            child: ClipPath(
                              clipper: UpperNipMessageClipper(MessageType.send),
                              child: AnimatedContainer(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 8, 20, 0),
                                duration: const Duration(microseconds: 300),
                                // width: 24,
                                // alignment: Alignment.center,
                                height: 40,
                                decoration: BoxDecoration(
                                  // borderRadius: const BorderRadius.only(
                                  //     topLeft: Radius.circular(8),
                                  //     bottomLeft: Radius.circular(8),
                                  //     bottomRight: Radius.circular(12)),

                                  color: FineTheme.palettes.primary300,
                                ),
                                child: Center(
                                  child: Row(
                                    children: [
                                      Text(
                                        quantity.toString(),
                                        style: FineTheme.typograhpy.subtitle1
                                            .copyWith(color: Colors.white),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      const Icon(
                                        Icons.person,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        '|',
                                        style: FineTheme.typograhpy.subtitle1
                                            .copyWith(color: Colors.white),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        'Ready: ',
                                        style: FineTheme.typograhpy.caption1
                                            .copyWith(color: Colors.white),
                                      ),
                                      model.partyStatus?.isReady == true
                                          ? const Icon(
                                              Icons.check_circle_rounded,
                                              size: 15,
                                              color: Colors.green,
                                            )
                                          : const Icon(
                                              Icons.cancel,
                                              size: 15,
                                              color: Colors.red,
                                            )
                                    ],
                                  ),
                                ),
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
  }
}

class MessageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    path.lineTo(size.width, size.height - 20);
    path.quadraticBezierTo(
        size.width, size.height, size.width - 20, size.height);
    path.lineTo(20, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 20);
    path.lineTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
