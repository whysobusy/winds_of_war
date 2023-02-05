import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:winds_of_war/main.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/model/enum.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/units/world/lord.dart';
import 'package:winds_of_war/util/game_sprite_sheet.dart';
import 'dart:async' as async;

import 'package:winds_of_war/util/mixins/world_npc_mixin.dart';

enum BattleSide { red, blue }

class BattleField extends GameDecoration with Lighting, ObjectCollision {
  // creator: blueSide
  final List<WorldNpcMixin> blueSide = [];
  final List<WorldNpcMixin> redSide = [];
  final List<Party> blueSideArmy = [];
  final List<Party> redSideArmy = [];

  final countDown = Timer(20);

  final FactionType creatorFaction;
  final String creatorId;
  bool battleStarted = false;
  final GameManager gameManager = BonfireInjector.instance.get();

  BattleField(Vector2 position,
      {required this.creatorFaction, required this.creatorId})
      : super.withAnimation(
          animation: GameSpriteSheet.torch(),
          position: position,
          size: Vector2.all(tileSize),
        ) {
    setupLighting(
      LightingConfig(
        radius: width * 2.5,
        blurBorder: width,
        pulseVariation: 0.1,
        color: Colors.deepOrangeAccent.withOpacity(0.2),
      ),
    );
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(width, height / 4),
            align: Vector2(0, height * 0.75),
          ),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    // print('updating');
    // if (redSideArmy.isNotEmpty && blueSideArmy.isNotEmpty && !battleStarted) {
    //   print('battleStarted');
    //   battleStarted = true;
    //   startBattle();
    // }

    if (redSide.isNotEmpty && blueSide.isNotEmpty && !battleStarted) {
      battleStarted = true;
      startBattle();
    }

    countDown.update(dt);
    if (countDown.finished) {
      redSideArmy.clear();

      if (redSideArmy.isEmpty) {
        for (final npc in redSide) {
          if (npc is Lord) {
            gameManager.addLoser(npc);
          }
          npc.removeFromParent();
        }
        endBattle();
        for (final npc in blueSide) {
          npc.isInBattle = false;
          npc.becomeVisible();
          if (npc is Lord) {
            npc.makeDecision(resumeDecision: true);
          }
        }
        removeFromParent();
      }

      if (blueSide.isEmpty) {
        for (final npc in blueSide) {
          if (npc is Lord) {
            gameManager.addLoser(npc);
          }
          npc.removeFromParent();
        }
        endBattle();
        for (final npc in redSide) {
          npc.isInBattle = false;
          npc.becomeVisible();
          if (npc is Lord) {
            npc.makeDecision(resumeDecision: true);
          }
        }
        removeFromParent();
      }
    }
    super.update(dt);
  }

  @override
  bool onCollision(GameComponent component, bool active) {
    if (component is Player) {}
    return super.onCollision(component, active);
  }

  void startBattle() {
    for (final npc in blueSide) {
      npc.becomeInvisible();
    }

    for (final npc in redSide) {
      npc.becomeInvisible();
    }
  }

  void endBattle() {
    gameManager.endBattle(creatorId);
    print("endBattle");
  }

  void enterBattle(WorldNpcMixin npc) {
    if (npc.faction == creatorFaction) {
      blueSide.add(npc);
      blueSideArmy.add(npc.party);
    } else {
      redSide.add(npc);
      blueSideArmy.add(npc.party);
    }

    if(battleStarted) {
      npc.becomeInvisible();
    }
  }
}
