// import 'dart:ffi';

// import 'package:fine/Accessories/dialog.dart';
// import 'package:fine/Constant/route_constraint.dart';
// import 'package:fine/Constant/view_status.dart';
// import 'package:fine/Model/DTO/CollectionDTO.dart';
// import 'package:fine/Model/DTO/ProductDTO.dart';
// import 'package:fine/Model/DTO/index.dart';
// import 'package:fine/Utils/constrant.dart';
// import 'package:fine/Utils/format_price.dart';
// import 'package:fine/ViewModel/home_viewModel.dart';
// import 'package:fine/ViewModel/root_viewModel.dart';
// import 'package:fine/theme/FineTheme/index.dart';
// import 'package:fine/widgets/cache_image.dart';
// import 'package:fine/widgets/shimmer_block.dart';
// import 'package:fine/widgets/touchopacity.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
// import 'package:get/get.dart';
// import 'package:scoped_model/scoped_model.dart';

// class HomeCollectionSection extends StatefulWidget {
//   const HomeCollectionSection({super.key});

//   @override
//   State<HomeCollectionSection> createState() => _HomeCollectionSectionState();
// }

// class _HomeCollectionSectionState extends State<HomeCollectionSection> {
//   HomeViewModel? _homeCollectionViewModel;

//   @override
//   void initState() {
//     super.initState();
//     _homeCollectionViewModel = HomeViewModel();
//     Get.find<HomeViewModel>().getMenus();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScopedModel(
//         model: Get.find<HomeViewModel>(),
//         child: ScopedModelDescendant<HomeViewModel>(
//           builder: (context, child, model) {
//             var collections = model.homeMenu;
//             if (model.status == ViewStatus.Loading || collections == null) {
//               return _buildLoading();
//             }
//             return Container(
//               padding: const EdgeInsets.only(left: 16, right: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Bộ Sưu Tập',
//                     style:
//                         FineTheme.typograhpy.h2.copyWith(color: Colors.black),
//                   ),
//                   const SizedBox(
//                     height: 8,
//                   ),
//                   Column(
//                     children: collections
//                         // .where((element) =>
//                         //     element.isActive == true ||
//                         //     element.products!.isNotEmpty)
//                         .where((element) =>
//                             element.productInMenus!
//                                 .where((e) => e.isActive == true)
//                                 .isNotEmpty &&
//                             element.isActive == true)
//                         .map(
//                           (c) => Container(
//                               margin: const EdgeInsets.only(
//                                   bottom: 8, left: 12, right: 12),
//                               padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
//                               decoration: BoxDecoration(
//                                   color: FineTheme.palettes.shades100,
//                                   borderRadius: BorderRadius.circular(8)),
//                               child: buildHomeCollection(c)),
//                         )
//                         .toList(),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ));
//   }

//   Widget buildHomeCollection(MenuDTO collection) {
//     // HomeViewModel root = HomeViewModel();
//     // root.getProductInMenu(collection.id);
//     return TouchOpacity(
//       onTap: () {
//         RootViewModel root = Get.find<RootViewModel>();
//         if (!root.isCurrentTimeSlotAvailable()) {
//           showStatusDialog("assets/images/error.png", "Opps",
//               "Hiện tại khung giờ bạn chọn đã chốt đơn. Bạn vui lòng xem khung giờ khác nhé 😓 ");
//         } else {
//           Get.toNamed(RoutHandler.PRODUCT_FILTER_LIST,
//               arguments: {'menu': collection.toJson()});
//         }
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     collection.menuName!,
//                     style: FineTheme.typograhpy.subtitle1.copyWith(
//                         fontFamily: 'Inter',
//                         color: Get.find<RootViewModel>()
//                                 .isCurrentTimeSlotAvailable()
//                             ? FineTheme.palettes.primary300
//                             : Colors.grey),
//                   ),
//                   // collection.description != null
//                   //     ? Text(
//                   //         collection.description ?? "",
//                   //         style: FineTheme.typograhpy.buttonSm
//                   //             .copyWith(color: FineTheme.palettes.neutral600),
//                   //         maxLines: 2,
//                   //         overflow: TextOverflow.ellipsis,
//                   //       )
//                   //     : const SizedBox(
//                   //         height: 0,
//                   //       )
//                 ],
//               ),
//               Text(
//                 'Xem tất cả',
//                 // style: FineTheme.typograhpy.buttonSm
//                 //     .copyWith(color: FineTheme.palettes.primary300),
//                 style: Get.find<RootViewModel>().isCurrentTimeSlotAvailable()
//                     ? FineTheme.typograhpy.buttonSm
//                         .copyWith(color: FineTheme.palettes.primary300)
//                     : const TextStyle(color: Colors.grey),
//               )
//             ],
//           ),
//           const SizedBox(height: 8),
//           ScopedModel(
//             model: Get.find<HomeViewModel>(),
//             child: ScopedModelDescendant<HomeViewModel>(
//               builder: (context, child, model) {
//                 // model.getProductInMenu(
//                 //     collection.id); // root.getProductInMenu(collection.id);
//                 // var product = model.productList;
//                 var list = collection.productInMenus!
//                     .where((element) => element.isActive == true)
//                     .toList();
//                 return Container(
//                   width: Get.width,
//                   height: 155,
//                   child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     separatorBuilder: (context, index) =>
//                         SizedBox(width: FineTheme.spacing.xs),
//                     itemBuilder: (context, index) {
//                       var product = list[index];

