import 'package:bonfire/bonfire.dart';
import 'package:equatable/equatable.dart';
import 'package:winds_of_war/model/enum.dart';
import 'package:winds_of_war/units/battle/goblin.dart';

class Party {
  final List<Unit> units;

  Party({List<Unit>? units}) : units = units ?? [];

  void addUnit(Unit unit) {
    units.add(unit);
  }

  void addAllUnit(List<Unit> unit) {
    units.addAll(unit);
  }

  void removeUnit(Unit unit) {
    units.remove(unit);
  }
}

enum BattleType { enemy, ally }

class StatData {
  double attack;
  double defence;
  double life;

  StatData({this.attack = 0, this.defence = 0, this.life = 0});

  StatData operator +(StatData ammount) {
    attack += ammount.attack;
    defence += ammount.defence;
    life += ammount.life;
    return this;
  }
}

abstract class Unit extends Equatable{
  final UnitType type;
  final double exp;
  final StatData statData;
  final FactionType faction;
  int level = 1;

  Unit(
      {required this.type,
      required this.faction,
      required this.statData,
      this.exp = 0});

  Npc toSprite(BattleType battleType, Vector2 initPosition);

  @override
  List<Object> get props => [type];
}

class GoblinUnit extends Unit {
  GoblinUnit()
      : super(
            statData: StatData(attack: 30, defence: 30, life: 100),
            type: UnitType.goblin,
            faction: FactionType.chaos);

  @override
  Npc toSprite(BattleType battleType, Vector2 initPosition) {
    switch (battleType) {
      case BattleType.ally:
        return GoblinAlly(initPosition);
      case BattleType.enemy:
        return Goblin(initPosition);
    }
  }
}
