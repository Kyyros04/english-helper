import 'package:flutter/material.dart';
import '../screens/glossary_screen.dart';

class WordFilterChip extends StatelessWidget {
  final String label;
  final WordFilter mode;
  final WordFilter selectedMode;
  final IconData icon;
  final Function(WordFilter) onSelected;

  const WordFilterChip({
    super.key,
    required this.label,
    required this.mode,
    required this.selectedMode,
    required this.icon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedMode == mode;

    return ChoiceChip(
      avatar: Icon(
        icon, 
        size: 18, 
        color: isSelected ? Colors.white : Colors.blue
      ),
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      // Rimuoviamo il contenitore visivo di default se non selezionato per un look più minimal
      showCheckmark: false, 
      onSelected: (bool selected) {
        if (selected) {
          onSelected(mode);
        }
      },
    );
  }
}
