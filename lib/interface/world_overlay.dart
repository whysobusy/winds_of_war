import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:winds_of_war/interface/character_overlay.dart';
import 'package:winds_of_war/interface/party_overlay.dart';
import 'package:winds_of_war/interface/setting_overlay.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/theme/colors.dart';
import 'package:winds_of_war/util/extensions.dart';
import 'package:winds_of_war/widgets/option_button.dart';
import 'package:winds_of_war/winds_of_war.dart';

class WorldOverlay extends StatefulWidget {
  const WorldOverlay({super.key});

  @override
  State<WorldOverlay> createState() => _WorldOverlayState();
}

class _WorldOverlayState extends State<WorldOverlay> {
  late GameManager _gameManager;

  @override
  void initState() {
    _gameManager = BonfireInjector.instance.get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                  color: MyColors.optionColor),
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OptionButton(
                      text: "Inventory",
                      onPressed: () {
                        context.goTo(SettingOverlay(
                          info: _gameManager.getPlayerInitInfo(),
                        ));
                      }),
                  OptionButton(
                      text: "Character",
                      onPressed: () {
                        context.goTo(CharacterOverlay(
                        ));
                      }),
                  OptionButton(
                      text: "Party",
                      onPressed: () {
                        context.goTo(PartyOverlay(
                          
                        ));
                      }),
                  OptionButton(text: "setting", onPressed: () {
                    _gameManager.playerEnterMenu();
                    context.goTo(SettingOverlay(
                          info: _gameManager.getPlayerInitInfo(),
                        ));
                  }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
