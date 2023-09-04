import 'package:fine/Accessories/form_item.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/ViewModel/signup_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:scoped_model/scoped_model.dart';

import '../Accessories/clip_path.dart';

class SignUp extends StatefulWidget {
  final AccountDTO? user;

  @override
  _SignUpState createState() => _SignUpState();

  SignUp({this.user});
}

class _SignUpState extends State<SignUp> {
  final form = FormGroup({
    'name': FormControl(validators: [
      Validators.required,
    ], touched: false),
    // 'ref_code': FormControl(touched: false),
  });

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: SignUpViewModel(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFD5F5FA),
        body: SafeArea(
          child: Container(
            child: ReactiveForm(
              formGroup: this.form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(16),
                      color: Colors.white,
                    ),
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HELLO SECTION
                        Text("Cho mình xin ít \"in-tư\" nhé ☺",
                            style: FineTheme.typograhpy.h1),
                        const SizedBox(height: 16),
                        FormItem(
                          "Họ Tên",
                          "vd: Nguyễn Văn A",
                          "name",
                        ),
                        // FormItem("Mã Giới Thiệu", "Nếu có", "ref_code"),

                        //SIGN UP BUTTON
                        ReactiveFormConsumer(builder: (context, form, child) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 2000),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.fromLTRB(0, 8, 0, 10),
                            child: Center(
                              child: ScopedModelDescendant<SignUpViewModel>(
                                builder: (context, child, model) =>
                                    ElevatedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                    ),
                                    backgroundColor: form.valid
                                        ? const MaterialStatePropertyAll(
                                            Color(0xFF238E9C))
                                        : const MaterialStatePropertyAll(
                                            Colors.grey),
                                  ),
                                  // shape: RoundedRectangleBorder(
                                  //   borderRadius: BorderRadius.circular(16.0),
                                  //   // side: BorderSide(color: Colors.red),
                                  // ),
                                  // color: form.valid
                                  //     ? Color(0xFF00d286)
                                  //     : Colors.grey,
                                  onPressed: () async {
                                    if (model.status == ViewStatus.Completed) {
                                      if (form.valid) {
                                        await model.signupUser(form.value);
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: model.status == ViewStatus.Loading
                                        ? const CircularProgressIndicator(
                                            backgroundColor: Color(0xFFFFFFFF))
                                        : Text(
                                            form.valid
                                                ? "Hoàn thành"
                                                : "Bạn chưa điền xong",
                                            style: FineTheme.typograhpy.h1
                                                .copyWith(color: Colors.white)),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        // BACK TO NAV SCREEN
                      ],
                    ),
                  ),
                  Container(
                    transform: Matrix4.translationValues(-50.0, 0.0, 0.0),
                    child: ClipPath(
                      clipper: TriangleClipPath(),
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    transform: Matrix4.translationValues(-100.0, -40.0, 0.0),
                    height: Get.height * 0.25,
                    // width: 250,
                    child: Image.asset(
                      'assets/images/logo.png',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
