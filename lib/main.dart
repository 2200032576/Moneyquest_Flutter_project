import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MoneyQuestApp());
}

class MoneyQuestApp extends StatelessWidget {
  const MoneyQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinanceProvider(),
      child: MaterialApp(
        title: 'MoneyQuest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}

// Main Provider for State Management
class FinanceProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  List<Budget> _budgets = [];
  List<Achievement> _achievements = [];
  int _userLevel = 1;
  int _userXP = 0;

  FinanceProvider() {
    _loadData();
  }

  List<Expense> get expenses => _expenses;
  List<Budget> get budgets => _budgets;
  List<Achievement> get achievements => _achievements;
  int get userLevel => _userLevel;
  int get userXP => _userXP;

  Future<void> _loadData() async {
    _expenses = await StorageService.getExpenses();
    _budgets = await StorageService.getBudgets();
    _achievements = await StorageService.getAchievements();
    _userLevel = await StorageService.getUserLevel();
    _userXP = await StorageService.getUserXP();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    await StorageService.saveExpenses(_expenses);
    
    // Award XP for logging expense
    _addXP(10);
    _checkAchievements();
    
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await StorageService.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<void> setBudget(Budget budget) async {
    final index = _budgets.indexWhere((b) => b.category == budget.category);
    if (index >= 0) {
      _budgets[index] = budget;
    } else {
      _budgets.add(budget);
    }
    await StorageService.saveBudgets(_budgets);
    notifyListeners();
  }

  void _addXP(int amount) {
    _userXP += amount;
    final xpForNextLevel = _userLevel * 100;
    
    if (_userXP >= xpForNextLevel) {
      _userLevel++;
      _userXP = _userXP - xpForNextLevel;
      StorageService.saveUserLevel(_userLevel);
    }
    
    StorageService.saveUserXP(_userXP);
  }

  void _checkAchievements() {
    // Check for streak achievement
    if (_expenses.length >= 7 && !_hasAchievement('streak_7')) {
      _unlockAchievement(Achievement(
        id: 'streak_7',
        title: '7-Day Streak',
        description: 'Logged expenses for 7 days',
        icon: '🔥',
        unlockedAt: DateTime.now(),
      ));
    }

    // Check for expense count
    if (_expenses.length >= 50 && !_hasAchievement('expense_50')) {
      _unlockAchievement(Achievement(
        id: 'expense_50',
        title: 'Tracking Master',
        description: 'Logged 50 expenses',
        icon: '📊',
        unlockedAt: DateTime.now(),
      ));
    }
  }

  bool _hasAchievement(String id) {
    return _achievements.any((a) => a.id == id);
  }

  void _unlockAchievement(Achievement achievement) {
    _achievements.add(achievement);
    StorageService.saveAchievements(_achievements);
    _addXP(50); // Bonus XP for unlocking achievement
  }

  double getCategorySpending(String category, DateTime month) {
    return _expenses
        .where((e) =>
            e.category == category &&
            e.date.year == month.year &&
            e.date.month == month.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double getTotalSpending(DateTime month) {
    return _expenses
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }
}

// Models
class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String note;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'],
        amount: json['amount'],
        category: json['category'],
        date: DateTime.parse(json['date']),
        note: json['note'],
      );
}

class Budget {
  final String category;
  final double limit;
  final DateTime month;

  Budget({
    required this.category,
    required this.limit,
    required this.month,
  });

  Map<String, dynamic> toJson() => {
        'category': category,
        'limit': limit,
        'month': month.toIso8601String(),
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        category: json['category'],
        limit: json['limit'],
        month: DateTime.parse(json['month']),
      );
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'unlockedAt': unlockedAt.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        icon: json['icon'],
        unlockedAt: DateTime.parse(json['unlockedAt']),
      );
}