import 'package:fine/Model/DTO/index.dart';
import 'package:fine/Service/firebase_dynamic_link_services.dart';
import 'package:fine/Service/push_notification_service.dart';
import 'package:fine/View/TopUp/topUp_screen.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/blogs_viewModel.dart';
import 'package:fine/ViewModel/cart_viewModel.dart';
import 'package:fine/ViewModel/category_viewModel.dart';
import 'package:fine/ViewModel/currentTime_viewModel.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/login_viewModel.dart';
import 'package:fine/ViewModel/orderHistory_viewModel.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/ViewModel/productFilter_viewModel.dart';
import 'package:fine/ViewModel/product_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/ViewModel/topUp_viewModel.dart';
import 'package:fine/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'ViewModel/station_viewModel.dart';

Future setup() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  PushNotificationService? ps = PushNotificationService.getInstance();
  await ps!.init();
}

void createRouteBindings() async {
  Get.put(RootViewModel());
  Get.put(HomeViewModel());
  Get.put(LoginViewModel());
  Get.put(AccountViewModel());
  Get.put(OrderHistoryViewModel());
  Get.put(BlogsViewModel());
  Get.put(CategoryViewModel());
  Get.put(CartViewModel());
  Get.put(OrderViewModel());
  Get.put(PartyOrderViewModel());
  Get.put(ProductFilterViewModel());
  Get.put(ProductDetailViewModel());
  Get.put(TopUpViewModel());
  Get.put(TimeCheckViewModel());
  Get.put(StationViewModel());
}
