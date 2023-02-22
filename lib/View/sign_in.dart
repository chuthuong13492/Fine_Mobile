import 'dart:ui';

import 'package:fine/ViewModel/login_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:scoped_model/scoped_model.dart';

class SignIn extends StatelessWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ScopedModel(
      model: LoginViewModel(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white,
                Colors.white,

                // FineTheme.palettes.secondary100,
                FineTheme.palettes.secondary100,

                FineTheme.palettes.secondary100,

                FineTheme.palettes.primary100,
                FineTheme.palettes.primary100,
                FineTheme.palettes.secondary100,
              ]),
        ),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                Positioned(
                  top: Get.height * 0.38,
                  left: 20,
                  child: Stack(
                    children: [
                      BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5)),
                      Container(
                        width: 150,
                        height: 150,
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  // blurStyle: BlurStyle.normal,
                                  color: FineTheme
                                      .palettes.secondary200, //color of shadow
                                  blurRadius: 100.0, // soften the shadow
                                  spreadRadius: 0.0, //extend the shadow
                                  offset: Offset(
                                      -5, // Move to right 10  horizontally
                                      -5 // Move to bottom 5 Vertically
                                      )),
                              BoxShadow(
                                  // blurStyle: BlurStyle.normal,
                                  color: FineTheme
                                      .palettes.secondary200, //color of shadow
                                  blurRadius: 100.0, // soften the shadow
                                  spreadRadius: 0.0, //extend the shadow
                                  offset: Offset(
                                      5, // Move to right 10  horizontally
                                      5 //Move to bottom 5 Vertically
                                      )),
                            ],
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                FineTheme.palettes.secondary200
                                    .withOpacity(0.1),
                                FineTheme.palettes.secondary100.withOpacity(0.1)
                              ],
                              radius: 0.75,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: Get.height * 0.6,
                  left: Get.width * 0.5,
                  child: Stack(
                    children: [
                      BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5)),
                      Container(
                        width: 200,
                        height: 200,
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  // blurStyle: BlurStyle.normal,
                                  color: FineTheme
                                      .palettes.primary200, //color of shadow
                                  blurRadius: 100.0, // soften the shadow
                                  spreadRadius: 0.0, //extend the shadow
                                  offset: Offset(
                                      -5, // Move to right 10  horizontally
                                      -5 // Move to bottom 5 Vertically
                                      )),
                              BoxShadow(
                                  // blurStyle: BlurStyle.normal,
                                  color: FineTheme
                                      .palettes.primary200, //color of shadow
                                  blurRadius: 100.0, // soften the shadow
                                  spreadRadius: 0.0, //extend the shadow
                                  offset: Offset(
                                      5, // Move to right 10  horizontally
                                      5 //Move to bottom 5 Vertically
                                      )),
                            ],
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                FineTheme.palettes.primary200.withOpacity(0.1),
                                FineTheme.palettes.primary100.withOpacity(0.1)
                              ],
                              radius: 0.75,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: Get.height * 0.75,
                  left: Get.width * 0.86,
                  right: 0,
                  child: Stack(
                    children: [
                      BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5)),
                      Container(
                        width: 100,
                        height: 100,
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                  // blurStyle: BlurStyle.normal,
                                  color: Colors.white, //color of shadow
                                  blurRadius: 100.0, // soften the shadow
                                  spreadRadius: 0.0, //extend the shadow
                                  offset: Offset(
                                      -5, // Move to right 10  horizontally
                                      -5 // Move to bottom 5 Vertically
                                      )),
                              BoxShadow(
                                  // blurStyle: BlurStyle.normal,
                                  color: Colors.white, //color of shadow
                                  blurRadius: 100.0, // soften the shadow
                                  spreadRadius: 0.0, //extend the shadow
                                  offset: Offset(
                                      5, // Move to right 10  horizontally
                                      5 //Move to bottom 5 Vertically
                                      )),
                            ],
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              // begin: Alignment.center,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.01)
                              ],
                              radius: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: screenHeight,
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
                          // padding: EdgeInsets.only(right: 24),
                          child: Image.asset(
                            'assets/images/logo.png',
                            // alignment: Alignment.topCenter,
                            fit: BoxFit.fitHeight,
                            // scale: 0.4,
                          ),
                        ),
                      ),
                      buildLoginButtons(screenHeight, context),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget buildLoginButtons(double screenHeight, BuildContext context) {
    return ScopedModelDescendant<LoginViewModel>(
      builder: (context, child, model) {
        return Stack(
          children: [
            Container(
              height: screenHeight * 0.6,
              decoration: const BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(48),
                  topRight: Radius.circular(48),
                ),
              ),
              child: BackdropFilter(
                  filter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              )),
            ),
            Container(
              decoration: BoxDecoration(
                // color: Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(48),
                  topRight: Radius.circular(48),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.3),

                    // Color(0xFF4ACADA).withOpacity(0.4),
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              height: screenHeight * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Chào mừng bạn đến với Fine!'.toUpperCase(),
                      style: const TextStyle(
                          fontFamily: 'Fira Sans',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF238E9C)),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Dùng mail trường để đăng nhập nhé!',
                      style: TextStyle(
                          fontFamily: 'Fira Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF238E9C)),
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
                        // color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF2D9B7E),
                              Color(0xFF1E8896),
                              Color(0xFF2B8793),
                              Color(0xFF3B479E)
                            ]),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Center(
                              child: FaIcon(
                            FontAwesomeIcons.googlePlusG,
                            color: Colors.white,
                          )),
                          SizedBox(
                            width: 8,
                          ),
                          Center(
                            child: Text(
                              'Đăng nhập bằng Gmail',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  fontFamily: 'Fira Sans'),
                            ),
                          ),
                        ],
                      ),
                    ),
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
