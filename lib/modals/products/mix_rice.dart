
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rice_dealer_pos/components/clock_widget.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rice_dealer_pos/views/settings_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rice_dealer_pos/state_manager.dart';

enum StateType { local, foreign}

class MixWholesale extends StatefulWidget {
  final Function(int) onSelectIndex;
  final Map<String, dynamic>? product;

  MixWholesale({required this.onSelectIndex, required this.product});

  @override
  _MixWholesaleState createState() => _MixWholesaleState();
}

class _MixWholesaleState extends State<MixWholesale>{

  StateType _currentState = StateType.local;
  late int selectedItemIndex;

  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> packages = [];
  String selectedPackage = '1KG';
  List<Map<String, dynamic>> allProducts = [];
  bool addedAnItem = false;

  List<String> itemNames = [];

  TextEditingController quantityController = TextEditingController();
  TextEditingController originalQuantityController = TextEditingController();

  TextEditingController totalQuantityController = TextEditingController();
  TextEditingController originalTotalQuantityController = TextEditingController();



  // void fetchPackages() async{
  //   final data = await DatabaseHelper.getAllPackages();
  //
  //   setState(() {
  //     packages = List<Map<String, dynamic>>.from(data);
  //   });
  //
  //   if (packages.isNotEmpty) {
  //     selectedPackage = packages[0]['package'];
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchRetails(Map<String, dynamic>? product) async {
    try {
      final data = await DatabaseHelper.getRetails();
      final sellingPrice = product!['selling_price'];

      final retailsList = List<Map<String, dynamic>>.from(data)
          .where((item) =>
      item['selling_price'] == sellingPrice &&
          item['item_id'] != product!['item_id'])
          .toList();


      return retailsList;
    } catch (e) {
      return []; // Return an empty list if there is an error
    }

  }

  Future<List<Map<String, dynamic>>> fetchProductList() async {
    try {
      final data = await DatabaseHelper.getProducts();

      final productList = List<Map<String, dynamic>>.from(data);
      return productList;
    } catch (e) {
      return []; // Return an empty list if there is an error
    }
  }


  void addItemToCart(Map<String, dynamic> item) {
    setState(() {
      items.add(item);
    });



  }

