import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CartSection extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final TextEditingController quantityController;
  final TextEditingController totalPriceController;
  final TextEditingController discountController;
  final void Function(int) removeItemFromCart;
  final void Function() updateChangeAmount;
  final void Function() calculateSubTotal;


  const CartSection({
    required this.items,
    required this.quantityController,
    required this.totalPriceController,
    required this.discountController,
    required this.removeItemFromCart,
    required this.updateChangeAmount,
    required this.calculateSubTotal,
  });

  @override
  _CartSectionState createState() => _CartSectionState();
}

class _CartSectionState extends State<CartSection> {

  late int selectedItemIndex;
  @override
  Widget build(BuildContext context) {
    return                         Expanded(
      flex: 3,
      child: Container(
        color: Colors.grey[300],
        child: ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return Container(
              color: Colors.grey[300],
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedItemIndex = index;
                  });

                  widget.totalPriceController.text = double.parse(item['total_price']) != null ? double.parse(item['total_price']).toString() : double.parse(item['selling_price']).toString();

                  widget.quantityController.text = (widget.items[selectedItemIndex]['quantity'] ?? 1.00).toString();
                  widget.discountController.text = '0';

                  if (item['selling_category'] != 'Retail') {
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
                                      const Text(
                                        'Bags',
                                        style: TextStyle(
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
                                              controller: widget.totalPriceController,
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
                                                const Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Discount Amount:',
                                                      style: TextStyle(
                                                        fontSize: 24.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Row(
                                                    //   children: [
                                                    //     Ink(
                                                    //       decoration: const ShapeDecoration(
                                                    //         color: Colors.red,
                                                    //         shape: CircleBorder(),
                                                    //       ),
                                                    //       child: IconButton(
                                                    //         onPressed: () {
                                                    //           setState(() {
                                                    //             double currentValue = double.tryParse(widget.quantityController.text) ?? 0;
                                                    //             double newValue = currentValue - 1.00;
                                                    //
                                                    //             double totalPrice = double.parse(item['selling_price']) * newValue;
                                                    //
                                                    //             // Check if newValue is within the valid range
                                                    //             if (newValue >= 0) {
                                                    //               widget.quantityController.text = newValue.toString();
                                                    //               widget.totalPriceController.text = totalPrice.toStringAsFixed(2);
                                                    //             }
                                                    //           });
                                                    //         },
                                                    //         icon: const Icon(Icons.remove, color: Colors.white),
                                                    //         color: Colors.red,
                                                    //         padding: const EdgeInsets.all(24),
                                                    //         constraints: const BoxConstraints(),
                                                    //       ),
                                                    //     ),
                                                    //
                                                    //
                                                    //     SizedBox(
                                                    //       width: 150,
                                                    //       child: TextFormField(
                                                    //         textAlign: TextAlign.center,
                                                    //         controller: widget.quantityController,
                                                    //         keyboardType: TextInputType.number,
                                                    //         inputFormatters: <TextInputFormatter>[
                                                    //           FilteringTextInputFormatter.digitsOnly // Restrict input to digits only
                                                    //         ],
                                                    //         style: const TextStyle(color: Colors.black, fontSize: 24),
                                                    //         decoration: const InputDecoration(
                                                    //           labelStyle: TextStyle(color: Colors.black),
                                                    //           prefixStyle: TextStyle(color: Colors.black),
                                                    //           enabledBorder: UnderlineInputBorder(
                                                    //             borderSide: BorderSide(color: Colors.black),
                                                    //           ),
                                                    //         ),
                                                    //         onChanged: (value) {
                                                    //           setState(() {
                                                    //             // Parse the entered quantity
                                                    //             if (value.isEmpty) {
                                                    //               widget.totalPriceController.text = '0.00';
                                                    //             }
                                                    //             double enteredQuantity = double.tryParse(value) ?? 0;
                                                    //
                                                    //             // Calculate the maximum allowed quantity based on available stock
                                                    //             double maxQuantity = double.parse(item['no_item_received'].toString());
                                                    //
                                                    //             // Check if the entered quantity is negative or exceeds the maximum allowed quantity
                                                    //             if (enteredQuantity < 0 || enteredQuantity > maxQuantity) {
                                                    //               // Limit the quantity to the valid range
                                                    //               widget.quantityController.text = enteredQuantity.clamp(0, maxQuantity).toString();
                                                    //             }
                                                    //
                                                    //             // Update the total price
                                                    //             double totalPrice = double.parse(item['selling_price']) * double.parse(widget.quantityController.text);
                                                    //             widget.totalPriceController.text = totalPrice.toStringAsFixed(2);
                                                    //           });
                                                    //         },
                                                    //       ),
                                                    //     ),
                                                    //     Ink(
                                                    //       decoration: const ShapeDecoration(
                                                    //         color: Colors.green,
                                                    //         shape: CircleBorder(),
                                                    //       ),
                                                    //       child: IconButton(
                                                    //         onPressed: () {
                                                    //           setState(() {
                                                    //             double currentValue = double.tryParse(widget.quantityController.text) ?? 0;
                                                    //             double newValue = currentValue + 1.00;
                                                    //             double maxQuantity = double.parse(item['no_item_received'].toString());
                                                    //
                                                    //             double totalPrice = double.parse(item['selling_price']) * newValue;
                                                    //
                                                    //             // Check if newValue is within the valid range
                                                    //             if (newValue <= maxQuantity) {
                                                    //               widget.quantityController.text = newValue.toString();
                                                    //               widget.totalPriceController.text = totalPrice.toStringAsFixed(2);
                                                    //             }
                                                    //           });
                                                    //         },
                                                    //         icon: const Icon(Icons.add, color: Colors.white),
                                                    //         tooltip: 'Plus',
                                                    //         padding: const EdgeInsets.all(24),
                                                    //         constraints: const BoxConstraints(),
                                                    //       ),
                                                    //     ),
                                                    //
                                                    //
                                                    //   ],
                                                    // ),
                                                    const SizedBox(height: 25),

                                                    SizedBox(
                                                      width: 150,
                                                      child: TextFormField(
                                                        textAlign: TextAlign.center,

                                                        controller: widget.discountController,
                                                        enabled: true,
                                                        keyboardType: TextInputType.number, // Set the keyboardType to number

                                                        style: const TextStyle(color: Colors.black, fontSize: 24),
                                                        decoration: const InputDecoration(
                                                          prefixText: '₱',
                                                          labelStyle: TextStyle(color: Colors.black),
                                                          prefixStyle: TextStyle(color: Colors.black),
                                                          hintStyle: TextStyle(color: Colors.black),
                                                          enabledBorder: UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Colors.black),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            // Parse the entered discount value
                                                            double? discount = double.tryParse(value) ?? 0;
                                                            double? totalPrice = double.parse(item['selling_price']) * double.parse(widget.quantityController.text);
                                                            widget.totalPriceController.text = totalPrice.toStringAsFixed(2);


                                                            // Clamp the discount value to ensure it is within the valid range
                                                            discount = discount.clamp(0, totalPrice) as double?;

                                                            // Update the TextFormField with the clamped discount value
                                                            // discountController.text = discount.toString();
                                                          });
                                                        },
                                                      ),
                                                    ),
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
                                                const Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Discount:',
                                                      style: TextStyle(
                                                        fontSize: 26.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 25),
                                                    SizedBox(
                                                      width: 150,
                                                      child: TextFormField(
                                                        textAlign: TextAlign.center,
                                                        readOnly: false,
                                                        enabled: true,
                                                        style: const TextStyle(color: Colors.black, fontSize: 26),
                                                        keyboardType: TextInputType.number, // Set the keyboardType to number
                                                        decoration: const InputDecoration(
                                                          hintText: 'Optional',
                                                          hintStyle: TextStyle(color: Colors.grey, fontSize: 16), // Set the style for the hint text
                                                          enabledBorder: UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Colors.black),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            // Update the first TextFormField with the discounted price

                                                            double totalPrice = double.parse(item['selling_price']) * double.parse(widget.quantityController.text);

                                                            double discountPercentage = double.tryParse(value) ?? 0;
                                                            discountPercentage = discountPercentage.clamp(0, 100);

                                                            double discountAmount = totalPrice * (discountPercentage / 100);

                                                            widget.totalPriceController.text = totalPrice.toStringAsFixed(2);
                                                            // totalPriceController.text = '${discountedPrice.toStringAsFixed(2)}';

                                                            // Update the second TextFormField with the discount amount
                                                            widget.discountController.text = discountAmount.toStringAsFixed(2);

                                                          });
                                                        },
                                                      ),
                                                    ),
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
                                    // Parse the entered quantity
                                    double enteredQuantity = double.tryParse(widget.quantityController.text) ?? 0.0;

                                    // Check if the quantity is empty or less than 0
                                    if (widget.quantityController.text.isEmpty || enteredQuantity <= 0) {
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

                                    // Update the values of the selected item
                                    if (widget.discountController.text.isNotEmpty && double.parse(widget.discountController.text) != 0) {
                                      double totalPrice = double.parse(widget.totalPriceController.text);
                                      double discount = double.parse(widget.discountController.text);

                                      if (discount > totalPrice) {
                                        // Display a dialog to prevent applying the discount amount
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                'Invalid Discount',
                                                style: TextStyle(color: Colors.red, fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.w400),
                                              ),
                                              content: const Text(
                                                'The discount amount cannot exceed the total price.',
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
                                      } else {
                                        setState(() {
                                          double newTotalPrice = totalPrice - discount;
                                          widget.items[selectedItemIndex]['total_price'] = newTotalPrice.toString();
                                          widget.items[selectedItemIndex]['quantity'] = widget.quantityController.text;
                                          widget.items[selectedItemIndex]['discount_amount'] = discount;
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        widget.items[selectedItemIndex]['total_price'] = widget.totalPriceController.text;
                                        widget.items[selectedItemIndex]['quantity'] = widget.quantityController.text;
                                      });
                                    }

                                    widget.calculateSubTotal();
                                    widget.updateChangeAmount();
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Poppins'),
                                  ),
                                ),


                              ],
                            ),
                          );
                      },
                    );
                  } else {
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
                                      const Text(
                                        'Retail',
                                        style: TextStyle(
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
                                              controller: widget.totalPriceController,
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
                                    thickness: 2.0,
                                    height: 20.0,
                                  ),
                                  const SizedBox(height: 50),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          children: [

                                            Row(
                                              children: [
                                                const Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Discount Amount:',
                                                      style: TextStyle(
                                                        fontSize: 24.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
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

                                                        controller: widget.discountController,
                                                        enabled: true,
                                                        keyboardType: TextInputType.number, // Set the keyboardType to number

                                                        style: const TextStyle(color: Colors.black, fontSize: 24),
                                                        decoration: const InputDecoration(
                                                          prefixText: '₱',
                                                          labelStyle: TextStyle(color: Colors.black),
                                                          prefixStyle: TextStyle(color: Colors.black),
                                                          hintStyle: TextStyle(color: Colors.black),
                                                          enabledBorder: UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Colors.black),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            // Parse the entered discount value
                                                            double? discount = double.tryParse(value) ?? 0;
                                                            double? totalPrice = double.parse(item['selling_price']) * double.parse(widget.quantityController.text);
                                                            widget.totalPriceController.text = totalPrice.toStringAsFixed(2);


                                                            // Clamp the discount value to ensure it is within the valid range
                                                            discount = discount.clamp(0, totalPrice) as double?;

                                                            // Update the TextFormField with the clamped discount value
                                                            // discountController.text = discount.toString();
                                                          });
                                                        },
                                                      ),
                                                    ),
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
                                                const Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Discount %:',
                                                      style: TextStyle(
                                                        fontSize: 26.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
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
                                                        readOnly: false,
                                                        enabled: true,
                                                        style: const TextStyle(color: Colors.black, fontSize: 26),
                                                        keyboardType: TextInputType.number, // Set the keyboardType to number
                                                        decoration: const InputDecoration(
                                                          hintText: 'Optional',
                                                          hintStyle: TextStyle(color: Colors.grey, fontSize: 16), // Set the style for the hint text
                                                          enabledBorder: UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Colors.black),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            // Update the first TextFormField with the discounted price

                                                            double totalPrice = double.parse(item['selling_price']) * double.parse(widget.quantityController.text);

                                                            double discountPercentage = double.tryParse(value) ?? 0;
                                                            discountPercentage = discountPercentage.clamp(0, 100);

                                                            double discountAmount = totalPrice * (discountPercentage / 100);

                                                            widget.totalPriceController.text = totalPrice.toStringAsFixed(2);
                                                            // totalPriceController.text = '${discountedPrice.toStringAsFixed(2)}';

                                                            // Update the second TextFormField with the discount amount
                                                            widget.discountController.text = discountAmount.toStringAsFixed(2);

                                                          });
                                                        },
                                                      ),
                                                    ),
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

                                    // Update the values of the selected item
                                    if (widget.discountController.text.isNotEmpty &&
                                        double.parse(widget.discountController.text) != 0) {
                                      double totalPrice = double.parse(widget.totalPriceController.text);
                                      double discount = double.parse(widget.discountController.text);

                                      if (discount > totalPrice) {
                                        // Display a dialog to prevent applying the discount amount
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Invalid Discount', style: TextStyle( color: Colors.red, fontSize: 32,  fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400,)),
                                              content: const Text('The discount amount cannot exceed the total price.', style: TextStyle(fontSize: 24,  fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w200,)),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(); // Close the dialog
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        return; // Stop further execution of the onPressed handler
                                      } else {
                                        setState(() {
                                          double newTotalPrice = totalPrice - discount;
                                          widget.items[selectedItemIndex]['total_price'] = newTotalPrice.toString();
                                          widget.items[selectedItemIndex]['quantity'] = widget.quantityController.text;
                                          widget.items[selectedItemIndex]['discount_amount'] = discount;
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        widget.items[selectedItemIndex]['total_price'] = widget.totalPriceController.text;
                                        widget.items[selectedItemIndex]['quantity'] = widget.quantityController.text;
                                      });
                                    }

                                    widget.calculateSubTotal();
                                    widget.updateChangeAmount();
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Poppins'),
                                  ),
                                ),

                              ],
                            ),
                          );
                      },
                    );
                  }
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
                                  widget.items[index]['item_name'],
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  ' - ${widget.items[index]['rice_category']}',
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
                                Text(
                                  '${widget.items[index]['package_category']}',
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                widget.items[index]['quantity'] != null && widget.items[index]['quantity'] != '1' && widget.items[index]['quantity'] != 1.0 && widget.items[index]['selling_category'] != 'Retail'
                                    ? Text(
                                  ' \u00D7 ${widget.items[index]['quantity']}',
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                )
                                    : const SizedBox(), // Render an empty SizedBox if quantity is null
                                const SizedBox(height: 8.0),
                              ],
                            ),


                            const SizedBox(height: 8.0),
                            Text(
                              'Total Price: ₱${widget.items[index]['total_price'] ?? widget.items[index]['selling_price']}',
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              widget.items[index]['selling_category'] == 'Retail'
                                  ? 'Category: Retail'
                                  : 'Category: Bags',
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.grey[600],
                              ),
                            ),
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
                            widget.removeItemFromCart(index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
