import 'package:fine/View/Home/HomeCategory.dart';
import 'package:fine/ViewModel/category_viewModel.dart';
import 'package:fine/ViewModel/login_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

Future setup() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void createRouteBindings() async {
  Get.put(RootViewModel());
  Get.put(LoginViewModel());
  Get.put(HomeCategory());
  Get.put(CategoryViewModel());
}
