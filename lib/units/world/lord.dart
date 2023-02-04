import 'dart:math';

import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:uuid/uuid.dart';
import 'package:winds_of_war/main.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/model/enum.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/util/enemy_sprite_sheet.dart';
import 'package:winds_of_war/util/functions.dart';
import 'package:winds_of_war/util/mixins/faction_mixin.dart';
import 'package:winds_of_war/util/mixins/world_npc_mixin.dart';

import 'dart:math';
import 'dart:ui';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/line_path_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum LordState {
  idle,
  moving,
  patrolling,
  inCity,
  following,
  fleeing,
}

enum LordAction {
  patrolAround,
  backToManor,
  attack,
  joinMarshall,
  idle,
}

class Lord extends SimpleNpc
    with
        FactionMixin,
        AutomaticRandomMovement,
        WorldNpcMixin,
        MyMoveToPositionAlongThePath,
        ObjectCollision {
  final GameManager manager = BonfireInjector.instance.get();

  final LordName name;
  LordState _state = LordState.idle;

  LordState get state => _state;

  set state(LordState state) {
    if (state == LordState.following && _state == LordState.inCity) {
      return;
    }

    _state = state;
    print(name.toString() +
        " with state: " +
        _state.toString() +
        'with visble ' +
        isVisible.toString());
  }

  LordAction action = LordAction.idle;
  final CityName manor;
  CityName currentLocation = CityName.none;
  late Random _random;

  Lord(
      {required super.position,
      required FactionType factionType,
      required this.name,
      required this.manor,
      required Party party})
      : super(
          animation: name == LordName.gwen
              ? EnemySpriteSheet.bossAnimations()
              : EnemySpriteSheet.goblinAnimations(),
          size: Vector2(tileSize * 0.8, tileSize),
          speed: name == LordName.riven ? tileSize : tileSize * 2,
        ) {
    faction = factionType;
    this.party.addAllUnit(party.units);
    if (name == LordName.riven) {
      this.party.addUnit(GoblinUnit());
    }
    var uuid = Uuid();
    id = uuid.v1();
    setupVision(drawVision: true);

    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(
              valueByTileSize(7),
              valueByTileSize(7),
            ),
            align: Vector2(valueByTileSize(3), valueByTileSize(4)),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> onLoad() {
    enabledCheckIsVisible = false;
    _becomeVisible();
    _random = Random();
    return super.onLoad();
  }

  void myRunRandomMovement(
    double dt, {
    bool runOnlyVisibleInCamera = true,
    double speed = 20,
    int maxDistance = 50,
    int minDistance = 0,
    int timeKeepStopped = 1000,
    bool useAngle = false,
    bool debug = false,

    /// milliseconds
  }) {
    if (runOnlyVisibleInCamera && !isVisibleReduction) {
      return;
    }

    int randomX = _random.nextInt(maxDistance);
    randomX = randomX < minDistance ? minDistance : randomX;
    int randomY = _random.nextInt(maxDistance);
    randomY = randomY < minDistance ? minDistance : randomY;

    int randomNegativeX = _random.nextBool() ? -1 : 1;
    int randomNegativeY = _random.nextBool() ? -1 : 1;
    final _targetRandomMovement = position.translate(
      randomX.toDouble() * randomNegativeX,
      randomY.toDouble() * randomNegativeY,
    );

    bool canMoveX = (_targetRandomMovement.x - x).abs() > speed * dt;
    bool canMoveY = (_targetRandomMovement.y - y).abs() > speed * dt;

    bool canMoveLeft = false;
    bool canMoveRight = false;
    bool canMoveUp = false;
    bool canMoveDown = false;
    if (canMoveX) {
      if (_targetRandomMovement.x > x) {
        canMoveRight = true;
      } else {
        canMoveLeft = true;
      }
    }
    if (canMoveY) {
      if (_targetRandomMovement.y > y) {
        canMoveDown = true;
      } else {
        canMoveUp = true;
      }
    }
    bool onMove = false;
    if (useAngle) {
      if (canMoveX && canMoveY) {
        onMove = moveFromAngle(speed, angle);
      }
    } else {
      if (canMoveLeft && canMoveUp) {
        onMove = moveUpLeft(speed, speed);
      } else if (canMoveLeft && canMoveDown) {
        onMove = moveDownLeft(speed, speed);
      } else if (canMoveRight && canMoveUp) {
        onMove = moveUpRight(speed, speed);
      } else if (canMoveRight && canMoveDown) {
        onMove = moveDownRight(speed, speed);
      } else if (canMoveRight) {
        onMove = moveRight(speed);
      } else if (canMoveLeft) {
        onMove = moveLeft(speed);
      } else if (canMoveUp) {
        onMove = moveUp(speed);
      } else if (canMoveDown) {
        onMove = moveDown(speed);
      }
    }
  }

  @override
  void update(double dt) {
    if (!isVisible) {
      return;
    }

    super.update(dt);
    if (!isInBattle) {
      if (state == LordState.patrolling) {
        myPatrol(
          dt,
          maxDistance: 16,
          minDistance: 0,
          debug: LordName.gwen == name,
        );
        //patrol(dt * 20, speed);
      }
      if (state == LordState.fleeing) {
        seeComponentType<WorldNpcMixin>(
            radiusVision: (tileSize * 15),
            observed: (npcs) {
              for (final npc in npcs) {
                if (npc != this && manager.isEnemy(faction, npc.faction)) {
                  bool move = runAwayFrom(
                    npc,
                    dtUpdate,
                    closeComponent: (comp) {
                      isInBattle = true;
                      manager.requestBattle(
                          id, (comp as WorldNpcMixin).id, this);
                      idle();
                      makeDecision(action);
                    },
                    escapeComponent: (comp) {
                      print("escape");
                      idle();
                      makeDecision(action);
                    },
                  );
                  return;
                }
              }
            },
            notObserved: () {
              idle();
              makeDecision(action);
            });
      }

      if (isVisible && state != LordState.fleeing) {
        seeComponentType<WorldNpcMixin>(
          radiusVision: (tileSize * 13),
          observed: (npcs) {
            for (final npc in npcs) {
              if (npc != this && manager.isEnemy(faction, npc.faction)) {
                if (npc.distance(this) < tileSize * 9) {
                  if (isStrongerThan(npc)) {
                    if (state != LordState.following) {
                      stopMoveAlongThePath();
                      state = LordState.following;
                    }
                    print("following");
                    print(currentPath);
                    bool move = myFollowComponent(npc, dtUpdate,
                        closeComponent: (comp) {
                      isInBattle = true;
                      manager.requestBattle(
                          id, (comp as WorldNpcMixin).id, this);
                      idle();
                      makeDecision(action);
                    }, escapeComponent: (comp) {
                      print("cannot catch");
                      idle();
                      makeDecision(action);
                    }, debug: false);
                    if (!move) {
                      print("no move");
                      makeDecision(action);
                    }
                  } else {
                    if (state != LordState.fleeing) {
                      stopMoveAlongThePath();
                      state = LordState.fleeing;
                    }
                    //runAwayFrom(npc);
                  }
                } else {
                  if (state == LordState.following) {
                    print("no move");
                    idle();
                    makeDecision(action);
                  }
                }
                return;
              }
            }
          },
          notObserved: () {
            if (!isIdle) {
              idle();
            }
            print("not ob");
          },
        );
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (state != LordState.inCity) {
      super.render(canvas);
    }
  }

  void _becomeVisible() {
    if (!isVisible) {
      isVisible = true;
      (gameRef as BonfireGame).addVisible(this);
    }
  }

  void _becomeInvisible() {
    if (isVisible) {
      isVisible = false;
      (gameRef as BonfireGame).removeVisible(this);
    }
  }

  void makeDecision([LordAction? decision]) {
    if (state == LordState.inCity) {
      _leaveCity();
    }

    if (decision != null) {
      action = decision;
    } else {
      final rnd = Random();
      action = LordAction.values[rnd.nextInt(2)];
    }

    switch (action) {
      case LordAction.attack:
      case LordAction.idle:
      case LordAction.joinMarshall:
        _checkPower();
        break;
      case LordAction.patrolAround:
        // TODO
        patrolAround(position);
        break;
      case LordAction.backToManor:
        if (state != LordState.inCity) {
          backToCity();
        }
        break;
    }
  }

  // void runAwayFrom(WorldNpcMixin npc) {
  //   final info = manager.nearestFriendCity(position, faction);
  //   final cityPosition = info[1] as Vector2;
  //   final cityName = info[0] as CityName;

  //   if (position.distanceTo(this.position) <
  //       this.position.distanceTo(npc.position)) {
  //     moveToPositionAlongThePath(
  //       cityPosition,
  //       onFinish: (() => _onEnterCity((info[0] as CityName))),
  //     );
  //   }
  // }

  void _checkPower() {
    makeDecision(LordAction.backToManor);
  }

  void patrolAround(Vector2 location) {
    print('lord patorl');
    print(position);
    state = LordState.moving;

    moveToPositionAlongThePath(location, onFinish: () {
      state = LordState.patrolling;
      debugPrint("Patrolling");
    });
  }

  void backToCity() {
    print('lord city');
    state = LordState.moving;

    if (manor == CityName.none) {
      final info = manager.nearestFriendCity(position, faction);
      moveToPositionAlongThePath(
        info[1] as Vector2,
        onFinish: (() => _onEnterCity((info[0] as CityName))),
      );
    } else {
      moveToPositionAlongThePath(manager.getCityPosition(manor), onFinish: () {
        _onEnterCity(manor);
      });
    }
  }

  void _leaveCity() {
    _becomeVisible();
    state = LordState.idle;
    manager.cityMap[currentLocation]!.exitCity(this);
  }

  void _onEnterCity(CityName cityName) {
    _becomeInvisible();
    currentLocation = cityName;
    state = LordState.inCity;
    manager.cityMap[cityName]!.enterCity(this);
    print(manager.cityMap[cityName]!.position);
    print(position);
  }
}

extension Myext on Movement {
  /// This method move this component to target
  /// Need use Movement mixin.
  /// Method that bo used in [update] method.
  /// return true if moved.
  bool myFollowComponent(
    GameComponent target,
    double dt, {
    required Function(GameComponent) closeComponent,
    required Function(GameComponent) escapeComponent,
    double margin = 0,
    bool debug = false,
  }) {
    final comp = target.rectConsideringCollision;
    double centerXPlayer = comp.center.dx;
    double centerYPlayer = comp.center.dy;

    double translateX = 0;
    double translateY = 0;
    double speed = this.speed * dt;

    Rect rectToMove = rectConsideringCollision;
    if (debug) {
      print("position: " + position.toString());
      print("target Pos: " + target.position.toString());
      print((target as Lord).id == (this as Lord).id);
    }

    translateX = rectToMove.center.dx > centerXPlayer ? (-1 * speed) : speed;

    translateX = _adjustTranslate(
      translateX,
      rectToMove.center.dx,
      centerXPlayer,
    );
    translateY = rectToMove.center.dy > centerYPlayer ? (-1 * speed) : speed;
    translateY = _adjustTranslate(
      translateY,
      rectToMove.center.dy,
      centerYPlayer,
    );

    Rect rectPlayerCollision = Rect.fromLTWH(
      comp.left - margin,
      comp.top - margin,
      comp.width + (margin * 2),
      comp.height + (margin * 2),
    );

    if (rectToMove.overlaps(rectPlayerCollision)) {
      if (debug) {
        print("overlap");
        print("to move: " + rectToMove.toString());
        print("target: " + rectPlayerCollision.toString());
      }
      closeComponent(target);
      if (!isIdle) {
        idle();
      }
      return false;
    }

    translateX /= dt;
    translateY /= dt;

    print(translateY);

    if (debug) {
      print("X:" + translateX.toString());
      print("Y: " + translateY.toString());
    }
    bool moved = false;

    if (translateX > 0 && translateY > 0) {
      moved = moveDownRight(translateX, translateY);
    } else if (translateX < 0 && translateY < 0) {
      moved = moveUpLeft(translateX.abs(), translateY.abs());
    } else if (translateX > 0 && translateY < 0) {
      moved = moveUpRight(translateX, translateY.abs());
    } else if (translateX < 0 && translateY > 0) {
      moved = moveDownLeft(translateX.abs(), translateY);
    } else {
      if (translateX > 0) {
        moved = moveRight(translateX);
      } else if (translateX < 0) {
        moved = moveLeft(translateX.abs());
      }
      if (translateY > 0) {
        moved = moveDown(translateY, debug: debug);
      } else if (translateY < 0) {
        moved = moveUp(translateY.abs());
      }
    }

    if (!moved) {
      idle();
      return false;
    }

    if (position.distanceTo(target.position) >= tileSize * 10) {
      print("cannot");
      escapeComponent(target);
    }

    return true;
  }

  bool myPatrol(
    double dt, {
    double margin = 0,
    bool debug = false,
    int maxDistance = 50,
    int minDistance = 0,
  }) {
    final _random = Random(Random().nextInt(1000));
    int randomX = _random.nextInt(maxDistance);
    randomX = randomX < minDistance ? minDistance : randomX;
    int randomY = _random.nextInt(maxDistance);
    randomY = randomY < minDistance ? minDistance : randomY;

    int randomNegativeX = _random.nextBool() ? -1 : 1;
    int randomNegativeY = _random.nextBool() ? -1 : 1;

    double centerXPlayer = randomX.toDouble() * randomNegativeX;
    double centerYPlayer = randomY.toDouble() * randomNegativeY;

    double translateX = 0;
    double translateY = 0;
    double speed = this.speed * dt;

    Rect rectToMove = rectConsideringCollision;

    translateX = rectToMove.center.dx > centerXPlayer ? (-1 * speed) : speed;
    translateY = rectToMove.center.dy > centerYPlayer ? (-1 * speed) : speed;

    translateX /= dt;
    translateY /= dt;

    if (debug) {
      print("X:" + translateX.toString());
      print("Y: " + translateY.toString());
    }
    bool moved = false;

    if (translateX > 0 && translateY > 0) {
      moved = moveDownRight(translateX, translateY);
    } else if (translateX < 0 && translateY < 0) {
      moved = moveUpLeft(translateX.abs(), translateY.abs());
    } else if (translateX > 0 && translateY < 0) {
      moved = moveUpRight(translateX, translateY.abs());
    } else if (translateX < 0 && translateY > 0) {
      moved = moveDownLeft(translateX.abs(), translateY);
    } else {
      if (translateX > 0) {
        moved = moveRight(translateX);
      } else if (translateX < 0) {
        moved = moveLeft(translateX.abs());
      }
      if (translateY > 0) {
        moved = moveDown(translateY, debug: debug);
      } else if (translateY < 0) {
        moved = moveUp(translateY.abs());
      }
    }

    if (!moved) {
      idle();
      return false;
    }

    return true;
  }

  bool runAwayFrom(
    GameComponent target,
    double dt, {
    required Function(GameComponent) closeComponent,
    required Function(GameComponent) escapeComponent,
    double margin = 0,
    bool debug = false,
  }) {
    final comp = target.rectConsideringCollision;
    double centerXPlayer = comp.center.dx;
    double centerYPlayer = comp.center.dy;

    double translateX = 0;
    double translateY = 0;
    double speed = this.speed * dt;

    Rect rectToMove = rectConsideringCollision;
    if (debug) {
      print("position: " + position.toString());
      print("target Pos: " + target.position.toString());
      print((target as Lord).id == (this as Lord).id);
    }

    translateX = rectToMove.center.dx > centerXPlayer ? speed : (-1 * speed);
    translateY = rectToMove.center.dy > centerYPlayer ? speed : (-1 * speed);
    Rect rectPlayerCollision = Rect.fromLTWH(
      comp.left - margin,
      comp.top - margin,
      comp.width + (margin * 2),
      comp.height + (margin * 2),
    );

    if (rectToMove.overlaps(rectPlayerCollision)) {
      if (debug) {
        print("overlap");
        print("to move: " + rectToMove.toString());
        print("target: " + rectPlayerCollision.toString());
      }
      closeComponent(target);
      if (!isIdle) {
        idle();
      }
      return false;
    }

    translateX /= dt;
    translateY /= dt;

    print(translateY);

    if (debug) {
      print("X:" + translateX.toString());
      print("Y: " + translateY.toString());
    }
    bool moved = false;

    if (translateX > 0 && translateY > 0) {
      moved = moveDownRight(translateX, translateY);
    } else if (translateX < 0 && translateY < 0) {
      moved = moveUpLeft(translateX.abs(), translateY.abs());
    } else if (translateX > 0 && translateY < 0) {
      moved = moveUpRight(translateX, translateY.abs());
    } else if (translateX < 0 && translateY > 0) {
      moved = moveDownLeft(translateX.abs(), translateY);
    } else {
      if (translateX > 0) {
        moved = moveRight(translateX);
      } else if (translateX < 0) {
        moved = moveLeft(translateX.abs());
      }
      if (translateY > 0) {
        moved = moveDown(translateY, debug: debug);
      } else if (translateY < 0) {
        moved = moveUp(translateY.abs());
      }
    }

    if (!moved) {
      idle();
      return false;
    }
    if ((position.distanceTo(target.position) >= tileSize * 12) ||
        !target.isVisible) {
      escapeComponent(target);
    }

    return true;
  }

  double _adjustTranslate(
    double translate,
    double centerEnemy,
    double centerPlayer,
  ) {
    double diff = centerPlayer - centerEnemy;
    double newTrasnlate = 0;
    if (translate.abs() > diff.abs()) {
      newTrasnlate = diff;
    } else {
      newTrasnlate = translate;
    }

    if (newTrasnlate.abs() < 0.1) {
      newTrasnlate = 0;
    }

    return newTrasnlate;
  }

  bool moveDown(double speed, {bool notifyOnMove = true, bool debug = false}) {
    double innerSpeed = speed * dtUpdate;
    Vector2 displacement = position.translate(0, innerSpeed);
    if (debug) {
      print("pos: " + position.toString());
      print("innerspeed:" + innerSpeed.toString());
      print("displacement: " + displacement.toString());
    }
    if (_isCollision(displacement)) {
      if (notifyOnMove) {
        onMove(
          0,
          Direction.down,
          BonfireUtil.getAngleFromDirection(Direction.down),
        );
      }
      return false;
    }

    isIdle = false;
    position = displacement;
    if (debug) {
      print("update pos" + position.toString());
    }
    lastDirection = Direction.down;
    if (notifyOnMove) {
      onMove(
        speed,
        lastDirection,
        BonfireUtil.getAngleFromDirection(lastDirection),
      );
    }
    //_requestUpdatePriority();
    return true;
  }

  bool _isCollision(Vector2 displacement) {
    if (isObjectCollision()) {
      (this as ObjectCollision).setCollisionOnlyVisibleScreen(isVisible);
      return (this as ObjectCollision)
          .isCollision(
            displacement: displacement,
          )
          .isNotEmpty;
    }
    return false;
  }
}

/// Mixin responsible for find path using `a_star_algorithm` and moving the component through the path
mixin MyMoveToPositionAlongThePath on Movement {
  static const REDUCTION_TO_AVOID_ROUNDING_PROBLEMS = 4;

  List<Offset> currentPath = [];
  int _currentIndex = 0;
  bool _showBarriers = false;
  bool _gridSizeIsCollisionSize = false;
  double _factorInflateFindArea = 2;
  VoidCallback? _onFinish;

  final List<Offset> _barriers = [];
  List ignoreCollisions = [];

  LinePathComponent? _linePathComponent;
  Color _pathLineColor = const Color(0xFF40C4FF).withOpacity(0.5);
  double _pathLineStrokeWidth = 4;
  final Paint _paintShowBarriers = Paint()
    ..color = const Color(0xFF2196F3).withOpacity(0.5);

  void setupMoveToPositionAlongThePath({
    /// Use to set line path color
    Color? pathLineColor,
    Color? barriersCalculatedColor,

    /// Use to set line path width
    double pathLineStrokeWidth = 4,

    /// Use to debug and show area collision calculated
    bool showBarriersCalculated = false,

    /// If `false` the algorithm use map tile size with base of the grid. if true this use collision size of the component.
    bool gridSizeIsCollisionSize = false,
    double factorInflateFindArea = 2,
  }) {
    _factorInflateFindArea = factorInflateFindArea;
    _paintShowBarriers.color =
        barriersCalculatedColor ?? const Color(0xFF2196F3).withOpacity(0.5);
    _showBarriers = showBarriersCalculated;

    _pathLineColor = pathLineColor ?? _pathLineColor;
    _pathLineStrokeWidth = pathLineStrokeWidth;
    _pathLineColor = pathLineColor ?? const Color(0xFF40C4FF).withOpacity(0.5);
    _gridSizeIsCollisionSize = gridSizeIsCollisionSize;
  }

  List<Offset> moveToPositionAlongThePath(
    Vector2 position, {
    List? ignoreCollisions,
    VoidCallback? onFinish,
  }) {
    if (!hasGameRef) {
      return [];
    }

    _onFinish = onFinish;
    this.ignoreCollisions.clear();
    this.ignoreCollisions.add(this);
    if (ignoreCollisions != null) {
      this.ignoreCollisions.addAll(ignoreCollisions);
    }

    _currentIndex = 0;
    _removeLinePathComponent();

    return _calculatePath(position);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (currentPath.isNotEmpty) {
      _move(dt);
    }
  }

  @override
  void renderBeforeTransformation(Canvas canvas) {
    _drawBarrries(canvas);
    super.renderBeforeTransformation(canvas);
  }

  void stopMoveAlongThePath() {
    currentPath.clear();
    _barriers.clear();
    _currentIndex = 0;
    _removeLinePathComponent();
    idle();
  }

  void _move(double dt) {
    double innerSpeed = speed * dt;
    Vector2 center = this.center;
    if (isObjectCollision()) {
      center = (this as ObjectCollision).rectCollision.center.toVector2();
    }
    double diffX = currentPath[_currentIndex].dx - center.x;
    double diffY = currentPath[_currentIndex].dy - center.y;
    double displacementX = diffX.abs() > innerSpeed ? speed : diffX.abs() / dt;
    double displacementY = diffY.abs() > innerSpeed ? speed : diffY.abs() / dt;

    if (diffX.abs() < 0.01 && diffY.abs() < 0.01) {
      _goToNextPosition();
    } else {
      bool onMove = false;
      if (diffX.abs() > 0.01 && diffY.abs() > 0.01) {
        if (diffX > 0 && diffY > 0) {
          onMove = moveDownRight(
            displacementX,
            displacementY,
          );
        } else if (diffX < 0 && diffY > 0) {
          onMove = moveDownLeft(
            displacementX,
            displacementY,
          );
        } else if (diffX > 0 && diffY < 0) {
          onMove = moveUpRight(
            displacementX,
            displacementY,
          );
        } else if (diffX < 0 && diffY < 0) {
          onMove = moveUpLeft(
            displacementX,
            displacementY,
          );
        }
      } else if (diffX.abs() > 0.01) {
        if (diffX > 0) {
          onMove = moveRight(displacementX);
        } else if (diffX < 0) {
          onMove = moveLeft(displacementX);
        }
      } else if (diffY.abs() > 0.01) {
        if (diffY > 0) {
          onMove = moveDown(displacementY);
        } else if (diffY < 0) {
          onMove = moveUp(displacementY);
        }
      }

      if (!onMove) {
        _goToNextPosition();
      }
    }
  }

  List<Offset> _calculatePath(Vector2 finalPosition) {
    final player = this;

    final positionPlayer = player is ObjectCollision
        ? (player as ObjectCollision).rectCollision.center.toVector2()
        : player.center;

    Offset playerPosition = _getCenterPositionByTile(positionPlayer);

    Offset targetPosition = _getCenterPositionByTile(finalPosition);

    double inflate = _tileSize * _factorInflateFindArea;

    double maxY = max(
      playerPosition.dy,
      targetPosition.dy,
    );

    double maxX = max(
      playerPosition.dx,
      targetPosition.dx,
    );

    int rows = maxY.toInt() + inflate.toInt();

    int columns = maxX.toInt() + inflate.toInt();

    _barriers.clear();

    Rect area =
        Rect.fromPoints(positionPlayer.toOffset(), finalPosition.toOffset());

    double left = area.left;
    double right = area.right;
    double top = area.top;
    double bottom = area.bottom;
    double size = max(area.width, area.height);
    if (positionPlayer.x < finalPosition.x) {
      left -= size;
    } else if (positionPlayer.x > finalPosition.x) {
      right += size;
    }

    if (positionPlayer.y < finalPosition.y) {
      top -= size;
    } else if (positionPlayer.y > finalPosition.y) {
      bottom += size;
    }

    area = Rect.fromLTRB(left, top, right, bottom).inflate(inflate);

    for (final e in gameRef.collisions()) {
      if (!ignoreCollisions.contains(e) && area.overlaps(e.rectCollision)) {
        _addCollisionOffsetsPositionByTile(e.rectCollision);
      }
    }

    Iterable<Offset> result = [];

    if (_barriers.contains(targetPosition)) {
      stopMoveAlongThePath();
      return [];
    }

    try {
      result = AStar(
        rows: rows + 1,
        columns: columns + 1,
        start: playerPosition,
        end: targetPosition,
        barriers: _barriers,
      ).findThePath();

      if (result.isNotEmpty || _isNeighbor(playerPosition, targetPosition)) {
        result = AStar.resumePath(result);
        currentPath = result.map((e) {
          return Offset(e.dx * _tileSize, e.dy * _tileSize)
              .translate(_tileSize / 2, _tileSize / 2);
        }).toList();

        _currentIndex = 0;
      }
    } catch (e) {
      // ignore: avoid_print
      print('ERROR(AStar):$e');
    }
    gameRef.add(
      _linePathComponent = LinePathComponent(
        currentPath,
        _pathLineColor,
        _pathLineStrokeWidth,
      ),
    );
    return currentPath;
  }

  /// Get size of the grid used on algorithm to calculate path
  double get _tileSize {
    double tileSize = 0.0;
    if (gameRef.map.tiles.isNotEmpty) {
      tileSize = gameRef.map.tiles.first.width;
    }
    if (_gridSizeIsCollisionSize) {
      if (isObjectCollision()) {
        return max(
          (this as ObjectCollision).rectCollision.width,
          (this as ObjectCollision).rectCollision.height,
        );
      }
      return max(height, width) + REDUCTION_TO_AVOID_ROUNDING_PROBLEMS;
    }
    return tileSize;
  }

  bool get isMovingAlongThePath => currentPath.isNotEmpty;

  Offset _getCenterPositionByTile(Vector2 center) {
    return Offset(
      (center.x / _tileSize).floorToDouble(),
      (center.y / _tileSize).floorToDouble(),
    );
  }

  /// creating an imaginary grid would calculate how many tile this object is occupying.
  void _addCollisionOffsetsPositionByTile(Rect rect) {
    final leftTop = Offset(
      ((rect.left / _tileSize).floor() * _tileSize),
      ((rect.top / _tileSize).floor() * _tileSize),
    );

    List<Rect> grid = [];
    int countColumns = (rect.width / _tileSize).ceil() + 1;
    int countRows = (rect.height / _tileSize).ceil() + 1;

    List.generate(countRows, (r) {
      List.generate(countColumns, (c) {
        grid.add(Rect.fromLTWH(
          leftTop.dx +
              (c * _tileSize) +
              REDUCTION_TO_AVOID_ROUNDING_PROBLEMS / 2,
          leftTop.dy +
              (r * _tileSize) +
              REDUCTION_TO_AVOID_ROUNDING_PROBLEMS / 2,
          _tileSize - REDUCTION_TO_AVOID_ROUNDING_PROBLEMS,
          _tileSize - REDUCTION_TO_AVOID_ROUNDING_PROBLEMS,
        ));
      });
    });

    List<Rect> listRect = grid.where((element) {
      return rect.overlaps(element);
    }).toList();

    final result = listRect.map((e) {
      return Offset(
        (e.center.dx / _tileSize).floorToDouble(),
        (e.center.dy / _tileSize).floorToDouble(),
      );
    }).toList();

    for (var element in result) {
      if (!_barriers.contains(element)) {
        _barriers.add(element);
      }
    }
  }

  bool _isNeighbor(Offset playerPosition, Offset targetPosition) {
    if ((playerPosition.dx - targetPosition.dx).abs() == 1) {
      return true;
    }
    if ((playerPosition.dy - targetPosition.dy).abs() == 1) {
      return true;
    }
    return false;
  }

  void _goToNextPosition() {
    if (_currentIndex < currentPath.length - 1) {
      _currentIndex++;
    } else {
      stopMoveAlongThePath();
      _onFinish?.call();
      _onFinish = null;
    }
  }

  void _drawBarrries(Canvas canvas) {
    if (_showBarriers) {
      for (var element in _barriers) {
        canvas.drawRect(
          Rect.fromLTWH(
            element.dx * _tileSize,
            element.dy * _tileSize,
            _tileSize,
            _tileSize,
          ),
          _paintShowBarriers,
        );
      }
    }
  }

  @override
  void onRemove() {
    _removeLinePathComponent();
    super.onRemove();
  }

  void _removeLinePathComponent() {
    _linePathComponent?.removeFromParent();
    _linePathComponent = null;
  }
}

mixin MyAutomaticRandomMovement on Movement {
  Vector2 _targetRandomMovement = Vector2.zero();
  // ignore: constant_identifier_names
  static const _KEY_INTERVAL_KEEP_STOPPED = 'INTERVAL_RANDOM_MOVEMENT';

  late Random _random;

  bool get isVisibleReduction {
    if (hasGameRef) {
      return gameRef.camera.cameraRect.overlapComponent(this);
    }
    return false;
  }

  /// Method that bo used in [update] method.
  void myRunRandomMovement(
    double dt, {
    bool runOnlyVisibleInCamera = true,
    double speed = 20,
    int maxDistance = 50,
    int minDistance = 0,
    int timeKeepStopped = 1000,
    bool useAngle = false,
    bool debug = false,

    /// milliseconds
  }) {
    if (runOnlyVisibleInCamera && !isVisibleReduction) {
      return;
    }

    if (_targetRandomMovement == Vector2.zero()) {
      if (debug) {
        print("inint");
      }
      if (checkInterval(_KEY_INTERVAL_KEEP_STOPPED, timeKeepStopped, dt)) {
        int randomX = _random.nextInt(maxDistance);
        randomX = randomX < minDistance ? minDistance : randomX;
        int randomY = _random.nextInt(maxDistance);
        randomY = randomY < minDistance ? minDistance : randomY;

        int randomNegativeX = _random.nextBool() ? -1 : 1;
        int randomNegativeY = _random.nextBool() ? -1 : 1;
        _targetRandomMovement = position.translate(
          randomX.toDouble() * randomNegativeX,
          randomY.toDouble() * randomNegativeY,
        );
        if (useAngle) {
          angle = BonfireUtil.angleBetweenPoints(
            rectConsideringCollision.center.toVector2(),
            _targetRandomMovement,
          );
        }

        if (debug) {
          print("target" + _targetRandomMovement.toString());
        }
      }
    } else {
      bool canMoveX = (_targetRandomMovement.x - x).abs() > speed;
      bool canMoveY = (_targetRandomMovement.y - y).abs() > speed;
      bool canMoveLeft = false;
      bool canMoveRight = false;
      bool canMoveUp = false;
      bool canMoveDown = false;
      if (canMoveX) {
        if (_targetRandomMovement.x > x) {
          canMoveRight = true;
        } else {
          canMoveLeft = true;
        }
      }
      if (canMoveY) {
        if (_targetRandomMovement.y > y) {
          canMoveDown = true;
        } else {
          canMoveUp = true;
        }
      }
      bool onMove = false;
      if (useAngle) {
        if (canMoveX && canMoveY) {
          onMove = moveFromAngle(speed, angle);
        }
      } else {
        if (canMoveLeft && canMoveUp) {
          onMove = moveUpLeft(speed, speed);
        } else if (canMoveLeft && canMoveDown) {
          onMove = moveDownLeft(speed, speed);
        } else if (canMoveRight && canMoveUp) {
          onMove = moveUpRight(speed, speed);
        } else if (canMoveRight && canMoveDown) {
          onMove = moveDownRight(speed, speed);
        } else if (canMoveRight) {
          onMove = moveRight(speed);
        } else if (canMoveLeft) {
          onMove = moveLeft(speed);
        } else if (canMoveUp) {
          onMove = moveUp(speed);
        } else if (canMoveDown) {
          onMove = moveDown(speed);
        }
      }

      if (!onMove) {
        _cleanTargetMovementRandom();
      }
    }
  }

  void _cleanTargetMovementRandom() {
    _targetRandomMovement = Vector2.zero();
    idle();
  }

  @override
  void onMount() {
    _random = Random(Random().nextInt(1000));
    super.onMount();
  }
}
