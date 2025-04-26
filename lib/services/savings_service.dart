import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/savings_plan.dart';

class SavingsService {
  static const String _savingsKey = 'savings_plans';

  static Future<List<SavingsPlan>> loadSavingsPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final savingsJson = prefs.getString(_savingsKey);
    
    if (savingsJson == null) {
      return [];
    }

    try {
      final List<dynamic> savingsList = json.decode(savingsJson);
      return savingsList.map((x) => SavingsPlan.fromJson(x)).toList();
    } catch (e) {
      print('Error loading savings plans: $e');
      return [];
    }
  }

  static Future<void> saveSavingsPlans(List<SavingsPlan> plans) async {
    final prefs = await SharedPreferences.getInstance();
    final savingsJson = json.encode(plans.map((x) => x.toJson()).toList());
    await prefs.setString(_savingsKey, savingsJson);
  }

  static Future<void> addSavingsPlan(SavingsPlan plan) async {
    final plans = await loadSavingsPlans();
    plans.add(plan);
    await saveSavingsPlans(plans);
  }

  static Future<void> updateSavingsPlan(SavingsPlan oldPlan, SavingsPlan newPlan) async {
    final plans = await loadSavingsPlans();
    final index = plans.indexWhere((p) => p.title == oldPlan.title);
    if (index != -1) {
      plans[index] = newPlan;
      await saveSavingsPlans(plans);
    }
  }

  static Future<void> deleteSavingsPlan(SavingsPlan plan) async {
    final plans = await loadSavingsPlans();
    plans.removeWhere((p) => p.title == plan.title);
    await saveSavingsPlans(plans);
  }

  static Future<void> addToSavingsPlan(SavingsPlan plan, double amount) async {
    final plans = await loadSavingsPlans();
    final index = plans.indexWhere((p) => p.title == plan.title);
    if (index != -1) {
      final updatedPlan = plan.copyWith(
        currentAmount: plan.currentAmount + amount,
      );
      plans[index] = updatedPlan;
      await saveSavingsPlans(plans);
    }
  }
} 