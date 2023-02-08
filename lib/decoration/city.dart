import 'package:bonfire/bonfire.dart';
import 'package:winds_of_war/interface/city_overlay.dart';
import 'package:winds_of_war/model/enum.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/npc/world/lord.dart';
import 'package:winds_of_war/util/extensions.dart';
import 'package:winds_of_war/util/mixins/faction_mixin.dart';

enum CityState {
  siege,
  peace,
}

class City extends GameDecoration with ObjectCollision, FactionMixin {
  final List<Lord> lordList = [];
  final Party party;
  final CityName name;
  LordName owner;
  bool isInBattle = false;

  City(
      {required super.position,
      required super.size,
      required this.name,
      required this.owner,
      required FactionType faction,
      required this.party}) {
    this.faction = faction;
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
  bool onCollision(GameComponent component, bool active) {
    if (component is FactionMixin) {
      if (component is Player) {
        if (false) {
          gameRef.player!.idle();
          context.goTo(CityWarMenu(
            cityParty: party,
          ));
        } else {
          gameRef.player!.idle();
          context.goTo(CityMenu());
        }
      }
    }
    return super.onCollision(component, active);
  }

  void spawnTroops() {}

  void enterCity(Lord lord) {
    print('enter city');
    // in battle TODO
    lordList.add(lord);
  }

  void exitCity(Lord lord) {
    lordList.remove(lord);
  }
}
