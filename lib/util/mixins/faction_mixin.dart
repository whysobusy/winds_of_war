import 'package:bonfire/bonfire.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/model/enum.dart';

mixin FactionMixin on GameComponent {
  final GameManager manager = BonfireInjector.instance.get();
  
  FactionType _faction = FactionType.none;

  FactionType get faction => _faction;

  set faction(FactionType faction) {
    _faction = faction;
  }

  bool isSameFaction(FactionMixin npc) {
    return faction == npc.faction;
  }
}