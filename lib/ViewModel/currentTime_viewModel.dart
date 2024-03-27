import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/ViewModel/base_model.dart';

class TimeCheckViewModel extends BaseModel {
  String? time;
  AccountDAO? _dao;

  TimeCheckViewModel() {
    _dao = AccountDAO();
  }

  Future<void> getTimeCheck() async {
    try {
      setState(ViewStatus.Loading);
      time = await _dao?.getCurrentTime();
      setState(ViewStatus.Completed);
    } catch (e) {
      time = null;
      setState(ViewStatus.Completed);
    }
  }
}
