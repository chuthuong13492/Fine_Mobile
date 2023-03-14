import 'package:fine/Accessories/dialog.dart';
import 'package:fine/Constant/route_constraint.dart';
import 'package:fine/Model/DAO/CampusDAO.dart';
import 'package:fine/Model/DAO/ProductDAO.dart';
import 'package:fine/Model/DTO/CartDTO.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Utils/shared_pref.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/base_model.dart';
import 'package:fine/ViewModel/blogs_viewModel.dart';
import 'package:fine/ViewModel/category_viewModel.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/login_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:get/get.dart';

class RootViewModel extends BaseModel {
  AccountDTO? user;
  CampusDTO? currentStore;
  TimeSlotDTO? selectedTimeSlot;
  List<TimeSlotDTO>? listTimeSlot;
  ProductDAO? _productDAO;
  bool changeAddress = false;

  RootViewModel() {
    _productDAO = ProductDAO();
    selectedTimeSlot = null;
  }
  Future refreshMenu() async {
    // fetchStore();
    // await Get.find<HomeViewModel>().getSuppliers();
    await Get.find<HomeViewModel>().getCollections();
    // await Get.find<OrderViewModel>().getUpSellCollections();
    // await Get.find<GiftViewModel>().getGifts();
  }

  Future startUp() async {
    await Get.find<AccountViewModel>().fetchUser();
    await Get.find<RootViewModel>().getListTimeSlot();
    await Get.find<HomeViewModel>().getCollections();
    await Get.find<CategoryViewModel>().getCategories();
    await Get.find<BlogsViewModel>().getBlogs();
  }

  Future<void> openProductDetail(ProductDTO? product,
      {showOnHome = true, fetchDetail = false}) async {
    Get.put<bool>(
      showOnHome,
      tag: "showOnHome",
    );
    try {
      if (fetchDetail) {
        showLoadingDialog();
        // CampusDTO store = await getStore();
        // product = await _productDAO.getProductDetail(
        //     product.id, store.id, selectedMenu.menuId);
        product = await _productDAO?.getProductDetail(product?.id);
      }
      await Get.toNamed(RoutHandler.PRODUCT_DETAIL, arguments: product);
      //
      hideDialog();
      await Get.delete<bool>(
        tag: "showOnHome",
      );
      notifyListeners();
    } catch (e) {
      await showErrorDialog(errorTitle: "Không tìm thấy sản phẩm");
      hideDialog();
    }
  }

  Future<void> getListTimeSlot() async {
    CampusDAO campusDAO = CampusDAO();
    listTimeSlot = await campusDAO.getTimeSlot();
    bool found = false;
    if (selectedTimeSlot == null) {
      selectedTimeSlot = listTimeSlot![0];
      for (TimeSlotDTO element in listTimeSlot!) {
        if (isTimeSlotAvailable(element)) {
          selectedTimeSlot = element;
          found = true;
          break;
        }
      }
    } else {
      for (TimeSlotDTO element in listTimeSlot!) {
        if (selectedTimeSlot?.id == element.id) {
          selectedTimeSlot = element;
          // listAvailableTimeSlots = selectedMenu.timeSlots
          //     .where((element) => isTimeSlotAvailable(element.checkoutTime))
          //     .toList();
          found = true;
          break;
        }
      }
    }
    // if (found == false) {
    //   Cart cart = await getCart();
    //   if (cart != null) {
    //     await showStatusDialog(
    //         "assets/images/global_error.png",
    //         "Khung giờ đã thay đổi",
    //         "Các sản phẩm trong giỏ hàng đã bị xóa, còn nhiều món ngon đang chờ bạn nhé");
    //     Get.find<OrderViewModel>().removeCart();
    //   }
    // } else {
    //   if (!isCurrentMenuAvailable()) {
    //     await showStatusDialog(
    //       "assets/images/global_error.png",
    //       "Đã hết giờ chốt đơn cho ${selectedMenu.menuName}",
    //       "Bạn vui lòng chọn menu khác nhé.",
    //     );
    //     await fetchStore();
    //     // remove cart
    //     Get.find<OrderViewModel>().removeCart();
    //   }
    // }
  }

  Future<void> confirmTimeSlot(TimeSlotDTO? timeSlot) async {
    if (timeSlot?.id != selectedTimeSlot?.id) {
      if (!isTimeSlotAvailable(timeSlot)) {
        showStatusDialog("assets/images/error.png", "Khung giờ đã qua rồi",
            "Hiện tại khung giờ này đã đóng vào lúc ${timeSlot?.checkoutTime}, bạn hãy xem khung giờ khác nhé 😃.");
        return;
      }
      int option = 1;
      Cart? cart = Get.find<OrderViewModel>().currentCart;
      if (cart != null) {
        option = await showOptionDialog(
            "Bạn có chắc không? Đổi khung giờ rồi là giỏ hàng bị xóa đó!!");
      }

      if (option == 1) {
        // showLoadingDialog();
        selectedTimeSlot = timeSlot;
        await Get.find<OrderViewModel>().removeCart();
        // await setStore(currentStore);
        await refreshMenu();
        // hideDialog();
        notifyListeners();
      }
    }
  }

  bool isCurrentTimeSlotAvailable() {
    final currentDate = DateTime.now();
    String currentTimeSlot = selectedTimeSlot!.checkoutTime!;
    var beanTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      double.parse(currentTimeSlot.split(':')[0]).round(),
      double.parse(currentTimeSlot.split(':')[1]).round(),
    );
    int differentTime = beanTime.difference(currentDate).inMilliseconds;
    if (differentTime <= 0) {
      return false;
    } else
      return true;
  }

  bool isTimeSlotAvailable(TimeSlotDTO? timeSlot) {
    final currentDate = DateTime.now();
    String currentTimeSlot = timeSlot!.checkoutTime!;
    var beanTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      double.parse(currentTimeSlot.split(':')[0]).round(),
      double.parse(currentTimeSlot.split(':')[1]).round(),
    );
    int differentTime = beanTime.difference(currentDate).inMilliseconds;
    if (differentTime <= 0) {
      return false;
    } else
      return true;
  }
}
