import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/CollectionDAO.dart';
import 'package:fine/Model/DAO/StoreDAO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:get/get.dart';

class HomeViewModel extends BaseModel {
  StoreDAO? _storeDAO;
  CollectionDAO? _collectionDAO;
  List<CollectionDTO>? homeCollections;
  HomeViewModel() {
    _collectionDAO = CollectionDAO();
    _storeDAO = StoreDAO();
    // _productDAO = ProductDAO();
  }

  Future<void> getCollections() async {
    try {
      setState(ViewStatus.Loading);
      RootViewModel root = Get.find<RootViewModel>();
      // var currentMenu = root.selectedMenu;
      // if (root.status == ViewStatus.Error) {
      //   setState(ViewStatus.Error);
      //   return;
      // }
      // if (currentMenu == null) {
      //   homeCollections = null;
      //   setState(ViewStatus.Completed);
      //   return;
      // }
      // final currentDate = DateTime.now();
      // String currentTimeSlot = currentMenu.timeFromTo[1];
      // var beanTime = new DateTime(
      //   currentDate.year,
      //   currentDate.month,
      //   currentDate.day,
      //   double.parse(currentTimeSlot.split(':')[0]).round(),
      //   double.parse(currentTimeSlot.split(':')[1]).round(),
      // );
      // int differentTime = beanTime.difference(currentDate).inMilliseconds;
      // if (!root.isCurrentMenuAvailable()) {
      //   homeCollections = null;
      //   setState(ViewStatus.Completed);
      //   return;
      // }
      // homeCollections = await _collectionDAO!
      //     .getCollections(currentMenu.menuId, params: {"show-on-home": true});
      await Future.delayed(Duration(microseconds: 500));
      setState(ViewStatus.Completed);
    } catch (e) {
      homeCollections = null;
      setState(ViewStatus.Completed);
    }
  }
}
