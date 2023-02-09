import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:winds_of_war/battle.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/theme/colors.dart';
import 'package:winds_of_war/util/extensions.dart';
import 'package:winds_of_war/widgets/option_button.dart';

class CityMenu extends StatelessWidget {
  const CityMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final GameManager manager = BonfireInjector.instance.get();
    return Scaffold(
      body: Column(
            children: [
              OptionButton(text: 'enter city', onPressed: () {}),
              OptionButton(text: 'recruit', onPressed: () {
                manager.addUnit(GoblinUnit());
                manager.addUnit(GoblinUnit());
              }),
              OptionButton(text: 'exit', onPressed: () => context.backTo()),
            ],
          ),
    );
  }
}

class CityWarMenu extends StatelessWidget {
  final Party cityParty;
  const CityWarMenu({super.key, required this.cityParty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
            children: [
              OptionButton(text: 'attack city', onPressed: () {
                //context.goTo(Battle(troop: cityParty));
              }),
              OptionButton(text: 'exit', onPressed: () => context.backTo()),
            ],
          ),
    );
  }
}