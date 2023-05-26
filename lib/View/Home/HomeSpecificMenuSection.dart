import 'package:cached_network_image/cached_network_image.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:fine/widgets/cache_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class HomeSpecifiHomeSection extends StatefulWidget {
  const HomeSpecifiHomeSection({super.key});

  @override
  State<HomeSpecifiHomeSection> createState() => _HomeSpecifiHomeSectionState();
}

class _HomeSpecifiHomeSectionState extends State<HomeSpecifiHomeSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.only(
        top: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(
              'Menu tăng đề kháng',
              style:
                  FineTheme.typograhpy.buttonLg.copyWith(color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(
              "Áp dụng từ 2 voucher mỗi đơn",
              style: FineTheme.typograhpy.caption2,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            width: Get.width,
            height: 270,
            child: ListView.separated(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    // height: 270,
                    width: 188,
                    decoration: BoxDecoration(
                      color: FineTheme.palettes.shades100,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 188,
                            height: 206,
                            decoration: BoxDecoration(
                              color: FineTheme.palettes.shades100,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(8),
                              ),
                              image: const DecorationImage(
                                image: AssetImage(
                                  "assets/images/menu.png",
                                ),
                                fit: BoxFit.fill,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: FineTheme.palettes.shades200
                                      .withOpacity(0.1),
                                  offset: const Offset(
                                    0.0,
                                    10.0,
                                  ),
                                  blurRadius: 20.0,
                                  spreadRadius: -2.0,
                                ), //BoxShadow
                                BoxShadow(
                                  color: FineTheme.palettes.shades200
                                      .withOpacity(0.05),
                                  offset: const Offset(
                                    -5.0,
                                    -20.0,
                                  ),
                                  blurRadius: 10.0,
                                  spreadRadius: -2.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 120),
                          child: SizedBox(
                            width: 188,
                            height: 40,
                            child: Center(
                              child: Container(
                                width: 120,
                                child: Text(
                                  "Mì trộn tóp mỡ trứng lòng đào",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 11, top: 175),
                          child: SizedBox(
                            width: 90,
                            height: 80,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: Get.width,
                                  height: 12,
                                  child: Text(
                                    "0.2km",
                                    style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                SizedBox(
                                  width: Get.width,
                                  height: 12,
                                  child: Text(
                                    "37 Xuân Thủy, phườngbjhbhjbjhbjh",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                SizedBox(
                                  width: Get.width,
                                  height: 14,
                                  child: Text(
                                    "55.000đ",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.red),
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                SizedBox(
                                    width: Get.width,
                                    height: 12,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FaIcon(
                                          Icons.star_half,
                                          color: FineTheme.palettes.primary300,
                                          size: 14,
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          "4.3",
                                          style: TextStyle(
                                            fontFamily: "Montserrat",
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          "(500+)",
                                          style: TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                              color: FineTheme
                                                  .palettes.neutral400),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          bottom: 29,
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: FineTheme.palettes.primary100,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "assets/icons/shopping-bag-02.png"),
                                          fit: BoxFit.fill)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 35,
                          child: Container(
                            width: 122,
                            height: 122,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                image: const DecorationImage(
                                    fit: BoxFit.fill,
                                    image: CachedNetworkImageProvider(
                                        "https://static.tuoitre.vn/tto/i/s626/2011/10/05/AoGOfe8y.jpg"))),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) =>
                  SizedBox(width: FineTheme.spacing.xs),
              itemCount: 4,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }
}
