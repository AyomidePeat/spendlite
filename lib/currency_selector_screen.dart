import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendlite/currency_provider.dart';

class CurrencySelectorScreen extends ConsumerStatefulWidget {
  const CurrencySelectorScreen({super.key});

  @override
  ConsumerState<CurrencySelectorScreen> createState() =>
      _CurrencySelectorScreenState();
}

class _CurrencySelectorScreenState
    extends ConsumerState<CurrencySelectorScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCurrencies = [];
  List<String> _allCurrencies = [];

  @override
  void initState() {
    super.initState();
    // Initialize the full list and sort it
    _allCurrencies = currencyData.keys.toList()..sort();
    _filteredCurrencies = _allCurrencies;

    // Listen for changes in the search field
    _searchController.addListener(_filterCurrencies);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCurrencies);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = _allCurrencies;
      } else {
        _filteredCurrencies = _allCurrencies.where((code) {
          final name = currencyData[code]?.name.toLowerCase() ?? '';
          return code.toLowerCase().contains(query) || name.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCode = ref.watch(currencyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Currency'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search currency (e.g., USD, Naira, Pound)',
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: _filteredCurrencies.isEmpty
          ? Center(
              child: Text(
                'No currencies found for "${_searchController.text}"',
                style: theme.textTheme.titleMedium,
              ),
            )
          : ListView.separated(
              itemCount: _filteredCurrencies.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final code = _filteredCurrencies[index];
                final symbol = currencyData[code]?.symbol ?? '';
                final name = currencyData[code]?.name ?? code;
                final isSelected = selectedCode == code;

                return ListTile(
                  tileColor:
                      isSelected ? theme.primaryColor.withOpacity(0.1) : null,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  leading: CircleAvatar(
                    backgroundColor:
                        isSelected ? theme.primaryColor : Colors.grey[200],
                    child: Text(
                      symbol,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  title: Text(
                    code,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected ? theme.primaryColor : null,
                    ),
                  ),
                  subtitle: Text(
                    name,
                    style: theme.textTheme.bodyMedium,
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: theme.primaryColor)
                      : const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    changeCurrency(ref, code);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Currency changed to $name ($code)')),
                    );
                  },
                );
              },
            ),
    );
  }
}
