class Word {
  final String term; // Il termine inglese
  final String translation; // La traduzione in italiano
  final String description;
  final List<String> examples; // Lista di frasi

  Word({
    required this.term, 
    required this.translation, 
    required this.description, 
    required this.examples
  });

  Map<String, dynamic> toMap() => {
    'term': term,
    'translation': translation,
    'description': description,
    'examples': examples,
  };

  factory Word.fromMap(Map<String, dynamic> map) => Word(
    term: map['term'] ?? '',
    translation: map['translation'] ?? '',
    description: map['description'] ?? '',
    examples: List<String>.from(map['examples'] ?? []),
  );
}