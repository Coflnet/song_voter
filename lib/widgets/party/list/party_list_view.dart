import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:song_voter/models/party.dart';
import 'package:song_voter/utils/route_utils.dart';
import 'package:song_voter/widgets/base/base.dart';
import 'package:song_voter/widgets/party/detail/party_detail_view.dart';
import 'package:song_voter/widgets/party/list/party_list_controller.dart';

class PartyListView extends GetView<PartyListController> {
  void _handleTap(Party party) {
    Get.toNamed(Routes.partyDetail, arguments: {party: party});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Base(
      showNavbar: true,
      navbarIndex: 1,
      child: Center(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.1,
                ),
                child: Text(
                  "Join",
                  style: theme.textTheme.headline1,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: controller.parties.length,
                itemBuilder: (BuildContext context, int index) {
                  final party = controller.parties[index];
                  return InkWell(
                    onTap: () => _handleTap(party),
                    child: Text(party.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
