import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendlite/expense_model.dart';
import 'package:spendlite/expense_provider.dart';

class ExportImportService {
  // Only needed for import on Android < 11 or iOS
  Future<bool> _requestPermission() async {
    if (Platform.isIOS) return true;
    if (Platform.isAndroid) {
      // For Android 13+, request photos/videos if needed, but not required for file_picker
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }
      return status.isGranted || status.isLimited;
    }
    return true;
  }

  // ====================== EXPORT CSV ======================
  Future<bool> exportCSV(WidgetRef ref) async {
    final expenses = ref.read(expenseServiceProvider).value ?? [];
    if (expenses.isEmpty) return false;

    final rows = [
      ['Date', 'Amount', 'Category', 'Description'],
      ...expenses.map((e) => [
            e.date.toIso8601String().split('T').first, // nicer date
            e.amount.toStringAsFixed(2),
            e.category,
            e.description ?? ''
          ])
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final bytes = Uint8List.fromList(csv.codeUnits);

    // This is the CORRECT way in 2025
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Expenses CSV',
      fileName: 'spendlite_export_${DateTime.now().toIso8601String().split('T').first}.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: bytes, // THIS IS THE KEY!
    );

    // If user cancels → result == null
    if (result == null) return false;

    // On modern Android, the file is ALREADY saved by the system!
    // You don't need to write anything yourself
    return true;
  }

  // ====================== EXPORT PDF ======================
  Future<bool> exportPDF(WidgetRef ref) async {
    final expenses = ref.read(expenseServiceProvider).value ?? [];
    if (expenses.isEmpty) return false;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Header(level: 0, text: 'Spendlite Expense Report'),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Date', 'Amount', 'Category', 'Description'],
            data: expenses
                .map((e) => [
                      e.date.toIso8601String().split('T').first,
                      '₹${e.amount.toStringAsFixed(2)}',
                      e.category,
                      e.description ?? '-',
                    ])
                .toList(),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();

    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Expense Report PDF',
      fileName: 'spendlite_report_${DateTime.now().toIso8601String().split('T').first}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      bytes: bytes,
    );

    return result != null;
  }

  // ====================== IMPORT CSV ======================
  Future<bool> importCSV(WidgetRef ref) async {
    await _requestPermission();

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return false;
    final file = result.files.single;

    String content;
    if (file.bytes != null) {
      // Web or when bytes are provided
      content = String.fromCharCodes(file.bytes!);
    } else if (file.path != null) {
      content = await File(file.path!).readAsString();
    } else {
      return false;
    }

    final rows = const CsvToListConverter().convert(content);
    if (rows.isEmpty) return false;

    final service = ref.read(expenseServiceProvider.notifier);

    for (var row in rows.skip(1)) {
      if (row.length < 3) continue;

      final dateStr = row[0].toString();
      final amountStr = row[1].toString();
      final category = row[2].toString();
      final description = row.length > 3 ? row[3].toString() : '';

      final amount = double.tryParse(amountStr) ?? 0.0;
      final date = DateTime.tryParse(dateStr) ?? DateTime.now();

      if (amount <= 0) continue;

      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch + DateTime.now().microsecondsSinceEpoch,
        amount: amount,
        category: category,
        date: date,
        description: description.isEmpty ? null : description,
      );

      await service.addExpense(expense);
    }

    ref.invalidate(expenseServiceProvider);
    ref.invalidate(monthlySummaryProvider);
    return true;
  }
}

final exportImportProvider = Provider((ref) => ExportImportService());