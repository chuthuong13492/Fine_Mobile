import 'package:fine/Constant/view_status.dart';
import 'package:fine/ViewModel/base_model.dart';

import '../Model/DAO/index.dart';
import '../Model/DTO/index.dart';

class ProductFilterViewModel extends BaseModel {
  List<ProductDTO>? listProducts;
  ProductDAO? _productDAO;
  CategoryDAO? _categoryDAO;
  List<CategoryDTO>? categories;
  MenuDTO? menuDTO;
  // PARAM
  // PRODUCT-NAME
  // CATEGORY
  // COLLECTION

  Map<String, dynamic> _params = {};

  ProductFilterViewModel() {
    _productDAO = ProductDAO();
  }

  Map<String, dynamic> get params => _params;
  // List get categoryParams => _params['id'] ?? [];

  setParam(Map<String, dynamic> param) {
    _params.addAll(param);
    print(_params);
    notifyListeners();
  }

  Future<void> getProductsWithFilter({int? id}) async {
    // RootViewModel root = Get.find<RootViewModel>();
    // MenuDTO currentMenu = root.selectedMenu;
    try {
      print("Filter param");
      print(params);
      setState(ViewStatus.Loading);
      // CampusDTO currentStore = await getStore();
      // var products = await _productDAO.getAllProductOfStore(
      //   currentStore.id,
      //   currentMenu.menuId,
      //   params: this.params,
      // );
      // listProducts = products;
      if (params["menu"] != null) {
        var products =
            await _productDAO?.getProductsByMenuId(params["menu"]["id"]);
        listProducts =
            products!.where((element) => element.isAvailable!).toList();
        params.clear();
      }
      if (params["store"] != null) {
        var products = await _productDAO
            ?.getProductsInMenuByStoreId(params["store"]["id"]);
        listProducts =
            products!.where((element) => element.isAvailable!).toList();
        params.clear();
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      setState(ViewStatus.Error, e.toString());
    }
  }
}
