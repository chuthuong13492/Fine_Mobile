import 'package:fine/Model/DTO/CubeModel.dart';

class BoxesResponse {
  CubeDTO? cube;
  int? maxQuantityInBox;

  BoxesResponse({
    this.cube,
    this.maxQuantityInBox,
  });
}
