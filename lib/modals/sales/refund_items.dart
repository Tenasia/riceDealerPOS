import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/database_helper.dart';
class MyDialog extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String productId;
  final VoidCallback onDialogDismissed; // Add this line


  const MyDialog({required this.items, required this.productId, required this.onDialogDismissed});

  @override
  _MyDialogState createState() => _MyDialogState();
}


class _MyDialogState extends State<MyDialog> {

  List<bool> checkedStates = [];
  List<TextEditingController> controllers = [];
  List<TextEditingController> quantityControllers = [];
  double? refund_amount;


  void sendRefundInfo(data) async {
    try {
      double amount = await DatabaseHelper.sendRefundInfo(data);
      setState(() {
        refund_amount = amount;
      });

      showDialog(
        context: context,
        barrierDismissible: false, // Prevents dialog dismissal when clicked outside
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              width: 450,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20,),
                      const Text(
                        'Total Refund Amount',
                        style: TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '\₱$refund_amount',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'OK',
                              style: TextStyle(fontSize: 32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                ],
              ),
            ),
          );
        },
      );

    } catch (e) {
      print('Failed to send data: $e');
      setState(() {
        refund_amount = 0; // Set a default value in case of an error
      });
    }
  }



  void _handleDialogDismissed() {

    widget.onDialogDismissed();
  }

  bool isConfirmed = false;

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> updatedItems = widget.items;
    String cart_id = widget.productId;


    return SingleChildScrollView(
      child: WillPopScope(
        onWillPop: () async{
          return false;
        },
        child: Dialog(

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15,),
              const Text(
                'Refund Items',
                style: TextStyle(fontSize: 32,),
              ),
              const SizedBox(height: 15,),
              SizedBox(
                width: 650,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = widget.items[index];

                    if (checkedStates.length <= index) {
                      checkedStates.add(false);
                    }

                    if (controllers.length <= index ) {
                      controllers.add(TextEditingController());
                    }

                    if (quantityControllers.length <= index ) {
                      quantityControllers.add(TextEditingController());
                    }

                    String packageCategory = item['package_category'];
                    String strippedValue = packageCategory.replaceAll('KG', '');
                    double package_amount = double.parse(strippedValue);

                    final controller = controllers[index];
                    final quantityController = quantityControllers[index];

                    if (item['refunded_no_item'] == null) {
                      return CheckboxListTile(
                        value: checkedStates[index],
                        onChanged: (bool? value) {
                          setState(() {
                            checkedStates[index] = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  item['item_name'],
                                  style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' ${item['package_category']}',
                                  style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' ${item['rice_category']}',
                                  style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' ₱${item['total']}',
                                  style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  ' \u00D7 ${item['no_item']}',
                                  style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 50),
                                Visibility(
                                  visible: checkedStates[index],
                                  child: Expanded(
                                    child: TextFormField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),

                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
                                      ],
                                      controller: controller, // Assign the controller
                                      // Customize the TextFormField as needed
                                      style: const TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Enter Refund Quantity',
                                        hintStyle: TextStyle(color: Colors.white70),
                                      ),
                                      onChanged: (value) {
                                        double enteredQuantity = double.tryParse(value) ?? 0;

                                        // Calculate the maximum allowed quantity based on available stock
                                        double maxQuantity = double.parse(item['no_item'].toString());
                                        // Check if the entered quantity is negative or exceeds the maximum allowed quantity
                                        if (enteredQuantity < 0 || enteredQuantity > maxQuantity) {
                                          // Limit the quantity to the valid range

                                          controller.text = enteredQuantity.clamp(0, maxQuantity).toString();
                                        }

                                        quantityControllers[index].text = controller.text.isEmpty
                                            ? '0' // Set to '0' if controller.text is empty
                                            : (double.parse(controller.text) * package_amount).toString();


                                        // updatedItems[index]['refunded_no_item'] = double.parse(controller.text);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 25,),
                                Visibility(
                                  visible: checkedStates[index] && item['package_category'] != '1KG',
                                  child: Expanded(
                                    child: TextFormField(
                                      style: const TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      enabled: false,
                                      controller: quantityController,
                                      decoration: const InputDecoration(
                                        // labelText: 'Amount To Refund',
                                        suffixText: 'KG',
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );                    }
                  },
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {

                        print(updatedItems);

                        for (var item in updatedItems) {
                          item.remove('refunded_no_item');
                        }

                        checkedStates.clear();
                        controllers.clear();


                        _handleDialogDismissed();
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 25,),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Check if all controllers are empty
                        bool allEmpty = controllers.every((controller) => controller.text.isEmpty);

                        if (allEmpty) {
                          // Show the dialog if all controllers are empty
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                  "Cannot Refund",
                                  style: TextStyle(fontSize: 32),
                                ),
                                content: const Text(
                                  "Items have no refund values",
                                  style: TextStyle(fontSize: 24),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "OK",
                                      style: TextStyle(fontSize: 24, color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          // Update the 'refunded_no_item' value in updatedItems
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Refund?', style: TextStyle(fontSize: 32),),
                                content: const Text('Are you sure you want to proceed with the refund?', style: TextStyle(fontSize: 24)),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                      // Execute the actions in the else block
                                      for (int index = 0; index < updatedItems.length; index++) {
                                        String refundedNoItem = controllers[index].text;
                                        if (checkedStates[index] && refundedNoItem != null && refundedNoItem.isNotEmpty) {
                                          updatedItems[index]['refunded_no_item'] = double.parse(refundedNoItem);
                                        }
                                      }
                                      Map<String, dynamic> newData = {
                                        "id": cart_id,
                                        "items": updatedItems,
                                      };
                                      sendRefundInfo(newData);
                                      controllers.clear();
                                      checkedStates.clear();
                                      for (var item in updatedItems) {
                                        item.remove('refunded_no_item');
                                      }
                                      _handleDialogDismissed();
                                      Navigator.pop(context); // Close the screen
                                    },
                                    child: const Text('Confirm', style: TextStyle(fontSize: 24)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: const Text('Cancel', style: TextStyle(fontSize: 24)),
                                  ),
                                ],
                              );
                            },
                          );

                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text(
                        'Confirm Refund',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
