import 'dart:math';

import 'package:bonfire/bonfire.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:winds_of_war/interface/knight_interface.dart';
import 'package:winds_of_war/main.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/model/player_info.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/player/knight.dart';
import 'package:winds_of_war/npc/battle/imp.dart';
import 'package:winds_of_war/npc/battle/mini_boss.dart';
import 'package:winds_of_war/npc/battle/spawn_point.dart';
import 'package:winds_of_war/util/dialogs.dart';
import 'package:winds_of_war/util/extensions.dart';
import 'package:winds_of_war/util/sounds.dart';
import 'package:winds_of_war/winds_of_war.dart';

import 'npc/battle/goblin.dart';

class Battle extends StatefulWidget {
  static bool useJoystick = false;
  final List<Party> blueSideArmy;
  final List<Party> redSideArmy;
  const Battle({required this.blueSideArmy, required this.redSideArmy, Key? key}) : super(key: key);

  @override
  _BattleState createState() => _BattleState();
}

class _BattleState extends State<Battle> implements GameListener {
  bool showGameOver = false;

  late GameController _controller;
  late GameManager _gameManager;

  @override
  void initState() {
    _controller = GameController()..addListener(this);
    //Sounds.playBackgroundSound();
    _gameManager = BonfireInjector.instance.get();
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
    if (!Battle.useJoystick) {
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
        gameController: _controller,
        joystick: joystick,
        player: Knight(
          Vector2(2 * tileSize, 3 * tileSize),
          _gameManager.getPlayerStatData()
        ),
        map: WorldMapByTiled(
          'tiled/map_battle.json',
          forceTileSize: Vector2(tileSize, tileSize),
          objectsBuilder: {
            'enemy_spawn_point': (p) => EnemySpawnPoint(p.position, p.size, widget.blueSideArmy),
            'ally_spawn_point': (p) => AllySpawnPoint(p.position, p.size, widget.redSideArmy),
            'goblin': (p) => Goblin(p.position),
            'goblin_ally': (p) => GoblinAlly(p.position),
            'imp': (p) => Imp(p.position),
            'mini_boss': (p) => MiniBoss(p.position),
          },
        ),
        interface: KnightInterface(),
        lightingColorGame: Colors.black.withOpacity(0.6),
        background: BackgroundColorGame(Colors.grey[900]!),
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
  void changeCountLiveEnemies(int count) {
    if (count == 0) {
      context.backTo();
    }
  }

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

