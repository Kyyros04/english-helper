import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/word_model.dart';
import '../services/storage_services.dart';
import '../main.dart' show loadProgress;

class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({super.key});

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  final termController = TextEditingController();
  final transController = TextEditingController();
  final descController = TextEditingController();
  final exController = TextEditingController();

  List<Word> words = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Carica la lista attuale per poter aggiungere la nuova parola
    final loaded = await loadProgress(); // La tua funzione che legge il JSON
    setState(() {
      words = loaded;
    });
  }

  void _saveWord() async {
    if (termController.text.isEmpty) return;

    final newWord = Word(
      term: termController.text,
      translation: transController.text,
      description: descController.text,
      examples: exController.text.split('+').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    );

    setState(() {
      words.add(newWord);
      termController.clear();
      transController.clear();
      descController.clear();
      exController.clear();
    });

    await saveToFile(words);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Word saved!"), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quick Add Word"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => SystemNavigator.pop(), // Esci dall'app
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: termController, autofocus: true, decoration: const InputDecoration(labelText: 'English Term')),
              TextField(controller: transController, decoration: const InputDecoration(labelText: 'Translation (IT)')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: exController, decoration: const InputDecoration(labelText: 'Examples (+ separated)')),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _saveWord,
                    icon: const Icon(Icons.save),
                    label: const Text("Save & Next"),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => SystemNavigator.pop(),
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text("Finish"),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
