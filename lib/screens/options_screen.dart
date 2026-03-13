import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  Future<void> _exportBackup(BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/progress_backup.json');

      if (await file.exists()) {
        final xFile = XFile(file.path);

        await SharePlus.instance.share(
          ShareParams(
            files: [xFile],
            subject: 'English Helper Backup',
            text: 'Ecco il mio dizionario!',
          ),
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("File non trovato!")));
        }
      }
    } catch (e) {
      debugPrint("Errore export: $e");
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File pickedFile = File(result.files.single.path!);
        String content = await pickedFile.readAsString();

        jsonDecode(content);

        final directory = await getApplicationDocumentsDirectory();
        final localFile = File('${directory.path}/progress_backup.json');
        await localFile.writeAsString(content);

        if (context.mounted) {
          _showSnackBar(
            context,
            "Backup ripristinato! Riavvia l'app per vedere i cambiamenti.",
          );
        }
      }
    } catch (e) {
      debugPrint("Errore Import: $e");
      if (context.mounted) {
        _showSnackBar(
          context,
          "Errore: il file selezionato non è un backup valido.",
        );
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Backup & Sync",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ListTile(
          leading: const Icon(Icons.cloud_upload, color: Colors.blue),
          title: const Text("Export to Google Drive / Share"),
          subtitle: const Text("Salva i tuoi progressi esternamente"),
          onTap: () => _exportBackup(context),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.file_download, color: Colors.green),
          title: const Text("Import Backup File"),
          subtitle: const Text(
            "Seleziona un file JSON per ripristinare i dati",
          ),
          onTap: () => _importBackup(context),
        ),
      ],
    );
  }
}
