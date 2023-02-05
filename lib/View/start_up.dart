import 'package:fine/ViewModel/startup_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class StartUpView extends StatelessWidget {
  const StartUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<StartUpViewModel>(
      model: StartUpViewModel(),
      child: ScopedModelDescendant<StartUpViewModel>(
          builder: (context, child, model) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Center(
                child: Container(
                  width: 250.0,
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // LoadingBean(),
                        SizedBox(height: 16),
                        Text(
                          "Bean Ơi",
                          style: Get.theme.textTheme.headline1,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Đặt ngay chờ chi 😎',
                    style: Get.theme.textTheme.headline3,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  final String title;
  const LoadingScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // width: 250.0,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LoadingBean(),
              SizedBox(height: 16),
              Text(
                this.title,
                style: Get.theme.textTheme.headline1,
              )
            ],
          ),
        ),
      ),
    );
  }
}
