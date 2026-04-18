import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/storage_services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/filter_chip_widget.dart';
import '../helpers/helper.dart' show formatCount;

enum WordFilter { all, learned, toLearn }

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => GlossaryScreenState();
}

class GlossaryScreenState extends State<GlossaryScreen> {
  WordFilter filterMode = WordFilter.all;
  String searchQuery = "";
  final searchController = TextEditingController();

  List<Word> words = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAppData());
  }

  Future<void> _initAppData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/progress_backup.json');

    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(contents);

      if (!mounted) return;

      setState(() {
        words = jsonData.map((w) => Word.fromMap(w)).toList();
        words.sort(
          (a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()),
        );
      });
    } else {
      if (!mounted) return;
      _showWelcomeDialog(file);
    }
  }

  void _showWelcomeDialog(File localFile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Welcome!'),
        content: const Text(
          'No local progress found. How do you want to start?',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await localFile.writeAsString(jsonEncode([]));
              Navigator.pop(context);
            },
            child: const Text('Start Fresh'),
          ),
          ElevatedButton(
            onPressed: () => _importFromExternal(localFile),
            child: const Text('Import Backup'),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromExternal(File localFile) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      File pickedFile = File(result.files.single.path!);
      String content = await pickedFile.readAsString();
      await localFile.writeAsString(content);
      Navigator.pop(context);
      _initAppData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredWords = words.where((w) {
      final matchesSearch = w.term.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      bool matchesFilter;
      switch (filterMode) {
        case WordFilter.learned:
          matchesFilter = w.isLearned;
          break;
        case WordFilter.toLearn:
          matchesFilter = !w.isLearned;
          break;
        case WordFilter.all:
        default:
          matchesFilter = true;
      }

      return matchesSearch && matchesFilter;
    }).toList();

    final totalCount = words.length;
    final learnedCount = words.where((w) => w.isLearned).length;
    final toLearnCount = totalCount - learnedCount;

    Color backgroundColor;
    switch (filterMode) {
      case WordFilter.learned:
        backgroundColor = Colors.green;
        break;
      case WordFilter.toLearn:
        backgroundColor = Colors.deepOrange;
        break;
      case WordFilter.all:
      default:
        backgroundColor = Colors.lightBlue; // Bianco standard per "All"
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search word...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() => searchQuery = "");
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                WordFilterChip(
                  label: 'All (${formatCount(totalCount)})',
                  mode: WordFilter.all,
                  selectedMode: filterMode,
                  icon: Icons.list,
                  onSelected: (newMode) => setState(() => filterMode = newMode),
                ),
                const SizedBox(width: 8),
                WordFilterChip(
                  label: 'Learned (${formatCount(learnedCount)})',
                  mode: WordFilter.learned,
                  selectedMode: filterMode,
                  icon: Icons.check_circle,
                  onSelected: (newMode) => setState(() => filterMode = newMode),
                ),
                const SizedBox(width: 8),
                WordFilterChip(
                  label: 'To Learn (${formatCount(toLearnCount)})',
                  mode: WordFilter.toLearn,
                  selectedMode: filterMode,
                  icon: Icons.radio_button_unchecked,
                  onSelected: (newMode) => setState(() => filterMode = newMode),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: backgroundColor.withAlpha(40),
              child: Material(
                // Aggiungi questo per forzare la trasparenza
                color: Colors.transparent,
                child: ListView.builder(
                  itemCount: filteredWords.length,
                  itemBuilder: (context, index) {
                    final word = filteredWords[index];
                    return ExpansionTile(
                      backgroundColor: Colors.transparent,
                      collapsedBackgroundColor: Colors.transparent,
                      title: Text(
                        word.term,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: word.isLearned
                              ? Colors.green.shade700
                              : Colors.deepOrange,
                        ),
                      ),

                      subtitle: Text(word.description),

                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Translation (IT): ${word.translation}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),

                              const Text(
                                "Examples:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Divider(),

                              ...word.examples.map(
                                (ex) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    "• $ex",
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),

                              const Divider(),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        word.isLearned =
                                            !word.isLearned; // Inverte lo stato
                                        saveToFile(
                                          words,
                                        ); // Salva subito sul JSON
                                      });
                                    },
                                    icon: Icon(
                                      word.isLearned
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: word.isLearned
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    label: Text(
                                      word.isLearned ? "Learned" : "To Learn",
                                      style: TextStyle(
                                        color: word.isLearned
                                            ? Colors.green
                                            : Colors.grey,
                                        fontWeight: word.isLearned
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () =>
                                        showAddWordDialog(word: word),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.blue,
                                    ),
                                    label: const Text(
                                      "Edit",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _confirmDelete(word),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddWordDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void showAddWordDialog({Word? word}) {
    final termController = TextEditingController(text: word?.term ?? "");
    final transController = TextEditingController(
      text: word?.translation ?? "",
    );
    final descController = TextEditingController(text: word?.description ?? "");
    final exController = TextEditingController(
      text: word?.examples.join('+ ') ?? "",
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(word == null ? 'Add New Term' : 'Edit Term'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: termController,
                decoration: const InputDecoration(labelText: 'English Term'),
              ),
              TextField(
                controller: transController,
                decoration: const InputDecoration(
                  labelText: 'Translation (IT)',
                ),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: exController,
                decoration: const InputDecoration(
                  labelText: 'Examples (+ separated)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (termController.text.isNotEmpty) {
                final newWord = Word(
                  id: word?.id,
                  term: termController.text,
                  translation: transController.text,
                  description: descController.text,
                  isLearned: word?.isLearned ?? false,
                  examples: exController.text
                      .split('+')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                );

                setState(() {
                  if (word == null) {
                    words.add(newWord);
                  } else {
                    int globalIndex = words.indexWhere((w) => w.id == word!.id);
                    if (globalIndex != -1) {
                      words[globalIndex] = newWord;
                    }
                  }
                  words.sort(
                    (a, b) =>
                        a.term.toLowerCase().compareTo(b.term.toLowerCase()),
                  );
                  saveToFile(words);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Word word) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Word?"),
        content: Text("Are you sure you want to remove '${word.term}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                words.removeWhere((w) => w.id == word.id);
                saveToFile(words);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
