import 'package:bonfire/bonfire.dart';
import 'package:winds_of_war/main.dart';
import 'package:winds_of_war/model/enum.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/npc/battle/goblin.dart';

abstract class SpawnPoint extends GameDecoration {
  final Party troop;
  SpawnPoint(Vector2 position, Vector2 size, {required this.troop})
      : super(
          position: position,
          size: size,
        );

  @override
  Future<void> onLoad() {
    spawn();
    return super.onLoad();
  }

  void spawn();
}

class EnemySpawnPoint extends SpawnPoint {
  EnemySpawnPoint(Vector2 position, Vector2 size, Party troop)
      : super(
          troop: troop,
          position,
          size,
        );

  @override
  void spawn() {
    for (final unit in troop.units) {
      gameRef.add(unit.toSprite(BattleType.enemy,
          Vector2(position.x + tileSize, position.y + tileSize)));
    }
  }
}

class AllySpawnPoint extends SpawnPoint {
  AllySpawnPoint(Vector2 position, Vector2 size, Party troop)
      : super(
          troop: troop,
          position,
          size,
        );

  @override
  void spawn() {
    for (final unit in troop.units) {
      gameRef.add(unit.toSprite(BattleType.ally,
          Vector2(position.x + tileSize, position.y + tileSize)));
    }
  }
}
