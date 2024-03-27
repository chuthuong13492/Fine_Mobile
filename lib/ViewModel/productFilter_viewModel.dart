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

  Map<String, dynamic> _params = {};

  ProductFilterViewModel() {
    _productDAO = ProductDAO();
  }

  Map<String, dynamic> get params => _params;

  setParam(MenuDTO menu) {
    menuDTO = menu;
    notifyListeners();
  }

  Future<void> getProductsWithFilter({String? id}) async {
    try {
      setState(ViewStatus.Loading);
      if (id != null) {
        var products = await _productDAO?.getProductsByMenuId(id);
        listProducts = products!.where((element) => element.isActive!).toList();
        params.clear();
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      setState(ViewStatus.Completed);
    }
  }
}
