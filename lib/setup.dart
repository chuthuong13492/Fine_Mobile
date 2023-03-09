import 'package:fine/Service/push_notification_service.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/blogs_viewModel.dart';
import 'package:fine/ViewModel/category_viewModel.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:fine/ViewModel/login_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

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
  Get.put(BlogsViewModel());
  Get.put(CategoryViewModel());
}
