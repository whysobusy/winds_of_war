import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/direction_animation.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/model/enum.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/util/mixins/faction_mixin.dart';

mixin WorldObjectMixin on FactionMixin {
  String id = "default";

  bool beatable(WorldNpcMixin attacker) {
    return true;
  }
}

mixin WorldBattleMixin on WorldObjectMixin {
  FactionType blueSideFaction = FactionType.none;
  FactionType redSideFactoin = FactionType.none;

  @override
  bool beatable(WorldNpcMixin attacker) {
    return true;
  }
}


mixin WorldNpcMixin on DirectionAnimation, WorldObjectMixin {
bool isInBattle = false;
  String? battleId;

  final Party party = Party();

  @override
  Future<void> onLoad() {
    enabledCheckIsVisible = false;
    becomeVisible();
    return super.onLoad();
  }
  
  @override
  bool beatable(WorldNpcMixin attacker) {
    return attacker.party.units.length >= party.units.length;
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

