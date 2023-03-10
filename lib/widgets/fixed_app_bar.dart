import 'package:fine/Constant/view_status.dart';
import 'package:fine/ViewModel/account_viewModel.dart';
import 'package:fine/ViewModel/login_viewModel.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class FixedAppBar extends StatefulWidget {
  final double height;
  final ValueNotifier<double> notifier;
  const FixedAppBar({super.key, required this.height, required this.notifier});

  @override
  State<FixedAppBar> createState() => _FixedAppBarState();
}

class _FixedAppBarState extends State<FixedAppBar> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      // color: FineTheme.palettes.primary100,
      width: Get.width,
      duration: const Duration(milliseconds: 300),
      // decoration: const BoxDecoration(
      //   boxShadow: [
      //                     BoxShadow(
      //         color: Colors.grey,
      //         spreadRadius: 3,
      //         // blurRadius: 6,
      //         offset: Offset(0, 25) // changes position of shadow
      //         ),
      //   ],
      //   // color: FineTheme.palettes.primary100,
      // ),
      child: ScopedModel(
        model: RootViewModel(),
        child: ScopedModelDescendant<RootViewModel>(
          builder: (context, child, model) {
            String text = "Đợi tý đang load...";
            final status = model.status;
            if (status == ViewStatus.Error) {
              text = "Có lỗi xảy ra...";
            }
            return Container(
              color: Colors.transparent,
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ignore: avoid_unnecessary_containers
                  Container(
                    child: Text(
                      '*Địa điểm giao',
                      style: TextStyle(
                        color: FineTheme.palettes.secondary400,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Fira Sans',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Container(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // AccountViewModel root = Get.find<AccountViewModel>();
                        // root.processSignout();
                      },
                      child: Container(
                        // color: Colors.transparent,
                        alignment: Alignment.center,
                        height: 32,
                        decoration: BoxDecoration(
                          color: FineTheme.palettes.primary300,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: FineTheme.palettes.primary300
                                  .withOpacity(0.8),
                              offset: const Offset(
                                0,
                                4.0,
                              ),
                              // blurRadius: 10.0,
                              // spreadRadius: 2.0,
                            ), //BoxShadow
                          ],
                        ),
                        child: Row(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Icon(
                                Icons.arrow_drop_down,
                                color: FineTheme.palettes.primary300,
                                size: 34,
                              ),
                            ),
                            const Center(
                              // width: 400,
                              child: Text(
                                "Trường Đại Học FPT - Khu công nghệ",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    fontFamily: 'Fira Sans'),
                              ),
                            ),
                            // SizedBox(
                            //   width: 8,
                            // ),
                            const Flexible(
                              child: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                                size: 34,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
