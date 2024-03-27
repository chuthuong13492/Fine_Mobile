import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/CollectionDAO.dart';
import 'package:fine/Model/DAO/MenuDAO.dart';
import 'package:fine/Model/DAO/StoreDAO.dart';
import 'package:fine/Model/DAO/index.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:get/get.dart';

import '../Model/DTO/ConfirmCartDTO.dart';

class HomeViewModel extends BaseModel {
  StoreDAO? _storeDAO;
  CollectionDAO? _collectionDAO;
  MenuDAO? _menuDAO;
  ProductDAO? _productDAO;
  List<SupplierDTO>? supplierList;
  SupplierDTO? selectedStore;
  // List<CollectionDTO>? homeCollections;
  OrderDTO? orderDTO;
  List<MenuDTO>? homeMenu;
  List<ReOrderDTO>? reOrderList;
  List<ProductDTO>? productList;

  HomeViewModel() {
    _collectionDAO = CollectionDAO();
    _storeDAO = StoreDAO();
    _productDAO = ProductDAO();
    _menuDAO = MenuDAO();
    // _productDAO = ProductDAO();
  }

  Future<void> getMenus() async {
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
      homeMenu = await _menuDAO?.getMenus(currentTimeSlot.id);

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
      // setState(ViewStatus.Error);
    }
  }

  Future<void> createReOrder(String id) async {
    try {
      RootViewModel root = Get.find<RootViewModel>();
      List<ConfirmCartItem> listCartItem = [];
      await deleteCart();
      orderDTO =
          await _storeDAO?.createReOrder(id, root.isNextDay == true ? 2 : 1);
      if (orderDTO != null) {
        for (var item in orderDTO!.orderDetails!) {
          listCartItem
              .add(ConfirmCartItem(item.productId, item.quantity, null));
        }
      }
      notifyListeners();
    } catch (e) {
      orderDTO = null;
    }
  }

  Future<void> getProductListInTimeSlot() async {
    try {
      setState(ViewStatus.Loading);
      RootViewModel root = Get.find<RootViewModel>();

      productList = await _productDAO
          ?.getListProductInTimeSlot(root.selectedTimeSlot!.id!);
      setState(ViewStatus.Completed);
    } catch (e) {
      productList = null;
      setState(ViewStatus.Error);
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
