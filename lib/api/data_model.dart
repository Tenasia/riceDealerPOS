import 'package:flutter/foundation.dart';

class DataModel extends ChangeNotifier {
  List<Map<String, dynamic>> items = []; // Your list of items

  void addItem(Map<String, dynamic> item) {
    items.add(item);
    notifyListeners(); // Notify listeners that the data has changed
  }

  void removeItem(int index) {
    items.removeAt(index);
    notifyListeners(); // Notify listeners that the data has changed
  }
}