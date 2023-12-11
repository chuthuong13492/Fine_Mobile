import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../Constant/route_constraint.dart';
import '../Utils/shared_pref.dart';
import '../ViewModel/order_viewModel.dart';
import '../theme/FineTheme/index.dart';
import 'custom_button_switch.dart';
import 'dialog.dart';

class CustomeCreateParty extends StatefulWidget {
  final bool isHome;
  final bool hasLinked;
  const CustomeCreateParty(
      {super.key, required this.isHome, required this.hasLinked});

  @override
  State<CustomeCreateParty> createState() => _CustomeCreatePartyState();
}

class _CustomeCreatePartyState extends State<CustomeCreateParty> {
  TextEditingController controller = TextEditingController(text: '');
  bool? isLinked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: Get.find<PartyOrderViewModel>(),
        child: ScopedModelDescendant<PartyOrderViewModel>(
          builder: (context, child, model) {
            if (model.partyCode != null) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mã:',
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: FineTheme.palettes.neutral400),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    model.partyCode!,
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: FineTheme.palettes.shades200),
                  ),
                  // const SizedBox(width: 8),
                  IconButton(
                      onPressed: () {
                        Clipboard.setData(
                            new ClipboardData(text: model.partyCode!));
                      },
                      icon: Icon(
                        Icons.copy,
                        size: 20,
                        color: FineTheme.palettes.neutral500,
                      ))
                ],
              );
            }
            return Column(
              children: [
                widget.hasLinked == true
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(height: 12),
                          Expanded(
                            child: Text(
                              'Đơn liên kết',
                              style: FineTheme.typograhpy.subtitle1,
                            ),
                          ),
                          CustomCupertinoSwitch(
                            value: isLinked!,
                            onChanged: (value) {
                              setState(() {
                                isLinked = value;
                              });
                              print(isLinked);
                              // model.setLinkedParty(value);
                            },
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                isLinked == false
                    ? const SizedBox(height: 12)
                    : const SizedBox.shrink(),
                isLinked == false
                    ? Row(
                        children: [
                          Flexible(
                            flex: 7,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  border: Border.all(
                                      color: FineTheme.palettes.primary100)),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: TextField(
                                  onChanged: (input) {},
                                  controller: controller,
                                  decoration: InputDecoration(
                                      hintText: 'Nhập code party',
                                      border: InputBorder.none,
                                      suffixIcon: IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          controller.clear();
                                        },
                                      )),
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    fontStyle: FontStyle.normal,
                                    color: FineTheme.palettes.neutral500,
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 1,
                                  autofocus: true,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            fit: FlexFit.tight,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    color: FineTheme.palettes.primary100,
                                    border: Border.all(
                                      color: FineTheme.palettes.primary100,
                                    )),
                                child: TextButton(
                                    onPressed: () async {
                                      hideDialog();
                                      if (controller.text.contains("CPO")) {
                                        await model.joinPartyOrder(
                                            code: controller.text);
                                      } else {
                                        await showStatusDialog(
                                            "assets/images/logo2.png",
                                            "Sai mã mất rùi",
                                            "Mã code hong đúng nè 😓");
                                      }
                                    },
                                    child: const Text('Tham gia',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15))),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    model.partyCode = await getPartyCode();

                    if (model.partyCode == null) {
                      await model.createCoOrder(isLinked!);
                      if (model.partyOrderDTO!.partyType == 1) {
                        if (widget.isHome == true) {
                          hideDialog();
                          await model.getPartyOrder();
                          Get.toNamed(RouteHandler.PARTY_ORDER_SCREEN);
                        } else {
                          hideDialog();
                          await model.getPartyOrder();

                          Get.offNamed(RouteHandler.PARTY_ORDER_SCREEN);
                        }
                      } else {
                        hideDialog();
                        await Get.find<OrderViewModel>().prepareOrder();
                      }
                    }
                  },
                  child: Container(
                    height: 55,
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: model.partyCode != null
                          ? FineTheme.palettes.shades100
                          : FineTheme.palettes.primary100,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Tạo phòng Party",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          color: FineTheme.palettes.shades100,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ));
  }
}
