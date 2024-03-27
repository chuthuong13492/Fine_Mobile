import 'package:fine/Model/DTO/index.dart';
import 'package:fine/ViewModel/home_viewModel.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../Constant/view_status.dart';
import '../../Utils/constrant.dart';
import '../../theme/FineTheme/index.dart';
import '../../widgets/cache_image.dart';
import '../../widgets/touchopacity.dart';

class HomeReOrderSection extends StatefulWidget {
  const HomeReOrderSection({super.key});

  @override
  State<HomeReOrderSection> createState() => _HomeReOrderSectionState();
}

class _HomeReOrderSectionState extends State<HomeReOrderSection> {
  HomeViewModel? _homeViewModel;
  @override
  void initState() {
    super.initState();
    _homeViewModel = Get.find<HomeViewModel>();
    getReOrderList();
  }

  void getReOrderList() async {
    // await _homeViewModel?.getReOrder();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: Get.find<HomeViewModel>(),
        child: ScopedModelDescendant<HomeViewModel>(
          builder: (context, child, model) {
            final list = model.reOrderList;
            ViewStatus status = model.status;
            if (status == ViewStatus.Loading) {
              return const SizedBox.shrink();
            }
            if (list == null || list.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              color: FineTheme.palettes.primary50,
              width: Get.width,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                color: FineTheme.palettes.shades100,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Hôm nay thử lại nha!",
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: FineTheme.palettes.shades200,
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Icon(
                            Icons.chevron_right_outlined,
                            color: FineTheme.palettes.primary100,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: Get.width,
                      height: 140,
                      child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            SizedBox(width: FineTheme.spacing.m),
                        itemCount: list.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          var reOrder = list[index];
                          return Material(
                            color: Colors.white,
                            child: TouchOpacity(
                              onTap: () async {
                                await model.createReOrder(reOrder.id!);
                              },
                              child: _buildItem(reOrder),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Widget _buildItem(ReOrderDTO reORder) {
    String productName =
        reORder.listProductNameInReOrder!.map((e) => e.productName).join(', ');
    String formattedDate =
        DateFormat('dd/MM HH:mm').format(reORder.checkInDate!);
    return Container(
      width: 312,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FineTheme.palettes.primary100),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 110,
                  height: 110,
                  child: CacheStoreImage(
                    imageUrl: reORder.listProductNameInReOrder?[0].imageUrl ??
                        defaultImage,
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                    width: 46,
                    height: 13,
                    decoration: BoxDecoration(
                      color: FineTheme.palettes.primary300,
                      borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(10)),
                    ),
                    child: Text(
                      "PROMO".toUpperCase(),
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  )),
            ],
          ),
          const SizedBox(
            width: 18,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    productName,
                    style: FineTheme.typograhpy.subtitle2.copyWith(
                      color: FineTheme.palettes.shades200,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "Đặt lần cuối: ${formattedDate}",
                  style: FineTheme.typograhpy.caption1.copyWith(
                    color: FineTheme.palettes.neutral500,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
