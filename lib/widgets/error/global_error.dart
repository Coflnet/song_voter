import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:song_voter/widgets/base/base.dart';

class GlobalErrorView extends StatelessWidget {
  final String headline = Get.arguments["title"] ?? "";
  final String subHeadline = Get.arguments["subTitle"] ?? "";

  GlobalErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Base(
      showNavbar: false,
      child: Center(
        child: Column(
          children: [
            Text(
              headline,
              style: theme.headline1!.copyWith(color: Colors.red),
            ),
            if (subHeadline.isNotEmpty)
              Text(
                subHeadline,
                style: theme.headline4!.copyWith(color: Colors.red),
              )
          ],
        ),
      ),
    );
  }
}
