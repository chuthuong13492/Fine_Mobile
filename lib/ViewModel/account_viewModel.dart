import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'root_viewModel.dart';

class AccountViewModel extends BaseModel {
  late AccountDAO _dao;
  AccountDTO? currentUser;

  AccountViewModel() {
    _dao = AccountDAO();
  }

  Future<void> fetchUser({bool isRefetch = false}) async {
    try {
      if (isRefetch) {
        setState(ViewStatus.Refreshing);
      } else if (status != ViewStatus.Loading) {
        setState(ViewStatus.Loading);
      }

      final user = await _dao.getUser();
      currentUser = user;

      String? token = await getToken();
      print(token.toString());
      // if(currentUser.phone != null || currentUser.phone != ""){

      // }
      setState(ViewStatus.Completed);
    } catch (e, stacktrace) {
      print(e.toString() + stacktrace.toString());
      currentUser = null;
      setState(ViewStatus.Error);
      // bool result = await showErrorDialog();
      // if (result) {
      //   await fetchUser();
      // } else {
      //   setState(ViewStatus.Error);
      // }
    }
  }

  Future<void> processSignout() async {
    try {
      int option = await showOptionDialog("Mình sẽ nhớ bạn lắm ó huhu :'(((");
      if (option == 1) {
        showLoadingDialog();
        await _dao.logOut();
        await removeALL();
        // await FirebaseAuth.instance.signOut();
        // await GoogleSignIn().signOut();
        // Get.testMode = true;
        // if (Get.testMode == false) {
        //   // TestWidgetsFlutterBinding.ensureInitialized();
        //   Get.testMode = true;
        //   Get.testMode = true;
        //   Get.offAll(RoutHandler.LOGIN);
        // }
        // await Get.find<RootViewModel>().startUp();
        hideDialog();
        Get.toNamed(RoutHandler.LOGIN);
      }
    } catch (e) {
      print(e);
      // setState(ViewStatus.Error);
    }
  }
}
