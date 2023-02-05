import 'package:fine/Model/DTO/AccountDTO.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:get/get.dart';

class RootViewModel extends BaseModel {
  AccountDTO? user;
  Future startUp() async {
    // await Get.find<AccountViewModel>().fetchUser();
  }
}
