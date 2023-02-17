import 'package:dio/dio.dart';
import 'package:fine/Model/DTO/CategoryDTO.dart';
import 'package:fine/Model/DTO/MetaDataDTO.dart';
import 'package:fine/Utils/request.dart';
// import 'package:dio_http_cache/dio_http_cache.dart';

class CategoryDAO {
  MetaDataDTO? _metaDataDTO;

  MetaDataDTO get metaDataDTO => _metaDataDTO!;
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
  Future<List<CategoryDTO>?> getCategories({
    Map<String, dynamic>? params,
  }) async {
    // print("Params: " + params.toString());
    // Response res = await request.get(
    //   'categories',
    //   queryParameters: params,
    //   // options: buildCacheOptions(Duration(minutes: 5)),
    // );

    //final res = await Dio().get("http://api.dominos.reso.vn/api/v1/products");
    // final categories = CategoryDTO.fromJson(categoryList);
    if (categoryList != null) {
      List<CategoryDTO> list =
          categoryList.map((e) => CategoryDTO.fromJson(e)).toList();
      return list;
    }
    // metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
    return null;
  }

  set metaDataDTO(MetaDataDTO value) {
    _metaDataDTO = value;
  }
}
