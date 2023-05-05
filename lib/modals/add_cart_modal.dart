import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';
import 'package:rice_dealer_pos/views/cart_view.dart';

class AddCartModal extends StatefulWidget {

  final String title;
  final String message;
  final List items;

  AddCartModal({required this.title, required this.message, required this.items});

  @override
  _AddCartState createState() => _AddCartState();
}

class _AddCartState extends State<AddCartModal> {
  List<Map<String, dynamic>> products = [];


  Future<List<String>> fetchProductNames() async {

    final itemNames = widget.items;
    print(itemNames);

    final data = await DatabaseHelper.getProducts();
    final List<Map<String, dynamic>> productList =
    List<Map<String, dynamic>>.from(data);
    final List<String> productNames = productList
        .map((product) => product['product_name'] as String)
        .toList();

    productNames.removeWhere((productName) => itemNames.contains(productName));

    return productNames;

  }

  Future<void> fetchProductData(String productName) async {
    final productList = await DatabaseHelper.getProducts();

    final selectedProduct = productList.firstWhere(
          (product) => product['product_name'] == productName,
      orElse: () => null,
    );

    if (selectedProduct != null) {
      setState(() {

        selectedPrice = selectedProduct['srp'].toString();
        selectedStock = selectedProduct['stock'].toString();
        selectedProductId = selectedProduct['id'].toString();
      });
    }
  }

  String selectedField = 'Product';
  String selectedPrice = 'Product Price';
  String selectedStock = 'Product Stock';
  String selectedProductId = '';

  double totalPrice = 0.0;


  final TextEditingController quantityController = TextEditingController();

  final TextEditingController totalPriceController = TextEditingController();

  void calculateTotalPrice() {
    final double quantity = double.tryParse(quantityController.text) ?? 0;
    final double price = double.tryParse(selectedPrice) ?? 0;
    final double totalPrice = quantity * price;

    setState(() {
      this.totalPrice = totalPrice;
      totalPriceController.text = totalPrice.toStringAsFixed(2);
    });
  }


  final FocusNode quantityFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchProductNames();
    quantityFocusNode.addListener(() {
      if (!quantityFocusNode.hasFocus) {
        calculateTotalPrice();
      }
    });
  }

  @override
  void dispose() {
    quantityController.dispose();
    totalPriceController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Dialog(

      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Container(
              width: 600,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select an item:'),
                  Container(
                    child: LayoutBuilder(
                      builder: (_, BoxConstraints constraints) => Autocomplete<String>(
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              child: SizedBox(
                                width: constraints.maxWidth,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return ListTile(
                                      title: Text(options.elementAt(index)),
                                      onTap: () {
                                        setState(() {
                                          selectedField = options.elementAt(index);
                                        });
                                        onSelected(selectedField);
                                        fetchProductData(selectedField);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        optionsBuilder: (TextEditingValue textEditingValue) async {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          final List<String> productNames = await fetchProductNames();
                          return productNames.where((productName) =>
                              productName.toLowerCase().startsWith(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selection) {
                          // Handle selection
                        }, displayStringForOption: (String option) => option,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
                width: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity'),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              enabled: selectedField != 'Product', // Enable/disable based on selectedField
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  final double quantity = double.tryParse(value) ?? 0;
                                  final double stock = double.tryParse(selectedStock) ?? 0;
                                  if (quantity > stock) {
                                    setState(() {
                                      quantityController.text = selectedStock;
                                    });
                                  }
                                  calculateTotalPrice();
                                }
                                // Calculate total price whenever quantity changes
                              },
                            ),
                          ],
                        ),
                    ),



                    SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price'),
                              SizedBox(height: 8),
                              TextFormField(
                                enabled: false,
                                decoration: InputDecoration(
                                  hintText: '₱ ' + selectedPrice,
                                  border: OutlineInputBorder(),
                                ),
                              ),


                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Stock'),
                              SizedBox(height: 8),
                              TextFormField(
                                decoration: InputDecoration(
                                  enabled: false,
                                  hintText: selectedStock,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (
                selectedProductId.isNotEmpty &&
                    selectedField.isNotEmpty &&
                    selectedPrice.isNotEmpty &&
                    quantityController.text.isNotEmpty &&
                    totalPriceController.text.isNotEmpty) {
                  List<String> dataList = [
                    selectedField,
                    selectedPrice,
                    quantityController.text,
                    totalPriceController.text,
                    selectedProductId,
                  ];
                  Navigator.pop(context, dataList);
                } else {
                  // Show an error message or perform any other action
                }
              },
              child: Text('Add Item'),
            ),
            Container(
              width: 600, // set desired width
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Price'),
                  TextFormField(
                    enabled: false,
                    controller: totalPriceController,
                    decoration: InputDecoration(
                      hintText: totalPriceController.text,
                      border: OutlineInputBorder(),
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(height: 16),

          ],
        ),
      ),
    );
  }
}


