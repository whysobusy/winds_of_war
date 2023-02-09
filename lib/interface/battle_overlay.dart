import 'package:flutter/material.dart';
import 'package:winds_of_war/battle.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/util/extensions.dart';
import 'package:winds_of_war/widgets/option_button.dart';

class BattleEncounterMenu extends StatelessWidget {
  final List<Party> blueSideArmy;
  final List<Party> redSideArmy;
  const BattleEncounterMenu({super.key, required this.blueSideArmy, required this.redSideArmy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
            children: [
              OptionButton(text: 'attack', onPressed: () {
                context.goTo(Battle(blueSideArmy: blueSideArmy, redSideArmy: redSideArmy));
              }),
              OptionButton(text: 'exit', onPressed: () => context.backTo()),
            ],
          ),
    );
  }
}