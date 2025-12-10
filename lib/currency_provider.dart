import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currencyProvider = StateProvider<String>((ref) => 'USD');

final currencySymbolProvider = Provider<String>((ref) {
  final code = ref.watch(currencyProvider);
  return currencyData[code]?.symbol ?? '\$';
});

final currencyNameProvider = Provider<String>((ref) {
  final code = ref.watch(currencyProvider);
  return currencyData[code]?.name ?? code;
});

final currencyInitializerProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('selected_currency') ?? 'USD';
  log('Loaded currency: $saved');
  ref.read(currencyProvider.notifier).state = saved;
});

final allCurrenciesProvider = Provider<List<String>>(
    (ref) => currencyData.keys.toList()..sort());

Future<void> changeCurrency(WidgetRef ref, String code) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('selected_currency', code);
  ref.read(currencyProvider.notifier).state = code;
}

/// Data structure for each currency
class CurrencyInfo {
  final String symbol;
  final String name;
  const CurrencyInfo({required this.symbol, required this.name});
}

/// All currency codes, symbols, and names (ISO 4217 + Bitcoin)
const Map<String, CurrencyInfo> currencyData = {
  'USD': CurrencyInfo(symbol: '\$', name: 'US Dollar'),
  'EUR': CurrencyInfo(symbol: '€', name: 'Euro'),
  'GBP': CurrencyInfo(symbol: '£', name: 'British Pound'),
  'JPY': CurrencyInfo(symbol: '¥', name: 'Japanese Yen'),
  'AUD': CurrencyInfo(symbol: 'A\$', name: 'Australian Dollar'),
  'CAD': CurrencyInfo(symbol: 'C\$', name: 'Canadian Dollar'),
  'CHF': CurrencyInfo(symbol: 'CHF', name: 'Swiss Franc'),
  'CNY': CurrencyInfo(symbol: '¥', name: 'Chinese Yuan'),
  'INR': CurrencyInfo(symbol: '₹', name: 'Indian Rupee'),
  'BRL': CurrencyInfo(symbol: 'R\$', name: 'Brazilian Real'),
  'NGN': CurrencyInfo(symbol: '₦', name: 'Nigerian Naira'),
  'MXN': CurrencyInfo(symbol: 'MX\$', name: 'Mexican Peso'),
  'SGD': CurrencyInfo(symbol: 'S\$', name: 'Singapore Dollar'),
  'HKD': CurrencyInfo(symbol: 'HK\$', name: 'Hong Kong Dollar'),
  'KRW': CurrencyInfo(symbol: '₩', name: 'South Korean Won'),
  'TRY': CurrencyInfo(symbol: '₺', name: 'Turkish Lira'),
  'RUB': CurrencyInfo(symbol: '₽', name: 'Russian Ruble'),
  'ZAR': CurrencyInfo(symbol: 'R', name: 'South African Rand'),
  'PLN': CurrencyInfo(symbol: 'zł', name: 'Polish Zloty'),
  'THB': CurrencyInfo(symbol: '฿', name: 'Thai Baht'),
  'VND': CurrencyInfo(symbol: '₫', name: 'Vietnamese Dong'),
  'AED': CurrencyInfo(symbol: 'د.إ', name: 'UAE Dirham'),
  'BTC': CurrencyInfo(symbol: '₿', name: 'Bitcoin'),
  // Add all remaining currencies in the same format
};
