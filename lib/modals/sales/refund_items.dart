import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../api/database_helper.dart';
class refundDialog extends StatefulWidget {
  final VoidCallback onDialogDismissed; // Add this line
  final Map<String, dynamic> product;
  final String formattedTime;
  const refundDialog({required this.onDialogDismissed, required this.product, required this.formattedTime});

  @override
  _refundDialogState createState() => _refundDialogState();
}


class _refundDialogState extends State<refundDialog> {

  List<bool> checkedStates = [];
  List<TextEditingController> refundControllers = [];
  List<TextEditingController> retailsControllers = [];
  List<TextEditingController> bagsControllers = [];

  double? refund_amount;

  List<dynamic> itemSales = [];

  Future<void> fetchSalesData(String cartId) async {
    final data = await DatabaseHelper.getItemSalesWithoutRefund(cartId);
    setState(() {
      itemSales = List<Map<String, dynamic>>.from(data);
    });
  }

  void sendRefundInfo(data) async {
    try {
      double amount = await DatabaseHelper.sendRefundInfo(data);
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        refund_amount = amount;
      });
      Navigator.of(context).pop();

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


      // Rest of your code...
    } catch (e) {
      print('Failed to send data: $e');
      if (!mounted) return; // Check if the widget is still mounted
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
  void initState() {
    super.initState();
    fetchSalesData(widget.product['id']);
  }

  @override
  Widget build(BuildContext context) {

    List<dynamic> updatedItems = itemSales;
    String cart_id = widget.product['id'];

    return Center(

      child: SingleChildScrollView(
        child: WillPopScope(
          onWillPop: () async{
            return false;
          },
          child: Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15,),
                Column(
                  children: [
                    Text(
                      updatedItems.isEmpty ? 'No More Items To Refund' : 'Refund Items',
                      style: TextStyle(fontSize: 32),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 650,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            widget.product['inv_number'],
                            style: TextStyle(fontSize: 24),
                          ),
                          Text(
                            widget.formattedTime,
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 15,),
                SizedBox(
                  width: 650,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: itemSales.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = itemSales[index];

                      if (checkedStates.length <= index) {
                        checkedStates.add(false);
                      }

                      if (refundControllers.length <= index ) {
                        refundControllers.add(TextEditingController());
                      }

                      if (retailsControllers.length <= index ) {
                        retailsControllers.add(TextEditingController());
                      }

                      if (bagsControllers.length <= index ) {
                       bagsControllers.add(TextEditingController());
                      }

                      String packageCategory = item['package_category'];
                      String strippedValue = packageCategory.replaceAll('KG', '');
                      double package_amount = double.parse(strippedValue);

                      final refundQuantityController = refundControllers[index];
                      final retailController = retailsControllers[index];
                      final bagController = bagsControllers[index];


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
                                        controller: refundQuantityController, // Assign the controller
                                        // Customize the TextFormField as needed
                                        style: const TextStyle(
                                          fontSize: 25,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter Refund Quantity',
                                          hintStyle: const TextStyle(color: Colors.white70),
                                          suffixText: (item['package_category'] == '1KG') ? 'KG' : 'Bags',
                                        ),

                                        onChanged: (value) {
                                          double enteredQuantity = double.tryParse(value) ?? 0;

                                          // Calculate the maximum allowed quantity based on available stock
                                          double maxQuantity = double.parse(item['no_item'].toString());
                                          // Check if the entered quantity is negative or exceeds the maximum allowed quantity
                                          if (enteredQuantity < 0 || enteredQuantity > maxQuantity) {
                                            // Limit the quantity to the valid range

                                            refundQuantityController.text = enteredQuantity.clamp(0, maxQuantity).toString();
                                          }

                                          String refundQuantityText = refundQuantityController.text;
                                          double refundQuantity = refundQuantityText.isEmpty ? 0.0 : double.parse(refundQuantityText);
                                          int integerPart = refundQuantity.toInt();
                                          double decimalPart = refundQuantity - refundQuantity.toInt(); // Get the decimal part
                                          double multipliedValue = decimalPart * package_amount;
                                          String result = multipliedValue.toString();
                                          retailsControllers[index].text = result;
                                          bagsControllers[index].text = double.parse(integerPart.toString()).toString();


                                          // retailsControllers[index].text = refundQuantityController.text.isEmpty
                                          //     ? '0' // Set to '0' if controller.text is empty
                                          //     : (double.parse(refundQuantityController.text) * package_amount).toString();

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
                                        controller: retailController,
                                        decoration: const InputDecoration(
                                          // labelText: 'Amount To Refund',
                                          suffixText: 'KG',
                                        ),
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
                                        controller: bagController,
                                        decoration: const InputDecoration(
                                          // labelText: 'Amount To Refund',
                                          suffixText: 'Bags',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 15),

                if (itemSales.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {

                          for (var item in updatedItems) {
                            item.remove('refunded_no_item');
                          }

                          checkedStates.clear();
                          refundControllers.clear();


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
                          bool allEmpty = refundControllers.every((controller) => controller.text.isEmpty);

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
                                          String refundedNoItem = refundControllers[index].text;
                                          String retailNoItem = retailsControllers[index].text;
                                          String bagNoItem = bagsControllers[index].text;
                                          if (checkedStates[index] &&
                                              refundedNoItem != null &&
                                              refundedNoItem.isNotEmpty) {
                                            if (updatedItems[index]['package_category'] == '1KG'){
                                              updatedItems[index]['refunded_no_item'] = double.parse(refundedNoItem);
                                              updatedItems[index]['refunded_retails_amount'] = double.parse(refundedNoItem);
                                              updatedItems[index]['refunded_bags_amount'] = 0.00;
                                            } else {
                                              updatedItems[index]['refunded_no_item'] = double.parse(refundedNoItem);
                                              updatedItems[index]['refunded_retails_amount'] = double.parse(retailNoItem);
                                              updatedItems[index]['refunded_bags_amount'] = double.parse(bagNoItem);

                                            }
                                          }
                                        }

                                        Map<String, dynamic> newData = {
                                          "id": cart_id,
                                          "items": updatedItems,
                                        };

                                        sendRefundInfo(newData);
                                        refundControllers.clear();
                                        checkedStates.clear();
                                        for (var item in updatedItems) {
                                          item.remove('refunded_no_item');
                                        }
                                        _handleDialogDismissed();
                                        // Navigator.pop(context); // Close the screen
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

                if (itemSales.isEmpty)
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {

                      for (var item in updatedItems) {
                        item.remove('refunded_no_item');
                      }

                      checkedStates.clear();
                      refundControllers.clear();


                      _handleDialogDismissed();
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text(
                      'Okay',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
