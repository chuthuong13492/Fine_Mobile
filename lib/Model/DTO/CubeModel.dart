import 'package:fine/Model/DTO/index.dart';

class CubeDTO {
  double? height;
  double? width;
  double? length;

  CubeDTO({
    this.height,
    this.width,
    this.length,
  });
}

class CheckFixBoxRequest {
  ProductAttributes? product;
  int? quantity;

  CheckFixBoxRequest({
    this.product,
    this.quantity,
  });
}

class ProductParingResponse {
  CubeDTO? productSupplanted;
  int? quantityCanAdd;

  ProductParingResponse({
    this.productSupplanted,
    this.quantityCanAdd,
  });
}

class FixBoxResponse {
  int? quantitySuccess;
  CubeDTO? remainingLengthSpace;
  CubeDTO? remainingWidthSpace;

  FixBoxResponse({
    this.quantitySuccess,
    this.remainingLengthSpace,
    this.remainingWidthSpace,
  });
}

class SpaceInBoxMode {
  bool? success;
  CubeDTO? remainingSpaceBox;
  CubeDTO? volumeOccupied;
  CubeDTO? remainingWidthSpace;
  CubeDTO? volumeWidthOccupied;
  CubeDTO? remainingLengthSpace;
  CubeDTO? volumeLengthOccupied;

  SpaceInBoxMode({
    this.success,
    this.remainingSpaceBox,
    this.volumeOccupied,
    this.remainingWidthSpace,
    this.volumeWidthOccupied,
    this.remainingLengthSpace,
    this.volumeLengthOccupied,
  });
}
