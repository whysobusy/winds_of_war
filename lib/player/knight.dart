import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:winds_of_war/main.dart';
import 'package:winds_of_war/model/unit.dart';
import 'package:winds_of_war/util/functions.dart';
import 'package:winds_of_war/util/game_sprite_sheet.dart';
import 'package:winds_of_war/util/player_sprite_sheet.dart';
import 'package:winds_of_war/util/sounds.dart';

class Knight extends SimplePlayer with Lighting, ObjectCollision {
  final StatData statData;
  double stamina = 100;
  double initSpeed = tileSize / 0.25;
  async.Timer? _timerStamina;
  bool containKey = false;
  bool showObserveEnemy = false;

  Knight(Vector2 position, this.statData)
      : super(
          animation: PlayerSpriteSheet.playerAnimations(),
          size: Vector2.all(tileSize),
          position: position,
          life: statData.life,
          speed: tileSize / 0.25,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(valueByTileSize(8), valueByTileSize(8)),
            align: Vector2(
              valueByTileSize(4),
              valueByTileSize(8),
            ),
          ),
        ],
      ),
    );

    setupLighting(
      LightingConfig(
        radius: width * 1.5,
        blurBorder: width,
        color: Colors.deepOrangeAccent.withOpacity(0.2),
      ),
    );
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    this.speed = initSpeed * event.intensity;
    super.joystickChangeDirectional(event);
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.id == 0 && event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    if (event.id == LogicalKeyboardKey.space.keyId &&
        event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    if (event.id == LogicalKeyboardKey.keyZ.keyId &&
        event.event == ActionEvent.DOWN) {
      actionAttackRange();
    }

    if (event.id == 1 && event.event == ActionEvent.DOWN) {
      actionAttackRange();
    }
    super.joystickAction(event);
  }

  @override
  void die() {
    removeFromParent();
    gameRef.add(
      GameDecoration.withSprite(
        sprite: Sprite.load('player/crypt.png'),
        position: Vector2(
          this.position.x,
          this.position.y,
        ),
        size: Vector2.all(30),
      ),
    );
    super.die();
  }

  void actionAttack() {
    if (stamina < 15) {
      return;
    }

    Sounds.attackPlayerMelee();
    decrementStamina(15);
    this.simpleAttackMelee(
      damage: statData.attack,
      animationRight: PlayerSpriteSheet.attackEffectRight(),
      size: Vector2.all(tileSize),
    );
  }

  void actionAttackRange() {
    if (stamina < 10) {
      return;
    }

    Sounds.attackRange();

    decrementStamina(10);
    this.simpleAttackRange(
      animationRight: GameSpriteSheet.fireBallAttackRight(),
      animationLeft: GameSpriteSheet.fireBallAttackLeft(),
      animationUp: GameSpriteSheet.fireBallAttackTop(),
      animationDown: GameSpriteSheet.fireBallAttackBottom(),
      animationDestroy: GameSpriteSheet.fireBallExplosion(),
      size: Vector2(tileSize * 0.65, tileSize * 0.65),
      damage: statData.attack / 2,
      speed: initSpeed * (tileSize / 32),
      enableDiagonal: false,
      onDestroy: () {
        Sounds.explosion();
      },
      collision: CollisionConfig(
        collisions: [
          CollisionArea.rectangle(size: Vector2(tileSize / 2, tileSize / 2)),
        ],
      ),
      lightingConfig: LightingConfig(
        radius: tileSize * 0.9,
        blurBorder: tileSize / 2,
        color: Colors.deepOrangeAccent.withOpacity(0.4),
      ),
    );
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _verifyStamina();
    this.seeEnemy(
      radiusVision: tileSize * 6,
      notObserved: () {
        showObserveEnemy = false;
      },
      observed: (enemies) {
        if (showObserveEnemy) return;
        showObserveEnemy = true;
        _showEmote();
      },
    );
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    super.render(c);
  }

  void _verifyStamina() {
    if (_timerStamina == null) {
      _timerStamina = async.Timer(Duration(milliseconds: 150), () {
        _timerStamina = null;
      });
    } else {
      return;
    }

    stamina += 2;
    if (stamina > 100) {
      stamina = 100;
    }
  }

  void decrementStamina(int i) {
    stamina -= i;
    if (stamina < 0) {
      stamina = 0;
    }
  }

  @override
  void receiveDamage(AttackFromEnum attacker, double damage, dynamic id) {
    if (isDead) return;
    final receivedDmg = damage - statData.defence / 2;
    this.showDamage(
      receivedDmg,
      config: TextStyle(
        fontSize: valueByTileSize(5),
        color: Colors.orange,
        fontFamily: 'Normal',
      ),
    );
    super.receiveDamage(attacker, receivedDmg, id);
  }

  void _showEmote({String emote = 'emote/emote_exclamacao.png'}) {
    gameRef.add(
      AnimatedFollowerObject(
        animation: SpriteAnimation.load(
          emote,
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime: 0.1,
            textureSize: Vector2(32, 32),
          ),
        ),
        target: this,
        size: Vector2(32, 32),
        positionFromTarget: Vector2(18, -6),
      ),
    );
  }
}
