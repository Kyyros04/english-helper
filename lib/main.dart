import 'package:flutter/material.dart';
import 'screens/glossary_screen.dart';
import 'screens/options_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/word_model.dart';

import 'package:quick_actions/quick_actions.dart';
import 'package:url_launcher/url_launcher.dart';

final GlobalKey<GlossaryScreenState> glossaryKey =
    GlobalKey<GlossaryScreenState>();

void main() {
  runApp(const EnglishHelperApp());

  // Inizializza le azioni rapide
  const QuickActions quickActions = QuickActions();
  
  // Crea il tasto che apparirà tenendo premuto sull'icona
  quickActions.setShortcutItems(<ShortcutItem>[
    const ShortcutItem(
      type: 'action_add_word', 
      localizedTitle: 'Aggiungi Parola', 
      icon: 'launcher_icon' // Usa l'icona che hai già
    ),
  ]);

  // Gestisci il click
  quickActions.initialize((shortcutType) {
    if (shortcutType == 'action_add_word') {
      // Aspetta che l'app sia pronta e apri il tuo dialogo
      Future.delayed(const Duration(milliseconds: 800), () {
        glossaryKey.currentState?.showAddWordDialog();
      });
    }
  });
}


class EnglishHelperApp extends StatelessWidget {
  const EnglishHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

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
