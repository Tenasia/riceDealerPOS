import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rice_dealer_pos/views/settings_view.dart';

class DatabaseHelper {

  static String ipAddress = '192.168.68.120';
  static String localHost = 'http://$ipAddress/rice-dealer/index.php/api';
  static String liveHost = 'https://philip-rice.metacoresystemsinc.com/api';
  static String currentHost = liveHost;

  static Future<List<dynamic>> getUsers() async {

    final response = await http.post(
        Uri.parse('$currentHost/get_users'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final users = data['data'] as List<dynamic>;

      return users;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getCustomers() async {
    final response = await http.post(
      Uri.parse('$currentHost/getCustomers'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final users = data['data'] as List<dynamic>;
      return users;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getRequestItems() async {
    final response = await http.post(
      Uri.parse('$currentHost/getRequestItems'),
      body: {
        'branchId': branchId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final requests = data['data'] as List<dynamic>;
      return requests;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getRequestRepricing() async {
    final response = await http.post(
      Uri.parse('$currentHost/getRequestRepricing'),
      body: {
        'branchId': branchId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final requests = data['data'] as List<dynamic>;
      return requests;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getRequestPullOut() async {
    final response = await http.post(
      Uri.parse('$currentHost/getRequestPullOut'),
      body: {
        'branchId': branchId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final requests = data['data'] as List<dynamic>;
      return requests;
    } else {
      throw Exception('Failed to load data');
    }
  }


  static Future<List<dynamic>> getAllProducts() async {
    final response = await http.post(
      Uri.parse('$currentHost/getItems'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final products = data['data'] as List<dynamic>;
      return products;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getAllPackages() async {
    final response = await http.post(
      Uri.parse('$currentHost/getPackages'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final products = data['data'] as List<dynamic>;
      return products;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getAvailablePackages(String itemName) async {
    final response = await http.post(
      Uri.parse('$currentHost/getAvailablePackages'),
      body: {
        'itemName': itemName,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final products = data['data'] as List<dynamic>;
      return products;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getAllBranches() async {
    final response = await http.post(
      Uri.parse('$currentHost/getBranches'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final branches = data['data'] as List<dynamic>;
      return branches;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getProducts() async {

    final response = await http.post(
      Uri.parse('$currentHost/getProducts'),
      body: {
        'branchId': branchId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final products = data['data'] as List<dynamic>;
      return products;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getBranchesProducts(String branch_id) async {

    final response = await http.post(
      Uri.parse('$currentHost/getProducts'),
      body: {
        'branchId': branch_id,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final products = data['data'] as List<dynamic>;


      return products;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getRetails() async {

    final response = await http.post(
      Uri.parse('$currentHost/getRetails'),
      body: {
        'branchId': branchId.toString(),
      },
    );

    if (response.statusCode == 200) {

      final data = json.decode(response.body) as Map<String, dynamic>;
      final products = data['data'] as List<dynamic>;
      print("Retails Length: ");
      print(products.length);
      return products;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getMainBranchStocks() async {

    final response = await http.post(
      Uri.parse('$currentHost/getMainBranchStocks'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final products = data['data'] as List<dynamic>;

      return products;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getSales(int page, int limit) async {

    final response = await http.post(
      Uri.parse('$currentHost/getSales'),
      body: {
        'branchId': branchId.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final sales = data['data'] as List<dynamic>;
      return sales;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getItemSales(String cartId) async {

    final response = await http.post(
      Uri.parse('$currentHost/getItemSales'),
      body: {
        'cartId': cartId,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      return items;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getDailyItemsSold(String SalesDate) async {

    final response = await http.post(
      Uri.parse('$currentHost/getDailyTotalItemsSold'),
      body: {
        'branchId': branchId.toString(),
        'salesDate': SalesDate,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      return items;
    } else {
      throw Exception('Failed to load data');
    }
  }


  static Future<List<dynamic>> getDailyItemDiscountSold(String SalesDate) async {

    final response = await http.post(
      Uri.parse('$currentHost/getDailyTotalItemDiscounts'),
      body: {
        'branchId': branchId.toString(),
        'salesDate': SalesDate,
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      return items;
    } else {
      throw Exception('Failed to load data');
    }
  }


  static Future<List<dynamic>> getMonthlyItemsSold(String SalesDate) async {

    final response = await http.post(
      Uri.parse('$currentHost/getMonthlyTotalItemSold'),
      body: {
        'branchId': branchId.toString(),
        'salesDate': SalesDate,
      },
    );

    if (response.statusCode == 200) {
      print('success');
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      return items;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getMonthlyItemDiscountSold(String SalesDate) async {

    final response = await http.post(
      Uri.parse('$currentHost/getDailyTotalItemDiscounts'),
      body: {
        'branchId': branchId.toString(),
        'salesDate': SalesDate,
      },
    );

    if (response.statusCode == 200) {
      print('this Worked!');
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      return items;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getItemSalesWithoutRefund(String cartId) async {

    final response = await http.post(
      Uri.parse('$currentHost/getItemSalesWithoutRefund'),
      body: {
        'cartId': cartId,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      return items;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getDailyTotalSales() async {

    final response = await http.post(
      Uri.parse('$currentHost/getDailyTotalSalesV1'),
      body: {
        'branchId': branchId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final sales = data['data'] as List<dynamic>;

      return sales;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getMonthlyTotalSales() async {

    final response = await http.post(
      Uri.parse('$currentHost/getMonthlyTotalSalesV1'),
      body: {
        'branchId': branchId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final sales = data['data'] as List<dynamic>;

      return sales;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getSalesTransactions() async {

    final response = await http.post(
      Uri.parse('$currentHost/getSalesTransactions'),
      body: {
        'branchId': branchId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final sales = data['data'] as List<dynamic>;
      return sales;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getTradeTransactions() async {

    final response = await http.post(
      Uri.parse('$currentHost/getTradeTransactions'),
      body: {
        'branchId': branchId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final sales = data['data'] as List<dynamic>;
      return sales;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getAllTradeTransactions() async {
    final response = await http.post(
      Uri.parse('$currentHost/getAllTradeTransactions'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final products = data['data'] as List<dynamic>;
      return products;
    } else {
      throw Exception('Failed to load data');
    }
  }



  static Future<void> processCheckout(Map<String, dynamic> data) async {
    final url = Uri.parse('$currentHost/processCheckout');

    // Convert the data object to JSON
    String jsonData = jsonEncode(data);

    final response = await http.post(
      url,
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }

  static Future<void> processCheckoutBranches(Map<String, dynamic> data) async {
    final url = Uri.parse('$currentHost/processCheckoutBetweenBranches');

    // Convert the data object to JSON
    String jsonData = jsonEncode(data);

    final response = await http.post(
      url,
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }

  static Future<void> sendRequestItems(Map<String, dynamic> data) async {
    final url = Uri.parse('$currentHost/sendRequestItems');

    // Convert the data object to JSON
    String jsonData = jsonEncode(data);

    final response = await http.post(
      url,
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );


    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }

  static Future<void> sendRequestReprice(Map<String, dynamic> data) async {
    final url = Uri.parse('$currentHost/sendRequestReprice');
    // Convert the data object to JSON
    String jsonData = jsonEncode(data);

    final response = await http.post(
      url,
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }

  static Future<void> distributeSacks(Map<String, dynamic> data) async {
    final url = Uri.parse('$currentHost/distributeSacks');

    // Convert the data object to JSON
    String jsonData = jsonEncode(data);
    final response = await http.post(
      url,
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }

  static Future<void> repackToSacks(Map<String, dynamic> data) async {
    final url = Uri .parse('$currentHost/repackRetails');

    // Convert the data object to JSON
    String jsonData = jsonEncode(data);
    final response = await http.post(
      url,
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }

  static Future<void> sendRequestPullOut(Map<String, dynamic> data) async {
    final url = Uri.parse('$currentHost/sendRequestPullOut');

    // Convert the data object to JSON
    String jsonData = jsonEncode(data);

    final response = await http.post(
      url,
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }


  static Future<void> sendDeliveryConfirmation(List<Map<String, dynamic>> dataList) async {
    final url = Uri.parse('$currentHost/confirmDelivery');

    // Convert the data object to JSON
    String jsonData = jsonEncode(dataList);


    final response = await http.post(
      url,
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }

  static Future<double> sendRefundInfo(Map<String, dynamic> newData) async {
    final url = Uri.parse('$currentHost/refundSale');

    // Convert the data object to JSON
    String jsonData = jsonEncode(newData);


    final response = await http.post(
      url,
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final sales = data['data'] as List<dynamic>;
      double totalRefundPrice = 0;

      for (var sale in sales) {
        final refundedPrice = double.parse(sale[0]['refunded_price'].toString());
        totalRefundPrice += refundedPrice;
      }

      return totalRefundPrice;
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }

  static Future<void> mixRice(Map<String, dynamic> data) async {
    final url = Uri.parse('$currentHost/mixRetailRice');

    // Convert the data object to JSON
    String jsonData = jsonEncode(data);

    final response = await http.post(
      url,
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }

  static Future<void> setOpeningAmount(String amount) async{
    
    final url = Uri.parse('$currentHost/setOpeningAmount');
    final response = await http.post(
      url,
      body: {
        'branchId': branchId.toString(),
        'openingAmount': amount,
      },
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }

  static Future<void> setClosingAmount(String amount) async{

    final url = Uri.parse('$currentHost/setClosingAmount');
    final response = await http.post(
      url,
      body: {
        'branchId': branchId.toString(),
        'closingAmount': amount,
      },
    );

    if (response.statusCode == 200) {

      print('that worked!');
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getOpeningClosingAmounts() async {

    print(branchId);
    final response = await http.post(
      Uri.parse('$currentHost/getOpeningClosingAmounts'),
      body: {
        'branchId': branchId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final openingClosingAmounts = data['data'] as Map<String, dynamic>;
      ;

      return openingClosingAmounts;
    } else {
      throw Exception('Failed to load data');
    }
  }




}





