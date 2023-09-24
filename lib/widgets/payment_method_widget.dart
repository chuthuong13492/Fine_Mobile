import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'button_widget.dart';

class PaymentMethodWidgets extends StatelessWidget {
  const PaymentMethodWidgets({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phương thức nạp tiền',
              style: FineTheme.typograhpy.h1.copyWith(
                fontSize: 14,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 28,
                  width: 45,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/icons/visa.png'),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Text(
                  '. . . .  . . . .  . . . .  1235',
                  style: FineTheme.typograhpy.h1.copyWith(
                    fontSize: 14,
                  ),
                ),
                const Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_drop_down),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 6,
            ),
            const Divider(),
            const SizedBox(
              height: 50,
            ),
            // Text(
            //   'Promo Code',
            // ),
            // const SizedBox(
            //   height: 8,
            // ),
            // Container(
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: 10,
            //   ),
            //   decoration: BoxDecoration(
            //     border: Border.all(color: FineTheme.palettes.primary100),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: TextField(
            //     autocorrect: false,
            //     decoration: InputDecoration(
            //         border: InputBorder.none,
            //         hintText: 'Enter Your Promo Code',
            //         hintStyle: FineTheme.typograhpy.h1.copyWith(
            //           fontSize: 12,
            //           color: FineTheme.palettes.neutral500,
            //         )),
            //   ),
            // ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Tóm tắt thanh toán',
              style: FineTheme.typograhpy.h1.copyWith(fontSize: 14),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nạp tiền',
                  style: FineTheme.typograhpy.h1.copyWith(
                      fontSize: 12, color: FineTheme.palettes.neutral500),
                ),
                Text(
                  'Rp 100.000',
                  style: FineTheme.typograhpy.h1.copyWith(fontSize: 14),
                )
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Admin Fee',
                  style: FineTheme.typograhpy.h1.copyWith(
                      fontSize: 12, color: FineTheme.palettes.neutral500),
                ),
                Text(
                  'Rp 1.500',
                  style: FineTheme.typograhpy.h1.copyWith(fontSize: 14),
                )
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: FineTheme.typograhpy.h1.copyWith(
                      fontSize: 14, color: FineTheme.palettes.primary100),
                ),
                Text(
                  'Rp 101.500',
                  style: FineTheme.typograhpy.h1.copyWith(
                    fontSize: 14,
                    color: FineTheme.palettes.primary100,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                // Get.offAllNamed(Routes.TRANSACTION_SUCCESS);
              },
              child: const ButtonWidgets(
                label: 'Top Up Now',
              ),
            )
          ],
        ),
      ),
    );
  }
}
