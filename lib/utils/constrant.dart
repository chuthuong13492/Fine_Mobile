const String CART_TAG = "cartTag";
const int ANIMATED_BODY_MS = 500;
const phoneReg = r'^(0|\+)([0-9])+$';
const int DEFAULT_SIZE = 50;
const String defaultImage =
    "https://firebasestorage.googleapis.com/v0/b/unidelivery-fad6f.appspot.com/o/images%2Fdefault_image.png?alt=media&token=3c1cf2f4-52be-4df1-aed5-cdb5fd4990d8";

class CourseStatus {
  static const int DRAFT = 1;
  static const int PENDING = 2;
  static const int WAITING = 3;
  static const int CANCEL_NOT_ENOUGH = 4;
  static const int START = 5;
  static const int END = 6;
}

class Badge {
  static const int Fresher = 1;
  static const int Junior = 2;
  static const int Senior = 3;
}

class CertificateStatus {
  static const int Pending = 1;
  static const int Approved = 2;
  static const int Denied = 3;
}

class ProductType {
  static const int SINGLE_PRODUCT = 0;
  static const int EXTRA_PRODUCT = 5;
  static const int MASTER_PRODUCT = 6;
  static const int DETAIL_PRODUCT = 7;
  static const int COMPLEX_PRODUCT = 10;
  static const int GIFT_PRODUCT = 12;
}
