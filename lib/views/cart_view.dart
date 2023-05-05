import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rice_dealer_pos/modals/add_cart_modal.dart';
import 'package:rice_dealer_pos/modals/confirm_modal.dart';
import 'package:rice_dealer_pos/components/clock_widget.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';



class CartView extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  CartView({required this.cartItems});

  @override
  _CartViewState createState() => _CartViewState();
}

class _CartViewState extends State<CartView>{

  List<Map<String, dynamic>> items = []; // Use widget.cartItems to access the cartItems passed from the previous page
  List<String> itemNames = [];
  double total = 0.0;
  double grandTotal = 0.0;
  TextEditingController totalController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController grandTotalController = TextEditingController();

  void addItemToList(List<String> dataList) {

    setState(() {
      Map<String, dynamic> newItem = {
        'id': dataList[4],
        'itemName': dataList[0],
        'price': dataList[1],
        'quantity': dataList[2],
        'total': dataList[3],
      };

      items.add(newItem);

      itemNames = items.map<String>((item) => item['itemName'].toString()).toList();

      print(itemNames);

      total = _calculateTotal();
      totalController.text = total.toStringAsFixed(2);
      updateGrandTotal();
      discountController.text = '0';
    });
  }

  void checkout() async {
    // Create the data object
    Map<String, dynamic> data = {
      'grandTotal': grandTotal,
      'items': items,
    };

    print(data);

    try {
      await DatabaseHelper.sendDataToServer(data);
      clearCartItems();
    } catch (e) {
      print('Failed to send data: $e');
    }
  }


  void handleDiscountInput(String discountValue) {
    double discountPercentage = 0.0;
    if (discountValue.isNotEmpty) {
      int discount = int.parse(discountValue);
      if (discount >= 0 && discount <= 100) {
        discountPercentage = discount / 100.0;
      } else if (discount > 100) {
        discountPercentage = 1.0; // Set the discount to 100% if the value is greater than 100
        discountController.text = '100'; // Update the discount field to display 100
      }
    }
    grandTotal = calculateGrandTotal(total, discountPercentage);
    grandTotalController.text = grandTotal.toStringAsFixed(2);
  }



  double calculateGrandTotal(double originalTotal, double discountPercentage) {
    double discountAmount = originalTotal * discountPercentage;
    return originalTotal - discountAmount;
  }

  double _calculateTotal() {
    double total = 0.0;
    for (var item in items) {
      String totalString = item['total'].replaceAll('₱', '');
      total += double.parse(totalString);
    }
    return total;
  }

  void removeItemFromList(int index) {
    setState(() {
      // Get the total value of the removed item
      double removedTotal = double.parse(items[index]['total'].replaceAll('₱', ''));

      // Remove the item from the list
      items.removeAt(index);
      itemNames.removeAt(index);

      // Deduct the total value of the removed item from the grand total
      total -= removedTotal;

      // Update the value of totalController
      totalController.text = total.toStringAsFixed(2);
      updateGrandTotal();
    });
  }

  void updateGrandTotal() {
    if (discountController.text.isNotEmpty) {
      double discountPercentage = double.parse(discountController.text) / 100.0;
      grandTotal = calculateGrandTotal(total, discountPercentage);
    } else {
      grandTotal = total;
    }
    grandTotalController.text = grandTotal.toStringAsFixed(2);
  }

  void clearCartItems() {
    setState(() {
      items.clear();
      itemNames.clear();
      total = 0.0;
      grandTotal = 0.0;
      totalController.text = total.toStringAsFixed(2);
      grandTotalController.text = grandTotal.toStringAsFixed(2);
    });

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    items = widget.cartItems;
    itemNames = items.map<String>((item) => item['itemName'].toString()).toList();
    total = _calculateTotal();
    totalController.text = total.toStringAsFixed(2);
    grandTotal = total;
    grandTotalController.text = grandTotal.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Container(), // add an empty Expanded widget to push the ClockWidget to the right
            ),
            ClockWidget(),
          ],
        ),
        automaticallyImplyLeading: false,
        flexibleSpace: Padding(
          padding: EdgeInsets.only(left: 16.0, top: 13.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Cart",
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
                  flex: 5,
                  child: Container(
                    color: Colors.grey[300],
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[200]!),
                        dividerThickness: 2.0,
                        dataRowHeight: 80.0,
                        dataTextStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                        ),
                        columns: const <DataColumn>[
                          DataColumn(
                            label: SizedBox(
                              width: 250,
                              child: Text(
                                'Product Name',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Action',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ],
                        rows: List<DataRow>.generate(
                          items.length,
                              (index) {
                            final item = items[index];
                            final color = index % 2 == 0 ? Colors.grey[300]! : Colors.grey[200]!;
                            return DataRow(
                              color: MaterialStateColor.resolveWith((states) => color),
                              cells: <DataCell>[
                                DataCell(Text(item['itemName'])),
                                DataCell(Text('₱${item['price']}')),
                                DataCell(Text('${item['quantity']}')),
                                DataCell(Text('₱${item['total']}')),
                                DataCell(
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        removeItemFromList(index);
                                      });
                                    },
                                    child: Text('Remove'),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red[400]!),
                                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                    ),
                                  ),
                                ),
                              ],
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
                    color: Colors.blue,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex:1,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddCartModal(
                                  title: 'Add Product',
                                  message: 'This is the message.',
                                  items: itemNames,
                                ),
                              ).then((result) {
                                // Handle the returned data list here
                                if (result != null && result is List<String>) {
                                  // Process the received data list
                                  addItemToList(result);
                                }
                              });
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all<Size>(
                                Size(200, 150), // Set the width and height of the button
                              ),
                            ),
                            child: Text(
                              "Add Item",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Column(
                            children: [
                              Text(
                                'Total Price',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextFormField(
                                enabled: false,
                                controller: totalController,
                                decoration: InputDecoration(
                                  hintText: 'Total Price',
                                  border: OutlineInputBorder(),
                                  prefix: Text(
                                    '₱',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Discount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Discount',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                  FilteringTextInputFormatter.deny(RegExp(r'^101(\.0{0,2})?$')), // Disallow 100 and values greater than 100
                                ],
                                onChanged: handleDiscountInput,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Grand Total',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextFormField(
                                enabled: false,
                                controller: grandTotalController,
                                decoration: InputDecoration(
                                  hintText: 'Grand Total',
                                  border: OutlineInputBorder(),
                                  prefix: Text(
                                    '₱',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),


                        Flexible(
                          flex: 1,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all<Size>(
                                Size(200, 150), // Set the width and height of the button
                              ),
                            ),
                            onPressed: items.isEmpty ? null : () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ConfirmModal(
                                    message: 'Are you sure you want to checkout?',
                                    onConfirm: () async {
                                      try {
                                        print(items);
                                        checkout();
                                      } catch (e) {
                                        print('Failed to send data: $e');
                                      }
                                    },
                                    onCancel: () {},
                                  );
                                },
                              );
                            },
                            child: Text(
                              'Checkout',
                              style: TextStyle(
                                fontSize: 20,
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



