import 'dart:math';

class Word {
  final String id;
  final String term; // Il termine inglese
  final String translation; // La traduzione in italiano
  final String description;
  final List<String> examples; // Lista di frasi
  bool isLearned;

  Word({
    String? id, 
    required this.term, 
    required this.translation, 
    required this.description, 
    required this.examples,
    this.isLearned = false,
  }) : id = id ?? "${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(999)}";

  Map<String, dynamic> toMap() => {
    'id': id,
    'term': term,
    'translation': translation,
    'description': description,
    'examples': examples,
    'isLearned': isLearned,
  };

  factory Word.fromMap(Map<String, dynamic> map) => Word(
    id: map['id'],
    term: map['term'] ?? '',
    translation: map['translation'] ?? '',
    description: map['description'] ?? '',
    examples: List<String>.from(map['examples'] ?? []),
    isLearned: map['isLearned'] ?? false,
  );
}