//                       return Material(
//                         color: Colors.white,
//                         child: TouchOpacity(
//                           onTap: () {
//                             RootViewModel root = Get.find<RootViewModel>();
//                             // // var firstTimeSlot = root.currentStore.timeSlots?.first;
//                             if (!root.isCurrentTimeSlotAvailable()) {
//                               showStatusDialog(
//                                   "assets/images/error.png",
//                                   "Opps",
//                                   "Hiện tại khung giờ bạn chọn đã chốt đơn. Bạn vui lòng xem khung giờ khác nhé 😓 ");
//                             } else {
//                               // if (product.type == ProductType.MASTER_PRODUCT) {}
//                               // root.openProductDetail(product,
//                               //     fetchDetail: true);
//                             }
//                           },
//                           child: buildProductInCollection(product),
//                         ),
//                       );
//                     },
//                     // itemCount: collection.products!.length,
//                     itemCount: list.length,
//                   ),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Container buildProductInCollection(ProductDTO product) {
//     return Container(
//       width: 110,
//       height: 200,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             width: 110,
//             height: 110,
//             child: ColorFiltered(
//               // colorFilter: ColorFilter.mode(
//               //   Colors.transparent,
//               //   BlendMode.saturation,
//               // ),
//               colorFilter: ColorFilter.mode(
//                 Get.find<RootViewModel>().isCurrentTimeSlotAvailable()
//                     ? Colors.transparent
//                     : Colors.grey,
//                 BlendMode.saturation,
//               ),
//               child: CacheImage(
//                 imageUrl: product.imageUrl == null
//                     ? 'https://firebasestorage.googleapis.com/v0/b/finedelivery-880b6.appspot.com/o/no-image.png?alt=media&token=b3efcf6b-b4b6-498b-aad7-2009389dd908'
//                     : product.imageUrl!,
//               ),
//             ),
//           ),
//           SizedBox(height: FineTheme.spacing.xxs),
//           Text(
//             product.productName!,
//             // style: FineTheme.typograhpy.buttonSm
//             //     .copyWith(color: FineTheme.palettes.shades200),
//             style: Get.find<RootViewModel>().isCurrentTimeSlotAvailable()
//                 ? FineTheme.typograhpy.buttonSm
//                     .copyWith(color: FineTheme.palettes.shades200)
//                 : FineTheme.typograhpy.buttonSm.copyWith(
//                     color: Colors.grey,
//                   ),
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 4),
//           Container(
//             // height: 40,
//             child: Text(
//               '${formatPriceWithoutUnit(product.price!)} đ',
//               // product.type != ProductType.MASTER_PRODUCT
//               //     ? '${formatPriceWithoutUnit(product.price!)} đ'
//               //     : 'từ ${formatPriceWithoutUnit(product.minPrice! ?? product.price!)} đ',
//               style: FineTheme.typograhpy.caption1.copyWith(
//                   color: Get.find<RootViewModel>().isCurrentTimeSlotAvailable()
//                       ? FineTheme.palettes.primary300
//                       : Colors.grey),
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           // SizedBox(height: 4),
//           // Material(
//           //   child: InkWell(
//           //     onTap: () {
//           //       print("ADD TO CART");
//           //     },
//           //     child: Container(
//           //       width: kWitdthItem,
//           //       padding: EdgeInsets.all(4),
//           //       decoration: BoxDecoration(
//           //           borderRadius: BorderRadius.circular(16),
//           //           border: Border.all(color: kPrimary)),
//           //       child: Text(
//           //         "Chọn",
//           //         style: TextStyle(fontSize: 12),
//           //         textAlign: TextAlign.center,
//           //       ),
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }

// Widget _buildLoading() {
//   return Container(
//     margin: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
//     padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
//     decoration: BoxDecoration(
//       color: FineTheme.palettes.shades100,
//       borderRadius: BorderRadius.circular(8),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             ShimmerBlock(width: Get.width * 0.4, height: 30),
//             ShimmerBlock(width: Get.width * 0.2, height: 30),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.only(bottom: 8),
//           width: Get.width,
//           height: 120,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemBuilder: (context, index) {
//               return const ShimmerBlock(
//                 height: 110,
//                 width: 110,
//                 borderRadius: 16,
//               );
//             },
//             separatorBuilder: (context, index) =>
//                 SizedBox(width: FineTheme.spacing.xs),
//             itemCount: 4,
//           ),
//         ),
//       ],
//     ),
//   );
// }
