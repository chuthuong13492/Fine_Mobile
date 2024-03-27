import 'package:country_picker/country_picker.dart';
import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/ViewModel/login_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class LoginByPhoneScreen extends StatefulWidget {
  final bool? isLoginMail;
  const LoginByPhoneScreen({super.key, this.isLoginMail});

  @override
  State<LoginByPhoneScreen> createState() => _LoginByPhoneScreenState();
}

class _LoginByPhoneScreenState extends State<LoginByPhoneScreen> {
  final TextEditingController controller = TextEditingController();
  List<DropdownMenuItem<String>>? _dropdownMenuItems;
  GlobalKey<FormState> _formKey = new GlobalKey();
  String? _phone, _countryCode = "+84";
  FocusNode? _phoneFocus;

  String? _validateTest;
  bool isError = false;
  Country country = CountryParser.parseCountryCode('VN');
  @override
  void initState() {
    super.initState();
    _phoneFocus = new FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return ScopedModel(
      model: LoginViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: FineTheme.palettes.primary100,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(2, 2), // changes position of shadow
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => Get.back(),
          ),
        ),
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: screenHeight,
              // decoration: const BoxDecoration(
              //   image: DecorationImage(
              //     image: AssetImage("assets/images/bgLandingPage.png"),
              //     fit: BoxFit.cover,
              //   ),
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SizedBox(
                  //   height: screenHeight * 0.05,
                  // ),
                  Expanded(
                    // flex: 1,
                    child: Container(
                      // color: Colors.blue,
                      // padding: const EdgeInsets.only(right: 24),
                      // padding: EdgeInsets.only(right: 24),
                      child: Image.asset(
                        'assets/images/logo.png',
                        alignment: Alignment.center,
                        // fit: BoxFit.fitHeight,

                        // scale: 0.4,
                      ),
                    ),
                  ),
                  buildLoginButtons(screenHeight, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoginButtons(double screenHeight, BuildContext context) {
    return ScopedModelDescendant<LoginViewModel>(
      builder: (context, child, model) {
        return Container(
          decoration: const BoxDecoration(
            // color: Colors.white.withOpacity(0.35),
            // color: FineTheme.palettes.primary50,
            image: DecorationImage(
                image: AssetImage("assets/images/bgLandingPage.jpg"),
                fit: BoxFit.fitHeight),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
          height: screenHeight * 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  'Nhập số điện thoại',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      height: 1.2,
                      color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Container(
                // height: 48,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                // height: 100,
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
                      suffixIcon: controller.text.length < 9 ||
                              controller.text.length > 10
                          ? null
                          : Container(
                              height: 25,
                              width: 25,
                              margin: const EdgeInsets.all(10.0),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                              child: const Icon(
                                Icons.done,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
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
              const SizedBox(height: 16),
              Center(
                child: ScopedModelDescendant<LoginViewModel>(
                  builder: (context, child, model) => ButtonTheme(
                    minWidth: 150.0,
                    height: 60,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            FineTheme.palettes.primary100),
                        padding: const MaterialStatePropertyAll(
                            EdgeInsets.fromLTRB(12, 0, 12, 0)),
                        elevation: const MaterialStatePropertyAll(8),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            side: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      // color: Colors.white,
                      // // padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                      // elevation: 8,
                      // shape: RoundedRectangleBorder(
                      //     // borderRadius: BorderRadius.circular(24.0),
                      //     // side: BorderSide(color: Colors.red),
                      //     ),
                      onPressed: () async {
                        // marks all children as touched
                        //form.touch();
                        if (_formKey.currentState!.validate()) {
                          if (!isError) {
                            _formKey.currentState!.save();
                            // await pr.show();
                            if (_phone![0].contains("0")) {
                              _phone = _phone!.substring(1);
                            }
                            String phone = '+' + country.phoneCode + _phone!;
                            await model.signInWithPhone(
                                phone, widget.isLoginMail!);
                          }
                        }
                      },
                      child: Container(
                        // width: double.infinity,
                        child: Text(
                          "Xác nhận",
                          style: FineTheme.typograhpy.h2
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
