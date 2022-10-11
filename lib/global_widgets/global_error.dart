import 'package:flutter/material.dart';
import 'package:song_voter/global_widgets/base.dart';

class GlobalErrorWidget extends StatelessWidget {
  final String headline;

  final String? subHeadline;

  const GlobalErrorWidget({Key? key, required this.headline, this.subHeadline})
      : super(key: key);

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
            if (subHeadline != null)
              Text(
                subHeadline!,
                style: theme.headline4!.copyWith(color: Colors.red),
              )
          ],
        ),
      ),
    );
  }
}
