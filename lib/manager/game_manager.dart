import 'dart:math';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:winds_of_war/decoration/city.dart';
import 'package:winds_of_war/main.dart';
import 'package:winds_of_war/model/enum.dart';
import 'package:winds_of_war/model/faction.dart';
import 'package:winds_of_war/model/player_info.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/npc/world/battle_field.dart';
import 'package:winds_of_war/npc/world/lord.dart';
import 'package:winds_of_war/player/player_world.dart';
import 'package:winds_of_war/util/mixins/world_npc_mixin.dart';
import 'package:winds_of_war/util/world_timer.dart';

enum GameState { playing, pause }

class GameManager extends GameComponent {
  final Map<CityName, City?> cityMap = {CityName.none: null};
  final Map<LordName, Lord> lordMap = {};
  final Map<LordName, Lord> lordRestingMap = {};
  final List<Lord> _loserLord = [];
  final Map<LordName, List<Lord>> _followingLords = {};
  late final WorldTimer timer;
  final uuid = Uuid();

  final factionInfoMap = Faction.getFactionMap();

  GameManager() {
    timer = WorldTimer(
        onDay: () {
          print("day: " + timer.day.toString());
        },
        onWeek: updateMap,
        onMonth: updateFaction);
  }

  void initGame() {
    debugPrint("init game");
    updateMap();
  }

  void clearGame() {}

  void updateFaction() {
    for (final faction in factionInfoMap.values) {
      faction.makeDecision();
    }
  }

  void updateMap() {
    debugPrint("update map");
    print("update");
    respawnLord();
    for (final cityName in cityMap.keys) {
      if (cityName != CityName.none) {
        cityMap[cityName]!.spawnTroops();
      }
    }

    for (final lordName in lordMap.keys) {
      final lord = lordMap[lordName]!;
      if (!lord.isInBattle &&
          lord.action != LordAction.rally &&
          lord.action != LordAction.attackCity) {
        if (false) {
          lordMap[lordName]!.makeDecision(decision: LordAction.rally);
        } else {
          lordMap[lordName]!.makeDecision();
        }
      }
    }

    for (final faction in factionInfoMap.keys) {
      factionInfoMap[faction]!.makeDecision();
    }
  }

  void addLoser(Lord lord) {
    unregisterLord(lord);
    _loserLord.add(lord);
  }

  void addFollowLord(LordName leaderName, Lord lord) {
    unregisterLord(lord);
    if (_followingLords.containsKey(leaderName)) {
      _followingLords[leaderName]!.add(lord);
    } else {
      _followingLords[leaderName] = [lord];
    }
  }

  void respawnLord() {
    print('respawn');
    for (final lord in _loserLord) {
      final respawnPosition = lord.manor == CityName.none
          ? nearestFriendCity(lord.position, lord.faction)[1] as Vector2
          : cityMap[lord.manor]!.position;
      final newLord = Lord(
          position: respawnPosition,
          factionType: lord.faction,
          name: lord.name,
          manor: lord.manor,
          party: lord.party);

      gameRef.add(newLord);
      registerLord(newLord);

      if (_followingLords.containsKey(lord.name)) {
        for (final followingLord in _followingLords[lord.name]!) {
          final respawnPosition = followingLord.manor == CityName.none
              ? nearestFriendCity(
                  followingLord.position, followingLord.faction)[1] as Vector2
              : cityMap[followingLord.manor]!.position;
          final newFollowLord = Lord(
              position: respawnPosition,
              factionType: followingLord.faction,
              name: followingLord.name,
              manor: followingLord.manor,
              party: followingLord.party);

          gameRef.add(newFollowLord);
          registerLord(newFollowLord);
        }
      }
      _followingLords.remove(lord.name);
    }
    _loserLord.clear();
  }

  void assginId(WorldNpcMixin npc) {
    npc.id = uuid.v1();
  }

  void registerCity(City city) {
    cityMap[city.name] = city;
  }

  void registerLord(Lord lord) {
    assginId(lord);
    lordMap[lord.name] = lord;
  }

  void unregisterLord(Lord lord) {
    lordMap.remove(lord.name);
  }

