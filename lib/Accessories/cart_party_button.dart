import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../Utils/constrant.dart';
import '../ViewModel/cart_viewModel.dart';
import '../ViewModel/root_viewModel.dart';
import '../theme/FineTheme/index.dart';

class CartParty extends StatefulWidget {
  const CartParty({super.key});

  @override
  State<CartParty> createState() => _CartPartyState();
}

class _CartPartyState extends State<CartParty> {
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: Get.find<CartViewModel>(),
        child: ScopedModelDescendant<CartViewModel>(
          builder: (context, child, model) {
            if (model.currentCart == null) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
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
                        border:
                            Border.all(color: FineTheme.palettes.primary100),
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
                            model.currentCart!.itemQuantity().toString(),
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
        ));
  }
}
