import 'package:flutter/material.dart';
import 'package:rice_dealer_pos/components/clock_widget.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';
import 'package:rice_dealer_pos/components/menu.dart';
import 'package:rice_dealer_pos/printing/printing_transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rice_dealer_pos/views/settings_view.dart';
import 'package:flutter/services.dart'; // Add this import statement
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rice_dealer_pos/modals/carts/customer_dropdown.dart';
import 'package:rice_dealer_pos/modals/carts/local_items.dart';
import 'package:rice_dealer_pos/modals/carts/imported_items.dart';
import 'package:rice_dealer_pos/modals/carts/cart_items.dart';





enum CartTab { local, imported }

typedef ToggleMenuVisibilityCallback = void Function();

class CartView extends StatefulWidget {

  final ToggleMenuVisibilityCallback toggleMenuVisibility;
  final List<Map<String, dynamic>> items;


  const CartView({required this.items, required this.toggleMenuVisibility});

  @override
  _CartViewState createState() => _CartViewState();
}

class _CartViewState extends State<CartView>{
  CartTab currentTab = CartTab.local;

  List<Map<String, dynamic>> items = [];
  double subTotal = 0.00;
  double subTotalCost = 0.00;

  double cashReceived = 0.00; // Initialize the cashReceived variable
  double gcashReceived = 0.00;
  double changeAmount = 0.00; // Initialize the changeAmount variable

  bool receiptCheck = false;
  bool printerConnected = false;

  late int selectedItemIndex;

  List<Map<String, dynamic>> packages = [];
  List<Map<String, dynamic>> customers = [];

  String? selectedPackage = '1KG';
  String? selectedCustomer;
  String? selectedCustomerName = '';
  String? employee_name = '';
  String? employee_fullname = '';

  String? gcashReferenceNumber = '';
  String? hybridGcashReferenceNumber = '';

  String? referenceNumber;
  String? paymentMethod;

  late Future<List<Map<String, dynamic>>> fetchRetailsLate;
  late Future<List<Map<String, dynamic>>> fetchWholesalesLate;



  int count = 1;
  int quantity = 1; // Default quantity

  TextEditingController quantityController = TextEditingController(text: '1');
  TextEditingController totalPriceController = TextEditingController();
  TextEditingController subTotalCostController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  TextEditingController cashReceivedController = TextEditingController();
  TextEditingController gcashReceivedController = TextEditingController();

  TextEditingController customCashReceivedController = TextEditingController();
  TextEditingController subTotalPriceController = TextEditingController(text: '0');

