import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Expenses
  static Future<List<Expense>> getExpenses() async {
    final jsonString = _prefs?.getString('expenses');
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> saveExpenses(List<Expense> expenses) async {
    final jsonString = json.encode(expenses.map((e) => e.toJson()).toList());
    return await _prefs?.setString('expenses', jsonString) ?? false;
  }

  // Budgets
  static Future<List<Budget>> getBudgets() async {
    final jsonString = _prefs?.getString('budgets');
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Budget.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> saveBudgets(List<Budget> budgets) async {
    final jsonString = json.encode(budgets.map((b) => b.toJson()).toList());
    return await _prefs?.setString('budgets', jsonString) ?? false;
  }

  // Achievements
  static Future<List<Achievement>> getAchievements() async {
    final jsonString = _prefs?.getString('achievements');
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Achievement.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> saveAchievements(List<Achievement> achievements) async {
    final jsonString = json.encode(achievements.map((a) => a.toJson()).toList());
    return await _prefs?.setString('achievements', jsonString) ?? false;
  }

  // User Level
  static Future<int> getUserLevel() async {
    return _prefs?.getInt('userLevel') ?? 1;
  }

  static Future<bool> saveUserLevel(int level) async {
    return await _prefs?.setInt('userLevel', level) ?? false;
  }

  // User XP
  static Future<int> getUserXP() async {
    return _prefs?.getInt('userXP') ?? 0;
  }

  static Future<bool> saveUserXP(int xp) async {
    return await _prefs?.setInt('userXP', xp) ?? false;
  }

  // Clear all data
  static Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }
}