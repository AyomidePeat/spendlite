import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendlite/database_helper.dart';
import 'package:spendlite/expense_model.dart';

// Implementation of the Domain Repository (Data/Infrastructure)
class ExpenseRepositoryImpl implements ExpenseRepository {
  final DatabaseInterface _dbHelper;
  static const String _tableName = 'expenses';

  ExpenseRepositoryImpl(this._dbHelper);

  @override
  Future<void> addExpense(Expense expense) async {
    await _dbHelper.insert(_tableName, expense.toMap());
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    final List<Map<String, dynamic>> maps = await _dbHelper.query(_tableName);
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  @override
  Future<List<Expense>> getMonthlyExpenses(int year, int month) async {
    
    // Calculate start and end timestamps for the given month
    final startOfMonth = DateTime(year, month, 1);
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final endOfMonth = DateTime(nextYear, nextMonth, 1).subtract(const Duration(milliseconds: 1));

    final List<Map<String, dynamic>> maps = await _dbHelper.query(
      _tableName,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch],
    );

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }
  
  @override
  Future<double> getMonthlyTotalSpending(int year, int month) async {
    final expenses = await getMonthlyExpenses(year, month);
return expenses.fold<double>(
  0.0,
  (sum, item) => sum + (item.amount ),
);
  }
}

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return ExpenseRepositoryImpl(dbHelper);
});