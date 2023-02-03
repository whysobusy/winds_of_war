import 'package:bonfire/bonfire.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:winds_of_war/main.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/model/enum.dart';
import 'package:winds_of_war/util/mixins/faction_mixin.dart';
import 'package:winds_of_war/util/custom_sprite_animation_widget.dart';
import 'package:winds_of_war/util/enemy_sprite_sheet.dart';
import 'package:winds_of_war/util/localization/strings_location.dart';
import 'package:winds_of_war/util/mixins/world_npc_mixin.dart';
import 'package:winds_of_war/util/npc_sprite_sheet.dart';
import 'package:winds_of_war/util/player_sprite_sheet.dart';
import 'package:winds_of_war/util/sounds.dart';

class Guard extends SimpleNpc
    with FactionMixin, AutomaticRandomMovement, WorldNpcMixin {
  final ValueChanged<String> exitMap;

  @override
  FactionType faction = FactionType.order;

  Guard(Vector2 position, this.exitMap)
      : super(
          animation: EnemySpriteSheet.bossAnimations(),
          position: position,
          size: Vector2(tileSize * 0.8, tileSize),
          speed: tileSize / 0.35,
        );

  @override
  void update(double dt) {
    super.update(dt);
    if (!isInBattle) {
      patrol(dt, speed);
    if (gameRef.player != null) {
      seeComponentType<FactionMixin>(
        radiusVision: (tileSize * 12),
        observed: (npcs) {
          for (final npc in npcs) { 
            if (manager.isEnemy(faction, npc.faction)) {
              bool move = followComponent(
                npc,
                dtUpdate,
                closeComponent: (comp) {
                  isInBattle = true;
                  if (comp is! Player) {
                    print("ai battle");
                    //manager.requestBattle(2, 1, this);
                    idle();
                  } else {

                  }
                },
              );
              if (!move) {
              }
            }
          }
        },
        notObserved: () {
          if (!isIdle) {
            idle();
          }
        },
      );
    }
    }
  }
}