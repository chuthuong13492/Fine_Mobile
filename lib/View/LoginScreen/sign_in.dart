// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers

import 'dart:ui';

import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/ViewModel/login_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:scoped_model/scoped_model.dart';

class SignIn extends StatelessWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ScopedModel(
      model: LoginViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
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
                  SizedBox(
                    height: screenHeight * 0.1,
                  ),
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
            // Align(
            //   alignment: Alignment.topLeft,
            //   child: Padding(
            //     padding: const EdgeInsets.only(left: 16, top: 12),
            //     // child: Text(
            //     //   'Chào mừng',
            //     //   style: FineTheme.typograhpy.h1
            //     //       .copyWith(color: FineTheme.palettes.primary100),
            //     // ),
            //     child: Image(
            //       image: AssetImage("assets/images/logo.png"),
            //       width: Get.width * 0.25,
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  Widget buildLoginButtons(double screenHeight, BuildContext context) {
    return ScopedModelDescendant<LoginViewModel>(
      builder: (context, child, model) {
        return Stack(
          children: [
            // Container(
            //   height: screenHeight * 0.5,
            //   decoration: const BoxDecoration(
            //     // color: Colors.white,
            //     borderRadius: BorderRadius.only(
            //       topLeft: Radius.circular(48),
            //       topRight: Radius.circular(48),
            //     ),
            //   ),
            //   child: BackdropFilter(
            //       filter: ImageFilter.blur(
            //     sigmaX: 5,
            //     sigmaY: 5,
            //   )),
            // ),
            Container(
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
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              height: screenHeight * 0.55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      'Dùng mail trường để đăng nhập nhé!',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  InkWell(
                    onTap: () {
                      model.signInWithGoogle();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 56,
                      decoration: BoxDecoration(
                        color: FineTheme.palettes.shades100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.asset(
                              "assets/icons/google.png",
                              width: 32,
                              height: 32,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Center(
                            child: Text(
                              'Đăng nhập bằng email',
                              style: FineTheme.typograhpy.body1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(160, 16, 160, 16),
                    child: MySeparator(color: FineTheme.palettes.shades100),
                  ),

                  InkWell(
                    onTap: () {
                      Get.toNamed(RouteHandler.LOGIN_PHONE, arguments: false);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 56,
                      decoration: BoxDecoration(
                        color: FineTheme.palettes.shades100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.phone,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                color: FineTheme.palettes.primary200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Center(
                            child: Text(
                              'Đăng nhập bằng mã OTP',
                              style: FineTheme.typograhpy.body1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  const SizedBox(
                    height: 48,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          "By continue you agree to our",
                          style: FineTheme.typograhpy.body2
                              .copyWith(color: Colors.white),
                        ),
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {},
                          child: Text(
                            "Terms & Privacy Policy",
                            style: FineTheme.typograhpy.buttonLg
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
