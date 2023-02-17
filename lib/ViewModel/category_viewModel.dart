import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DAO/CategoryDAO.dart';
import 'package:fine/Model/DTO/CategoryDTO.dart';
import 'package:fine/ViewModel/base_model.dart';

class CategoryViewModel extends BaseModel {
  CategoryDAO? _categoryDAO;
  List<CategoryDTO>? categories;
  List categoryList = [
    {
      "id": 15,
      "category_name": "PASSIO COFFEE",
      "position": 509,
      "pic_url":
          "https://unideli.s3.amazonaws.com/images/logo.png?AWSAccessKeyId=AKIAICIMXGRRHZQCC4NA&Expires=1642218778&Signature=t0%2F5gyWe8e9qzVnSWgJ0g3Q3pDU%3D",
      "show_on_home": false,
      "type": 1
    },
    {
      "id": 44,
      "category_name": "Cơm",
      "position": 1000,
      "pic_url":
          "https://prod-reso.s3.ap-southeast-1.amazonaws.com/bean-oi/rice.png",
      "show_on_home": true,
      "type": 1
    },
    {
      "id": 45,
      "category_name": "Món Nước",
      "position": 1000,
      "show_on_home": false,
      "type": 1
    },
    {
      "id": 46,
      "category_name": "Đồ Uống",
      "position": 1000,
      "pic_url":
          "https://prod-reso.s3.ap-southeast-1.amazonaws.com/bean-oi/liquor.png",
      "show_on_home": true,
      "type": 1
    },
    {
      "id": 1059,
      "category_name": "Món phụ",
      "position": 1000,
      "show_on_home": false,
      "type": 1
    },
    {
      "id": 2088,
      "category_name": "Cơm nóng",
      "position": 1000,
      "pic_url":
          "https://unideli.s3.amazonaws.com/images/logo.png?AWSAccessKeyId=AKIAICIMXGRRHZQCC4NA&Expires=1642218914&Signature=wGwu7%2BlW1LeUXTgkZXgrtGDkGro%3D",
      "show_on_home": false,
      "type": 1
    },
    {
      "id": 2089,
      "category_name": "Mì- Bún",
      "position": 1000,
      "pic_url":
          "https://prod-reso.s3.ap-southeast-1.amazonaws.com/bean-oi/noodles.png",
      "show_on_home": true,
      "type": 1
    },
    {
      "id": 2103,
      "category_name": "Nước uống",
      "position": 0,
      "pic_url":
          "https://prod-reso.s3.ap-southeast-1.amazonaws.com/bean-oi/bubble-tea.png",
      "show_on_home": true,
      "type": 1
    },
    {
      "id": 2110,
      "category_name": "Món khác",
      "position": 500,
      "pic_url":
          "https://prod-reso.s3.ap-southeast-1.amazonaws.com/bean-oi/fast-food.png",
      "show_on_home": true,
      "type": 1
    },
    {
      "id": 2111,
      "category_name": "Coffee",
      "position": 500,
      "pic_url":
          "https://prod-reso.s3.ap-southeast-1.amazonaws.com/bean-oi/coffee-cup.png",
      "show_on_home": true,
      "type": 1
    },
    {
      "id": 2112,
      "category_name": "Tea",
      "position": 500,
      "pic_url":
          "https://prod-reso.s3.ap-southeast-1.amazonaws.com/bean-oi/tea.png",
      "show_on_home": true,
      "type": 1
    },
    {
      "id": 2113,
      "category_name": "Combo",
      "position": 504,
      "pic_url":
          "https://prod-reso.s3.ap-southeast-1.amazonaws.com/bean-oi/combo.png",
      "show_on_home": true,
      "type": 1
    }
  ];
  CategoryViewModel() {
    _categoryDAO = CategoryDAO();
  }
  Future getCategories() async {
    try {
      setState(ViewStatus.Loading);
      // categories = await _categoryDAO?.getCategories(params: params);
      categories = categoryList.map((e) => CategoryDTO.fromJson(e)).toList();
      setState(ViewStatus.Completed);
    } catch (e) {
      print(e);
      setState(ViewStatus.Error);
    }
  }
}
