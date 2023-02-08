import 'package:winds_of_war/model/enum.dart';

class Faction {
  final List<FactionType> isAtWar;
  final List<FactionType> allies;
  final FactionType factionType;
  final List<CityName> cities;
  final List<LordName> lords;

  Faction(this.factionType,
      {this.isAtWar = const [],
      this.allies = const [],
      this.lords = const [],
      this.cities = const []});

  void declareWar(Faction faction) {
    isAtWar.add(faction.factionType);
    faction.isAtWar.add(this.factionType);
  }

  void makePeace(Faction faction) {
    isAtWar.remove(faction.factionType);
    faction.isAtWar.remove(faction.factionType);
  }

  void makeAlly(Faction faction) {
    allies.add(faction.factionType);
    faction.allies.add(this.factionType);
  }

  void brekeAlly(Faction faction) {
    allies.remove(faction.factionType);
    faction.allies.remove(faction.factionType);
  }

  void addLord(LordName lordName) {
    lords.add(lordName);
  }

  void removeLord(LordName lordName) {
    lords.remove(lordName);
  }

  void addCity(CityName cityName) {
    cities.add(cityName);
  }

  void removeCity(CityName cityName) {
    cities.remove(cityName);
  }

  void makeDecision() {}

  static Map<FactionType, Faction> getFactionMap() {
    return {
      FactionType.chaos:
          Faction(FactionType.chaos, isAtWar: [FactionType.order], lords: [LordName.riven, LordName.yasuo], cities: [CityName.cityB]),
      FactionType.order:
          Faction(FactionType.order, isAtWar: [FactionType.chaos], lords: [LordName.gwen], cities: [CityName.cityA]),
      FactionType.death:
          Faction(FactionType.death, isAtWar: [FactionType.life]),
      FactionType.life: Faction(FactionType.life, isAtWar: [FactionType.death]),
      FactionType.might:
          Faction(FactionType.might, isAtWar: [FactionType.nature]),
      FactionType.nature:
          Faction(FactionType.nature, isAtWar: [FactionType.might]),
      FactionType.player: Faction(FactionType.player),
      FactionType.none: Faction(FactionType.none),
    };
  }
}
