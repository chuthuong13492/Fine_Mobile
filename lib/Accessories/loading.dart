import 'package:flutter/material.dart';

class LoadingFine extends StatelessWidget {
  const LoadingFine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: const [
          Image(
            width: 72,
            height: 72,
            image: AssetImage("assets/images/loading.gif"),
          ),
        ],
      ),
    );
  }
}
