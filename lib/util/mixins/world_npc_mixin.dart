import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/util/mixins/faction_mixin.dart';

mixin WorldNpcMixin on Npc, AutomaticRandomMovement, FactionMixin {

  String id = "default";

  bool isInBattle = false;

  final Party party = Party();

  // WorldManager getWorldManger() {
  //   return gameRef.componentsByType<WorldManager>().first;
  // }
  

  void patrol(double dt, double speed) {
    runRandomMovement(
          dt,
          runOnlyVisibleInCamera: false,
          speed: speed,
          maxDistance: 128,
          minDistance: 64,
        );
  }

  bool isStrongerThan(WorldNpcMixin npc) {
    return party.units.length > npc.party.units.length;
  }

}

