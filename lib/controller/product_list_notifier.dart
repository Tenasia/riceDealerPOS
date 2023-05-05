import 'package:flutter/material.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';
import 'dart:async';

class ProductListNotifier extends ChangeNotifier{
  List<Map<String, dynamic>> products = [];

  void fetchData() async{
    final data = await DatabaseHelper.getProducts();
    products = List <Map<String, dynamic>>.from(data);
    notifyListeners();
  }

  Stream<List<Map<String, dynamic>>> listenToDataChanges() {
    StreamController<List<Map<String, dynamic>>> controller =
        StreamController<List<Map<String, dynamic>>>();
    
    Timer.periodic(Duration(seconds: 5), (_) => fetchData());

    return controller.stream;
  }


}