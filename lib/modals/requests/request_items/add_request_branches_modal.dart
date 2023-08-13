
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rice_dealer_pos/components/clock_widget.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rice_dealer_pos/views/settings_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum StateType { local, foreign}

class AddRequestBranchesModal extends StatefulWidget {
  final Function(int) onSelectIndex;

  AddRequestBranchesModal({required this.onSelectIndex});

  @override
  _AddRequestBranchesModalState createState() => _AddRequestBranchesModalState();
}

class _AddRequestBranchesModalState extends State<AddRequestBranchesModal>{

  StateType _currentState = StateType.local;
  late int selectedItemIndex;

  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> packages = [];
  List<Map<String, dynamic>> branches = [];

  String? selectedPackage;
  String? selectedBranch;
  String? selectedBranchId = '1';


  List<Map<String, dynamic>> allProducts = [];

  List<String> itemNames = [];

  TextEditingController quantityController = TextEditingController(text: '1');
  TextEditingController totalPriceController = TextEditingController();
  TextEditingController subTotalController = TextEditingController();

  String? paymentMethod;

  double subTotal = 0.00;

  void fetchPackages() async{
    final data = await DatabaseHelper.getAllPackages();

    setState(() {
      packages = List<Map<String, dynamic>>.from(data);
    });

    if (packages.isNotEmpty) {
      selectedPackage = packages[0]['package'];
    }
  }

  Future<List<Map<String, dynamic>>> fetchBranchesProducts(String branch_id) async {
    try {
      final data = await DatabaseHelper.getBranchesProducts(branch_id);
      final productList = List<Map<String, dynamic>>.from(data);
      return productList;
    } catch (e) {
      return []; // Return an empty list if there is an error
    }
  }

