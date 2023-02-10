// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:fine/Constant/view_status.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Model/DAO/AccountDAO.dart';
import 'package:fine/Model/DTO/AccountDTO.dart';
import 'package:fine/Service/analytic_service.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginViewModel extends BaseModel {
  late AccountDAO dao = AccountDAO();
  late String verificationId;
  late AnalyticsService _analyticsService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseAuth _auth;
  // User get user => _auth.currentUser!;

  late AccountDTO userInfo;

  LoginViewModel() {
    _analyticsService = AnalyticsService.getInstance()!;
  }

  Future<void> signInWithGoogle() async {
    try {
      setState(ViewStatus.Loading);
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        await _auth.signInWithCredential(credential);

        User userToken = FirebaseAuth.instance.currentUser!;
        final idToken = await userToken.getIdToken();
        final fcmToken = await FirebaseMessaging.instance.getToken();
        print('idToken: ' + idToken);
        print('fcmToken: ' + fcmToken.toString());
        userInfo = await dao.login(idToken);
        await _analyticsService.setUserProperties(userInfo);
        // ignore: unnecessary_null_comparison
        if (userInfo != null) {
          await Get.find<RootViewModel>().startUp();
          Get.rawSnackbar(
              message: "Đăng nhập thành công!!",
              duration: Duration(seconds: 2),
              snackPosition: SnackPosition.BOTTOM,
              margin: EdgeInsets.only(left: 8, right: 8, bottom: 32),
              borderRadius: 8);

          await Get.offAllNamed(RoutHandler.NAV);
        }
      }
      await Future.delayed(Duration(microseconds: 500));
      setState(ViewStatus.Completed);
    } on FirebaseAuthException catch (e) {
      log(e.message!);
      // });
      setState(ViewStatus.Completed);
    }
  }
}
