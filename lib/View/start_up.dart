import 'package:fine/ViewModel/startup_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../Accessories/index.dart';

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
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bgLandingPage.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                width: Get.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image(
                    //   image: AssetImage("assets/icons/logo.png"),
                    // ),
                    // SizedBox(
                    //   width: 8,
                    // ),
                    Text(
                      "F.i.n.e".toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Fira Sans',
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  final String? title;
  const LoadingScreen({Key? key, this.title}) : super(key: key);

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
              const LoadingFine(),
              const SizedBox(height: 16),
              Text(
                this.title!,
                style: FineTheme.typograhpy.h1,
              )
            ],
          ),
        ),
      ),
    );
  }
}
