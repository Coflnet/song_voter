import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/route_manager.dart';
import 'package:song_voter/app/data/models/party.dart';
import 'package:song_voter/app/modules/party/party_detail.dart';
import 'package:song_voter/global_widgets/base.dart';

class PartyListWidget extends StatefulWidget {
  State<StatefulWidget> createState() => _PartyListWidgetState();
}

class _PartyListWidgetState extends State<PartyListWidget> {
  late List<Party> _parties;

  @override
  initState() {
    super.initState();
    _parties = List.empty();

    _loadParties();
  }

  Future _loadParties() async {
    final List<Party> parties = [];

    setState(() => _parties = parties);
  }

  void _handleTap(Party party) {
    Get.to(PartyDetailWidget(party: party));
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
                itemCount: _parties.length,
                itemBuilder: (BuildContext context, int index) {
                  final party = _parties[index];
                  return InkWell(
                    onTap: () => _handleTap(party),
                    child: Container(
                      child: Text(party.name),
                    ),
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
