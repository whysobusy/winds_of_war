import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/theme/colors.dart';
import 'package:winds_of_war/util/extensions.dart';
import 'package:winds_of_war/widgets/option_button.dart';

class CharacterOverlay extends StatefulWidget {
  const CharacterOverlay({super.key});

  @override
  State<CharacterOverlay> createState() => _CharacterOverlayState();
}

class _CharacterOverlayState extends State<CharacterOverlay> {
  late GameManager _gameManager;

  @override
  void initState() {
    _gameManager = BonfireInjector.instance.get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.optionColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            OptionButton(
                text: 'at',
                onPressed: () {
                  _gameManager.changeStat(StatData(attack: 100));
                }),
            OptionButton(text: 'de', onPressed: () {}),
            OptionButton(text: 'life', onPressed: () {}),
            OptionButton(text: 'op1', onPressed: () {}),
            OptionButton(text: 'op1', onPressed: () {}),
            OptionButton(text: 'exit', onPressed: () => context.backTo()),
          ],
        ),
      ),
    );
  }
}