  void removeItemFromCart(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void mixRice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? user_id = await prefs.getInt('loggedInUserId');

    Map<String, dynamic> data = {
      'userId': user_id,
      'branchId': branchId,
      'out_item_id': widget.product!['item_id'],
      'in_item_id': items[0]['item_id'],
      'no_item_difference': quantityController.text,
    };

    print(data);
    try {
      await DatabaseHelper.mixRice(data);

      // Navigate to another page
      widget.onSelectIndex(2); // Access the callback function through the widget property
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
    // fetchPackages();
    selectedPackage = '1KG';
  }

  @override
  Widget build(BuildContext context) {

    originalQuantityController.text = widget.product!['no_item_received'].toString();

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
                  widget.onSelectIndex(2); // Navigates back when the button is pressed
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
                "| Mix Rice",
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
                          width: double.infinity,
                          color: const Color(0xff394a5a),
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
                              primary: selectedPackage == '1KG' ? Color(0xff232d37) : Color(0xff394a5a),
                              // Apply any other styles or conditions based on the selected package
                            ),
                            child: const Text('Retail', style: TextStyle(fontSize: 24)),
                          ),
                        ),



                        if (_currentState == StateType.local)
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              child: FutureBuilder<List<Map<String, dynamic>>>(
                                future: selectedPackage == '1KG' ? fetchRetails(widget.product) : fetchProductList(),
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
                                                if (items.isNotEmpty) {
                                                  return; // Item already exists in cartItems, so return early and disable the button
                                                }

                                                // product['quantity'] = product['no_item_received'];
                                                addItemToCart(product);

                                              },

                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: items.isNotEmpty
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
                                future: selectedPackage == '1KG' ? fetchRetails(widget.product) : fetchProductList(),
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
                                                if (items.isNotEmpty) {
                                                  return; // Item already exists in cartItems, so return early and disable the button
                                                }
                                                // product['quantity'] = product['no_item_received'];
                                                addItemToCart(product);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: items.isNotEmpty
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
                  child: Container(
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Container(
                              height: 25,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text('SELECTED RICE:', style: TextStyle(color: Colors.black, fontSize: 24),),

                                  SizedBox(height: 32.0),

                                  Row(
                                    children: [
                                      Text(
                                        widget.product!['item_name'],
                                        style: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        ' - ${widget.product!['rice_category']}',
                                        style: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        ' (${widget.product!['package_category']})',
                                        style: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text('Stocks in KG:', style: TextStyle(fontSize: 20, color: Colors.black),)
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: originalQuantityController,
                                          enabled: false,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                          ),
                                          decoration: InputDecoration(
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.black,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),


                                  Text('Quantity to mix:', style: TextStyle(color: Colors.black, fontSize: 18),),

                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          controller: quantityController,
                                          enabled: !addedAnItem,
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                          decoration: InputDecoration(
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.black,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.black,
                                              ),
                                            ),
                                            suffixText: 'KG', // Add the suffix 'KG' here
                                            suffixStyle: TextStyle(
                                              color: Colors.black, // Customize the suffix text color if needed
                                            ),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}$')),
                                          ],
                                          keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false), // Set keyboard prompt to an integer
                                          onChanged: (value) {

                                            if (value.isEmpty) {
                                              quantityController.text = '';
                                              return;
                                            }
                                            double? enteredQuantity = double.parse(quantityController.text);

                                            double maxQuantity = double.parse(originalQuantityController.text);
                                            print(maxQuantity);

                                            if (enteredQuantity == null || enteredQuantity < 0 || enteredQuantity > maxQuantity) {
                                              enteredQuantity = enteredQuantity?.clamp(0, maxQuantity)?.toDouble();
                                              quantityController.text = enteredQuantity.toString();
                                            }
                                          },
                                        ),

                                      ),
                                      SizedBox(width: 8), // Adjust the spacing between the button and the text field

                                      Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          onPressed: addedAnItem || items.isEmpty ? null : () {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Confirmation'),
                                                  content: Text('Confirm addition?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        double enteredQuantity = double.tryParse(quantityController.text) ?? 0;
                                                        double maxQuantity = double.parse(widget.product!['no_item_received'].toString());
                                                        double currentTotalQuantity = double.tryParse(originalTotalQuantityController.text) ?? 0.0;

                                                        if (enteredQuantity < 0 || enteredQuantity > maxQuantity) {
                                                          enteredQuantity = enteredQuantity.clamp(0, maxQuantity).toDouble();
                                                          quantityController.text = enteredQuantity.toString();
                                                        }

                                                        double totalQuantity = currentTotalQuantity + enteredQuantity;
                                                        double updatedMaxQuantity = maxQuantity - enteredQuantity;

                                                        setState(() {
                                                          widget.product!['no_item_received'] = updatedMaxQuantity.toString();
                                                          // quantityController.text = '';
                                                          originalQuantityController.text = updatedMaxQuantity.toString();

                                                          WidgetsBinding.instance!.addPostFrameCallback((_) {
                                                            totalQuantityController.text = totalQuantity.toStringAsFixed(2);
                                                          });

                                                          addedAnItem = true;
                                                        });

                                                        Navigator.pop(context); // Close the dialog
                                                      },
                                                      child: Text('Confirm'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          addedAnItem = false;
                                                        });
                                                        Navigator.pop(context); // Close the dialog
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text('Add'),
                                          style: ButtonStyle(
                                            backgroundColor: addedAnItem || items.isEmpty ? MaterialStateProperty.all(Colors.grey) : null,
                                          ),
                                        )
                                        ,
                                      ),
                                    ],
                                  ),



                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left:32.0, right:32.0),
                          child: Divider(
                            color: Colors.grey[800], // Set the color of the divider to black
                            thickness: 2.0, // Set the width of the divider to 5
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];

                              // totalQuantityController.text = item['no_item_received'].toString();

                              originalTotalQuantityController.text = item['no_item_received'].toString();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left:32, right: 32, top: 16,),
                                    child: Text('RICE TO MIX WITH:', style: TextStyle(color: Colors.black, fontSize: 24),),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.all(32.0),
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
                                                    item['item_name'],
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
                                                    ' (${item['package_category']})',
                                                    style: const TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                'Stocks: ${item['no_item_received']}${item['package_category'] == '1KG' ? ' KG' : ' KG'}',
                                                style: const TextStyle(
                                                  fontSize: 20.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!addedAnItem)
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
                                        if(addedAnItem)
                                          Expanded(
                                            flex: 1,
                                            child: IconButton(
                                              icon: const Icon(Icons.delete),
                                              color: Colors.grey,
                                              onPressed: () {
                                                return null;
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.only(left:32.0, right: 32),
                                      decoration: BoxDecoration(
                                        color: index % 2 == 0 ? Colors.grey[300] : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                      child: Text('Stocks after mixing:', style: TextStyle(color: Colors.black, fontSize: 18),)),

                                  Container(
                                    padding: const EdgeInsets.only(left:32.0, right: 32),
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0 ? Colors.grey[300] : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: TextFormField(
                                            controller: totalQuantityController,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                            decoration: InputDecoration(
                                              labelStyle: TextStyle(
                                                color: Colors.black,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.black,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.black,
                                                ),
                                              ),
                                              suffixText: 'KG', // Add the suffix 'KG' here
                                              suffixStyle: TextStyle(
                                                color: Colors.black, // Customize the suffix text color if needed
                                              ),
                                            ),

                                          ),

                                        ),
                                        SizedBox(width: 8), // Adjust the spacing between the button and the text field

                                        Expanded(
                                          flex: 1,
                                          child: ElevatedButton(
                                            onPressed: !addedAnItem ? null : () {

                                              double originalQuantity = double.tryParse(originalTotalQuantityController.text) ?? 0.0;
                                              double totalQuantity = double.tryParse(totalQuantityController.text) ?? 0.0;

                                              double deductedQuantity = totalQuantity - originalQuantity;


                                              double currentQuantity = double.tryParse(originalQuantityController.text) ?? 0.0;
                                              double updatedQuantity = currentQuantity + deductedQuantity;

                                              setState(() {
                                                addedAnItem = false;
                                                WidgetsBinding.instance!.addPostFrameCallback((_) {
                                                  originalQuantityController.text = updatedQuantity.toStringAsFixed(2);
                                                  totalQuantityController.text = originalTotalQuantityController.text;
                                                });
                                                widget.product!['no_item_received'] = updatedQuantity.toString();
                                                quantityController.text = '';
                                              });

                                            },
                                            child: Text('RMV.'),
                                            style: ButtonStyle(
                                              backgroundColor: addedAnItem
                                                  ? MaterialStateProperty.all(Colors.red)
                                                  : MaterialStateProperty.all(Colors.grey),
                                            ),

                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),



                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 25,
                            child: ElevatedButton(
                              onPressed: !addedAnItem ? null : () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Mixing Rice', style: TextStyle(fontSize: 32)),
                                      content: const Text('Are you sure about the items being mixed?', style: TextStyle(fontSize: 24)),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel', style: TextStyle(fontSize: 24)),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ElevatedButton(
                                          child: const Text('Mix Rice', style: TextStyle(fontSize: 24)),
                                          onPressed: () {
                                            mixRice();
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
                              },
                              style: ButtonStyle(
                                backgroundColor: addedAnItem
                                    ? MaterialStateProperty.all(Colors.green)
                                    : MaterialStateProperty.all(Colors.grey),
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
                                      'Mix Rice',
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



