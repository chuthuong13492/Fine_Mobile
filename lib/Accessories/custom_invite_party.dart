import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../ViewModel/login_viewModel.dart';
import '../theme/FineTheme/index.dart';

class CustomInviteParty extends StatefulWidget {
  const CustomInviteParty({super.key});

  @override
  State<CustomInviteParty> createState() => _CustomInvitePartyState();
}

class _CustomInvitePartyState extends State<CustomInviteParty> {
  final TextEditingController controller = TextEditingController();
  List<DropdownMenuItem<String>>? _dropdownMenuItems;
  GlobalKey<FormState> _formKey = new GlobalKey();
  String? _phone, _countryCode = "+84";
  FocusNode? _phoneFocus;

  String? _validateTest;
  bool isError = false;
  bool isCancled = false;
  bool isCountdown = false;
  Country country = CountryParser.parseCountryCode('VN');
  late int _secondsRemaining;
  late Timer _timer;
  late ValueNotifier<int> _notifier;
  PartyOrderViewModel _partyOrderViewModel = Get.find<PartyOrderViewModel>();

  @override
  void initState() {
    super.initState();
    _secondsRemaining = 10;
    // _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);
    _notifier = ValueNotifier<int>(_secondsRemaining);

    _phoneFocus = new FocusNode();
  }

  // void _updateTimer(Timer timer) {
  //   setState(() {
  //     if (_secondsRemaining > 0) {
  //       _secondsRemaining--;
  //     } else {
  //       timer.cancel();
  //     }
  //   });
  // }

  void startCountdown() async {
    _notifier.value = _secondsRemaining;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_notifier.value > 0) {
        _notifier.value--;
      } else {
        timer.cancel();
        if (isCancled == false) {
          _partyOrderViewModel.inviteParty(_partyOrderViewModel.acount!.id!,
              _partyOrderViewModel.partyCode!);
        }
        setState(() {
          isCountdown = false;
          isCancled = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: Get.find<PartyOrderViewModel>(),
      child: Column(
        children: [
          Center(
            child: Text(
              'Nhập số điện thoại',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  height: 1.2,
                  color: FineTheme.palettes.primary100),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            // height: 48,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            // height: 100,
            child: Row(
              children: [
                Flexible(
                  flex: 8,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      // autofocus: true,
                      focusNode: _phoneFocus,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      controller: controller,
                      keyboardType: TextInputType.number,
                      validator: (input) {
                        if (input!.trim().length < 9 ||
                            input.trim().length > 10) {
                          setState(() {
                            _validateTest = "Số diện thoại chưa đúng";
                            isError = true;
                          });
                        }
                        return null;
                      },
                      style: _phoneFocus!.hasFocus
                          ? const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w600)
                          : FineTheme.typograhpy.subtitle1
                              .copyWith(color: Colors.white),
                      onSaved: (value) {
                        _phone = value;
                      },
                      onChanged: (value) {
                        setState(() {
                          isError = false;
                          _validateTest = null;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Số điện thoại của bạn",
                        hintStyle: const TextStyle(
                            fontSize: 15,
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600),
                        errorText: _validateTest,
                        filled: true,
                        fillColor: _phoneFocus!.hasFocus
                            ? FineTheme.palettes.shades100
                            : FineTheme.palettes.shades100,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.black12,
                            // style: BorderStyle.solid,
                          ),
                          // borderRadius: new BorderRadius.circular(25.7),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.black12,
                            // style: BorderStyle.solid,
                          ),
                        ),
                        // suffixIcon: controller.text.length < 9 ||
                        //         controller.text.length > 10
                        //     ? null
                        //     : Container(
                        //         height: 25,
                        //         width: 25,
                        //         margin: const EdgeInsets.all(10.0),
                        //         decoration: const BoxDecoration(
                        //           shape: BoxShape.circle,
                        //           color: Colors.green,
                        //         ),
                        //         child: const Icon(
                        //           Icons.done,
                        //           color: Colors.white,
                        //           size: 20,
                        //         ),
                        //       ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(8),
                          child: InkWell(
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                countryListTheme: CountryListThemeData(
                                  inputDecoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FineTheme.palettes.neutral500,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: _phoneFocus!.hasFocus
                                          ? FineTheme.palettes.primary100
                                          : FineTheme.palettes.neutral500,
                                    ),
                                    enabled: true,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FineTheme.palettes.primary100,
                                      ),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                  bottomSheetHeight: Get.height * 0.55,
                                  textStyle: FineTheme.typograhpy.subtitle2
                                      .copyWith(
                                          color: FineTheme.palettes.primary100),
                                ),
                                onSelect: (value) {
                                  setState(() {
                                    country = value;
                                  });
                                },
                              );
                            },
                            child: Text(
                              '${country.flagEmoji} +${country.phoneCode}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: Container(
                    child: Center(
                        child: ScopedModelDescendant<PartyOrderViewModel>(
                      builder: (context, child, model) {
                        return IconButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (!isError) {
                                  _formKey.currentState!.save();
                                  // await pr.show();
                                  if (_phone![0].contains("0")) {
                                    _phone = _phone!.substring(1);
                                  }
                                  String phone =
                                      '+' + country.phoneCode + _phone!;
                                  await model.getCustomerByPhone(phone);
                                  model.isInvited = false;
                                  isCountdown = false;
                                  isCancled = false;
                                  // await model.signInWithPhone(
                                  //     phone, widget.isLoginMail!);
                                }
                              }
                            },
                            icon: Icon(
                              Icons.person_search,
                              size: 30,
                              color: FineTheme.palettes.primary100,
                            ));
                      },
                    )),
                  ),
                ),
              ],
            ),
          ),
          ScopedModelDescendant<PartyOrderViewModel>(
            builder: (context, child, model) {
              if (model.acount == null) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                model.acount!.name!,
                                style: FineTheme.typograhpy.subtitle1,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Icon(
                                Icons.circle,
                                color: FineTheme.palettes.shades200,
                                size: 5.0,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                model.acount!.phone!,
                                style: FineTheme.typograhpy.subtitle1,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: isCountdown == false
                              ? model.isInvited == false
                                  ? TextButton(
                                      onPressed: () {
                                        startCountdown();
                                        setState(() {
                                          isCancled = false;
                                          isCountdown = true;
                                        });
                                      },
                                      child: Text(
                                        'Mời'.toUpperCase(),
                                        style: FineTheme.typograhpy.subtitle1
                                            .copyWith(color: Colors.green),
                                      ),
                                    )
                                  : Text(
                                      'Đã Mời'.toUpperCase(),
                                      style: FineTheme.typograhpy.subtitle1
                                          .copyWith(color: Colors.green),
                                    )
                              : TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isCancled = true;
                                      isCountdown = false;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      _notifier.value > 0
                                          ? !isCancled
                                              ? ValueListenableBuilder<int>(
                                                  valueListenable: _notifier,
                                                  builder:
                                                      (context, value, child) {
                                                    return Container(
                                                      // padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 10,
                                                        value: (value /
                                                            _secondsRemaining),
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                FineTheme
                                                                    .palettes
                                                                    .neutral500),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : const SizedBox.shrink()
                                          : const SizedBox.shrink(),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      Text(
                                        'Hủy'.toUpperCase(),
                                        style: _notifier.value > 0
                                            ? FineTheme.typograhpy.subtitle1
                                                .copyWith(
                                                    color: !isCancled
                                                        ? FineTheme
                                                            .palettes.neutral500
                                                        : Colors.green)
                                            : FineTheme.typograhpy.subtitle1
                                                .copyWith(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          )
          // const SizedBox(height: 16),
        ],
      ),
    );
  }
}
