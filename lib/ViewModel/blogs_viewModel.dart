import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/StoreDAO.dart';
import 'package:fine/Model/DTO/BlogDTO.dart';
import 'package:fine/ViewModel/base_model.dart';

class BlogsViewModel extends BaseModel {
  // StoreDAO? _storeDAO;
  // List<BlogDTO>? blogs;
  List blogs = [
    {
      "id": 1,
      "images":
          'https://free4kwallpapers.com/uploads/originals/2022/04/20/rubiks-cube-digital-art-wallpaper.jpg',
    },
    {
      "id": 2,
      'images':
          'https://free4kwallpapers.com/uploads/originals/2022/01/27/gas-station-digital-art-wallpaper.jpg',
    },
    {
      "id": 3,
      'images':
          'https://free4kwallpapers.com/uploads/originals/2020/10/24/chris-bo--digital-landscape-artwork-wallpaper.jpg',
    },
  ];
  BlogDTO? dialogBlog;
  BlogsViewModel() {
    // _storeDAO = StoreDAO();
  }

  Future<void> getBlogs() async {
    try {
      setState(ViewStatus.Loading);
      // RootViewModel root = Get.find<RootViewModel>();
      // CampusDTO currentStore = root.currentStore;
      // if (root.status == ViewStatus.Error) {
      //   setState(ViewStatus.Error);
      //   return;
      // }
      // if (blogs != null) {
      //   return;
      // }
      await Future.delayed(Duration(microseconds: 500));
      // check truong hop product tra ve rong (do khong co menu nao trong TG do)
      setState(ViewStatus.Completed);
    } catch (e) {
      // blogs = null;
      setState(ViewStatus.Completed);
    }
  }
}
