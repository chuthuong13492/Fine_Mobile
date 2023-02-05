import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/utils/shared_pref.dart';

class AccountViewModel extends BaseModel {
  late AccountDAO _dao;
  late AccountDTO currentUser;

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
    }
  }
}
