import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/model/enum.dart';
import 'package:winds_of_war/model/enum.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/theme/colors.dart';
import 'package:winds_of_war/util/custom_sprite_animation_widget.dart';
import 'package:winds_of_war/util/enemy_sprite_sheet.dart';
import 'package:winds_of_war/util/extensions.dart';
import 'package:winds_of_war/widgets/option_button.dart';

class PartyOverlay extends StatefulWidget {
  const PartyOverlay({super.key});

  @override
  State<PartyOverlay> createState() => _PartyOverlayState();
}

class _PartyOverlayState extends State<PartyOverlay> {
  Unit? _currentUnit;
  Map<Unit, int> unitMap = {};

  @override
  void initState() {
    _sortUnits();
    super.initState();
  }

  void _selectUnit(Unit unit) {
    setState(() {
      _currentUnit = unit;
    });
  }

  void _sortUnits() {
    final GameManager manager = BonfireInjector.instance.get();
    for (final unit in manager.getPlayerInfo().party.units) {
      unitMap[unit] = (unitMap[unit] ?? 0) + 1;
    }
    print(unitMap);
  }

  @override
  Widget build(BuildContext context) {
    final GameManager manager = BonfireInjector.instance.get();
    return Scaffold(
        backgroundColor: Colors.grey,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PartySkills(
                    unit: _currentUnit,
                  ),
                  TroopView(),
                  Company(
                    unitMap: unitMap,
                    onPressed: _selectUnit,
                  ),
                ],
              ),
              flex: 3,
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OptionButton(text: "Reset", onPressed: () {}),
                  OptionButton(
                      text: "Done",
                      onPressed: () {
                        context.backTo();
                      }),
                ],
              ),
              flex: 1,
            )
          ],
        ));
  }
}

class PartySkills extends StatelessWidget {
  final Unit? unit;
  const PartySkills({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width / 3,
      decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(20),
          color: MyColors.optionColor),
      child: unit != null
          ? Column(
              children: [
                Text(
                  "Party Skills",
                  style: TextStyle(fontSize: 40, color: Colors.white70),
                ),
                Text(unit!.statData.attack.toString()),
              ],
            )
          : Text('none'),
    );
  }
}

class TroopView extends StatefulWidget {
  const TroopView({super.key});

  @override
  State<TroopView> createState() => _TroopViewState();
}

class _TroopViewState extends State<TroopView> {
  Future<SpriteAnimation> _sprite = EnemySpriteSheet.goblinIdleRight();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width / 4,
      decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(20),
          color: MyColors.optionColor),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: CustomSpriteAnimationWidget(
              animation: _sprite,
            ),
          )
        ],
      ),
    );
  }
}

class Company extends StatelessWidget {
  final Map<Unit, int> unitMap;
  final Function(Unit) onPressed;
  const Company({required this.unitMap, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width / 3,
      decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(20),
          color: MyColors.optionColor),
      child: Column(
        children: [
          Text(
            "Company",
            style: TextStyle(fontSize: 40, color: Colors.white70),
          ),
          for (final unit in unitMap.keys)
            TextButton(
              onPressed: () {
                onPressed(unit);
              },
              child: Text(unit.type.toString() + unitMap[unit].toString()),
            ),
        ],
      ),
    );
  }
}
