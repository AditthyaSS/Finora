import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'storage_service.dart';

class ExportService {
  static Future<String?> exportToJson() async {
    try {
      final data = StorageService.exportAllData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/finora_export_$timestamp.json');
      
      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      print('Error exporting to JSON: $e');
      return null;
    }
  }

  static Future<String?> exportToCsv() async {
    try {
      final data = StorageService.exportAllData();
      final transactions = data['transactions'] as List;

      if (transactions.isEmpty) {
        return null;
      }

      final buffer = StringBuffer();
      
      // CSV Header
      buffer.writeln('Date,Title,Category,Type,Amount,Notes');

      // CSV Rows
      for (var t in transactions) {
        final date = t['date'].toString().split('T')[0];
        final title = _escapeCsv(t['title']);
        final category = _escapeCsv(t['category']);
        final type = t['type'];
        final amount = t['amount'];
        final notes = _escapeCsv(t['notes'] ?? '');
        
        buffer.writeln('$date,$title,$category,$type,$amount,$notes');
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/finora_transactions_$timestamp.csv');
      
      await file.writeAsString(buffer.toString());
      return file.path;
    } catch (e) {
      print('Error exporting to CSV: $e');
      return null;
    }
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
