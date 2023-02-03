import 'package:bonfire/bonfire.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:winds_of_war/manager/game_manager.dart';
import 'package:winds_of_war/menu.dart';
import 'package:winds_of_war/util/localization/my_localizations_delegate.dart';
import 'package:winds_of_war/util/sounds.dart';

double tileSize = 16;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();
  }
  await Sounds.initialize();
  final gameManager = GameManager();
  BonfireInjector.instance.put((i) => gameManager);
  MyLocalizationsDelegate myLocation = const MyLocalizationsDelegate();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.acme().fontFamily
      ),
      home: Menu(),
      supportedLocales: MyLocalizationsDelegate.supportedLocales(),
      localizationsDelegates: [
        myLocation,
        DefaultCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: myLocation.resolution,
    ),
  );
}

