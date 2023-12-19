import 'package:fine/Accessories/index.dart';
import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:fine/ViewModel/order_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/shimmer_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class StationPickerScreen extends StatefulWidget {
  const StationPickerScreen({super.key});

  @override
  State<StationPickerScreen> createState() => _StationPickerScreenState();
}

class _StationPickerScreenState extends State<StationPickerScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  // Future<void> _refresh() async {
  //   Get.find<OrderViewModel>().getListStation();
  // }

  OrderViewModel? _orderViewModel;
  @override
  void initState() {
    super.initState();
    // _orderViewModel = Get.find<OrderViewModel>();
    // if (_checkCall == false) {
    //   Get.find<OrderViewModel>().getListStation();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FineTheme.palettes.shades100,
      appBar: DefaultAppBar(title: "Chọn nơi nhận"),
      body: ScopedModel(
        model: Get.find<OrderViewModel>(),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // _buildSearchVoucher(),
              ScopedModelDescendant<OrderViewModel>(
                builder: (context, child, model) {
                  return ValueListenableBuilder(
                    valueListenable: model.notifierTimeRemaining,
                    builder: (context, value, child) {
                      if (value == 0) {
                        return const SizedBox.shrink();
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Bạn có ",
                            style: FineTheme.typograhpy.subtitle1.copyWith(
                              color: FineTheme.palettes.neutral500,
                            ),
                          ),
                          Text(
                            "${value} ",
                            style: FineTheme.typograhpy.subtitle1
                                .copyWith(color: FineTheme.palettes.primary100),
                          ),
                          Text(
                            "giây để hoàn thành đơn hàng",
                            style: FineTheme.typograhpy.subtitle1.copyWith(
                              color: FineTheme.palettes.neutral500,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                child: Text(
                  'Các station có đủ box cho bạn nè',
                  style: FineTheme.typograhpy.subtitle1,
                ),
              ),

              _buildListStation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListStation() {
    return ScopedModelDescendant<OrderViewModel>(
      builder: (context, child, model) {
        if (model.status == ViewStatus.Loading) {
          return _buildLoading();
        }
        if (model.status == ViewStatus.Error ||
            model.stationList == null &&
                model.stationList!.isEmpty &&
                model.stationList?.length == 0) {
          return Center(
            child: Text(
              model.msg ?? "Hiện tại không có station khả dụng",
              style: FineTheme.typograhpy.subtitle1
                  .copyWith(color: FineTheme.palettes.primary100),
            ),
          );
        }
        return Flexible(
          child: ListView.separated(
            itemBuilder: (context, index) {
              if (index == model.stationList!.length) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Bạn đã xem hết rồi đấy 🐱‍👓",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                );
              }
              final station = model.stationList!.elementAt(index);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: stationCard(station),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) =>
                MySeparator(color: FineTheme.palettes.neutral500),
            itemCount: model.stationList!.length,
          ),
        );
      },
    );
  }

  Widget stationCard(StationDTO? dto) {
    bool isApplied = false;
    final stationInCart = Get.find<OrderViewModel>().orderDTO!.stationDTO;
    if (stationInCart == null) {
      isApplied = false;
    } else {
      isApplied = stationInCart.id == dto!.id;
    }
    return InkWell(
      onTap: () {
        if (!isApplied) {
          Get.find<OrderViewModel>().addStationToCart(dto);
        }
        Get.back();
      },
      child: SizedBox(
        height: 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: SvgPicture.asset(
                "assets/icons/box_icon.svg",
                color: isApplied
                    ? FineTheme.palettes.primary100
                    : FineTheme.palettes.shades200,
                height: 30,
                width: 30,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 16),
                    width: Get.width,
                    child: Text(
                      'Giao đến',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          fontStyle: FontStyle.normal,
                          color: isApplied
                              ? FineTheme.palettes.primary100
                              : FineTheme.palettes.neutral600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 16),
                    width: Get.width,
                    child: Text(
                      dto!.name!,
                      style: isApplied
                          ? FineTheme.typograhpy.subtitle2
                              .copyWith(color: FineTheme.palettes.neutral600)
                          : FineTheme.typograhpy.subtitle2,
                    ),
                  )
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Chọn',
                  style: FineTheme.typograhpy.subtitle2
                      .copyWith(color: FineTheme.palettes.primary100),
                ),
                const Icon(
                  Icons.add_circle_outline,
                  size: 25,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Flexible(
      child: ListView.separated(
        itemCount: 10,
        itemBuilder: (context, index) => Container(
          height: 140,
          width: Get.width,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AspectRatio(
                  aspectRatio: 1, child: ShimmerBlock(width: 140, height: 140)),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBlock(width: 120, height: 20),
                    SizedBox(height: 4),
                    ShimmerBlock(width: 175, height: 20),
                    SizedBox(height: 8),
                    Flexible(child: Container()),
                    Row(
                      children: [
                        ShimmerBlock(width: 50, height: 20, borderRadius: 16),
                        SizedBox(width: 8),
                        ShimmerBlock(width: 50, height: 20, borderRadius: 16),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}
