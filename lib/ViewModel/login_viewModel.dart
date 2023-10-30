// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Model/DAO/AccountDAO.dart';
// import 'package:fine/Model/DTO/AccountDTO.dart';
import 'package:fine/Service/analytic_service.dart';
import 'package:fine/Service/firebase_auth.dart';
import 'package:fine/Service/push_notification_service.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Model/DTO/index.dart';

class LoginViewModel extends BaseModel {
  AccountDAO? _dao;
  late String verificationId;
  late AnalyticsService _analyticsService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AccountDTO? userInfo;

  LoginViewModel() {
    _dao = AccountDAO();
    _analyticsService = AnalyticsService.getInstance()!;
  }

  Future<AccountDTO?> signIn(UserCredential userCredential, bool isLoginGmail,
      [String method = "phone"]) async {
    try {
      // lay thong tin user tu firebase

      await _analyticsService.logLogin(method);
      // TODO: Thay uid = idToken
      String token = await userCredential.user!.getIdToken();
      print("idToken: $token");
      String phone = userCredential.user!.phoneNumber!;
      String numericPhoneNumber = Uri.encodeComponent(phone);

      // Check if the numericPhoneNumber starts with "+84" (Vietnam country code)
      // if (numericPhoneNumber.startsWith('84')) {
      //   // Replace the country code with "0" (standard Vietnam format)
      //   numericPhoneNumber = '0' + numericPhoneNumber.substring(2);
      // }
      if (isLoginGmail == true) {
        final userDTO = AccountDTO(
          name: null,
          email: null,
          phone: numericPhoneNumber,
          dateOfBirth: null,
          imageUrl: null,
        );
        userInfo = await _dao!.updateUser(userDTO);
        return userInfo;
      } else {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        final userInfo = await _dao?.login(token, fcmToken!, true);
        await PushNotificationService.getInstance()!.init();

        await _analyticsService.setUserProperties(userInfo!);
        return userInfo;
      }
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await signIn(userCredential, isLoginGmail);
      } else {
        setState(ViewStatus.Error);
      }
    }
    return null;
  }

  Future<void> signInWithGoogle() async {
    try {
      setState(ViewStatus.Loading);

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        await _auth.signInWithCredential(credential);

        User userToken = FirebaseAuth.instance.currentUser!;
        final idToken = await userToken.getIdToken();
        final fcmToken = await FirebaseMessaging.instance.getToken();
        // print('idToken: ' + idToken);
        log('idToken: ' + idToken);
        log('fcmToken: ' + fcmToken.toString());

        userInfo = await _dao?.login(idToken, fcmToken!, false);
        if (userInfo == null) {
          await showStatusDialog("assets/images/error.png", 'Éc éc ⚠️',
              'Bạn vui lòng đăng nhập bằng mail trường nhé 🥰');
        } else {
          if (userInfo!.phone == null) {
            await Get.toNamed(RouteHandler.LOGIN_PHONE, arguments: true);
          } else {
            showLoadingDialog();
            await _analyticsService.setUserProperties(userInfo!);
            await Get.find<RootViewModel>().startUp();
            Get.rawSnackbar(
                message: "Đăng nhập thành công!!",
                duration: const Duration(seconds: 2),
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.only(left: 8, right: 8, bottom: 32),
                borderRadius: 8);
            hideDialog();
            await Get.offAllNamed(RouteHandler.NAV);
          }
        }
      }

      await Future.delayed(const Duration(microseconds: 500));
      setState(ViewStatus.Completed);
    } on FirebaseAuthException catch (e) {
      log(e.message!);

      setState(ViewStatus.Completed);
    }
  }

  Future<void> signInWithPhone(String phone, bool isLoginGmail) async {
    try {
      setState(ViewStatus.Loading);
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (phoneAuthCredential) async {
          await _auth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) async {
          await showStatusDialog("assets/images/error.png", 'Éc éc ⚠️',
              'Đăng nhập thất bại ùi kìa 🥰');
          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          Get.toNamed(RouteHandler.LOGIN_OTP, arguments: {
            "verId": verificationId,
            "isLoginGmail": isLoginGmail
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
      setState(ViewStatus.Completed);
    } on FirebaseAuthException catch (e) {
      log(e.message!);

      setState(ViewStatus.Completed);
    }
  }

  Future<void> onsignInWithOTP(
      smsCode, verificationId, bool isLoginGmail) async {
    showLoadingDialog();

    try {
      final authCredential =
          await AuthService().signInWithOTP(smsCode, verificationId);
      final userCredential = await AuthService().signIn(authCredential);

      userInfo = await signIn(userCredential, isLoginGmail);
      if (userInfo != null) {
        if (userInfo!.name == null) {
          await Get.offAndToNamed(RouteHandler.SIGN_UP, arguments: userInfo);
        } else {
          Get.rawSnackbar(
              message: "Đăng nhập thành công!!",
              duration: const Duration(seconds: 3),
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.only(left: 8, right: 8, bottom: 32),
              borderRadius: 8);
          await Get.find<RootViewModel>().startUp();
          await Get.offAllNamed(RouteHandler.NAV);
        }
      }
    } on FirebaseAuthException catch (e) {
      await showStatusDialog("assets/images/error.png", "Error", e.message!);
    } catch (e) {
      await showStatusDialog("assets/images/error.png", "Error", e.toString());
    } finally {
      hideDialog();
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Get.offAllNamed(RouteHandler.LOGIN);
  }
}
