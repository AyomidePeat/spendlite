import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendlite/eport_import.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _isLoading = false;

  Future<void> _handleOperation(Future<bool> Function() operation, String successMessage) async {
  setState(() => _isLoading = true);
  try {
    final success = await operation();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? successMessage : 'Operation was cancelled or failed.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final service = ref.read(exportImportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Import & Export')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Export Data',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                _buildButton(
                  icon: Icons.description,
                  title: "Export as CSV",
                  subtitle: "Save all expenses to a spreadsheet file",
                  color: Colors.green,
                  onTap: () => _handleOperation(
                    () => service.exportCSV(ref),
                    'CSV export successful!',
                  ),
                ),
                const SizedBox(height: 16),
                _buildButton(
                  icon: Icons.picture_as_pdf,
                  title: "Export as PDF",
                  subtitle: "Download printable PDF report",
                  color: Colors.red,
                  onTap: () => _handleOperation(
                    () => service.exportPDF(ref),
                    'PDF export successful!',
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Import Data',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                _buildButton(
                  icon: Icons.upload_file,
                  title: "Import CSV File",
                  subtitle: "Restore data from CSV backup",
                  color: Colors.blue,
                  onTap: () => _handleOperation(
                    () => service.importCSV(ref),
                    'CSV import successful!',
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}
