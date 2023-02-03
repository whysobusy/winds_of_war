import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:winds_of_war/battle.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/menu.dart';
import 'package:winds_of_war/model/player_info.dart';
import 'package:winds_of_war/theme/colors.dart';
import 'package:winds_of_war/util/extensions.dart';
import 'package:winds_of_war/widgets/option_button.dart';

class SettingOverlay extends StatefulWidget {
  final PlayerInfo info;
  const SettingOverlay({required this.info, super.key});

  @override
  State<SettingOverlay> createState() => _SettingOverlayState();
}

class _SettingOverlayState extends State<SettingOverlay> {
  final GameManager manager = BonfireInjector.instance.get();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.optionColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            OptionButton(text: 'op1', onPressed: () {}),
            OptionButton(text: 'op1', onPressed: () {}),
            OptionButton(text: 'print city', onPressed: () {
              print(manager.gameRef.visibleComponents());
              print(manager.cityMap.entries.first.value.lordList);
            }),
            OptionButton(text: 'load', onPressed: () {
              manager.save();
            }),
            OptionButton(text: 'menu', onPressed: () {
              manager.resumeGame();
              manager.removeFromParent();
              context.exitToMenu(Menu());
            }),
            OptionButton(text: 'exit', onPressed: () {
              manager.resumeGame();
              context.backTo();
            }),
          ],
        ),
      ),
    );
  }
}