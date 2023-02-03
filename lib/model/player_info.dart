import 'package:winds_of_war/model/unit.dart';

import 'enum.dart';

class PlayerInfo {
  final Party party;
  StatData statData;
  final FactionType faction;
  int level = 1;
  int exp = 0;

  PlayerInfo(
      {required this.faction, required this.statData, required this.party});

  void increaseLevel({int ammount = 1}) {
    level += ammount;
  }

  void increaseExp({int ammount = 1}) {
    exp += ammount;
  }

  void changeStat(StatData ammount) {
    statData += ammount;
  }

  void addUnit(Unit unit) {
    party.addUnit(unit);
  }

  void removeUnit(Unit unit) {
    party.removeUnit(unit);
  }
}
