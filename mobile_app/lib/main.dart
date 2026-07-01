import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations_delegate.dart';
import 'screens/language_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('language') ?? 'sw';
  runApp(CommunityMonitorApp(initialLang: savedLang));
}

class CommunityMonitorApp extends StatefulWidget {
  final String initialLang;
  const CommunityMonitorApp({super.key, required this.initialLang});

  @override
  State<CommunityMonitorApp> createState() => CommunityMonitorAppState();
}

class CommunityMonitorAppState extends State<CommunityMonitorApp> {
  late String _lang;

  @override
  void initState() {
    super.initState();
    _lang = widget.initialLang;
  }

  void changeLang(String lang) {
    setState(() {
      _lang = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
      ),
      locale: Locale(_lang),
      supportedLocales: const [Locale('sw'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: LanguageScreen(onLangChanged: changeLang),
    );
  }
}

