import 'package:flutter/material.dart';
import 'screens/glossary_screen.dart';
import 'screens/options_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/word_model.dart';
import 'package:app_links/app_links.dart';
import 'screens/quick_add_screen.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();


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
    // Usiamo il delay per dare tempo ad Android di portare l'app in primo piano
    Future.delayed(const Duration(milliseconds: 400), () {
      if (navKey.currentState != null) {
        // Pulisce lo stack e mette la QuickAddScreen in cima
        navKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const QuickAddScreen()),
          (route) => route.isFirst,
        );
      }
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
      home: MainNavigator(),
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
    GlossaryScreen(),
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
