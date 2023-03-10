import 'package:fine/Constant/view_status.dart';
import 'package:fine/ViewModel/base_model.dart';

import '../Model/DAO/index.dart';
import '../Model/DTO/index.dart';

class ProductFilterViewModel extends BaseModel {
  List<ProductDTO>? listProducts;
  ProductDAO? _productDAO;
  CategoryDAO? _categoryDAO = CategoryDAO();
  List<CategoryDTO>? categories;

  // PARAM
  // PRODUCT-NAME
  // CATEGORY
  // COLLECTION

  Map<String, dynamic> _params = {};

  ProductFilterViewModel() {
    _productDAO = ProductDAO();
  }

  Map<String, dynamic> get params => _params;
  List get categoryParams => _params['category-id'] ?? [];

  setParam(Map<String, dynamic> param) {
    _params.addAll(param);
    print(_params);
    notifyListeners();
  }

  Future getProductsWithFilter() async {
    // RootViewModel root = Get.find<RootViewModel>();
    // MenuDTO currentMenu = root.selectedMenu;
    try {
      // print("Filter param");
      // print(params);
      setState(ViewStatus.Loading);
      // CampusDTO currentStore = await getStore();
      // var products = await _productDAO.getAllProductOfStore(
      //   currentStore.id,
      //   currentMenu.menuId,
      //   params: this.params,
      // );
      // listProducts = products;
      setState(ViewStatus.Completed);
    } catch (e) {
      setState(ViewStatus.Error, e.toString());
    }
  }
}
