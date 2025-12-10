import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spendlite/add_expense.dart';
import 'package:spendlite/currency_provider.dart';
import 'package:spendlite/currency_selector_screen.dart';
import 'package:spendlite/expense_model.dart';
import 'package:spendlite/expense_provider.dart';
import 'package:spendlite/export_data_screen.dart';
import 'package:spendlite/main.dart'; 

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider);
    final allExpensesAsync = ref.watch(expenseServiceProvider);
    final init = ref.watch(currencyInitializerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendLite'),
        actions: [
          IconButton(
    icon: const Icon(Icons.currency_exchange, color: SpendLiteApp.accentColor),
    onPressed: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CurrencySelectorScreen()),
      );
    },
  ),
          IconButton(
            icon: const Icon(Icons.file_upload_outlined, color: SpendLiteApp.accentColor),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ExportScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SummaryCard(summaryAsync: summaryAsync),
            ),
          ),
          
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: CategoryBreakdownChart(),
            ),
          ),

          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ),
          ),

          allExpensesAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: SpendLiteApp.primaryColor))),
            error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red)))),
            data: (expenses) {
              if (expenses.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No expenses yet. Tap + to record your first spend!',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final expense = expenses[index];
                    return ExpenseTile(expense: expense);
                  },
                  childCount: expenses.length,
                ),
              );
            },
            
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            sliver: SliverToBoxAdapter(
              child: SizedBox(height: 30,)
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_expense',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddExpenseScreen(),
          );
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}

class SummaryCard extends ConsumerWidget {
  final AsyncValue<MonthlySummary> summaryAsync;

  const SummaryCard({required this.summaryAsync, super.key});

  String getTopCategory(Map<String, double> breakdown) {
    if (breakdown.isEmpty) return 'N/A';
    return breakdown.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrencyCode = ref.watch(currencyProvider);
    final symbol = currencyData[selectedCurrencyCode]?.symbol ?? '\$';

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SpendLiteApp.primaryColor, Color(0xFFC4B5FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SpendLiteApp.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: summaryAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) =>
            Text('Error: $err', style: const TextStyle(color: Colors.white)),
        data: (summary) {
          final month = DateFormat('MMMM').format(DateTime.now());

          final formattedSpending = NumberFormat.currency(
            symbol: symbol,
            decimalDigits: 2,
            locale: 'en_US',
          ).format(summary.totalSpending);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$month Spending',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formattedSpending,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: SpendLiteApp.accentColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Highest Category: ${getTopCategory(summary.categoryBreakdown)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}


class CategoryBreakdownChart extends ConsumerWidget {
  const CategoryBreakdownChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider);

    return summaryAsync.when(
      loading: () => const Card(
        child: SizedBox(
          height: 250,
          child: Center(child: CircularProgressIndicator(color: SpendLiteApp.accentColor)),
        ),
      ),
      error: (err, stack) => Card(
        child: SizedBox(
          height: 250,
          child: Center(child: Text('Error loading chart', style: TextStyle(color: Colors.red))),
        ),
      ),
      data: (summary) {
        final breakdown = summary.categoryBreakdown;

        if (breakdown.isEmpty) {
          return const Card(
            child: SizedBox(
              height: 250,
              child: Center(
                child: Text('No Data Yet', style: TextStyle(color: Colors.white54)),
              ),
            ),
          );
        }

        final sections = breakdown.entries.map((e) {
          final percent = (e.value / summary.totalSpending) * 100;

          return PieChartSectionData(
            title: '${percent.toStringAsFixed(0)}%',
            value: e.value,
            radius: 60,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            color: SpendLiteApp.primaryColor.withOpacity(0.3 + (percent / 100 * 0.7)),
          );
        }).toList();

        return Card(
          color: const Color(0xFF1E1E2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            height: 400,
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Category Breakdown",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),

                SizedBox(height: 40,),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: breakdown.entries.map((e) {
                    final percent = (e.value / summary.totalSpending) * 100;
                    final color = SpendLiteApp.primaryColor.withOpacity(0.3 + (percent / 100 * 0.7));

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          e.key,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ExpenseTile extends ConsumerWidget { // CHANGED to ConsumerWidget
  final Expense expense;
  const ExpenseTile({required this.expense, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // ADDED WidgetRef ref
    final selectedCurrencyCode = ref.watch(currencyProvider); // WATCH THE CURRENCY
    final symbol = currencyData[selectedCurrencyCode]?.symbol ?? '\$';

    // Currency formatting logic
    final formattedAmount = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
      locale: 'en_US',
    ).format(expense.amount);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: SpendLiteApp.primaryColor.withOpacity(0.1),
          child: Icon(_getIconForCategory(expense.category), color: SpendLiteApp.primaryColor),
        ),
        title: Text(
          expense.description ?? expense.category,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        subtitle: Text(
          '${expense.category} • ${DateFormat('MMM dd').format(expense.date)}',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: Text(
          '-$formattedAmount', // USE FORMATTED STRING HERE
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        // onTap: () {
        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //     content: Text('Tapped on ${expense.description}'),
        //     duration: const Duration(seconds: 1),
        //   ));
        // },
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    // ... (rest of the method is unchanged)
    switch (category) {
      case 'Food & Drink': return Icons.fastfood;
      case 'Groceries': return Icons.shopping_basket;
      case 'Transportation': return Icons.directions_bus;
      case 'Bills & Utilities': return Icons.receipt_long;
      case 'Personal': return Icons.person;
      case 'Entertainment': return Icons.movie;
      case 'Housing': return Icons.house;
      default: return Icons.money_off;
    }
  }
}