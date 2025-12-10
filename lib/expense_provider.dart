import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendlite/expense_model.dart';
import 'package:spendlite/repo_impl.dart';
// expense_provider.dart (FIXED VERSION)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendlite/expense_model.dart';
import 'package:spendlite/repo_impl.dart';

class MonthlySummary {
  final double totalSpending;
  final Map<String, double> categoryBreakdown;

  MonthlySummary({
    required this.totalSpending,
    required this.categoryBreakdown,
  });
}

class ExpenseService extends AsyncNotifier<List<Expense>> {
  ExpenseRepository get _repository => ref.read(expenseRepositoryProvider); // ← NO late!

  @override
  Future<List<Expense>> build() async {
    // This ensures DB is ready and returns initial data
    return _repository.getAllExpenses();
  }

  Future<void> addExpense(Expense expense) async {
    state = const AsyncValue.loading();

    try {
      await _repository.addExpense(expense);
      state = await AsyncValue.guard(() => _repository.getAllExpenses());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  

  Future<MonthlySummary> getSummaryForMonth(int year, int month) async {
    final expenses = await _repository.getMonthlyExpenses(year, month);

    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);

    final breakdown = <String, double>{};
    for (var e in expenses) {
      breakdown.update(e.category, (v) => v + e.amount, ifAbsent: () => e.amount);
    }

    return MonthlySummary(totalSpending: total, categoryBreakdown: breakdown);
  }
}

final expenseServiceProvider = 
    AsyncNotifierProvider<ExpenseService, List<Expense>>(ExpenseService.new);


// A separate provider for the monthly summary, listening to the main state
final monthlySummaryProvider = FutureProvider.autoDispose<MonthlySummary>((ref) async {
  // Listen to the current list of expenses for reactivity
  final expensesAsync = ref.watch(expenseServiceProvider);
  // Get the current month/year for the summary
  final now = DateTime.now();

  // If the list is loading or has an error, show a zero summary
  if (expensesAsync.isLoading || expensesAsync.hasError || !expensesAsync.hasValue) {
    return MonthlySummary(totalSpending: 0.0, categoryBreakdown: {});
  }
  
  // Use the service method to calculate the summary based on the current month's filter
  final service = ref.watch(expenseServiceProvider.notifier);
  return service.getSummaryForMonth(now.year, now.month);
});

// List of available categories for the UI
final expenseCategories = [
  'Food & Drink',
  'Groceries',
  'Transportation',
  'Bills & Utilities',
  'Personal',
  'Entertainment',
  'Housing',
  'Health',
  'Savings',
  'Other',
];

