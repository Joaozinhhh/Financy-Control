import 'package:financy_control/core/components/constants.dart';
import 'package:financy_control/firebase_options.dart';
import 'package:financy_control/l10n/gen/app_localizations.dart';
import 'package:financy_control/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupLocator();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: (locales, supported) {
        if (locales != null) {
          for (final locale in locales) {
            if (supported.any(
              (l) =>
                  l.languageCode == locale.languageCode &&
                  (l.countryCode == null || l.countryCode == locale.countryCode),
            )) {
              return locale;
            }
          }
        }
        return const Locale('en');
      },
    );
  }
}

ThemeData get _lightTheme {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Montserrat',
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xffffffff),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF38b6ff),
      brightness: Brightness.light,
      primary: const Color(0xff38b6ff),
      secondary: const Color(0xff4b5ae4),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
      bodySmall: TextStyle(color: Colors.black54),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: Color(0xffffffff),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(36)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      suffixIconColor: Colors.black38,
      prefixIconColor: Colors.black38,
      fillColor: Color(0xffffffff),
      filled: true,
      floatingLabelAlignment: FloatingLabelAlignment.start,
      floatingLabelStyle: TextStyle(
        color: Colors.black,
        backgroundColor: Color(0xffffffff),
      ),
      border: kDefaultLightBorder,
      errorBorder: kDefaultLightBorder,
      enabledBorder: kDefaultLightBorder,
      focusedBorder: kDefaultLightBorder,
      disabledBorder: kDefaultLightBorder,
      focusedErrorBorder: kDefaultLightBorder,
      outlineBorder: BorderSide(
        color: Colors.black,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        animationDuration: Durations.short2,
        backgroundColor: const Color(0x00F1F1F1),
        foregroundColor: const Color(0xff2b524a),
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        elevation: 0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        animationDuration: Durations.short2,
        backgroundColor: const Color(0xff4b5ae4),
        foregroundColor: const Color(0xffffffff),
        minimumSize: const Size.fromHeight(50),
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        elevation: 0,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
    ),
  );
}

ThemeData get _darkTheme {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Montserrat',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xff1e1e1e),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF38b6ff),
      brightness: Brightness.dark,
      primary: const Color(0xff38b6ff),
      secondary: const Color(0xff4b5ae4),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white60),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: Color(0xff1e1e1e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(36)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      suffixIconColor: kDefaultIconLightColor,
      prefixIconColor: kDefaultIconLightColor,
      floatingLabelAlignment: FloatingLabelAlignment.start,
      floatingLabelStyle: const TextStyle(
        color: Colors.white,
        backgroundColor: Color(0xff1e1e1e),
      ),
      border: kDefaultDarkBorder,
      errorBorder: kDefaultDarkBorder,
      enabledBorder: kDefaultDarkBorder,
      focusedBorder: kDefaultDarkBorder,
      disabledBorder: kDefaultDarkBorder,
      focusedErrorBorder: kDefaultDarkBorder,
      outlineBorder: const BorderSide(
        color: Colors.white,
      ),
      filled: true,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        animationDuration: Durations.short2,
        backgroundColor: const Color(0x001e1e1e),
        foregroundColor: const Color(0xff38b6ff),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        elevation: 0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        animationDuration: Durations.short2,
        backgroundColor: const Color(0xff4b5ae4),
        foregroundColor: const Color(0xffffffff),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        elevation: 0,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
    ),
  );
}