  void fetchBranches() async {
    final data = await DatabaseHelper.getAllBranches();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      branchId = prefs.getInt('branchId') ?? 0; // Use a default value if the stored value is null
    });

    setState(() {
      branches = List<Map<String, dynamic>>.from(data.where((branch) =>
      branch['branch_name'] != 'Main Branch' && int.parse(branch['id'].toString()) != branchId));
    });

    if (branches.isNotEmpty) {
      selectedBranch = branches[0]['branch_name'];
      selectedBranchId = branches[0]['id'];
    }



  }


  void addItemToCart(Map<String, dynamic> item) {
    setState(() {
      if (!item.containsKey('quantity')) {
        item['quantity'] = 1;
      }
      items.add(item);
      calculateSubTotal();
    });
  }

  void calculateSubTotal() {

    subTotal = 0.0;
    for (var item in items) {

      if (item['total_price'] == null){
        item['total_price'] = item['selling_price'];
      }

      if (item['total_price'] != null) {
        subTotal += double.parse(item['total_price'].toString());
      }

    }
    setState(() {
      subTotalController.text = subTotal.toStringAsFixed(2);
    });
  }

  void removeItemFromCart(int index) {
    setState(() {
      double removedItemTotalPrice = double.parse(items[index]['total_price']);
      items.removeAt(index);
      subTotal -= removedItemTotalPrice;
      subTotalController.text = subTotal.toStringAsFixed(2);
    });
  }

  void processCheckoutFromMainBranch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? user_id = await prefs.getInt('loggedInUserId');

    Map<String, dynamic> data = {
      'user_id': user_id,
      'customer_branch_id': branchId, // Customer Branch ID
      'branch_id': selectedBranchId, // Main Branch ID
      'total': subTotalController.text, // Customer Branch ID
      'payment_method': paymentMethod,
      'items': items,
    };

    try {
      // print('test');
      await DatabaseHelper.processCheckoutBranches(data);
      // Navigate to another page
      widget.onSelectIndex(3); // Access the callback function through the widget property
    } catch (e) {
    }
  }


  void removeItemFromList(int index) {
    setState(() {
      items.removeAt(index);
      itemNames.removeAt(index);
    });
  }


  void clearCartItems() {
    setState(() {
      items.clear();
      itemNames.clear();
    });

    Navigator.pop(context);
  }

  void loadBranchId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      branchId = prefs.getInt('branchId') ?? 0; // Use a default value if the stored value is null
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPackages();
    loadBranchId();
    fetchBranches();
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
          padding: const EdgeInsets.only(left: 16.0, top: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  widget.onSelectIndex(3); // Navigates back when the button is pressed
                },
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      "Back",
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "| Request Items From Other Branches",
                style: TextStyle(fontSize: 24.0),
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
                        Container(
                          height: 50,
                          color: Color(0xff394a5a),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              // Generate the buttons dynamically
                              ...List.generate(branches.length, (index) {
                                final branch = branches[index]['branch_name'];
                                final branch_id = branches[index]['id'];

                                return SizedBox(
                                  width: 350, // Adjust the width as needed
                                  // margin: EdgeInsets.symmetric(horizontal: 8), // Add margin between buttons
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (items.isNotEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Cannot Switch Branches", style: TextStyle(fontSize: 32),),
                                              content: const Text("Please empty the list before choosing another branch to transact with", style: TextStyle(fontSize: 24),),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("OK", style: TextStyle(fontSize: 24, color: Colors.white)),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        setState(() {
                                          selectedBranch = branch;
                                          selectedBranchId = branch_id;
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      primary: selectedBranch == branch ? Color(0xff232d37) : const Color(0xff394a5a),
                                      // Apply any other styles or conditions based on the selected package
                                    ),
                                    child: Text(branch, style: const TextStyle(fontSize: 24)),
                                  ),

                                );
                              }),
                            ],
                          ),
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
                                        _currentState = StateType.local;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      primary: _currentState == StateType.local ? Color(0xff232d37) : const Color(0xff394a5a),
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
                                          style: TextStyle(fontSize: 24),
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
                                  width: double.infinity,

                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _currentState = StateType.foreign;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      primary: _currentState == StateType.foreign ? Color(0xff232d37) : const Color(0xff394a5a),
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
                                          style: TextStyle(fontSize: 24),
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
                              // Generate the buttons dynamically
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
                                      primary: selectedPackage == package ? Color(0xff232d37) : const Color(0xff394a5a),
                                      // Apply any other styles or conditions based on the selected package
                                    ),
                                    child: Text(package, style: const TextStyle(fontSize: 24)),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),



                        if (_currentState == StateType.local)
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              child: FutureBuilder<List<Map<String, dynamic>>>(
                                future: fetchBranchesProducts(selectedBranchId!),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Container();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    final productList = snapshot.data!;


                                    final filteredProducts = productList
                                        .where((product) =>
                                    product['package_category'] == selectedPackage &&
                                        product['rice_category'] == 'Local' &&
                                        product['cost'] != null &&
                                        product['selling_price'] != null)
                                        .toList();



                                    if (filteredProducts.isEmpty) {
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: SvgPicture.asset(
                                              'assets/icons/grains-wheat-svgrepo-com.svg',
                                              width: 175,
                                              height: 175,
                                              colorFilter: null,
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              'Currently no stocks for ${selectedPackage == '1KG' ? 'Retails' : selectedPackage}!',
                                              style: const TextStyle(fontSize: 32, color: Colors.black),
                                            ),

                                          ),
                                        ],
                                      );
                                    }

                                    return GridView.count(
                                      childAspectRatio: (1500 / 800), // Number of buttons per row
                                      crossAxisCount: 4,
                                      children: List.generate(
                                        filteredProducts.length,
                                            (index) {
                                          final product = filteredProducts[index];
                                          final color = index % 2 == 0 ? Colors.grey[300]! : Colors.grey[200]!;

                                          return Container(
                                            margin: const EdgeInsets.all(16),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (selectedPackage != '1KG' && items.any((existingItem) => existingItem['item_id'] == product['item_id'] && existingItem['branch_id'] == selectedBranchId)) {
                                                  return; // Item already exists in cartItems, so return early and disable the button
                                                }

                                                product['quantity'] = 1;
                                                addItemToCart(product);

                                              },

                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: (selectedPackage != '1KG' && items.any((existingItem) => existingItem['item_id'] == product['item_id'] && existingItem['branch_id'] == selectedBranchId))
                                                    ? Colors.grey[500] // Use a darker shade of grey
                                                    : Colors.grey[300],

                                                shape: RoundedRectangleBorder(
                                                  side: const BorderSide(
                                                    color: Colors.black,
                                                  ),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    product['item_name'],
                                                    style: const TextStyle(color: Colors.black, fontSize: 18),
                                                  ),
                                                  Text(
                                                    '${product['no_item_received'].toString()} Bags',
                                                    style: const TextStyle(color: Colors.black, fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        if (_currentState == StateType.foreign)
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              child: FutureBuilder<List<Map<String, dynamic>>>(
                                future: fetchBranchesProducts(selectedBranchId!),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Container();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    final productList = snapshot.data!;


                                    final filteredProducts = productList
                                        .where((product) =>
                                    product['package_category'] == selectedPackage &&
                                        product['rice_category'] == 'Imported' &&
                                        product['cost'] != null &&
                                        product['selling_price'] != null)
                                        .toList();



                                    if (filteredProducts.isEmpty) {
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: SvgPicture.asset(
                                              'assets/icons/grains-wheat-svgrepo-com.svg',
                                              width: 175,
                                              height: 175,
                                              colorFilter: null,
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              'Currently no stocks for ${selectedPackage == '1KG' ? 'Retails' : selectedPackage}!',
                                              style: const TextStyle(fontSize: 32, color: Colors.black),
                                            ),

                                          ),
                                        ],
                                      );
                                    }



                                    return GridView.count(
                                      childAspectRatio: (1500 / 800), // Number of buttons per row
                                      crossAxisCount: 4,
                                      children: List.generate(
                                        filteredProducts.length,
                                            (index) {
                                          final product = filteredProducts[index];
                                          final color = index % 2 == 0 ? Colors.grey[300]! : Colors.grey[200]!;

                                          return Container(
                                            margin: const EdgeInsets.all(16),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (items.any((existingItem) => existingItem['item_id'] == product['item_id'])) {
                                                  return; // Item already exists in cartItems, so return early and disable the button
                                                }
                                                product['quantity'] = 1;
                                                addItemToCart(product);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: items.any((existingItem) => existingItem['item_id'] == product['item_id'])
                                                    ? Colors.grey[500] // Use a darker shade of grey
                                                    : Colors.grey[300],
                                                shape: RoundedRectangleBorder(
                                                  side: const BorderSide(
                                                    color: Colors.black,
                                                  ),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    product['item_name'],
                                                    style: const TextStyle(color: Colors.black, fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),

                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: (items.isEmpty)
                      ? Container(
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: SvgPicture.asset(
                            'assets/icons/wheat-svgrepo-com.svg',
                            width: 100,
                            height: 100,
                            colorFilter: null,
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Currently no requested items.',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      : Container(
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 5,
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];

                              return GestureDetector(

                                onTap: () {

                                  setState(() {
                                    selectedItemIndex = index;
                                  });

                                  quantityController.text = (items[selectedItemIndex]['quantity'] ?? 1).toString();
                                  totalPriceController.text = item['total_price'] != null ? item['total_price'].toString() : item['selling_price'].toString();


                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return
                                        SingleChildScrollView(
                                          child: AlertDialog(
                                            backgroundColor: Colors.grey[300],
                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  children: [
                                                    Text(
                                                      '${item['item_name']} - ${item['rice_category']} (${item['package_category']})',
                                                      style: const TextStyle(
                                                        fontSize: 32.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${item['branch_name']}',
                                                      style: const TextStyle(
                                                        fontSize: 18.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),


                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const Text('Total Price', style: TextStyle(color: Colors.black, fontSize: 24)),
                                                        const SizedBox(width: 12),
                                                        SizedBox(
                                                          width: 150,
                                                          child: TextFormField(
                                                            controller: totalPriceController,
                                                            readOnly: true,
                                                            textAlign: TextAlign.center,
                                                            // enabled: false,
                                                            style: const TextStyle(color: Colors.black, fontSize: 24),
                                                            decoration: const InputDecoration(
                                                              prefixText: '₱',
                                                              prefixStyle: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 24,
                                                              ),
                                                              labelStyle: TextStyle(color: Colors.black),
                                                              enabledBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                  color: Colors.black,
                                                                ),
                                                              ),

                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),


                                                  ],
                                                ),

                                              ],
                                            ),
                                            content: Column(
                                              children: [
                                                Divider(  // Add the Divider widget here
                                                  color: Colors.grey[400],
                                                  thickness: 1.0,
                                                  height: 20.0,
                                                ),
                                                const SizedBox(height: 25),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                children: const [
                                                                  Text(
                                                                    'Quantity:',
                                                                    style: TextStyle(
                                                                      fontSize: 24.0,
                                                                      color: Colors.black,
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 50),
                                                                ],
                                                              ),
                                                              const SizedBox(width: 10),
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  SizedBox(
                                                                    width: 150,
                                                                    child: TextFormField(
                                                                      textAlign: TextAlign.center,
                                                                      controller: quantityController,
                                                                      keyboardType: TextInputType.number,
                                                                      inputFormatters: <TextInputFormatter>[
                                                                        FilteringTextInputFormatter.digitsOnly // Restrict input to digits only
                                                                      ],
                                                                      style: const TextStyle(color: Colors.black, fontSize: 24, ),
                                                                      decoration: const InputDecoration(
                                                                        prefixText: '\u00D7',
                                                                        labelStyle: TextStyle(color: Colors.black),
                                                                        prefixStyle: TextStyle(color: Colors.black),
                                                                        enabledBorder: UnderlineInputBorder(
                                                                          borderSide: BorderSide(color: Colors.black),
                                                                        ),
                                                                      ),
                                                                      onChanged: (value) {
                                                                        setState(() {

                                                                          // Parse the entered quantity
                                                                          double enteredQuantity = double.tryParse(value) ?? 0.00;
                                                                          if (value.isEmpty){
                                                                            totalPriceController.text = '0.00';
                                                                          }

                                                                          // Calculate the maximum allowed quantity based on available stock
                                                                          double maxQuantity = double.parse(item['no_item_received'].toString());

                                                                          // Check if the entered quantity is negative or exceeds the maximum allowed quantity
                                                                          if (enteredQuantity < 0 || enteredQuantity > maxQuantity) {
                                                                            // Limit the quantity to the valid range
                                                                            quantityController.text = enteredQuantity.clamp(0, maxQuantity).toString();
                                                                          }

                                                                          // Update the total price
                                                                          double totalPrice = double.parse(item['selling_price']) * double.parse(quantityController.text);
                                                                          totalPriceController.text = totalPrice.toStringAsFixed(2);
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 25),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 50),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                children: const [
                                                                  Text(
                                                                    'Stock/s:',
                                                                    style: TextStyle(
                                                                      fontSize: 26.0,
                                                                      color: Colors.black,
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 50),
                                                                ],
                                                              ),
                                                              const SizedBox(width: 10),
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  SizedBox(
                                                                      width: 150,
                                                                      child: TextFormField(
                                                                        controller: TextEditingController(text: item['no_item_received'].toString()),
                                                                        textAlign: TextAlign.center,
                                                                        style: const TextStyle(
                                                                          fontSize: 26.0,
                                                                          color: Colors.black,
                                                                        ),
                                                                      )
                                                                  ),
                                                                  const SizedBox(height: 25),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  // Handle cancel action here
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel',
                                                  style: TextStyle(color: Colors.black, fontSize: 26 , fontFamily: 'Poppins'),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {

                                                  double enteredQuantity = double.tryParse(quantityController.text) ?? 0.0;

                                                  if (quantityController.text.isEmpty || enteredQuantity < 0) {
                                                    // Display a dialog to notify the invalid quantity
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                            'Invalid Quantity',
                                                            style: TextStyle(color: Colors.red, fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.w400),
                                                          ),
                                                          content: const Text(
                                                            'Please enter a valid quantity.',
                                                            style: TextStyle(fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.w200),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(context).pop(); // Close the dialog
                                                              },
                                                              child: const Text(
                                                                'OK',
                                                                style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Poppins'),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                    return; // Stop further execution of the onPressed handler
                                                  }
                                                  setState(() {
                                                    items[selectedItemIndex]['total_price'] = totalPriceController.text;
                                                    items[selectedItemIndex]['quantity'] = quantityController.text;
                                                  });

                                                  calculateSubTotal();
                                                  // updateChangeAmount();
                                                  Navigator.pop(context); // Close the dialog
                                                },
                                                child: const Text('Apply', style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Poppins'),),
                                              ),

                                            ],
                                          ),
                                        );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: index % 2 == 0 ? Colors.grey[300] : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Row(
                                              children: [
                                                Text(
                                                  items[index]['item_name'],
                                                  style: const TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  ' - ${items[index]['rice_category']}',
                                                  style: const TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  ' (${items[index]['package_category']})',
                                                  style: const TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),

                                                const SizedBox(height: 8.0),
                                              ],
                                            ),
                                            const Divider(
                                              height: 20,
                                              thickness: 2,
                                              endIndent: 0,
                                              color: Colors.grey,
                                            ),
                                            Text(
                                              'Branch: ${items[index]['branch_name']} ',
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Total Price: ₱${items[index]['total_price'] ?? items[index]['selling_price']}',
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            items[index]['quantity'] != null &&
                                                items[index]['quantity'] != '1' &&
                                                items[index]['quantity'] != 1 &&
                                                items[index]['selling_category'] != 'Retail'
                                                ? Text(
                                              '${items[index]['quantity']} Bags',
                                              style: const TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.black,
                                              ),
                                            )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                          onPressed: () {
                                            removeItemFromCart(index);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),


                        Divider(  // Add the Divider widget here
                          color: Colors.grey[400],
                          thickness: 1.0,
                          height: 20.0,
                        ),

                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [

                                    const SizedBox(width: 15),

                                    const Text('Subtotal: ₱', style: TextStyle(fontSize: 24, color: Colors.black)),

                                    Text(subTotalController.text, style: const TextStyle(fontSize: 24, color: Colors.black),),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),



                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Center(
                                            child: SingleChildScrollView(
                                              child: AlertDialog(
                                                title: Text('Confirm Cash Payment of ₱$subTotal', style: const TextStyle(fontSize: 32)),
                                                content: Column(
                                                  children: [
                                                    const Text('Are you sure about the items?', style: TextStyle(fontSize: 24)),
                                                    const SizedBox(height: 10),
                                                    Text('(Please pay when the delivery comes in)', style: TextStyle(fontSize: 18, color: Colors.grey[400]))
                                                  ],
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('Cancel', style: TextStyle(fontSize: 24, color: Colors.white)),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      paymentMethod = 'Cash';
                                                      processCheckoutFromMainBranch();
                                                      Navigator.of(context).pop();
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      primary: Colors.green,
                                                    ),
                                                    child: const Text('Confirm', style: TextStyle(fontSize: 24)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green[500],
                                    onPrimary: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/money-svgrepo-com.svg',
                                          width: 30,
                                          height: 30,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 15,),
                                        const Text(
                                          'Pay Cash',
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Expanded(
                            //   flex: 1,
                            //   child: SizedBox(
                            //     height: 50,
                            //     child: ElevatedButton(
                            //       onPressed: () {
                            //         setState(() {
                            //           showDialog(
                            //             context: context,
                            //             builder: (BuildContext context) {
                            //               return Center(
                            //                 child: SingleChildScrollView(
                            //                   child: AlertDialog(
                            //                     title: Text('Confirm Credit Payment of ₱$subTotal', style: const TextStyle(fontSize: 32)),
                            //                     content: Column(
                            //                       children: [
                            //                         const Text('Are you sure about the items?', style: TextStyle(fontSize: 24)),
                            //                         const SizedBox(height: 10),
                            //                         Text('(This will be placed in your branch\'s tab)', style: TextStyle(fontSize: 18, color: Colors.grey[400]))
                            //                       ],
                            //                     ),
                            //                     actions: <Widget>[
                            //                       TextButton(
                            //                         child: const Text('Cancel', style: TextStyle(fontSize: 24, color: Colors.white)),
                            //                         onPressed: () {
                            //                           Navigator.of(context).pop();
                            //                         },
                            //                       ),
                            //                       ElevatedButton(
                            //                         onPressed: () {
                            //                           paymentMethod = 'Credit';
                            //                           processCheckoutFromMainBranch();
                            //                           Navigator.of(context).pop();
                            //                         },
                            //                         style: ElevatedButton.styleFrom(
                            //                           primary: Colors.deepOrange,
                            //                         ),
                            //                         child: const Text('Confirm', style: TextStyle(fontSize: 24)),
                            //                       ),
                            //                     ],
                            //                   ),
                            //                 ),
                            //               );
                            //             },
                            //           );
                            //         });
                            //       },
                            //       style: ElevatedButton.styleFrom(
                            //         primary: Colors.deepOrange,
                            //         onPrimary: Colors.white,
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(0),
                            //         ),
                            //       ),
                            //       child: Center(
                            //         child: Row(
                            //           mainAxisAlignment: MainAxisAlignment.center,
                            //           children: [
                            //             SvgPicture.asset(
                            //               'assets/icons/bank-svgrepo-com.svg',
                            //               width: 30,
                            //               height: 30,
                            //               color: Colors.white,
                            //             ),
                            //             const SizedBox(width: 15,),
                            //             const Text(
                            //               'Use Credit',
                            //               style: TextStyle(fontSize: 24),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
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



