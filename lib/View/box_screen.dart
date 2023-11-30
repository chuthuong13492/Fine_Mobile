import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/index.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../Accessories/index.dart';
import '../ViewModel/station_viewModel.dart';
import '../theme/FineTheme/index.dart';

class BoxScreen extends StatefulWidget {
  final OrderDTO order;
  const BoxScreen({super.key, required this.order});

  @override
  State<BoxScreen> createState() => _BoxScreenState();
}

class _BoxScreenState extends State<BoxScreen> {
  final stationModel = Get.find<StationViewModel>();

  @override
  void initState() {
    super.initState();
    stationModel.getBoxListByStation(widget.order.stationDTO!.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: FineTheme.palettes.shades100,
      appBar: DefaultAppBar(
        title: "Danh sách tủ",
      ),
      body: ScopedModel(
        model: Get.find<StationViewModel>(),
        child: ScopedModelDescendant<StationViewModel>(
          builder: (context, child, model) {
            final list = model.boxList;
            int customSort(BoxDTO a, BoxDTO b) {
              int aNumber = int.parse(a.value!.split('_')[0]);
              int bNumber = int.parse(b.value!.split('_')[0]);
              return aNumber.compareTo(bNumber);
            }

            list?.sort(customSort);
            switch (model.status) {
              case ViewStatus.Loading:
                return const Center(
                  child: LoadingFine(),
                );
              case ViewStatus.Error:
                return Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    child: Image.asset(
                      'assets/images/error.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              case ViewStatus.Completed:
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    Center(
                      child: Text(
                        "Trạm: ${widget.order.stationDTO!.name}",
                        style: FineTheme.typograhpy.h2,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle,
                          color: FineTheme.palettes.emerald25,
                          size: 15.0,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text('Tủ của bạn',
                            style: FineTheme.typograhpy.body1.copyWith(
                                color: FineTheme.palettes.neutral900,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.all(6),
                          color: FineTheme.palettes.neutral600,
                          height: Get.height,
                          child: GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 5,
                            children: [
                              ...model.boxList!.map((box) => _buildBoxes(box))
                            ],
                          )),
                    )
                  ],
                );
              default:
                break;
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBoxes(BoxDTO box) {
    bool? isStored = false;
    for (var item in widget.order.boxesCode!) {
      if (box.value == item) {
        isStored = true;
      }
    }

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: isStored == true ? FineTheme.palettes.emerald25 : Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  '${box.value?.split('_')[0]}',
                  style: FineTheme.typograhpy.subtitle2.copyWith(
                      color: isStored == true
                          ? Colors.white
                          : FineTheme.palettes.emerald25),
                ),
                // Text(
                //   textAlign: TextAlign.center,
                //   '(${quantity})',
                //   style: FineTheme.typograhpy.subtitle3.copyWith(
                //       color: isStored == true
                //           ? Colors.white
                //           : FineTheme.palettes.emerald25),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
