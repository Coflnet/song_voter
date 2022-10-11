import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:song_voter/app/modules/home/home.dart';
import 'package:song_voter/app/modules/party/party_overview.dart';
import 'package:song_voter/app/modules/settings/settings.dart';

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

  void navigate(Widget target, int targetIndex) {
    Transition? transition;
    if (_selectedIndex == null) {
      transition = Transition.native;
    } else if (targetIndex > _selectedIndex!) {
      transition = Transition.leftToRight;
    } else {
      transition = Transition.rightToLeft;
    }
    Get.to(target, transition: transition);
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
              navigate(HomeWidget(), index);
              break;
            case 1:
              navigate(PartyOverviewWidget(), index);
              break;
            case 2:
              navigate(SettingsView(), index);
              break;
          }
        })
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "<value>",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.celebration_outlined),
          label: "<value>",
        ),
        const BottomNavigationBarItem(
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
