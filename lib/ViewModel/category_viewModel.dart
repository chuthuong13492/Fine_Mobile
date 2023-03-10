import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/CategoryDAO.dart';
import 'package:fine/Model/DTO/CategoryDTO.dart';
import 'package:fine/ViewModel/base_model.dart';

class CategoryViewModel extends BaseModel {
  CategoryDAO? _categoryDAO;
  List<CategoryDTO>? categories;

  CategoryViewModel() {
    _categoryDAO = CategoryDAO();
  }
  Future getCategories({Map<String, dynamic>? params}) async {
    try {
      setState(ViewStatus.Loading);
      categories = await _categoryDAO?.getCategories(params: params);
      // await Future.delayed(const Duration(microseconds: 500));

      setState(ViewStatus.Completed);
    } catch (e) {
      print(e);
      // categories = null;
      setState(ViewStatus.Error);
    }
  }
}
