import 'package:fine/ViewModel/base_model.dart';

import '../Accessories/index.dart';
import '../Constant/view_status.dart';
import '../Model/DAO/StationDAO.dart';
import '../Model/DTO/index.dart';

class StationViewModel extends BaseModel {
  List<BoxDTO>? boxList;
  StationDAO? _stationDAO;

  StationViewModel() {
    _stationDAO = StationDAO();
  }

  Future<void> getBoxListByStation(String stationId) async {
    try {
      setState(ViewStatus.Loading);
      final data = await _stationDAO?.getAllBoxByStation(stationId: stationId);
      if (data != null) {
        boxList = data;
      }
      await Future.delayed(const Duration(milliseconds: 500));

      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      boxList = null;
      setState(ViewStatus.Error);
    }
  }
}
