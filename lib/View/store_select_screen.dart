import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/CampusDTO.dart';
import 'package:fine/ViewModel/root_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class StoreSelectScreen extends StatefulWidget {
  const StoreSelectScreen({Key? key}) : super(key: key);
  @override
  _StoreSelectScreenState createState() => _StoreSelectScreenState();
}

class _StoreSelectScreenState extends State<StoreSelectScreen> {
  @override
  void initState() {
    Get.find<RootViewModel>().getListCampus();
    super.initState();
    // _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: FineTheme.palettes.neutral100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Image(
                    image: AssetImage('assets/images/logo.png'),
                    height: 200,
                    width: 200,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  alignment: Alignment.center,
                  child: Text(
                    'CHỌN KHU VỰC ĐẶT ĐƠN',
                    style: FineTheme.typograhpy.h2.copyWith(
                        color: FineTheme.palettes.primary300,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ScopedModel(
                  model: Get.find<RootViewModel>(),
                  child: ScopedModelDescendant<RootViewModel>(
                      builder: (context, child, model) {
                    final status = model.status;
                    final stores = model.campusList;

                    if (status == ViewStatus.Loading)
                      return AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            child: Center(child: CircularProgressIndicator())),
                      );

                    if (stores == null)
                      return Center(
                        child: Text('Không có cửa khu vực nào'),
                      );

                    return Container(
                        margin: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: FineTheme.palettes.neutral300,
                                blurRadius: 6.0, // soften the shadow
                                offset: const Offset(
                                  0.0, // Move to right 10  horizontally
                                  5.0, // Move to bottom 10 Vertically
                                ),
                              )
                            ]),
                        child: Column(
                          children: stores
                              .map((store) => buildStoreSelect(store))
                              .toList(),
                        ));
                  }),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: const Text('Không có trong khu vực bạn muốn?'),
                      ),
                      Container(
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  print('Gợi ý is tapped');
                                },
                                child: Text(
                                  'Gợi ý',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: FineTheme.palettes.primary300,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                              const Text(' cho chúng mình nhé')
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Container(
            //       child: Image(
            //         image: AssetImage('assets/images/logo.png'),
            //         height: 200,
            //         width: 200,
            //       ),
            //     )
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget buildStoreSelect(CampusDTO area) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Get.find<RootViewModel>().setCurrentCampus(area);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: FineTheme.palettes.primary200,
                ),
                Text(
                  area.name!,
                  style: FineTheme.typograhpy.body2,
                )
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: FineTheme.palettes.primary200,
            )
          ],
        ),
      ),
    );
  }
}
