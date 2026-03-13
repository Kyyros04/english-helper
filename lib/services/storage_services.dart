import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/word_model.dart';
import 'dart:convert';

Future<void> saveToFile(List<Word> list) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/progress_backup.json');
  await file.writeAsString(jsonEncode(list.map((w) => w.toMap()).toList()));
}
