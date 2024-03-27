import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/AccountDTO.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:get/get.dart';

import '../Accessories/dialog.dart';
import '../Constant/route_constraint.dart';
import 'root_viewModel.dart';

class SignUpViewModel extends BaseModel {
  AccountDAO? dao;
  SignUpViewModel() {
    dao = AccountDAO();
  }

  Future<void> signupUser(Map<String, dynamic> user) async {
    try {
      setState(ViewStatus.Loading);
      final userDTO = AccountDTO(
        name: user["name"],
        email: user["email"] ?? null,
        phone: user["phone"] ?? null,
        dateOfBirth: user["dateOfBirth"] ?? null,
        imageUrl: user["imageUrl"] ?? null,
      );
      await dao!.updateUser(userDTO);
      // setToken here
      setState(ViewStatus.Completed);
      await Get.find<RootViewModel>().startUp();
      Get.offAllNamed(RouteHandler.NAV);

      // await Future.delayed(Duration(seconds: 3));
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await signupUser(user);
      } else {
        setState(ViewStatus.Error);
      }
    }
  }
}