  String getGreeting() {
    DateTime now = DateTime.now();
    int currentHour = now.hour;

    if (currentHour >= 0 && currentHour < 12) {
      return 'Good Morning';
    } else if (currentHour >= 12 && currentHour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Future <void> fetchPackages() async{
    final data = await DatabaseHelper.getAllPackages();
    setState(() {
      packages = List<Map<String, dynamic>>.from(data);
    });
  }

  Future <void> fetchCustomers() async {
    final data = await DatabaseHelper.getCustomers();
    setState(() {
      customers = List<Map<String, dynamic>>.from(data);
      selectedCustomer = customers.isNotEmpty ? customers[0]['id'].toString() : 'Walk In';

      // Find the selected customer
      final selectedCustomerData = customers.firstWhere(
            (customer) => customer['id'].toString() == selectedCustomer,
        orElse: () => {},
      );

      // Set selectedCustomerName based on the selected customer
      if (selectedCustomerData != null) {
        selectedCustomerName = selectedCustomerData['customer_name'].toString();
      } else {
        selectedCustomerName = 'Walk In';
      }

    });

  }

  Future <void> fetchUsers() async {
    List<dynamic> data = await DatabaseHelper.getUsers();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? user_id = await prefs.getInt('loggedInUserId');

    // Iterate through the data list
    for (var user in data) {
      if (user['id'] == user_id.toString()) {
        // Concatenate the first_name and last_name
        employee_name = '${user['first_name']}';
        employee_fullname = '${user['first_name']} ${user['last_name']}';
        break; // Exit the loop since we found the match
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchRetails() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final data = await DatabaseHelper.getRetails();
      final retailsList = List<Map<String, dynamic>>.from(data);
      return retailsList;
    } catch (e) {
      return []; // Return an empty list if there is an error
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductList() async {
    await Future.delayed(const Duration(seconds: 1)); // Wait for 2 seconds
    try {
      final data = await DatabaseHelper.getProducts();
      final productList = List<Map<String, dynamic>>.from(data);
      return productList;
    } catch (e) {
      return []; // Return an empty list if there is an error
    }
  }



  List<String> buttons = [
    '₱20',
    '₱50',
    '₱100',
    '₱200',
    '₱500',
    '₱1000',
    'Custom',
    'Clear',
  ];

  List<Color> buttonColors = [
    Colors.orange,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.lightBlue,
    Colors.black,
    Colors.red,
  ];
  void calculateSubTotal() {

    subTotal = 0.0;
    subTotalCost = 0.0;

    for (var item in items) {

      if (item['total_price'] == null){
        item['total_price'] = item['selling_price'];
      }
      if (item['total_cost'] == null){
        item['total_cost'] = item['cost'];
      }

      if (item['total_price'] != null) {
        subTotal += double.parse(item['total_price'].toString());
      }

      if (item['package_category'] != '1KG'){
        item['total_cost'] = double.parse(item['cost'].toString()) * double.parse(item['quantity'].toString());
      }

      if (item['total_cost'] != null){
        subTotalCost += double.parse(item['total_cost'].toString());
      }

    }
    setState(() {
      subTotalPriceController.text = subTotal.toStringAsFixed(2);
      subTotalCostController.text = subTotalCost.toStringAsFixed(2);
    });

  }

  void updateChangeAmount() {
    setState(() {
      print(gcashReceived);
      if (subTotal == 0) {
        changeAmount = 0.00;
      } else if (gcashReceived != 0){

        changeAmount = (gcashReceived + cashReceived) - subTotal;
      } else {
        changeAmount = cashReceived - subTotal;
      }
    });
  }


  void addItemToCart(Map<String, dynamic> item) {
    setState(() {
      final existingItemIndex = items.indexWhere((element) => element['item_id'] == item['item_id']);
      if (existingItemIndex != -1 && item['selling_category'] == 'Retail') {
        final existingItem = items[existingItemIndex];
        final existingPackageCategory = existingItem['package_category'];
        final newItemPackageCategory = item['package_category'];

        // Remove the "KG" from package categories and convert them to numbers
        final existingPackageAmount = double.parse(existingPackageCategory.replaceAll('KG', ''));
        final newItemPackageAmount = double.parse(newItemPackageCategory.replaceAll('KG', ''));

        // Calculate the new quantity by adding existing quantity and new package amount
        final existingQuantity = existingItem['quantity'] ?? 0.0;
        final newQuantity = existingQuantity + newItemPackageAmount;

        // Update the existing item's package category with the new quantity
        existingItem['package_category'] = '$newQuantity' 'KG';

        // Multiply item['selling_price'] by the newQuantity
        final itemSellingPrice = double.parse(item['selling_price']) * newQuantity;
        final itemCostPrice = double.parse(item['cost']) * newQuantity;


        // Update the existing item's selling_price with the multiplied value
        existingItem['total_price'] = itemSellingPrice.toStringAsFixed(2);
        existingItem['total_cost'] = itemCostPrice.toStringAsFixed(2);
        existingItem['quantity'] = newQuantity;


        // Replace the existing item in the items list
        items[existingItemIndex] = existingItem;
        calculateSubTotal();
        updateChangeAmount();
      } else if (existingItemIndex != -1 && item['selling_category'] != 'Retail') {

        final existingItem = items[existingItemIndex];

    // Calculate the new quantity by adding existing quantity and new package amount
        final existingQuantity = existingItem['quantity'] ?? 0.0;
        final newQuantity = existingQuantity + item['quantity_to_add'];

    // Multiply item['selling_price'] by the newQuantity
        final itemSellingPrice = double.parse(item['selling_price']) * newQuantity;
        final itemCostPrice = double.parse(item['cost']) * newQuantity;

    // Update the existing item's selling_price with the multiplied value
        existingItem['total_price'] = itemSellingPrice.toStringAsFixed(2);
        existingItem['total_cost'] = itemCostPrice.toStringAsFixed(2);
        existingItem['quantity'] = newQuantity;

    // Replace the existing item in the items list
        items[existingItemIndex] = existingItem;
        calculateSubTotal();
        updateChangeAmount();

      }
        else {
        // If there is no existing item with the same item_id, add the item to the list

        if (!item.containsKey('quantity')) {
          item['quantity'] = item['quantity_to_add'];
        }

        if (!item.containsKey('discount_amount')) {
          item['discount_amount'] = 0.00;
        }

        item['branch_name'];

        items.add(item);
        calculateSubTotal();
        updateChangeAmount();
        }
    });
  }





  @override
  void dispose() {
    // Dispose of the TextEditingController
    totalPriceController.dispose();
    quantityController.dispose();
    // totalPriceController.dispose();
    discountController.dispose();
    // cashReceivedController.dispose();
    subTotalPriceController.dispose();

    super.dispose();
  }


  void removeItemFromCart(int index) {
    setState(() {
      double removedItemTotalPrice = double.parse(items[index]['total_price']);
      double removedItemTotalCost = double.parse(items[index]['total_cost'].toString());
      items.removeAt(index);
      subTotal -= removedItemTotalPrice;
      subTotalCost -= removedItemTotalCost;
      subTotalPriceController.text = subTotal.toStringAsFixed(2);
      subTotalCostController.text = subTotal.toStringAsFixed(2);

    });

    updateChangeAmount();
  }

  String branch_name = '';

  void loadBranchId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      branchId = prefs.getInt('branchId') ?? 0; // Use a default value if the stored value is null
    });
  }

  void loadBranchName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      branch_name = prefs.getString('branch_name') ?? ''; // Use a default value if the stored value is null
    });
  }


  void clearCartItems() {
    setState(() {
      items.clear();
      calculateSubTotal();
      changeAmount = 0.00;
      cashReceived = 0.00;
      gcashReceived = 0.00;
      cashReceivedController.text = '0.00';
    });
  }

  Map<String, dynamic> receiptData = {};

  void processCheckout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? user_id = await prefs.getInt('loggedInUserId');

    if (gcashReferenceNumber != null && gcashReferenceNumber!.isNotEmpty) {
      setState(() {
        referenceNumber = gcashReferenceNumber;
        paymentMethod = 'GCash';
      });
    } else if (hybridGcashReferenceNumber != null && hybridGcashReferenceNumber!.isNotEmpty) {
      setState(() {
        referenceNumber = hybridGcashReferenceNumber;
        paymentMethod = 'Hybrid';
      });
    } else {
      setState(() {
        paymentMethod = 'Cash';
      });
    }

    print("CASH:");
    print(cashReceived);
    print("GCASH:");
    print(gcashReceived);

    double discountTotal = items.fold(0, (previousValue, item) => previousValue + item['discount_amount']);

    Map<String, dynamic> data = {
      'user_id': user_id,
      'employee_name': employee_name,
      'branch_id': branchId,
      'branch_name': branch_name,
      'reference_number': referenceNumber,
      'payment_method': paymentMethod,
      'customer_id': selectedCustomer,
      'total': subTotal,
      'cost_total': subTotalCost,
      'cash_received': cashReceived,
      'gcash_received': gcashReceived,
      'change_amount': changeAmount,
      'items': items,
      'discount_total': discountTotal,
    };

    setState(() {
      receiptData = data;
    });

    try {
      await DatabaseHelper.processCheckout(data);
    } catch (e) {

    }
  }
  @override
  void initState(){
    super.initState();
    loadBranchId();
    loadBranchName();
    fetchPackages();
    items = widget.items;
    calculateSubTotal();
    updateChangeAmount();
    fetchCustomers();
    fetchUsers();
    clearCartItems();
    //
    fetchRetailsLate = fetchRetails();
    fetchWholesalesLate = fetchProductList();
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Container(), // add an empty Expanded widget to push the ClockWidget to the right
            ),
            const ClockWidget(),
          ],
        ),
        automaticallyImplyLeading: false,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              MenuToggleButton(onPressed: () {
                // Call the toggleMenuVisibility callback function with the parameter set to true
                widget.toggleMenuVisibility();
              }),
              const Text(
                "Cart",
                style: TextStyle(fontSize: 24.0, fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,),
              ),
            ],
          ),
        ),
      ),


      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: Colors.grey[200],
                      child: Column(
                        children: [
                          CurrentCustomerDropdown(
                            selectedCustomer: selectedCustomer,
                            selectedCustomerName: selectedCustomerName,
                            customers: customers,
                            onCustomerChanged: (value, selectedCustomerNameValue) {

                              setState(() {
                                selectedCustomer = value;
                                selectedCustomerName = selectedCustomerNameValue;
                              });
                              // Handle customer change logic here
                            },
                          ),
                          Container(
                            height: 50,
                            color: Colors.red[400],
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: double.infinity,
                                    child: ElevatedButton(

                                      onPressed: () {
                                        setState(() {
                                          currentTab = CartTab.local;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero,
                                        ),
                                        primary: currentTab == CartTab.local ? const Color(0xff232d37) : const Color(0xff394a5a),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/wheat-svgrepo-com.svg',
                                            width: 30,
                                            height: 30,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8), // Adjust the spacing between the icon and text
                                          const Text(
                                            'Local',
                                            style: TextStyle(fontSize: 24,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          currentTab = CartTab.imported;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero,
                                        ),
                                        primary: currentTab == CartTab.imported ? const Color(0xff232d37) : const Color(0xff394a5a),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/wheat-svgrepo-com.svg',
                                            width: 30,
                                            height: 30,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8), // Adjust the spacing between the icon and text
                                          const Text(
                                            'Imported',
                                            style: TextStyle(fontSize: 24,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            color: const Color(0xff394a5a),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                SizedBox(
                                  width: 150, // Adjust the width as needed
                                  // margin: EdgeInsets.symmetric(horizontal: 8), // Add margin between buttons
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Handle the button's onPressed event
                                      setState(() {
                                        // Perform any actions needed when the button is pressed
                                        selectedPackage = '1KG';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      primary: selectedPackage == '1KG' ? const Color(0xff232d37) : const Color(0xff394a5a),
                                      // Apply any other styles or conditions based on the selected package
                                    ),
                                    child: const Text('Retail', style: TextStyle(fontSize: 24)),
                                  ),
                                ),
                                // Generate the rest of the buttons dynamically
                                ...List.generate(packages.length, (index) {
                                  final package = packages[index]['package'];

                                  return SizedBox(
                                    width: 150, // Adjust the width as needed
                                    // margin: EdgeInsets.symmetric(horizontal: 8), // Add margin between buttons
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Handle the button's onPressed event
                                        setState(() {
                                          // Set the selected package as the state or perform any other action when the button is pressed
                                          selectedPackage = package;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero,
                                        ),
                                        primary: selectedPackage == package ? const Color(0xff232d37) : const Color(0xff394a5a),
                                        // Apply any other styles or conditions based on the selected package
                                      ),
                                      child: Text(package, style: const TextStyle(fontSize: 24)),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          if (currentTab == CartTab.local)
                            LocalItems(
                                receiptCheck: receiptCheck,
                                selectedPackage: selectedPackage,
                                items: items, fetchRetails: fetchRetails,
                                fetchProductList: fetchProductList,
                                addItemToCart: addItemToCart,
                                calculateSubTotal: calculateSubTotal,
                                quantityController: quantityController,
                                totalPriceController: totalPriceController,
                                fetchWholesalesLate: fetchWholesalesLate,
                                fetchRetailsLate: fetchRetailsLate,
                            ),
                          if (currentTab == CartTab.imported)
                            ImportedItems(
                                receiptCheck: receiptCheck,
                                selectedPackage: selectedPackage,
                                items: items, fetchRetails: fetchRetails,
                                fetchProductList: fetchProductList,
                                addItemToCart: addItemToCart,
                                calculateSubTotal: calculateSubTotal,
                            ),
                        ],
                      ),
                    ),
                  ),
                if (receiptCheck == false)
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (items.isEmpty)
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                '${getGreeting()} $employee_name!',
                                style: const TextStyle(color: Colors.black, fontSize: 24,  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,),
                              ),
                            ),
                          ),

                        ),
                        if (items.isNotEmpty)
                          CartSection(items: items, quantityController: quantityController, totalPriceController: totalPriceController, discountController: discountController, removeItemFromCart: removeItemFromCart, updateChangeAmount: updateChangeAmount, calculateSubTotal: calculateSubTotal),
                          Expanded(
                              flex: 2,
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        color: Colors.grey[300], // Set background color
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(width: 10),
                                            const Expanded(
                                              flex: 2,
                                              child: Text(
                                                'SUBTOTAL:',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 24,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 0.0),
                                                child: Text(
                                                  '₱${subTotalPriceController.text}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 24,

                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        color: Colors.grey[300], // Set background color
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: FractionallySizedBox(
                                            widthFactor: 1.0,
                                            heightFactor: 1.0, // Adjust the height factor as needed
                                            child: GridView.builder(
                                              itemCount: buttons.length,
                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 4,
                                                mainAxisSpacing: 8.0, // Add spacing between rows
                                                crossAxisSpacing: 8.0, // Add spacing between columns
                                                childAspectRatio: 2.00, // Adjust the aspect ratio as needed
                                              ),
                                              itemBuilder: (context, index) {
                                                final text = buttons[index];
                                                final color = buttonColors[index];

                                                return SizedBox(
                                                  height: 50.0, // Set the desired button height
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      if (text == 'Clear') {
                                                        cashReceived = 0.0;
                                                        updateChangeAmount();// Clear the cashReceived variable
                                                      } else if (text == 'Custom') {

                                                        customCashReceivedController.text = '';

                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            final focusNode = FocusNode();

                                                            Future.delayed(const Duration(milliseconds: 200), () {
                                                              FocusScope.of(context).requestFocus(focusNode);
                                                            });

                                                            return AlertDialog(
                                                              title: const Text('Input Cash Received', style: TextStyle(fontSize: 32.0, fontFamily: 'Poppins')),
                                                              content: TextFormField(
                                                                controller: customCashReceivedController,
                                                                focusNode: focusNode,
                                                                keyboardType: TextInputType.number,
                                                                decoration: const InputDecoration(
                                                                  labelText: 'Cash Received',
                                                                ),
                                                                style: const TextStyle(fontSize: 32.0), // Adjust the font size as desired
                                                              ),
                                                                actions: [
                                                                TextButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context); // Close the dialog// Update the controller value
                                                                    focusNode.unfocus(); // Unfocus the text field
                                                                  },
                                                                  child: const Text('Cancel', style: TextStyle(fontSize: 24.0, fontFamily: 'Poppins')),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed: () {
                                                                    cashReceivedController.text = customCashReceivedController.text;
                                                                    String enteredCash = cashReceivedController.text;
                                                                    double enteredCashValue = double.tryParse(enteredCash) ?? 0.0;

                                                                    if (cashReceivedController.text.isEmpty){
                                                                      setState(() {
                                                                        cashReceived = 0.00;
                                                                      });
                                                                    } else {
                                                                      setState(() {
                                                                        cashReceived = enteredCashValue;
                                                                      });
                                                                    }


                                                                    updateChangeAmount();
                                                                    Navigator.pop(context); // Close the dialog
                                                                    focusNode.unfocus(); // Unfocus the text field

                                                                  },
                                                                  child: const Text('Apply', style: TextStyle(fontSize: 24.0, fontFamily: 'Poppins')),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                      else {
                                                        // Parse the value from the button text (remove the '₱' symbol)
                                                        final value = double.parse(text.substring(1));
                                                        cashReceived += value; // Add the parsed value to cashReceived
                                                        updateChangeAmount(); // Update the changeAmount

                                                      }
                                                      setState(() {
                                                        cashReceivedController.text = cashReceived.toStringAsFixed(2);
                                                      });
                                                      // Update the UI or perform other actions after modifying cashReceived
                                                      // For example, you can update a Text widget with the new value:
                                                    },

                                                    style: OutlinedButton.styleFrom(
                                                      side: BorderSide(color: color, width: 2.0), // Apply the color to the button outline
                                                      backgroundColor: Colors.grey[300], // Set the button color fill to transparent
                                                    ),
                                                    child: FittedBox(
                                                      child: Text(
                                                        text,
                                                        style: const TextStyle(fontSize: 20, color: Colors.black),
                                                        softWrap: false,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),

                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        color: Colors.grey[300],
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 6,
                                              child: Column(
                                                children: [
                                                  const SizedBox(height: 7,),
                                                  const Text(
                                                    'Cash Received',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  Text(
                                                    '₱${cashReceivedController.text}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 24,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 6,
                                              child: Column(
                                                children: [
                                                  const SizedBox(height: 7,),
                                                  const Text(
                                                    'Change',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  Text(
                                                    '₱${changeAmount < 0 ? "0.00" : changeAmount}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 24,
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Container(
                                      height: 50,
                                      color: Colors.blue[800],
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              if (items.isEmpty) {
                                                // Remove the sign from changeAmount
                                                final formattedAmount = (changeAmount * -1).toStringAsFixed(2);
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text('Cannot Proceed to Checkout', style: TextStyle( color: Colors.red, fontSize: 32,  fontFamily: 'Poppins',
                                                        fontWeight: FontWeight.w400,)),
                                                      content: const Text('There are no items.', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',  fontWeight: FontWeight.w400,)),
                                                      actions: <Widget>[
                                                        ElevatedButton(
                                                          style: ButtonStyle(
                                                            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                                          ),
                                                          child: const Text('OK', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                            fontWeight: FontWeight.w400,)),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                        ),
                                                      ],

                                                    );
                                                  },
                                                );
                                              } else {
                                                showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    gcashReferenceNumber = '';
                                                    gcashReceived = 0;
                                                    gcashReceivedController.text = "0";
                                                    return SingleChildScrollView(
                                                      child: AlertDialog(
                                                        title: const Text('GCash Payment', style: TextStyle(fontSize: 32,  fontFamily: 'Poppins',
                                                          fontWeight: FontWeight.w400,)),
                                                        content: SingleChildScrollView(
                                                          child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('Confirm Checkout of ₱$subTotal', style: const TextStyle(fontSize: 24)),
                                                                const SizedBox(height: 25),
                                                                TextFormField(
                                                                  controller: gcashReceivedController,
                                                                  keyboardType: TextInputType.number,
                                                                  decoration: const InputDecoration(
                                                                    labelText: 'Cash Received From GCash',
                                                                    labelStyle: TextStyle(fontSize: 24),
                                                                  ),
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      gcashReceived = double.parse(gcashReceivedController.text);
                                                                    });
                                                                  },
                                                                ),
                                                                const SizedBox(height: 10),
                                                                TextFormField(
                                                                  decoration: const InputDecoration(
                                                                    hintText: 'GCash Reference Number',
                                                                  ),
                                                                  onChanged: (value) {
                                                                    gcashReferenceNumber = value;
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                        ),
                                                        actions: <Widget>[
                                                          SizedBox(
                                                            height: 50,
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                TextButton(
                                                                  child: const Text('Cancel', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                                    fontWeight: FontWeight.w400, color: Colors.white)),
                                                                  onPressed: () {
                                                                    setState(() {
                                                                      gcashReferenceNumber = '';
                                                                      gcashReceived = 0;
                                                                      gcashReceivedController.text = "";
                                                                    });
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                ),
                                                                ElevatedButton(
                                                                  style: ButtonStyle(
                                                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                                                  ),
                                                                  child: const Text('Checkout', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                                    fontWeight: FontWeight.w400,)),
                                                                  onPressed: () {
                                                                    showDialog(
                                                                      context: context,
                                                                      builder: (BuildContext context) {

                                                                        if (gcashReferenceNumber!.isNotEmpty && double.parse(gcashReceivedController.text) >= subTotal){
                                                                          return AlertDialog(
                                                                            title: const Text(
                                                                              'Confirm Checkout',
                                                                              style: TextStyle(fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.w400),
                                                                            ),
                                                                            content: const Text('Are you sure you want to proceed with the checkout?', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                                              fontWeight: FontWeight.w400,)),
                                                                            actions: [
                                                                              ElevatedButton(
                                                                                style: ButtonStyle(
                                                                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                                                                ),
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                  cashReceived = 0;
                                                                                  updateChangeAmount();
                                                                                  processCheckout();

                                                                                  setState(() {
                                                                                    paymentMethod = 'GCash';
                                                                                    receiptCheck = true;
                                                                                  });
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                child: const Text('Checkout', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                                                  fontWeight: FontWeight.w400,)),
                                                                              ),
                                                                              TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                child: const Text('No', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                                                  fontWeight: FontWeight.w400,)),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        } else {
                                                                          return AlertDialog(
                                                                            title: const Text(
                                                                              'Cannot Checkout',
                                                                              style: TextStyle(fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.w400),
                                                                            ),
                                                                            content: Text(
                                                                              double.parse(gcashReceivedController.text) < subTotal
                                                                                  ? 'Amount received is less than the subtotal, cannot proceed with the checkout.'
                                                                                  : 'There is no GCash reference number, cannot proceed with the checkout.',
                                                                              style: const TextStyle(
                                                                                fontSize: 24,
                                                                                fontFamily: 'Poppins',
                                                                                fontWeight: FontWeight.w400,
                                                                              ),
                                                                            ),

                                                                            actions: [
                                                                              TextButton(
                                                                                onPressed: () {

                                                                                  setState(() {
                                                                                    cashReceived = double.parse(cashReceivedController.text);
                                                                                    gcashReceived = double.parse(gcashReceivedController.text);
                                                                                  });

                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                child: const Text('OK', style: TextStyle(fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.w400)),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        }

                                                                      },
                                                                    );
                                                                  },

                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/gcash-svgrepo-com.svg',
                                                  width: 30,
                                                  height: 30,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 5), // Adds some spacing between the icon and the text

                                                const Text( 'Gcash',
                                                  style: TextStyle(
                                                    fontSize: 24.0,
                                                    color: Colors.white,
                                                  ),
                                                ),

                                              ],
                                            ),

                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (changeAmount < 0.00 || items.isEmpty) {
                                                // Remove the sign from changeAmount
                                                final formattedAmount = (changeAmount * -1).toStringAsFixed(2);
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text('Cannot Proceed to Checkout', style: TextStyle( color: Colors.red, fontSize: 32,  fontFamily: 'Poppins',
                                                        fontWeight: FontWeight.w400,)),
                                                      content: items.isEmpty
                                                          ? const Text('There are no items.', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                        fontWeight: FontWeight.w400,))
                                                          : Text('Still has a balance of ₱$formattedAmount', style: const TextStyle(fontSize: 24)),
                                                      actions: <Widget>[
                                                        ElevatedButton(
                                                          style: ButtonStyle(
                                                            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                                          ),
                                                          child: const Text('OK', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                            fontWeight: FontWeight.w400,)),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                        ),
                                                      ],

                                                    );
                                                  },
                                                );
                                              } else {

                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text('Proceed to Checkout', style: TextStyle(fontSize: 32,  fontFamily: 'Poppins',
                                                        fontWeight: FontWeight.w400,)),
                                                      content: Text('Confirm Checkout of ₱$subTotal', style: const TextStyle(fontSize: 24,  )),
                                                      actions: <Widget>[
                                                        SizedBox(
                                                          height: 50,
                                                          child: ElevatedButton(
                                                            style: ButtonStyle(
                                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                                            ),
                                                            child: const Text('Checkout', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                              fontWeight: FontWeight.w400,)),
                                                            onPressed: () {
                                                              processCheckout();


                                                              setState(() {
                                                                fetchWholesalesLate = fetchProductList();
                                                                fetchRetailsLate = fetchRetails();
                                                              });

                                                              fetchProductList();
                                                              fetchRetails();

                                                              setState(() {
                                                                paymentMethod = 'Cash';
                                                                receiptCheck = true;
                                                              });
                                                              Navigator.of(context).pop();
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/money-svgrepo-com.svg',
                                                  width: 30,
                                                  height: 30,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 5), // Adds some spacing between the icon and the text

                                                const Text(
                                                  'Cash',
                                                  style: TextStyle(
                                                    fontSize: 24.0,
                                                    color: Colors.white,
                                                  ),
                                                ),

                                              ],
                                            ),

                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (items.isEmpty) {
                                                // Remove the sign from changeAmount
                                                final formattedAmount = (changeAmount * -1).toStringAsFixed(2);
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text('Cannot Proceed to Checkout', style: TextStyle( color: Colors.red, fontSize: 32,  fontFamily: 'Poppins',
                                                        fontWeight: FontWeight.w400,)),
                                                      content: const Text('There are no items.', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',  fontWeight: FontWeight.w400,)),
                                                      actions: <Widget>[
                                                        ElevatedButton(
                                                          style: ButtonStyle(
                                                            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                                          ),
                                                          child: const Text('OK', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                            fontWeight: FontWeight.w400,)),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                        ),
                                                      ],

                                                    );
                                                  },
                                                );
                                              } else {
                                                showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    hybridGcashReferenceNumber = '';
                                                    gcashReceived = 0;
                                                    gcashReceivedController.text = "";
                                                    return AlertDialog(
                                                      title: const Text('Gcash and Cash Payment', style: TextStyle(fontSize: 32,  fontFamily: 'Poppins',
                                                        fontWeight: FontWeight.w400,)),
                                                      content: SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text('Confirm Checkout of ₱$subTotal', style: const TextStyle(fontSize: 24)),
                                                            const SizedBox(height: 25),
                                                            Text('Cash Received', style: const TextStyle(fontSize: 18)),
                                                            TextFormField(
                                                              controller: cashReceivedController,
                                                              keyboardType: TextInputType.number,
                                                              decoration: const InputDecoration(
                                                                labelStyle: TextStyle(fontSize: 24),
                                                              ),
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  cashReceived = double.parse(cashReceivedController.text);
                                                                });
                                                              },
                                                            ),
                                                            const SizedBox(height: 25),

                                                            Text('Cash Received From GCash', style: const TextStyle(fontSize: 18)),
                                                            TextFormField(
                                                              controller: gcashReceivedController,
                                                              keyboardType: TextInputType.number,
                                                              decoration: const InputDecoration(
                                                                labelText: "Enter GCash Amount",
                                                                labelStyle: TextStyle(fontSize: 24),
                                                              ),
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  cashReceived = double.parse(cashReceivedController.text);
                                                                  gcashReceived = double.parse(gcashReceivedController.text);
                                                                });
                                                              },
                                                            ),

                                                            const SizedBox(height: 10),


                                                            TextFormField(
                                                              keyboardType: TextInputType.number,

                                                              decoration: const InputDecoration(
                                                                hintText: 'Gcash Reference Number',
                                                              ),
                                                              onChanged: (value) {
                                                                hybridGcashReferenceNumber = value;
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        SizedBox(
                                                          height: 50,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              TextButton(

                                                                child: const Text('Cancel', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                                    fontWeight: FontWeight.w400, color: Colors.white)),
                                                                onPressed: () {

                                                                  setState(() {
                                                                    hybridGcashReferenceNumber = '';
                                                                    gcashReceived = 0;
                                                                    gcashReceivedController.text = "";
                                                                  });

                                                                  Navigator.of(context).pop();


                                                                },

                                                              ),
                                                              ElevatedButton(
                                                                style: ButtonStyle(
                                                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrange),
                                                                ),
                                                                child: const Text('Checkout', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                                  fontWeight: FontWeight.w400,)),
                                                                onPressed: () {
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) {


                                                                      double totalAmount = double.parse(cashReceivedController.text) + double.parse(gcashReceivedController.text);


                                                                      if (hybridGcashReferenceNumber!.isNotEmpty && totalAmount >= subTotal){
                                                                        return AlertDialog(
                                                                          title: const Text(
                                                                            'Confirm Checkout',
                                                                            style: TextStyle(fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.w400),
                                                                          ),
                                                                          content: const Text('Are you sure you want to proceed with the checkout?', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                                            fontWeight: FontWeight.w400,)),
                                                                          actions: [
                                                                            ElevatedButton(
                                                                              style: ButtonStyle(
                                                                                backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrange),
                                                                              ),
                                                                              onPressed: () {

                                                                                Navigator.of(context).pop();

                                                                                updateChangeAmount();
                                                                                processCheckout();

                                                                                setState(() {
                                                                                  paymentMethod = 'Hybrid';
                                                                                  receiptCheck = true;
                                                                                });
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: const Text('Checkout', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                                                fontWeight: FontWeight.w400,)),
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: const Text('No', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                                                fontWeight: FontWeight.w400,)),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      } else {
                                                                        return AlertDialog(
                                                                          title: const Text(
                                                                            'Cannot Checkout',
                                                                            style: TextStyle(fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.w400),
                                                                          ),
                                                                          content: Text(
                                                                            totalAmount < subTotal
                                                                                ? 'Amount received is less than the subtotal, cannot proceed with the checkout.'
                                                                                : 'There is no gcash reference number, cannot proceed with the checkout.',
                                                                            style: const TextStyle(
                                                                              fontSize: 24,
                                                                              fontFamily: 'Poppins',
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                          ),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () {

                                                                                setState(() {
                                                                                  cashReceived = double.parse(cashReceivedController.text);
                                                                                  gcashReceived = double.parse(gcashReceivedController.text);
                                                                                });
                                                                                updateChangeAmount();
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: const Text('OK', style: TextStyle(fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.w400)),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      }

                                                                    },
                                                                  );
                                                                },

                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrange),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/cashier-machine-svgrepo-com.svg',
                                                  width: 30,
                                                  height: 30,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 5), // Adds some spacing between the icon and the text

                                                const Text(
                                                  'Hybrid ',
                                                  style: TextStyle(
                                                    fontSize: 24.0,
                                                    color: Colors.white,
                                                  ),
                                                ),

                                              ],
                                            ),

                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
                if (receiptCheck == true)
                  Expanded(
                    flex: 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: const Border(
                          left: BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top:16.0),
                                      child: SizedBox(
                                        width: 100,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              receiptCheck = false;
                                              clearCartItems();
                                            });
                                          },
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.black,
                                            size: 36,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.check,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8.0,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Customer',
                                      style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '$selectedCustomerName',
                                      style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8.0,),
                                Text(
                                  'Total ₱$subTotal',
                                  style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4.0,),

                                Text(DateFormat('MMM dd yyyy (EEEE) | hh:mm:ss a').format(DateTime.now()), style: const TextStyle(color: Colors.black, fontSize: 16),),
                                const SizedBox(height: 8.0,),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cash Received: ₱$cashReceived',
                                          style: const TextStyle(color: Colors.black, fontSize: 14),
                                        ),
                                        Text(
                                          'GCash Received: ₱$gcashReceived',
                                          style: const TextStyle(color: Colors.black, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Change Amount: ₱$changeAmount',
                                          style: const TextStyle(color: Colors.black, fontSize: 14),
                                        ),
                                        Text(
                                          'Payment Method: $paymentMethod',
                                          style: const TextStyle(color: Colors.black, fontSize: 14),
                                        ),

                                      ],
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),

                          const SizedBox(height: 16.0),
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                const Text('Receipt Details', style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold)),
                                Expanded(
                                  flex: 3,
                                  child: ListView.builder(
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                  ),
                                                  Text(
                                                    items[index]['item_name'],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    ' - ${items[index]['rice_category']}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    ' ( ${items[index]['package_category']} / ',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${items[index]['selling_category'] ?? 'Wholesale'} )',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  if (items[index]['selling_category'] != 'Retail')
                                                    Text(
                                                      ' \u00D7 ${items[index]['quantity'] ?? ''}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '₱${items[index]['total_price']}   ',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return PrintingTransactionPage(receiptData);
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green[500],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.print,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    'Print Receipt',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

  }
}

