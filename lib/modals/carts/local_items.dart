import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LocalItems extends StatefulWidget {
  final bool receiptCheck;
  final String? selectedPackage;
  final List<Map<String, dynamic>> items;
  final Future<List<Map<String, dynamic>>> Function() fetchRetails;
  final Future<List<Map<String, dynamic>>> Function() fetchProductList;
  final void Function(Map<String, dynamic>) addItemToCart;
  final void Function() calculateSubTotal;
  final TextEditingController quantityController;
  final TextEditingController totalPriceController;
  final Future<List<Map<String, dynamic>>> fetchRetailsLate;
  final Future<List<Map<String, dynamic>>> fetchWholesalesLate;

  const LocalItems({
    required this.receiptCheck,
    required this.selectedPackage,
    required this.items,
    required this.fetchRetails,
    required this.fetchProductList,
    required this.addItemToCart,
    required this.calculateSubTotal,
    required this.quantityController,
    required this.totalPriceController,
    required this.fetchRetailsLate,
    required this.fetchWholesalesLate,
  });

  @override
  _LocalItemsState createState() => _LocalItemsState();
}

class _LocalItemsState extends State<LocalItems> {

  @override
  void initState(){
    super.initState();
    fetchRetails = widget.fetchRetails();
    fetchWholesales = widget.fetchProductList();
  }

  late Future<List<Map<String, dynamic>>> fetchRetails;
  late Future<List<Map<String, dynamic>>> fetchWholesales;


  List<String> retailButtonList = ['0.25KG', '0.50KG', '1.00KG', '3.00KG', '5.00KG', '10.0KG'];
  List<String> bagButtonList = ['1 Bag', '2 Bags', '3 Bags', '5 Bags', '8 Bags', '10 Bags'];

  List<List<String>> getRetailButtonList() {
    return [
      retailButtonList.sublist(0, 3),
      retailButtonList.sublist(3, 6),
    ];
  }

  List<List<String>> getBagButtonList() {
    return [
      bagButtonList.sublist(0, 3),
      bagButtonList.sublist(3, 6),
    ];
  }

