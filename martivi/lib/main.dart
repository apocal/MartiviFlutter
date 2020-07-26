import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:martivi/Views/ProductPage.dart';
import 'package:martivi/Views/singup_loginPage.dart';
import 'package:provider/provider.dart';

import 'Localizations/app_localizations.dart';
import 'Views/HomePage.dart';

void main() => runApp(MartiviApp());

class MartiviApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (c) => MainViewModel(),
        ),
        StreamProvider<FirebaseUser>.value(
          value: FirebaseAuth.instance.onAuthStateChanged,
        )
      ],
      child: MaterialApp(
        initialRoute: HomePage.id,
        routes: {
          HomePage.id: (context) => HomePage(),
          ProductPage.id: (context) => ProductPage(),
          SingUpLoginPage.id: (context) => SingUpLoginPage()
        },
        supportedLocales: [Locale('en', 'US'), Locale('ka', 'GE')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          AppLocalizations.delegate
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          // Check if the current device locale is supported
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          // If the locale of the device is not supported, use the first one
          // from the list (English, in this case).
          return supportedLocales.first;
        },
        title: 'Martivi',
        theme: ThemeData(
          appBarTheme: AppBarTheme(color: kPrimary),
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.muktaVaaniTextTheme(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
