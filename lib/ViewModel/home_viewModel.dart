import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/CollectionDAO.dart';
import 'package:fine/Model/DAO/MenuDAO.dart';
import 'package:fine/Model/DAO/StoreDAO.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:get/get.dart';

class HomeViewModel extends BaseModel {
  StoreDAO? _storeDAO;
  CollectionDAO? _collectionDAO;
  MenuDAO? _menuDAO;
  ProductDAO? _productDAO;
  List<SupplierDTO>? supplierList;
  SupplierDTO? selectedStore;
  // List<CollectionDTO>? homeCollections;
  List<MenuDTO>? homeMenu;
  List<ProductDTO>? productList;
  HomeViewModel() {
    _collectionDAO = CollectionDAO();
    _storeDAO = StoreDAO();
    _productDAO = ProductDAO();
    _menuDAO = MenuDAO();
    // _productDAO = ProductDAO();
  }

  Future<void> getCollections() async {
    try {
      setState(ViewStatus.Loading);
      RootViewModel root = Get.find<RootViewModel>();
      var currentTimeSlot = root.selectedTimeSlot;
      // var currentMenu = root.selectedMenu;
      if (root.status == ViewStatus.Error) {
        setState(ViewStatus.Error);
        return;
      }
      if (currentTimeSlot == null) {
        homeMenu = null;
        setState(ViewStatus.Completed);
        return;
      }
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
      homeMenu = await _menuDAO?.getCollections(currentTimeSlot.id);

      await Future.delayed(const Duration(microseconds: 500));
      setState(ViewStatus.Completed);
    } catch (e) {
      homeMenu = null;
      setState(ViewStatus.Completed);
    }
  }

  Future<void> getListSupplier() async {
    try {
      setState(ViewStatus.Loading);
      RootViewModel root = Get.find<RootViewModel>();
      var currentTimeSlot = root.selectedTimeSlot;
      // var currentMenu = root.selectedMenu;
      if (root.status == ViewStatus.Error) {
        setState(ViewStatus.Error);
        return;
      }
      if (currentTimeSlot == null) {
        homeMenu = null;
        setState(ViewStatus.Completed);
        return;
      }
      supplierList = await _storeDAO?.getSuppliers(currentTimeSlot.id!);
      await Future.delayed(const Duration(microseconds: 500));
      setState(ViewStatus.Completed);
    } catch (e) {
      supplierList = null;
      setState(ViewStatus.Completed);
    }
  }

  // Future<void> getProductInMenu(int? menuId) async {
  //   try {
  //     setState(ViewStatus.Loading);
  //     productList = await _productDAO?.getProductsByMenuId(menuId);
  //     await Future.delayed(const Duration(microseconds: 500));
  //     setState(ViewStatus.Completed);
  //   } catch (e) {
  //     productList = null;
  //     setState(ViewStatus.Completed);
  //   }
  // }
}
