import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

import '../Utils/shared_pref.dart';
import '../ViewModel/order_viewModel.dart';
import '../theme/FineTheme/index.dart';

class CustomeCreateParty extends StatefulWidget {
  final PartyOrderViewModel model;
  final VoidCallback onChange;
  const CustomeCreateParty(
      {super.key, required this.model, required this.onChange});

  @override
  State<CustomeCreateParty> createState() => _CustomeCreatePartyState();
}

class _CustomeCreatePartyState extends State<CustomeCreateParty> {
  PartyOrderViewModel party = Get.find<PartyOrderViewModel>();
  @override
  void initState() {
    super.initState();
    getCode();
  }

  void getCode() async {
    party.partyCode = await getPartyCode();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onChange,
      child: Container(
        height: 55,
        width: Get.width,
        decoration: BoxDecoration(
          color: party.partyCode != null
              ? FineTheme.palettes.shades100
              : FineTheme.palettes.primary100,
          borderRadius: const BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: Center(
          child: party.partyCode != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Mã:',
                      style: FineTheme.typograhpy.subtitle2
                          .copyWith(color: FineTheme.palettes.neutral400),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      party.partyCode!,
                      style: FineTheme.typograhpy.subtitle2
                          .copyWith(color: FineTheme.palettes.shades200),
                    ),
                    // const SizedBox(width: 8),
                    IconButton(
                        onPressed: () {
                          Clipboard.setData(
                              new ClipboardData(text: party.partyCode));
                        },
                        icon: Icon(
                          Icons.copy,
                          size: 20,
                          color: FineTheme.palettes.neutral500,
                        ))
                  ],
                )
              : Text(
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
    );
  }
}
