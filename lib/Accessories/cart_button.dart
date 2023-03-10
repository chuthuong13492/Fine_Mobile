import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Utils/constrant.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class CartButton extends StatefulWidget {
  final bool isMart;
  CartButton({this.isMart = false});

  @override
  State<StatefulWidget> createState() {
    return _CartButtonState();
  }
}

class _CartButtonState extends State<CartButton> {
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: Get.find<OrderViewModel>(),
        child: ScopedModelDescendant<OrderViewModel>(
            builder: (context, child, model) {
          if (model.status == ViewStatus.Loading) {
            return const SizedBox.shrink();
          }
          if (model.currentCart == null) return const SizedBox.shrink();
          int quantity = model.currentCart!.itemQuantity();
          return Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 4,
              heroTag: CART_TAG,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                // side: BorderSide(color: Colors.red),
              ),
              onPressed: () async {
                // await Get.toNamed(RoutHandler.ORDER);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      AntDesign.shoppingcart,
                      color: FineTheme.palettes.primary300,
                    ),
                  ),
                  Positioned(
                    top: -10,
                    left: 32,
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
                          quantity.toString(),
                          style: FineTheme.typograhpy.subtitle1
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }));
  }
}
