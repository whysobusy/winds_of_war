import 'package:bonfire/bonfire.dart';

class LooterSpriteSheet {
  static Future<SpriteAnimation> attackEffectBottom() => SpriteAnimation.load(
        'enemy/atack_effect_bottom.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> attackEffectLeft() => SpriteAnimation.load(
        'enemy/atack_effect_left.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );
  static Future<SpriteAnimation> attackEffectRight() => SpriteAnimation.load(
        'enemy/atack_effect_right.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );
  static Future<SpriteAnimation> attackEffectTop() => SpriteAnimation.load(
        'enemy/atack_effect_top.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static SimpleDirectionAnimation arthaxAnimations() =>
      SimpleDirectionAnimation(
        idleDown: SpriteAnimation.load(
          'Champions/Arthax.png',
          SpriteAnimationData.sequenced(
            amount: 2,
            stepTime: 0.15,
            textureSize: Vector2(0, 0),
          ),
        ),
        idleUp: SpriteAnimation.load(
          'Champions/Arthax.png',
          SpriteAnimationData.sequenced(
            amount: 2,
            stepTime: 0.15,
            textureSize: Vector2(0, 16),
          ),
        ),
        idleRight: SpriteAnimation.load(
          'Champions/Arthax.png',
          SpriteAnimationData.sequenced(
            amount: 2,
            stepTime: 0.15,
            textureSize: Vector2(0, 32),
          ),
        ),
        idleLeft: SpriteAnimation.load(
          'Champions/Arthax.png',
          SpriteAnimationData.sequenced(
            amount: 2,
            stepTime: 0.15,
            textureSize: Vector2(0, 48),
          ),
        ),
        runDown: SpriteAnimation.load(
          'Champions/Arthax.png',
          SpriteAnimationData.sequenced(
            amount: 4,
            stepTime: 0.15,
            textureSize: Vector2(16, 0),
          ),
        ),
        runUp: SpriteAnimation.load(
          'Champions/Arthax.png',
          SpriteAnimationData.sequenced(
            amount: 4,
            stepTime: 0.15,
            textureSize: Vector2(16, 16),
          ),
        ),
        runRight: SpriteAnimation.load(
          'Champions/Arthax.png',
          SpriteAnimationData.sequenced(
            amount: 4,
            stepTime: 0.15,
            textureSize: Vector2(16, 32),
          ),
        ),
        runLeft: SpriteAnimation.load(
          'Champions/Arthax.png',
          SpriteAnimationData.sequenced(
            amount: 4,
            stepTime: 0.15,
            textureSize: Vector2(16, 48),
          ),
        ),
      );

  static SimpleDirectionAnimation goblinAnimations() =>
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'enemy/goblin/goblin_idle_left.png',
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.1,
            textureSize: Vector2(16, 16),
          ),
        ),
        idleRight: SpriteAnimation.load(
          'enemy/goblin/goblin_idle.png',
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.1,
            textureSize: Vector2(16, 16),
          ),
        ),
        runLeft: SpriteAnimation.load(
          'enemy/goblin/goblin_run_left.png',
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.1,
            textureSize: Vector2(16, 16),
          ),
        ),
        runRight: SpriteAnimation.load(
          'enemy/goblin/goblin_run_right.png',
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.1,
            textureSize: Vector2(16, 16),
          ),
        ),
      );
}
