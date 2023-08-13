
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rice_dealer_pos/components/clock_widget.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rice_dealer_pos/views/settings_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum StateType { local, foreign}

class AddRequestReprice extends StatefulWidget {
  final Function(int) onSelectIndex;

  AddRequestReprice({required this.onSelectIndex});

  @override
  _AddRequestRepriceState createState() => _AddRequestRepriceState();
}

class _AddRequestRepriceState extends State<AddRequestReprice>{

  StateType _currentState = StateType.local;
  late int selectedItemIndex;

  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> packages = [];
  String? selectedPackage;
  List<Map<String, dynamic>> allProducts = [];

  List<String> itemNames = [];

  TextEditingController quantityController = TextEditingController(text: '1');

  void fetchPackages() async{
    final data = await DatabaseHelper.getAllPackages();

    setState(() {
      packages = List<Map<String, dynamic>>.from(data);
    });

    if (packages.isNotEmpty) {
      selectedPackage = packages[0]['package'];
    }
  }

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final data = await DatabaseHelper.getProducts();

      final productList = List<Map<String, dynamic>>.from(data);
      return productList;
    } catch (e) {
      print('Error fetching product list: $e');
      return []; // Return an empty list if there is an error
    }
  }


  void addItemToCart(Map<String, dynamic> item) {
    setState(() {
      items.add(item);
    });
    print(items);
  }

  void removeItemFromCart(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void requestPullOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? user_id = await prefs.getInt('loggedInUserId');

    Map<String, dynamic> data = {
      'userId': user_id,
      'branchId': branchId,
      'items': items,
    };

    try {
      await DatabaseHelper.sendRequestReprice(data);

      // Navigate to another page
      widget.onSelectIndex(3); // Access the callback function through the widget property
    } catch (e) {
      print('Failed to send data: $e');
    }
  }


  void removeItemFromList(int index) {
    setState(() {
      // Remove the item from the list
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

  @override
  void initState() {
    super.initState();
    // items = widget.cartItems;
    fetchPackages();
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
                "| Request Reprice",
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
                                      primary: _currentState == StateType.local ? Colors.lightBlue : Colors.blue[800],
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
                                child: Container(
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
                                      primary: _currentState == StateType.foreign ? Colors.lightBlue : Colors.blue[800],
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
                          color: Colors.blue[800],
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              // Generate the buttons dynamically
                              ...List.generate(packages.length, (index) {
                                final package = packages[index]['package'];

                                return Container(
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
                                      primary: selectedPackage == package ? Colors.lightBlue : Colors.blue[800],
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
                                future: fetchProducts(),
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
                                        product['rice_category'] == 'Local')
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
                                                if (selectedPackage != '1KG' && items.any((existingItem) => existingItem['item_id'] == product['item_id'])) {
                                                  return; // Item already exists in cartItems, so return early and disable the button
                                                }

                                                product['quantity'] = product['no_item_received'];
                                                addItemToCart(product);

                                              },

                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: (selectedPackage != '1KG' && items.any((existingItem) => existingItem['item_id'] == product['item_id']))
                                                    ? Colors.grey[500] // Use a darker shade of grey
                                                    : Colors.grey[300],

                                                shape: RoundedRectangleBorder(
                                                  side: const BorderSide(
                                                    color: Colors.black,
                                                  ),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: Text(
                                                product['item_name'],
                                                style: const TextStyle(color: Colors.black, fontSize: 18),
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
                                future: fetchProducts(),
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
                                                product['quantity'] = product['no_item_received'];
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

                                  quantityController.text = (items[selectedItemIndex]['no_item_received'] ?? 1).toString();

                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return
                                        SingleChildScrollView(
                                          child: AlertDialog(
                                            backgroundColor: Colors.grey[300],
                                            title: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      '${item['item_name']}',
                                                      style: const TextStyle(
                                                        fontSize: 25.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      ' - ${item['rice_category']} ',
                                                      style: const TextStyle(
                                                        fontSize: 25.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      '(${item['package_category']})',
                                                      style: const TextStyle(
                                                        fontSize: 25.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            content: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const SizedBox(height: 8.0),
                                                Row(
                                                  children: [
                                                    const Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        'Stocks',
                                                        style: TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        '${item['no_item_received']}',
                                                        style: const TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors.black,
                                                        ),
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
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  String enteredQuantity = quantityController.text;

                                                  if (enteredQuantity != null && enteredQuantity.isNotEmpty && int.tryParse(enteredQuantity) != 0) {
                                                    setState(() {
                                                      items[selectedItemIndex]['quantity'] = enteredQuantity;
                                                    });

                                                    Navigator.pop(context); // Close the dialog
                                                  } else {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text('Invalid Quantity'),
                                                          content: const Text('Please enter a valid quantity.'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(context); // Close the dialog
                                                              },
                                                              child: const Text('OK'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                                child: const Text('Apply'),
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
                                              ],
                                            ),
                                            items[index]['quantity'] != null &&
                                                items[index]['quantity'] != '1' &&
                                                items[index]['quantity'] != 1 &&
                                                items[index]['selling_category'] != 'Retail'
                                                ? Text(
                                              '${items[index]['quantity']} Sacks',
                                              style: const TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              ),
                                            )
                                                : const SizedBox(),
                                            const SizedBox(height: 8.0),
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



                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 25,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (items.isEmpty) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Cannot Pullout Items', style: TextStyle(fontSize: 32)),
                                          content: const Text('The list is empty. Cannot pullout items.', style: TextStyle(fontSize: 24)),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Cancel', style: TextStyle(fontSize: 24)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            ElevatedButton(
                                              child: const Text('OK', style: TextStyle(fontSize: 24)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.red,
                                              ),
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
                                          title: const Text('Confirm Pullout Items', style: TextStyle(fontSize: 32)),
                                          content: const Text('Are you sure about the requested items?', style: TextStyle(fontSize: 24)),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Cancel', style: TextStyle(fontSize: 24)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            ElevatedButton(
                                              child: const Text('Request', style: TextStyle(fontSize: 24)),
                                              onPressed: () {
                                                requestPullOut();
                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.green,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                  }
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
                                      'assets/icons/request-sent-svgrepo-com.svg',
                                      width: 40,
                                      height: 40,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 15,),
                                    const Text(
                                      'Request Reprice',
                                      style: TextStyle(fontSize: 30),
                                    ),
                                  ],
                                ),
                              ),
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



