import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:song_voter/widgets/base/base.dart';
import 'package:song_voter/widgets/party/create/party_create_controller.dart';

class PartyCreateView extends GetView<PartyCreateController> {
  Future _handleCreate() async {
    // TODO do everything

    // TODO show success
  }

  void onPrivateChange(bool value) {
    controller.setIsPrivate(value);
  }

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
                  Obx(() => Switch(
                        value: controller.isPrivate.value,
                        onChanged: onPrivateChange,
                      )),
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
                onPressed: _handleCreate,
                child: Text(
                  "Create",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
