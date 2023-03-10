import 'package:fine/ViewModel/productFilter_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ProductsFilterPage extends StatefulWidget {
  final Map<String, dynamic> params;
  const ProductsFilterPage({Key? key, this.params = const {}})
      : super(key: key);

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
    _prodFilterModel = ProductFilterViewModel();
    _prodFilterModel?.setParam(widget.params);
    _prodFilterModel?.getProductsWithFilter();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
