import 'dart:async';

import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Model/DAO/AccountDAO.dart';
import 'package:fine/Service/firebase_dynamic_link_services.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'root_viewModel.dart';

class StartUpViewModel extends BaseModel {
  DynamicLinkService? _dynamicLinkService = DynamicLinkService();
  StartUpViewModel() {
    handleStartUpLogic();
  }
  Future handleStartUpLogic() async {
    await _dynamicLinkService!.initDynamicLinks();
    AccountDAO _accountDAO = AccountDAO();
    await Future.delayed(const Duration(seconds: 3));
    var hasLoggedInUser = await _accountDAO.isUserLoggedIn();
    bool isFirstOnBoard = await getIsFirstOnboard() ?? true;
    if (isFirstOnBoard) {
      // await Get.find<RootViewModel>().startUp();
      Get.offAndToNamed(RouteHandler.ONBOARD);
    } else if (hasLoggedInUser) {
      await Get.find<RootViewModel>().startUp();
      Get.offAndToNamed(RouteHandler.NAV);
    } else {
      Get.offAndToNamed(RouteHandler.WELCOME_SCREEN);
    }
  }
}
