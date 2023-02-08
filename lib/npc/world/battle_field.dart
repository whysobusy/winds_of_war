import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:winds_of_war/decoration/city.dart';
import 'package:winds_of_war/main.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/model/enum.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/npc/world/lord.dart';
import 'package:winds_of_war/util/game_sprite_sheet.dart';
import 'package:winds_of_war/util/mixins/faction_mixin.dart';
import 'dart:async' as async;

import 'package:winds_of_war/util/mixins/world_npc_mixin.dart';

enum BattleSide { red, blue }
enum BattleType { city, normal}

class BattleField extends GameDecoration
    with
        Lighting,
        ObjectCollision,
        FactionMixin,
        WorldObjectMixin,
        WorldBattleMixin {
  // creator: blueSide
  final List<WorldNpcMixin> blueSide = [];
  final List<WorldNpcMixin> redSide = [];
  final List<Party> blueSideArmy = [];
  final List<Party> redSideArmy = [];

  final countDown = Timer(20);
  bool battleStarted = false;
  final GameManager gameManager = BonfireInjector.instance.get();

  BattleField(Vector2 position,
      {required FactionType blueSideFaction,
      required FactionType redSideFactoin,
      required String id})
      : super.withAnimation(
          animation: GameSpriteSheet.torch(),
          position: position,
          size: Vector2.all(tileSize),
        ) {
    this.id = id;
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
    // if (component is WorldNpcMixin) {
    //   print('coll');
    //   gameManager.requestBattle(component.id, creatorId, component);

    //   print("blue: ");
    //   for (final npc in blueSide) {
    //     print((npc as Lord).name);
    //   }
    //   print("red: ");
    //   for (final npc in redSide) {
    //     print((npc as Lord).name);
    //   }
    // }
    return super.onCollision(component, active);
  }

  void startBattle() {
    for (final npc in blueSide) {
      npc.becomeInvisible();
    }

    for (final npc in redSide) {
      npc.becomeInvisible();
    }
    battleStarted = true;
  }

  void endBattle() {
    gameManager.endBattle(id);
    print("endBattle");
  }

  void enterBattleCity(City city) {
    city.isInBattle = true;
    redSideArmy.add(city.party);
    for (final lord in city.lordList) {
      lord.isInBattle = true;
      lord.battleId = id;
      redSide.add(lord);
      redSideArmy.add(lord.party);
    }
  }

  void enterBattleSige(Lord attackLeader) {
    attackLeader.isInBattle = true;
    attackLeader.battleId = id;

    blueSide.add(attackLeader);
    blueSideArmy.add(attackLeader.party);

    for (final party in attackLeader.followingParty) {
      blueSideArmy.add(attackLeader.party);
    }
  }

  void enterBattle(WorldNpcMixin npc) {
    npc.isInBattle = true;
    npc.battleId = id;
    if (npc.faction == blueSideFaction) {
      blueSide.add(npc);
      blueSideArmy.add(npc.party);
    } else {
      redSide.add(npc);
      redSideArmy.add(npc.party);
    }

    if (battleStarted) {
      npc.becomeInvisible();
    }
  }
}
