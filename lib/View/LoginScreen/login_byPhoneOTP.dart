import 'dart:async';

import 'package:fine/Constant/view_status.dart';
import 'package:fine/ViewModel/login_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:scoped_model/scoped_model.dart';

class LoginWithPhoneOtpScreen extends StatefulWidget {
  final String? verificationId;
  final bool? isLoginGmail;

  const LoginWithPhoneOtpScreen({
    super.key,
    this.verificationId,
    this.isLoginGmail,
  });

  @override
  State<LoginWithPhoneOtpScreen> createState() =>
      _LoginWithPhoneOtpScreenState();
}

class _LoginWithPhoneOtpScreenState extends State<LoginWithPhoneOtpScreen> {
  StreamController<ErrorAnimationType>? errorController;

  final form = FormGroup({
    'otp': FormControl(validators: [
      Validators.required,
      // Validators.number,
    ], touched: false),
  });

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return ScopedModel(
      model: LoginViewModel(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
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
                      offset: Offset(2, 2), // changes position of shadow
                    ),
                  ]),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => Get.back(),
          ),
        ),
        body: Container(
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
            padding: const EdgeInsets.fromLTRB(32, 50, 32, 16),
            height: screenHeight * 0.55,
            child: ScopedModelDescendant<LoginViewModel>(
              builder: (context, child, model) {
                return Column(
                  children: [
                    const Center(
                      child: Text(
                        'Nhập mã OTP',
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
                    _buildOTPForm(context, model),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                          model.status == ViewStatus.Error
                              ? "Bạn chưa nhập đủ mã OTP :(."
                              : "",
                          style: FineTheme.typograhpy.subtitle2
                              .copyWith(color: Colors.red)),
                    ),
                    Center(
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
                        onPressed: () async {
                          if (!form.valid) {
                            errorController!.add(ErrorAnimationType
                                .shake); // Triggering error shake animation
                            model.setState(ViewStatus.Loading);
                          } else {
                            if ((form.value["otp"] as String).length != 6) {
                              errorController!.add(ErrorAnimationType
                                  .shake); // Triggering error shake animation
                              model.setState(ViewStatus.Error);
                            } else {
                              await model.onsignInWithOTP(form.value["otp"],
                                  widget.verificationId, widget.isLoginGmail!);
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
                  ],
                );
              },
            ));
      },
    );
  }

  Widget _buildOTPForm(BuildContext context, LoginViewModel model) {
    return PinCodeTextField(
      textStyle: FineTheme.typograhpy.h1,
      length: 6,
      animationType: AnimationType.fade,
      obscureText: false,
      keyboardType: TextInputType.number,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        inactiveColor: FineTheme.palettes.neutral500,
        selectedFillColor: Colors.white,
        inactiveFillColor: FineTheme.palettes.neutral300,
        activeFillColor: Colors.white,
        activeColor: FineTheme.palettes.primary100,
        selectedColor: FineTheme.palettes.primary100,
        borderRadius: BorderRadius.circular(8),
        fieldHeight: 50,
        fieldWidth: 40,
      ),
      animationDuration: const Duration(milliseconds: 300),
      backgroundColor: Colors.transparent,
      enableActiveFill: true,
      errorAnimationController: errorController,
      onCompleted: (value) {},
      onChanged: (value) {
        form.control('otp').value = value;
        if (value.length == 6) {
          model.onsignInWithOTP(
              value, widget.verificationId, widget.isLoginGmail!);
        }
      },
      validator: (v) {
        if (v!.length < 3) {
          return "I'm from validator";
        } else {
          return null;
        }
      },
      appContext: context,
    );
  }
}
