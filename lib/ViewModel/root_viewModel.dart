import 'package:fine/Model/DTO/AccountDTO.dart';
import 'package:fine/Model/DTO/CampusDTO.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:get/get.dart';

class RootViewModel extends BaseModel {
  AccountDTO? user;
  CampusDTO? currentStore;

  List TimeSlot = [
    {'id': 1, 'timeSlot': '7:00 - 9:15'},
    {'id': 2, 'timeSlot': '9:30 - 12:15'},
    {'id': 3, 'timeSlot': '12:30 - 14:45'},
    {'id': 4, 'timeSlot': '15:00 - 17:15'},
    {'id': 5, 'timeSlot': '18:00 - 20:15'},
  ];
  Future startUp() async {
    // await Get.find<AccountViewModel>().fetchUser();
  }
}
