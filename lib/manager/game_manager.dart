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
import 'package:winds_of_war/units/world/battle_field.dart';
import 'package:winds_of_war/units/world/lord.dart';
import 'package:winds_of_war/util/mixins/world_npc_mixin.dart';
import 'package:winds_of_war/util/world_timer.dart';

enum GameState { playing, pause }

class GameManager extends GameComponent {
  final Map<CityName, City?> cityMap = {CityName.none : null};
  final Map<LordName, Lord> lordMap = {};
  final Map<LordName, Lord> lordRestingMap = {};
  final List<Lord> _loserLord = [];
  late final WorldTimer timer;
  final uuid = Uuid();

  final _factionInfoMap = Faction.getFactionMap();

  GameManager() {
    timer = WorldTimer(
        onDay: () {
          print("day: " + timer.day.toString());
        },
        onWeek: updateMap);
  }

  void initGame() {
    debugPrint("init game");
    updateMap();
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
      if (!lord.isInBattle) {
        lordMap[lordName]!.makeDecision();
      }
    }

    for (final faction in _factionInfoMap.keys) {
      _factionInfoMap[faction]!.makeDecision();
    }
  }

  void addLoser(Lord lord) {
    unregisterLord(lord);
    _loserLord.add(lord);
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
    final faction = _factionInfoMap[factionType];
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

  void ayaya() {
    print(this.gameRef.player);
  }

  StatData getPlayerStatData() {
    return _debugInfo.statData;
  }

  PlayerInfo getPlayerInfo() {
    return _debugInfo;
  }

  void increaseLevel({int ammount = 1}) =>
      _debugInfo.increaseLevel(ammount: ammount);

  void increaseExp({int ammount = 1}) =>
      _debugInfo.increaseExp(ammount: ammount);

  void changeStat(StatData ammount) => _debugInfo.changeStat(ammount);

  void addUnit(Unit unit) => _debugInfo.addUnit(unit);

  void removeUnit(Unit unit) => _debugInfo.removeUnit(unit);

  // battle
  Map<String, List<String>> joiner = {};
  Map<String, BattleField> battleField = {};
  void requestBattle(String creator, String follower, WorldNpcMixin npc) {
    if (joiner.containsKey(follower)) {
      debugPrint("join Battle ");
      joiner[follower]!.add(creator);
      battleField[follower]!.enterBattle(npc);
    } else {
      joiner[creator] = [creator];
      debugPrint("create Battle ");
      final battle = BattleField(
          creatorFaction: npc.faction, creatorId: creator, npc.position);
      battle.enterBattle(npc);
      battleField[creator] = battle;
      gameRef.add(battle);
    }
  }

  void endBattle(String id) {
    joiner.remove(id);
    battleField[id]!.removeFromParent();
    battleField.remove(id);
  }

  // Factoin
  Relation relation(FactionType a, FactionType b) {
    if (a == b || isFriend(a, b)) {
      return Relation.ally;
    } else if (isEnemy(a, b)) {
      return Relation.atWar;
    } else {
      return Relation.neutral;
    }
  }

  bool isFriend(FactionType a, FactionType b) {
    return _factionInfoMap[a]!.allies.contains(b);
  }

  bool isEnemy(FactionType a, FactionType b) {
    return _factionInfoMap[a]!.isAtWar.contains(b);
  }
}
