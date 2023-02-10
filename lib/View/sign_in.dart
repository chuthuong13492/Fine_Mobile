import 'package:fine/ViewModel/login_viewModel.dart';
import 'package:fine/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:scoped_model/scoped_model.dart';

// class SignIn extends StatelessWidget {
//   const SignIn({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ScopedModel(
//       model: Get.put(LoginViewModel()),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Container(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height,
//           decoration: BoxDecoration(
//             image: DecorationImage(
//                 image: AssetImage("assets/images/bg-signin.png"),
//                 fit: BoxFit.fill),
//           ),
//           child: Container(
//             padding: EdgeInsets.fromLTRB(20, 240, 20, 0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   "Chào mừng bạn qua trở lại",
//                   style: TextStyle(
//                     fontFamily: 'Nunito-Black',
//                     color: Colors.black,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 40),
//                 Text(
//                   "Đăng nhập và tận hưởng những ưu đãi yêu thích của bạn!",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontFamily: 'Nunito-SemiBold',
//                       color: labelColor,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600),
//                 ),
//                 SizedBox(height: 40),
//                 ScopedModelDescendant<LoginViewModel>(
//                   builder: (context, child, model) {
//                     return InkWell(
//                       onTap: () {
//                         model.signInWithGoogle();
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: primary,
//                           borderRadius: BorderRadius.circular(24),
//                           boxShadow: [
//                             BoxShadow(
//                               color: secondary.withOpacity(0.05),
//                               spreadRadius: 1,
//                               blurRadius: 1,
//                               offset: Offset(0, 0),
//                             ),
//                           ],
//                         ),
//                         width: 280,
//                         height: 48,
//                         alignment: Alignment.center,
//                         child: Text(
//                           "Đăng nhập bằng Gmail",
//                           style: TextStyle(
//                               fontFamily: 'Nunito-SemiBold',
//                               color: appBgColor,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 SizedBox(height: 80),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool islogin = true;

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: LoginViewModel(),
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Color(0xFFDFF8FE)),
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: 360,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Chào mừng trở lại với Fine",
                            style: GoogleFonts.roboto(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4BB8F4)),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Đăng nhập và tận hưởng những ưu đãi \nyêu thích của bạn!",
                            style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF4BB8F4)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Stack(
                        children: [
                          //Making of the Login Part

                          islogin
                              ? Positioned(
                                  top: 20,
                                  left: 20,
                                  right: 20,
                                  child: Container(
                                    height: 550,
                                    width: MediaQuery.of(context).size.width *
                                        0.98,
                                    child: Stack(
                                      children: [
                                        //Did for z-index
                                        Container(
                                          child: ClipPath(
                                            //WIll make  a clip Path of the shape as Login
                                            clipper: SignupClipper(),

                                            child: Container(
                                              height: 500,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.92,
                                              decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.8)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 30,
                                                        top: 20,
                                                        right: 30),
                                                    child: Text(
                                                      "Tài Xế",
                                                      style: GoogleFonts.roboto(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 40,
                                                          color:
                                                              Colors.grey[400]),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        CustomPaint(
                                          //Shadow for the Box
                                          painter: loginShadowPaint(),
                                          child: ClipPath(
                                            //WIll make  a clip Path of the shape as Login
                                            clipper: loginClipper(),

                                            child: Container(
                                              height: 500,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.92,
                                              decoration: BoxDecoration(
                                                  color: Colors.white),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 30, top: 20),
                                                    child: Text(
                                                      "Sinh viên",
                                                      style: GoogleFonts.roboto(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 32,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Container(
                                                      width: 130,
                                                      margin: EdgeInsets.only(
                                                        left: 30,
                                                      ),
                                                      height: 12,
                                                      child: Card(
                                                          elevation: 2,
                                                          color: Color(
                                                              0xFF4BB8F4))),
                                                  SizedBox(
                                                    height: 60,
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                    margin: EdgeInsets.only(
                                                      left: 30,
                                                    ),
                                                    height: 200,
                                                    child: Text(
                                                      "Các homies vui lòng đăng nhập bằng Gmail của trường nhé 😘 ",
                                                      style: GoogleFonts.roboto(
                                                          fontSize: 26,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: Color(
                                                              0xFF4BB8F4)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        ScopedModelDescendant<LoginViewModel>(
                                          builder: (context, child, model) {
                                            return Positioned(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.32,
                                              bottom: 35,
                                              child: Align(
                                                alignment: Alignment(0, 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 120,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xFF4BB8F4),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          25)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Color(
                                                                    0xFF4BB8F4),
                                                                spreadRadius: 5,
                                                                blurRadius: 12)
                                                          ]),
                                                      child: MaterialButton(
                                                        onPressed: () {
                                                          model
                                                              .signInWithGoogle();
                                                        },
                                                        elevation: 2,
                                                        child: Text(
                                                          "Gmail Login ",
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ))
                              : Container(),

                          //Making of the Signup Part

                          /* Finishing the Singup PArt Now */

                          islogin == false
                              ? Positioned(
                                  top: 20,
                                  left: 20,
                                  right: 20,
                                  child: Container(
                                    height: 550,
                                    width: MediaQuery.of(context).size.width *
                                        0.98,
                                    margin: EdgeInsets.only(bottom: 20),
                                    child: Stack(
                                      children: [
                                        CustomPaint(
                                          //Shadow for the Box
                                          painter: signupShadowPaint(),
                                          child: Stack(
                                            children: [
                                              Container(
                                                child: ClipPath(
                                                  //WIll make  a clip Path of the shape as Login
                                                  clipper: loginClipper(),

                                                  child: Container(
                                                    height: 500,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.92,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.8)),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 30,
                                                                  top: 20,
                                                                  right: 30),
                                                          child: Text(
                                                            "Sinh viên",
                                                            style: GoogleFonts.roboto(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 40,
                                                                color: Colors
                                                                    .grey[400]),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ClipPath(
                                                //WIll make  a clip Path of the shape as Login
                                                clipper: SignupClipper(),

                                                child: Container(
                                                  height: 500,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.92,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Spacer(),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 30,
                                                                    top: 20,
                                                                    right: 30),
                                                            child: Text(
                                                              "Tài Xế",
                                                              style: GoogleFonts.roboto(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 32,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Spacer(),
                                                          Container(
                                                              width: 85,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 30,
                                                                      right:
                                                                          30),
                                                              height: 12,
                                                              child: Card(
                                                                  elevation: 2,
                                                                  color: Color(
                                                                      0xFF4BB8F4))),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 60,
                                                      ),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                          margin:
                                                              EdgeInsets.only(
                                                            left: 30,
                                                          ),
                                                          height: 60,
                                                          child: TextField(
                                                            decoration:
                                                                InputDecoration(
                                                                    icon: Icon(
                                                                      Icons
                                                                          .mail,
                                                                      size: 24,
                                                                      color: Color(
                                                                          0xFF4BB8F4),
                                                                    ),
                                                                    labelText:
                                                                        "Email Address",
                                                                    labelStyle: GoogleFonts.lato(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .grey[500])),
                                                          )),
                                                      SizedBox(
                                                        height: 30,
                                                      ),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                          margin:
                                                              EdgeInsets.only(
                                                            left: 30,
                                                          ),
                                                          height: 60,
                                                          child: TextField(
                                                            decoration:
                                                                InputDecoration(
                                                                    icon: Icon(
                                                                      FontAwesomeIcons
                                                                          .eyeSlash,
                                                                      size: 20,
                                                                      color: Color(
                                                                          0xFF4BB8F4),
                                                                    ),
                                                                    labelText:
                                                                        "Password",
                                                                    labelStyle: GoogleFonts.lato(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .grey[500])),
                                                          )),
                                                      // SizedBox(
                                                      //   height: 30,
                                                      // ),
                                                      // Container(
                                                      //     width: MediaQuery.of(
                                                      //                 context)
                                                      //             .size
                                                      //             .width *
                                                      //         0.7,
                                                      //     margin:
                                                      //         EdgeInsets.only(
                                                      //       left: 30,
                                                      //     ),
                                                      //     height: 60,
                                                      //     child: TextField(
                                                      //       decoration:
                                                      //           InputDecoration(
                                                      //               icon: Icon(
                                                      //                 FontAwesomeIcons
                                                      //                     .eyeSlash,
                                                      //                 size: 20,
                                                      //                 color: Color(
                                                      //                     0xFF4BB8F4),
                                                      //               ),
                                                      //               labelText:
                                                      //                   "Confirm Password",
                                                      //               labelStyle: GoogleFonts.lato(
                                                      //                   fontSize:
                                                      //                       16,
                                                      //                   color: Colors
                                                      //                       .grey[500])),
                                                      //     )),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.32,
                                          bottom: 35,
                                          child: Align(
                                            alignment: Alignment(0, 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 120,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Color(0xFF4BB8F4),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  25)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Color(
                                                                0xFF4BB8F4),
                                                            spreadRadius: 5,
                                                            blurRadius: 12)
                                                      ]),
                                                  child: MaterialButton(
                                                    onPressed: () {},
                                                    elevation: 2,
                                                    child: Text(
                                                      "Login",
                                                      style: GoogleFonts.roboto(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ))
                              : Container(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.09,
                right: MediaQuery.of(context).size.width * 0.32,
                child: Icon(
                  FontAwesomeIcons.cog,
                  color: Color(0xFF4BB8F4),
                  size: 18,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.21,
                right: MediaQuery.of(context).size.width * 0.2,
                child: Icon(
                  FontAwesomeIcons.cog,
                  color: Color(0xFF4BB8F4),
                  size: 12,
                ),
              ),
              // Positioned(
              //   top: MediaQuery.of(context).size.height * 0.22,
              //   left: MediaQuery.of(context).size.width * 0.21,
              //   child: Icon(
              //     LineIcons.byName('close'),
              //     color: Color(0xFF4BB8F4),
              //     size: 24,
              //   ),
              // ),
              Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.07,
                  left: MediaQuery.of(context).size.width * 0.36,
                  child: Container(
                    width: 160,
                    child: GestureDetector(
                      onTap: () {
                        if (islogin) {
                          setState(() {
                            islogin = false;
                          });
                        } else {
                          setState(() {
                            islogin = true;
                          });
                        }
                      },
                      child: Center(
                        child: Text(
                          islogin
                              ? "Bạn có phải tài xế ?"
                              : "Sinh viên qua đây nè!",
                          style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Color(0xFF4BB8F4),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class SignupClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path clip = new Path();
    clip.moveTo(size.width, 70);
    clip.lineTo(size.width, size.height - 70);
    clip.quadraticBezierTo(
        size.width, size.height, size.width - 70, size.height);

    clip.lineTo(70, size.height);
    clip.quadraticBezierTo(0, size.height, 0, size.height - 70);

    clip.lineTo(0, size.height * 0.3 + 50);
    clip.quadraticBezierTo(0, size.height * 0.3, 50, size.height * 0.3 - 50);
    clip.lineTo(size.width - 70, 0);

    clip.quadraticBezierTo(size.width, 0, size.width, 70);

    clip.close();
    return clip;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class loginShadowPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path clip = new Path();

    clip.moveTo(0, 70);
    clip.lineTo(0, size.height - 70);
    clip.quadraticBezierTo(0, size.height, 70, size.height);

    clip.lineTo(size.width - 70, size.height);
    clip.quadraticBezierTo(
        size.width, size.height, size.width, size.height - 70);

    clip.lineTo(size.width, size.height * 0.3 + 50);
    clip.quadraticBezierTo(
        size.width, size.height * 0.3, size.width - 50, size.height * 0.3 - 50);

    clip.lineTo(70, 0);
    clip.quadraticBezierTo(0, 0, 0, 70);
    clip.close();

    canvas.drawShadow(clip, Color(0xFF4BB8F4), 5, false);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

class loginClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path clip = new Path();

    clip.moveTo(0, 70);
    clip.lineTo(0, size.height - 70);
    clip.quadraticBezierTo(0, size.height, 70, size.height);

    clip.lineTo(size.width - 70, size.height);
    clip.quadraticBezierTo(
        size.width, size.height, size.width, size.height - 70);

    clip.lineTo(size.width, size.height * 0.3 + 50);
    clip.quadraticBezierTo(
        size.width, size.height * 0.3, size.width - 50, size.height * 0.3 - 50);

    clip.lineTo(70, 0);
    clip.quadraticBezierTo(0, 0, 0, 70);
    clip.close();

    return clip;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class signupShadowPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path clip = new Path();
    clip.moveTo(size.width, 70);
    clip.lineTo(size.width, size.height - 70);
    clip.quadraticBezierTo(
        size.width, size.height, size.width - 70, size.height);

    clip.lineTo(70, size.height);
    clip.quadraticBezierTo(0, size.height, 0, size.height - 70);

    clip.lineTo(0, size.height * 0.3 + 50);
    clip.quadraticBezierTo(0, size.height * 0.3, 50, size.height * 0.3 - 50);
    clip.lineTo(size.width - 70, 0);

    clip.quadraticBezierTo(size.width, 0, size.width, 70);

    clip.close();

    canvas.drawShadow(clip, Color(0xFF4BB8F4), 5, false);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
