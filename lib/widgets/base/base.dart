import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:song_voter/utils/route_utils.dart';
import 'package:song_voter/widgets/party/party_overview_view.dart';
import 'package:song_voter/widgets/settings/settings_view.dart';

class Base extends StatefulWidget {
  Base({required this.child, required this.showNavbar, this.navbarIndex});

  final Widget child;
  final bool showNavbar;
  final int? navbarIndex;

  @override
  State<StatefulWidget> createState() => _BaseState();
}

class _BaseState extends State<Base> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();

    if (widget.navbarIndex != null) _selectedIndex = widget.navbarIndex;
  }

  Widget? _bottomNavigationBar() {
    if (!widget.showNavbar) {
      return null;
    }

    if (widget.navbarIndex == null) {
      throw Exception("when showNavbar is true navbarIndex must be given");
    }

    return BottomNavigationBar(
      currentIndex: _selectedIndex!,
      showSelectedLabels: false,
      showUnselectedLabels: false, // this will be set when a new tab is tapped
      onTap: (index) => {
        setState(() {
          _selectedIndex = index;
          switch (index) {
            case 0:
              Get.toNamed(Routes.home);
              break;
            case 1:
              Get.toNamed(Routes.party);
              break;
            case 2:
              Get.toNamed(Routes.settings);
              break;
          }
        })
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "<value>",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.celebration_outlined),
          label: "<value>",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_arrow_outlined),
          label: "<value>",
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      backgroundColor: Theme.of(context).backgroundColor,
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }
}
