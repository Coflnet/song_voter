import 'package:flutter/material.dart';
import 'package:song_voter/widgets/base.dart';

class PartyCreateWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PartyCreateWidgetState();
}

class _PartyCreateWidgetState extends State {
  bool? _private;

  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();

    _handlePrivateParty(false);
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  Future _handleCreate() async {
    final name = _nameController.value.text;

    if (_private == null) {
      //TODO show error
    }

    // TODO do everything

    // TODO show success
  }

  void _handlePrivateParty(bool value) => setState(() => _private = value);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Base(
      showNavbar: true,
      navbarIndex: 1,
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: size.width * 0.05,
                right: size.width * 0.05,
                top: size.height * 0.15,
              ),
              child: Row(
                children: [
                  Switch(
                    value: _private ?? false,
                    onChanged: _handlePrivateParty,
                  ),
                  Text(
                    "Private Party",
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: size.width * 0.05,
                right: size.width * 0.05,
              ),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: size.height * 0.2,
              ),
              child: TextButton(
                child: Text(
                  "Create",
                  style: Theme.of(context).textTheme.headline5,
                ),
                onPressed: _handleCreate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
