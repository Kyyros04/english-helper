import 'package:flutter/material.dart';
import 'screens/glossary_screen.dart';
import 'screens/options_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/word_model.dart';
import 'package:app_links/app_links.dart';

final GlobalKey<GlossaryScreenState> glossaryKey =
    GlobalKey<GlossaryScreenState>();

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

final GlobalKey<MainNavigatorState> mainNavKey = GlobalKey<MainNavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appLinks = AppLinks();

  // 1. Gestione all'avvio (Cold Start)
  final Uri? initialUri = await appLinks.getInitialLink();
  if (initialUri != null) {
    _handleDeepLink(initialUri);
  }

  // 2. Gestione ad app già aperta (Background/Foreground)
  appLinks.uriLinkStream.listen((uri) {
    _handleDeepLink(uri);
  });

  runApp(const EnglishHelperApp());
}

void _handleDeepLink(Uri uri) {
  if (uri.scheme == 'englishhelper' && uri.host == 'add') {
    
    // 1. Aspetta un tempo sufficiente affinché il motore grafico sia pronto
    Future.delayed(const Duration(milliseconds: 800), () {
      
      // 2. Se l'app è già aperta, pulisci le rotte sovrapposte
      if (navKey.currentContext != null) {
        Navigator.of(navKey.currentContext!).popUntil((route) => route.isFirst);
      }

      // 3. Forza la Tab del glossario
      mainNavKey.currentState?.setTab(0); 

      // 4. USIAMO UN MICRO-DELAY PER IL DIALOGO
      // Questo garantisce che GlossaryScreen sia disegnata e la chiave sia agganciata
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (glossaryKey.currentState != null) {
            glossaryKey.currentState!.showAddWordDialog();
          }
        });
      });
    });
  }
}



class EnglishHelperApp extends StatelessWidget {
  const EnglishHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: MainNavigator(key: mainNavKey),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => MainNavigatorState();
}

class MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  void setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {


  final List<Widget> screens = [
    GlossaryScreen(key: glossaryKey),
    const Center(child: Text("Phrasal Verbs Coming Soon")),
    const OptionsScreen(),
  ];

    return Scaffold(
      appBar: AppBar(title: const Text("English Helper")),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Glossary"),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: "Phrasals"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Options"),
        ],
      ),
    );
  }
}

Future<File> get _localFile async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/progress_backup.json');
}

Future<List<Word>> loadProgress() async {
  try {
    final file = await _localFile;
    if (await file.exists()) {
      String contents = await file.readAsString();
      List<dynamic> jsonData = jsonDecode(contents);
      return jsonData.map((w) => Word.fromMap(w)).toList();
    }
  } catch (e) {
    debugPrint("Errore caricamento: $e");
  }
  return [];
}
