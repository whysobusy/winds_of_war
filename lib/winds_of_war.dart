import 'dart:math';

import 'package:bonfire/bonfire.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:winds_of_war/battle.dart';
import 'package:winds_of_war/decoration/city.dart';
import 'package:winds_of_war/interface/world_overlay.dart';
import 'package:winds_of_war/main.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/model/enum.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/player/knight.dart';
import 'package:winds_of_war/player/player_world.dart';
import 'package:winds_of_war/units/world/exit_map_sensor.dart';
import 'package:winds_of_war/units/world/farmer.dart';
import 'package:winds_of_war/units/world/guard.dart';
import 'package:winds_of_war/units/world/lord.dart';
import 'package:winds_of_war/util/dialogs.dart';
import 'package:winds_of_war/util/extensions.dart';
import 'package:winds_of_war/util/sounds.dart';

class MyController extends GameController {
  final GameManager manager;

  MyController(this.manager);

  @override
  void update(double dt) {
    manager.timer.update(dt);
  }
}

class WindsOfWar extends StatefulWidget {
  static bool useJoystick = false;
  const WindsOfWar({Key? key}) : super(key: key);

  @override
  _WindsOfWarState createState() => _WindsOfWarState();
}

class _WindsOfWarState extends State<WindsOfWar> implements GameListener {
  bool showGameOver = false;

  late MyController _controller;
  late GameManager _gameManager;

  @override
  void initState() {
    _gameManager = BonfireInjector.instance.get();
    _controller = MyController(_gameManager)..addListener(this);
    //Sounds.playBackgroundSound();
    super.initState();
  }

  @override
  void dispose() {
    Sounds.stopBackgroundSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size sizeScreen = MediaQuery.of(context).size;
    tileSize = max(sizeScreen.height, sizeScreen.width) / 15;

    var joystick = Joystick(
      directional: JoystickDirectional(
        spriteBackgroundDirectional: Sprite.load('joystick_background.png'),
        spriteKnobDirectional: Sprite.load('joystick_knob.png'),
        size: 100,
        isFixed: false,
      ),
      actions: [
        JoystickAction(
          actionId: 0,
          sprite: Sprite.load('joystick_atack.png'),
          spritePressed: Sprite.load('joystick_atack_selected.png'),
          size: 80,
          margin: EdgeInsets.only(bottom: 50, right: 50),
        ),
        JoystickAction(
          actionId: 1,
          sprite: Sprite.load('joystick_atack_range.png'),
          spritePressed: Sprite.load('joystick_atack_range_selected.png'),
          size: 50,
          margin: EdgeInsets.only(bottom: 50, right: 160),
        )
      ],
    );
    if (!WindsOfWar.useJoystick) {
      joystick = Joystick(
        keyboardConfig: KeyboardConfig(
          keyboardDirectionalType: KeyboardDirectionalType.wasdAndArrows,
          acceptedKeys: [
            LogicalKeyboardKey.space,
            LogicalKeyboardKey.keyZ,
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: BonfireWidget(
        cameraConfig: CameraConfig(zoom: 0.5),
        gameController: _controller,
        joystick: joystick,
        player: PlayerWorld(
          info: _gameManager.getPlayerInfo(),
          Vector2(2 * tileSize, 3 * tileSize),
        ),
        map: WorldMapByTiled(
          'tiled/tile/norhan.json',
          forceTileSize: Vector2(tileSize, tileSize),
          objectsBuilder: {
            'lord': (p) {
              final lord = Lord(
                  position: p.position,
                  factionType: FactionType.values.byName(p.others['faction_type']),
                  name: LordName.values.byName(p.others['lord_name']),
                  manor: CityName.values.byName(p.others['manor']),
                  party: Party(units: [GoblinUnit()]));
              _gameManager.registerLord(lord);
              return lord;
            },
            'guard': (p) => Guard(p.position, (v) => _enterBattle(v, context)),
            'farmer': (p) =>
                Farmer(p.position, (v) => _enterBattle(v, context)),
            'city': (p) {
              final city = City(
                  position: p.position,
                  size: p.size,
                  name: CityName.values.byName(p.others['city_name']),
                  owner: LordName.values.byName(p.others['owner']),
                  faction: FactionType.values.byName(p.others['faction_type']),
                  party: Party(units: [GoblinUnit()]));
              _gameManager.registerCity(city);
              return city;
            }
          },
        ),
        initialActiveOverlays: ['worldOverlay'],
        overlayBuilderMap: {
          'worldOverlay': (_, game) => WorldOverlay(),
        },
        lightingColorGame: Colors.black.withOpacity(0.6),
        background: BackgroundColorGame(Colors.grey[900]!),
        components: [_gameManager],
        onReady: (value) {
          _gameManager.initGame();
        },
        progress: Container(
          color: Colors.black,
          child: Center(
            child: Text(
              "Loading...",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Normal',
                fontSize: 20.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  final Party troop = Party(units: [GoblinUnit()]);
  void _enterBattle(String value, BuildContext context) {
    context.goTo(Battle(
      troop: troop,
    ));
  }

  void _showDialogGameOver() {
    setState(() {
      showGameOver = true;
    });
    Dialogs.showGameOver(
      context,
      () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => WindsOfWar()),
          (Route<dynamic> route) => false,
        );
      },
    );
  }

  @override
  void changeCountLiveEnemies(int count) {}

  @override
  void updateGame() {
    if (_controller.player != null && _controller.player?.isDead == true) {
      if (!showGameOver) {
        showGameOver = true;
        _showDialogGameOver();
      }
    }
  }
}
