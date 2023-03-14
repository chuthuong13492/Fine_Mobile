import 'package:fine/Constant/view_status.dart';
import 'package:fine/Model/DTO/MenuDTO.dart';
import 'package:fine/View/product_search.dart';
import 'package:fine/ViewModel/productFilter_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/shimmer_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../Accessories/index.dart';

class ProductsFilterPage extends StatefulWidget {
  final MenuDTO? dto;
  const ProductsFilterPage({Key? key, this.dto}) : super(key: key);

  @override
  State<ProductsFilterPage> createState() => _ProductsFilterPageState();
}

class _ProductsFilterPageState extends State<ProductsFilterPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  ProductFilterViewModel? _prodFilterModel;

  Future<void> _refreshHandler() async {
    await _prodFilterModel?.getProductsWithFilter();
  }

  @override
  void initState() {
    super.initState();
    _prodFilterModel = ProductFilterViewModel(menu: widget.dto);
    _prodFilterModel?.getProductsWithFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: "Danh sách sản phẩm",
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshHandler,
        child: Column(
          children: [
            // _buildFilter(),
            _buildListProduct(),
          ],
        ),
      ),
    );
  }

  Widget _buildListProduct() {
    return ScopedModel(
      model: ProductFilterViewModel(menu: widget.dto),
      child: ScopedModelDescendant<ProductFilterViewModel>(
        builder: (context, child, model) {
          if (model.status == ViewStatus.Loading) {
            return _buildLoading();
          }

          if (model.status == ViewStatus.Error) {
            return Flexible(
              child: Center(
                child: Text(model.msg ?? "Có gì đó sai sai",
                    style: FineTheme.typograhpy.subtitle1.copyWith(
                      color: Colors.red,
                    )),
              ),
            );
          }

          return Flexible(
            child: ListView.separated(
              itemCount: widget.dto!.products!.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                if (index == widget.dto!.products!.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Bạn đã xem hết rồi đấy 🐱‍👓",
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final product = widget.dto!.products!.elementAt(index);
                return ProductSearchItem(product: product, index: index);
              },
            ),
          );
        },
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
                    const ShimmerBlock(width: 120, height: 20),
                    const SizedBox(height: 4),
                    const ShimmerBlock(width: 175, height: 20),
                    const SizedBox(height: 8),
                    Flexible(child: Container()),
                    Row(
                      children: const [
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