  List nearestFriendCity(Vector2 currentPosition, FactionType factionType) {
    final faction = factionInfoMap[factionType];
    double minDist = 9999;
    Vector2? nearestLoction;
    CityName nearestCity = CityName.none;
    for (final cityName in faction!.cities) {
      final cityPosition = cityMap[cityName]!.position;
      final dist = currentPosition.distanceTo(cityPosition);
      if (dist < minDist) {
        minDist = dist;
        nearestLoction = cityPosition;
        nearestCity = cityName;
      }
    }
    return [nearestCity, nearestLoction ?? currentPosition];
  }

  Vector2 getCityPosition(CityName cityName) {
    return cityMap[cityName]!.position;
  }

  void pauseGame() {
    gameRef.pauseEngine();
  }

  void resumeGame() {
    gameRef.resumeEngine();
  }

  void save() {
    print(gameRef.visibleComponentsByType<WorldNpcMixin>().first.position);
  }

  final _debugInfo = PlayerInfo(
      faction: FactionType.death,
      statData: StatData(attack: 30, defence: 30, life: 100),
      party: Party(units: [GoblinUnit()]));

  StatData getPlayerStatData() {
    return (gameRef.player! as PlayerWorld).info.statData;
  }

  PlayerInfo getPlayerInitInfo() {
    return _debugInfo;
  }

  void playerEnterBattle() {
    pauseGame();
  }

  void playerEnterMenu() {
    pauseGame();
  }

  void increaseLevel({int ammount = 1}) =>
      (gameRef.player! as PlayerWorld).info.increaseLevel(ammount: ammount);

  void increaseExp({int ammount = 1}) =>
      (gameRef.player! as PlayerWorld).info.increaseExp(ammount: ammount);

  void changeStat(StatData ammount) =>
      (gameRef.player! as PlayerWorld).info.changeStat(ammount);

  void addUnit(Unit unit) =>
      (gameRef.player! as PlayerWorld).info.addUnit(unit);

  void removeUnit(Unit unit) =>
      (gameRef.player! as PlayerWorld).info.removeUnit(unit);

  // battle
  Map<String, BattleField> battleField = {};

  void endBattle(String id) {
    battleField[id]!.removeFromParent();
    battleField.remove(id);
  }

  void createBattle(
      String id1, String id2, WorldNpcMixin npc1, WorldNpcMixin npc2) {
    final id = id1 + id2;
    final battle = BattleField(npc1.position,
        blueSideFaction: npc1.faction, redSideFactoin: npc2.faction, id: id);
    battleField[id] = battle;
    battle.enterBattle(npc1);
    battle.enterBattle(npc2);
    battle.startBattle();
    gameRef.add(battle);
  }

  void createCityBattle(String lordId, City city, Lord attackLeader) {
    final battle = BattleField(city.position,
        blueSideFaction: attackLeader.faction,
        redSideFactoin: city.faction,
        id: lordId);
    battleField[lordId] = battle;

    battle.enterBattleSige(attackLeader);
    battle.enterBattleCity(city);
    battle.startBattle();
    gameRef.add(battle);
  }

  void joinBattle(String battleId, WorldNpcMixin npc) {
    battleField[battleId]!.enterBattle(npc);
  }

  // Factoin
  // Relation relation(FactionType a, FactionType b) {
  //   if (a == b || isFriend(a, b)) {
  //     return Relation.ally;
  //   } else if (isEnemy(a, b)) {
  //     return Relation.atWar;
  //   } else {
  //     return Relation.neutral;
  //   }
  // }

  bool isEnemy(WorldObjectMixin origin, WorldObjectMixin target) {
    if (target is WorldNpcMixin) {
      return factionInfoMap[origin.faction]!.isAtWar.contains(target.faction);
    } else if (target is WorldBattleMixin) {
      return factionInfoMap[origin.faction]!
              .isAtWar
              .contains(target.blueSideFaction) ||
          factionInfoMap[origin.faction]!
              .isAtWar
              .contains(target.redSideFactoin);
    } else {
      return false;
    }
  }
}
