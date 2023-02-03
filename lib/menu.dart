import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';

import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:winds_of_war/util/custom_sprite_animation_widget.dart';
import 'package:winds_of_war/util/enemy_sprite_sheet.dart';
import 'package:winds_of_war/util/localization/strings_location.dart';
import 'package:winds_of_war/util/player_sprite_sheet.dart';
import 'package:winds_of_war/util/sounds.dart';
import 'package:winds_of_war/widgets/custom_radio.dart';
import 'package:winds_of_war/winds_of_war.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool showSplash = false;
  int currentPosition = 0;
  List<Future<SpriteAnimation>> sprites = [
    PlayerSpriteSheet.idleRight(),
    EnemySpriteSheet.goblinIdleRight(),
    EnemySpriteSheet.impIdleRight(),
    EnemySpriteSheet.miniBossIdleRight(),
    EnemySpriteSheet.bossIdleRight(),
  ];

  @override
  void dispose() {
    Sounds.stopBackgroundSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: showSplash ? buildSplash() : buildMenu(),
    );
  }

  Widget buildMenu() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/background.png"), fit: BoxFit.fill)),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  "Winds of War",
                  style: TextStyle(color: Colors.black, fontSize: 30.0),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                if (sprites.isNotEmpty)
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CustomSpriteAnimationWidget(
                      animation: sprites[currentPosition],
                    ),
                  ),
                const SizedBox(
                  height: 30.0,
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      minimumSize: Size(100, 40), //////// HERE
                    ),
                    child: Text(
                      getString('play_cap'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17.0,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WindsOfWar()),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      minimumSize: Size(100, 40), //////// HERE
                    ),
                    child: const Text(
                      "LOAD",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.0,
                      ),
                    ),
                    onPressed: () {
                        // TODO
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 80,
                  width: 200,
                  child: Sprite.load('keyboard_tip.png').asWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 20,
          margin: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      getString('powered_by'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Normal',
                          fontSize: 12.0),
                    ),
                    InkWell(
                      onTap: () {
                        _launchURL('https://github.com/whysobusy');
                      },
                      child: const Text(
                        'Alan Lun',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontFamily: 'Normal',
                          fontSize: 12.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      getString('built_with'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Normal',
                          fontSize: 12.0),
                    ),
                    InkWell(
                      onTap: () {
                        _launchURL(
                            'https://github.com/RafaelBarbosatec/bonfire');
                      },
                      child: const Text(
                        'Bonfire',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontFamily: 'Normal',
                          fontSize: 12.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSplash() {
    return FlameSplashScreen(
      theme: FlameSplashTheme.dark,
      onFinish: (BuildContext context) {
        setState(() {
          showSplash = false;
        });
      },
    );
  }


  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
