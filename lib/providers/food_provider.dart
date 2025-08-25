import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';

class FoodProvider extends ChangeNotifier {
  List<FoodItem> _foodItems = [];
  static const String _storageKey = 'food_items';

  List<FoodItem> get foodItems => List.unmodifiable(_foodItems);

  FoodProvider() {
    _loadFoodItems();
  }

  // Load food items from storage
  Future<void> _loadFoodItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? foodItemsJson = prefs.getString(_storageKey);
      
      if (foodItemsJson != null) {
        final List<dynamic> decodedList = json.decode(foodItemsJson);
        _foodItems = decodedList
            .map((item) => FoodItem.fromJson(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading food items: $e');
      }
    }
  }

  // Save food items to storage
  Future<void> _saveFoodItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedList = json.encode(
        _foodItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_storageKey, encodedList);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving food items: $e');
      }
    }
  }

  // Add new food item
  Future<void> addFoodItem(FoodItem foodItem) async {
    _foodItems.add(foodItem);
    await _saveFoodItems();
    notifyListeners();
  }

  // Update existing food item
  Future<void> updateFoodItem(FoodItem updatedItem) async {
    final index = _foodItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _foodItems[index] = updatedItem;
      await _saveFoodItems();
      notifyListeners();
    }
  }

  // Delete food item
  Future<void> deleteFoodItem(String id) async {
    _foodItems.removeWhere((item) => item.id == id);
    await _saveFoodItems();
    notifyListeners();
  }

  // Get food item by ID
  FoodItem? getFoodItemById(String id) {
    try {
      return _foodItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear all food items
  Future<void> clearAllFoodItems() async {
    _foodItems.clear();
    await _saveFoodItems();
    notifyListeners();
  }
}
