import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/transactions.json');
  }

  static Future<void> saveTransactions(List<Map<String, dynamic>> transactions) async {
    final file = await _localFile;
    final data = jsonEncode({'transactions': transactions});
    await file.writeAsString(data);
  }

  static Future<List<Map<String, dynamic>>> loadTransactions() async {
    final file = await _localFile;

    if (!await file.exists()) {
      return [];
    }

    final contents = await file.readAsString();
    final data = jsonDecode(contents) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['transactions']);
  }
}
