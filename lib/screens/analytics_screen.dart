import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        if (provider.expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No data to analyze yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add some expenses to see analytics',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Category Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending by Category',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 250,
                      child: CategoryPieChart(
                        provider: provider,
                        month: currentMonth,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Others']
                        .map((category) {
                      final spending = provider.getCategorySpending(category, currentMonth);
                      if (spending == 0) return const SizedBox.shrink();
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CategoryRow(
                          category: category,
                          amount: spending,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Monthly Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Month',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatCard(
                          icon: Icons.receipt_long,
                          label: 'Transactions',
                          value: provider.expenses
                              .where((e) =>
                                  e.date.year == now.year &&
                                  e.date.month == now.month)
                              .length
                              .toString(),
                          color: Colors.blue,
                        ),
                        _StatCard(
                          icon: Icons.attach_money,
                          label: 'Total Spent',
                          value: '₹${provider.getTotalSpending(currentMonth).toStringAsFixed(0)}',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CategoryPieChart extends StatelessWidget {
  final FinanceProvider provider;
  final DateTime month;

  const CategoryPieChart({
    super.key,
    required this.provider,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Others'];
    final categoryColors = {
      'Food': Colors.orange,
      'Transport': Colors.blue,
      'Shopping': Colors.purple,
      'Bills': Colors.red,
      'Entertainment': Colors.pink,
      'Others': Colors.grey,
    };

    final sections = categories.map((category) {
      final spending = provider.getCategorySpending(category, month);
      final total = provider.getTotalSpending(month);
      final percentage = total > 0 ? (spending / total * 100) : 0;

      return PieChartSectionData(
        value: spending,
        title: spending > 0 ? '${percentage.toStringAsFixed(1)}%' : '',
        color: categoryColors[category],
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).where((section) => section.value > 0).toList();

    if (sections.isEmpty) {
      return const Center(child: Text('No data'));
    }

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        startDegreeOffset: -90,
      ),
    );
  }
}

class CategoryRow extends StatelessWidget {
  final String category;
  final double amount;

  const CategoryRow({
    super.key,
    required this.category,
    required this.amount,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt_long;
      case 'Entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Shopping':
        return Colors.purple;
      case 'Bills':
        return Colors.red;
      case 'Entertainment':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: _getCategoryColor(category).withOpacity(0.1),
          radius: 20,
          child: Icon(
            _getCategoryIcon(category),
            color: _getCategoryColor(category),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            category,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          radius: 30,
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}