import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/StoreDAO.dart';
import 'package:fine/Model/DTO/BlogDTO.dart';
import 'package:fine/ViewModel/base_model.dart';

class BlogsViewModel extends BaseModel {
  StoreDAO? _storeDAO;
  List<BlogDTO>? blogs;

  BlogDTO? dialogBlog;
  BlogsViewModel() {
    _storeDAO = StoreDAO();
  }

  Future<void> getBlogs() async {
    try {
      setState(ViewStatus.Loading);

      // ignore: prefer_conditional_assignment
      if (blogs == null) {
        blogs = await _storeDAO?.getBlogs();
      }
      await Future.delayed(const Duration(microseconds: 500));
      setState(ViewStatus.Completed);
    } catch (e) {
      blogs = null;
      setState(ViewStatus.Completed);
    }
  }
}