  @override
  Widget build(BuildContext context) {

    if (widget.receiptCheck){
      fetchRetails = widget.fetchRetails();
      fetchWholesales = widget.fetchProductList();
    }


    return Expanded(
      child: Container(
        color: Colors.grey[300],
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: widget.selectedPackage == '1KG' ? fetchRetails : fetchWholesales,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final productList = snapshot.data!;

              final filteredProducts = productList.where((product) =>
              product['package_category'] == widget.selectedPackage &&
                  product['rice_category'] == 'Local' &&
                  product['no_item_received'] != null &&
                  product['cost'] != null &&
                  product['selling_price'] != null).toList();

              if (filteredProducts.isEmpty || widget.receiptCheck == true) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: widget.receiptCheck
                          ? Container(
                        width: 150,
                        height: 150,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 100,
                          color: Colors.white,
                        ),
                      )
                          : SvgPicture.asset(
                        'assets/icons/grains-wheat-svgrepo-com.svg',
                        width: 100,
                        height: 100,
                        colorFilter: null,
                      ),
                    ),
                    const SizedBox(height: 25,),
                    Center(
                      child: Text(
                        widget.receiptCheck ? 'Finished a transaction!' : 'Currently No Products For ${widget.selectedPackage == '1KG' ? 'Retails' : widget.selectedPackage}.',
                        style: const TextStyle(fontSize: 32, color: Colors.black, fontFamily: 'Poppins', fontWeight: FontWeight.w200),
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
                    return Container(
                      margin: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () {

                          // setState(() {
                          //   fetchRetails =  widget.fetchRetails();
                          //   fetchWholesales = widget.fetchProductList();
                          // });

                          fetchWholesales = widget.fetchProductList();
                          fetchRetails = widget.fetchRetails();

                          if (widget.selectedPackage == '1KG') {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  elevation: 1,
                                  insetPadding: const EdgeInsets.only(right: 325),
                                  title: Text('Select Retail Amount: ${product['item_name']}', style: const TextStyle(fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.w400,)),
                                  content: SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.50,
                                    width: MediaQuery.of(context).size.height * 0.90,
                                    child: Column(
                                      children: [
                                        Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          children: getRetailButtonList()[0].map<Widget>((buttonText) {


                                            return Container(
                                              child: _buildButton(buttonText, () {
                                                product['package_category'] = buttonText;
                                                product['selling_category'] = 'Retail';


                                                final noItemReceived = product['no_item_received'];
                                                double? maxQuantity;

                                                if (noItemReceived is double) {
                                                  maxQuantity = noItemReceived;
                                                } else if (noItemReceived is String) {
                                                  maxQuantity = double.tryParse(noItemReceived);
                                                } else if (noItemReceived is int) {
                                                  maxQuantity = noItemReceived.toDouble();
                                                }

                                                final packageCategory = product['package_category'];
                                                final packageAmount = double.tryParse(packageCategory.replaceAll('KG', '')) ?? 0.0;

                                                if (!product.containsKey('quantity')) {
                                                  product['quantity'] = packageAmount;
                                                }

                                                double currentQuantity = 0.0;
                                                final itemIndex = widget.items.indexWhere((item) => item['item_id'] == product['item_id'] && item['selling_category'] == 'Retail');
                                                if (itemIndex != -1) {
                                                  currentQuantity = double.parse(widget.items[itemIndex]['quantity'].toString());
                                                }

                                                final itemSellingPrice = double.parse(product['selling_price']) * packageAmount;
                                                final itemCostPrice = double.parse(product['cost']) * packageAmount;

                                                product['total_price'] = itemSellingPrice.toStringAsFixed(2);
                                                product['total_cost'] = itemCostPrice.toStringAsFixed(2);



                                                if (currentQuantity + packageAmount <= maxQuantity!) {
                                                  widget.addItemToCart(product);
                                                } else {
                                                  // product.remove('quantity');
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text('Warning', style: TextStyle(color: Colors.red, fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.w400)),
                                                        content: const Text('Package amount exceeds available quantity.', style: TextStyle(fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.w200)),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(context); // Close the dialog
                                                            },
                                                            child: const Text('OK', style: TextStyle(fontSize: 32, color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w400)),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              }),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          children: getRetailButtonList()[1].map<Widget>((buttonText) {
                                            return _buildButton(buttonText, () {
                                              product['package_category'] = buttonText;
                                              product['selling_category'] = 'Retail';

                                              final noItemReceived = product['no_item_received'];
                                              double? maxQuantity;

                                              if (noItemReceived is double) {
                                                maxQuantity = noItemReceived;
                                              } else if (noItemReceived is String) {
                                                maxQuantity = double.tryParse(noItemReceived);
                                              } else if (noItemReceived is int) {
                                                maxQuantity = noItemReceived.toDouble();
                                              }

                                              final packageCategory = product['package_category'];
                                              final packageAmount = double.tryParse(packageCategory.replaceAll('KG', '')) ?? 0.0;

                                              if (!product.containsKey('quantity')) {
                                                product['quantity'] = packageAmount;
                                              }

                                              double currentQuantity = 0.0;
                                              final itemIndex = widget.items.indexWhere((item) => item['item_id'] == product['item_id'] && item['selling_category'] == 'Retail');
                                              if (itemIndex != -1) {
                                                currentQuantity = widget.items[itemIndex]['quantity'];
                                              }

                                              final itemSellingPrice = double.parse(product['selling_price']) * packageAmount;
                                              final itemCostPrice = double.parse(product['cost']) * packageAmount;

                                              product['total_price'] = itemSellingPrice.toStringAsFixed(2);
                                              product['total_cost'] = itemCostPrice.toStringAsFixed(2);


                                              if (currentQuantity + packageAmount <= maxQuantity!) {
                                                widget.addItemToCart(product);
                                              } else {
                                                // product.remove('quantity');
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text('Warning', style: TextStyle(color: Colors.red, fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.w400)),
                                                      content: const Text('Package amount exceeds available quantity.', style: TextStyle(fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.w200)),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context); // Close the dialog
                                                          },
                                                          child: const Text('OK', style: TextStyle(fontSize: 32, color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w400)),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            });
                                          }).toList(),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: '${product['item_name']} Stocks: ',
                                                ),
                                                TextSpan(
                                                  text:
                                                  '${product['no_item_received']}KG',
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.bold,
                                                    color: double.parse(product['no_item_received'].toString()) > double.parse('30')
                                                        ? Colors.green
                                                        : double.parse(product['no_item_received'].toString()) > double.parse('10')
                                                        ? Colors.orange
                                                        : Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  elevation: 1,
                                  insetPadding: const EdgeInsets.only(right: 325),
                                  title: Text('Select Bag Amount: ${product['item_name']}', style: const TextStyle(fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.w400,)),
                                  content: SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.50,
                                    width: MediaQuery.of(context).size.height * 0.90,
                                    child: Column(
                                      children: [
                                        Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          children: getBagButtonList()[0].map<Widget>((buttonText) {
                                            return Container(
                                              child: _buildButton(buttonText, () {
                                                // Assuming buttonText is in the format '1 Bag', '2 Bags', etc.
                                                final List<String> parts = buttonText.split(' '); // Split the string by space
                                                final double bagQuantity = double.parse(parts[0]) ?? 0; // Extract the integer value or default to 0
                                                final noItemReceived = product['no_item_received'];
                                                double? maxQuantity;

                                                if (noItemReceived is double) {
                                                  maxQuantity = noItemReceived;
                                                } else if (noItemReceived is String) {
                                                  maxQuantity = double.tryParse(noItemReceived);
                                                } else if (noItemReceived is int) {
                                                  maxQuantity = noItemReceived.toDouble();
                                                }

                                                double currentQuantity = 0.0;
                                                final itemIndex = widget.items.indexWhere((item) => item['item_id'] == product['item_id']);
                                                if (itemIndex != -1) {
                                                  currentQuantity = widget.items[itemIndex]['quantity'];
                                                }

                                                product['quantity_to_add'] = bagQuantity;


                                                final itemSellingPrice = double.parse(product['selling_price']) * bagQuantity;
                                                final itemCostPrice = double.parse(product['cost']) * bagQuantity;

                                                product['total_price'] = itemSellingPrice.toStringAsFixed(2);
                                                product['total_cost'] = itemCostPrice.toStringAsFixed(2);



                                                if (currentQuantity + bagQuantity <= maxQuantity!) {
                                                  widget.addItemToCart(product);
                                                } else {
                                                  // product.remove('quantity');
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text('Warning', style: TextStyle(color: Colors.red, fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.w400)),
                                                        content: const Text('Bag amount exceeds available quantity.', style: TextStyle(fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.w200)),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(context); // Close the dialog
                                                            },
                                                            child: const Text('OK', style: TextStyle(fontSize: 32, color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w400)),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              }),
                                            );
                                          }).toList(),
                                        ),
                                        Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          children: getBagButtonList()[1].map<Widget>((buttonText) {
                                            return Container(
                                              child: _buildButton(buttonText, () {
                                                final List<String> parts = buttonText.split(' '); // Split the string by space
                                                final double bagQuantity = double.parse(parts[0]) ?? 0; // Extract the integer value or default to 0
                                                final noItemReceived = product['no_item_received'];
                                                double? maxQuantity;

                                                if (noItemReceived is double) {
                                                  maxQuantity = noItemReceived;
                                                } else if (noItemReceived is String) {
                                                  maxQuantity = double.tryParse(noItemReceived);
                                                } else if (noItemReceived is int) {
                                                  maxQuantity = noItemReceived.toDouble();
                                                }

                                                double currentQuantity = 0.0;
                                                final itemIndex = widget.items.indexWhere((item) => item['item_id'] == product['item_id']);
                                                if (itemIndex != -1) {
                                                  currentQuantity = widget.items[itemIndex]['quantity'];
                                                }

                                                product['quantity_to_add'] = bagQuantity;


                                                final itemSellingPrice = double.parse(product['selling_price']) * bagQuantity;
                                                final itemCostPrice = double.parse(product['cost']) * bagQuantity;

                                                product['total_price'] = itemSellingPrice.toStringAsFixed(2);
                                                product['total_cost'] = itemCostPrice.toStringAsFixed(2);



                                                if (currentQuantity + bagQuantity <= maxQuantity!) {
                                                  widget.addItemToCart(product);
                                                } else {
                                                  // product.remove('quantity');
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text('Warning', style: TextStyle(color: Colors.red, fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.w400)),
                                                        content: const Text('Bag amount exceeds available quantity.', style: TextStyle(fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.w200)),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(context); // Close the dialog
                                                            },
                                                            child: const Text('OK', style: TextStyle(fontSize: 32, color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w400)),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              }),
                                            );
                                          }).toList(),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'Remaining ${product['item_name']} Bag Stocks: ',
                                                ),
                                                TextSpan(
                                                  text:
                                                  '${product['no_item_received']} Bags',
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.bold,
                                                    color: double.parse(product['no_item_received'].toString()) > double.parse('30')
                                                        ? Colors.green
                                                        : double.parse(product['no_item_received'].toString()) > double.parse('10')
                                                        ? Colors.orange
                                                        : Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                            // widget.addItemToCart(product);
                            // widget.calculateSubTotal();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xff232d37)),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              product['item_name'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            if (widget.selectedPackage == '1KG')
                            Text(
                              '${product['no_item_received'].toString()} KG',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            if (widget.selectedPackage != '1KG')
                              Text(
                                '${product['no_item_received'].toString()} Bags',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                ),
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
    );
  }
}


Widget _buildButton(String buttonText, VoidCallback onPressed) {
  return Container(
    width: 220,
    height: 150,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(50.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        side: const BorderSide(color: Colors.black),
        backgroundColor: Colors.grey[300],
      ),
      child: Text(buttonText, style: const TextStyle(fontSize: 32, color: Colors.black, fontFamily: 'Poppins', fontWeight: FontWeight.w400)),
    ),
  );
}

