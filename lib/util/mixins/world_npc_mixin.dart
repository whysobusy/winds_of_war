import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/direction_animation.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/util/mixins/faction_mixin.dart';

mixin WorldNpcMixin on Npc, AutomaticRandomMovement, DirectionAnimation, FactionMixin {

  String id = "default";

  bool isInBattle = false;

  final Party party = Party();

  @override
  Future<void> onLoad() {
    enabledCheckIsVisible = false;
    becomeVisible();
    return super.onLoad();
  }
  

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
    return party.units.length >= npc.party.units.length;
  }


  void becomeVisible() {
    if (!isVisible) {
      isVisible = true;
      (gameRef as BonfireGame).addVisible(this);
    }
  }

  void becomeInvisible() {
    if (isVisible) {
      isVisible = false;
      (gameRef as BonfireGame).removeVisible(this);
    }
  }

}

