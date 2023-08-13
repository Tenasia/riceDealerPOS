import 'package:flutter/material.dart';
import '../../api/database_helper.dart';
class RepackDialog extends StatefulWidget {

  final Map<String, dynamic> retail_product;
  final List<Map<String, dynamic>> packages;
  final Function fetchData; // Add the fetchData function as a parameter
  final Function fetchRetailData; // Add the fetchData function as a parameter
  final VoidCallback onDialogDismissed; // Add this line



  const RepackDialog({
    required this.retail_product,
    required this.packages,
    required this.fetchData,
    required this.fetchRetailData,
    required this.onDialogDismissed,

  });

  @override
  _RepackDialogState createState() => _RepackDialogState();
}


class _RepackDialogState extends State<RepackDialog> {

  List<bool> checkedStates = [];
  List<TextEditingController> controllers = [];
  List<TextEditingController> quantityControllers = [];
  List<Map<String, dynamic>> availablePackages = [];
  bool isConfirmed = false;


  TextEditingController textFieldController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();


  String? selectedPackageAmount;
  double quantity = 0.00;
  double totalAmount = 0.00;

  void repackToSacks(data) async {

    try {
      await DatabaseHelper.repackToSacks(data);
    } catch (e) {
      print('Failed to send data: $e');
    }
  }





  void _handleDialogDismissed() {
    widget.onDialogDismissed();
  }

  @override
  void initState() {
    super.initState();
    widget.packages;
    if (widget.packages.isNotEmpty) {
      selectedPackageAmount = widget.packages[0]['package'];
      textFieldController = TextEditingController(text: selectedPackageAmount != null ? selectedPackageAmount!.replaceAll('KG', '') : '');
      quantity = double.tryParse(selectedPackageAmount!.replaceAll('KG', '')) ?? 0;
      totalAmount = 0.00;
      totalAmountController.text = '1.0';
    }
  }



  @override
  Widget build(BuildContext context) {

    Map<String, dynamic> updatedRetailProduct = widget.retail_product;
    List<Map<String, dynamic>> packageAmounts = widget.packages;

    return SingleChildScrollView(
      child: Dialog(
          child: Container(
          width: 650,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                updatedRetailProduct['item_name'] + ' - ' + updatedRetailProduct['rice_category'] + ' (' + 'Retail' +  ')',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Available Packages To Repack',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 5),

              Container(
                height: 50,
                color: Color(0xff394a5a),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: packageAmounts.length,
                  itemBuilder: (context, index) {

                    final package = packageAmounts[index]['package'];

                    final originalPackageAmount = selectedPackageAmount;
                    final originalQuantity = quantity;

                    return SizedBox(
                      width: 150, // Adjust the width as needed
                      // margin: EdgeInsets.symmetric(horizontal: 8), // Add margin between buttons
                      child: ElevatedButton(
                        onPressed: () {

                          setState(() {
                            selectedPackageAmount = package;
                            quantity = double.tryParse(selectedPackageAmount!.replaceAll('KG', '')) ?? 0;
                          });

                          if (double.parse(updatedRetailProduct['no_item_received'].toString()) >= quantity){
                            setState(() {
                              // Set the selected package as the state or perform any other action when the button is pressed
                              textFieldController = TextEditingController(text: selectedPackageAmount != null ? selectedPackageAmount!.replaceAll('KG', '') : '');
                              // quantity = double.tryParse(selectedPackageAmount!.replaceAll('KG', '')) ?? 0;
                              totalAmount = 0.00;
                              totalAmountController.text = '1.0';
                            });
                          } else {

                            selectedPackageAmount = originalPackageAmount;
                            quantity = originalQuantity;

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Invalid Package Selection'),
                                  content: Text('The package is over the current stocks of retail ${updatedRetailProduct['item_name']}'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }

                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ), backgroundColor: selectedPackageAmount == package ? Color(0xff232d37) : Color(0xff394a5a),
                          // Apply any other styles or conditions based on the selected package
                        ),
                        child: Text(package, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  },
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 10), // Add some spacing between the TextFormField and the button

                  const Divider(),
                  const SizedBox(height: 10), // Add some spacing between the TextFormField and the button

                  Row(
                    children: [
                      const Expanded(
                        flex:1,
                        child: Text(
                          'Repack to Wholesale:   ',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            IconButton(

                              onPressed: () {
                                setState(() {
                                  double updatedTotalAmount = totalAmount - quantity;

                                  if (updatedTotalAmount < 0) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Invalid Deduction'),
                                          content: const Text('The deduction will result in a negative total amount.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    totalAmount = updatedTotalAmount;
                                    textFieldController.text = totalAmount.toString();
                                    String selectedPackage = selectedPackageAmount!.replaceAll('KG', '');
                                    double packageAmount = double.tryParse(selectedPackage) ?? 0;
                                    double calculatedAmount = totalAmount / packageAmount;
                                    totalAmountController.text = calculatedAmount.toString();
                                  }
                                });
                              },
                              icon: const Icon(Icons.remove),
                              iconSize: 24,
                              color: Colors.white,
                              splashRadius: 24,
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),


                            const SizedBox(width: 10), // Add some spacing between the TextFormField and the button

                            SizedBox(
                              width: 75,
                              child: TextFormField(
                                enabled: false,
                                readOnly: true,
                                controller: textFieldController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white, fontSize: 24),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(color: Colors.grey[600]),
                                  prefixStyle: TextStyle(color: Colors.grey[600]),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10), // Add some spacing between the TextFormField and the button
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  double updatedQuantity = double.tryParse(updatedRetailProduct['no_item_received'].toString()) ?? 0;
                                  double updatedTotalAmount = totalAmount + quantity;

                                  if (updatedTotalAmount > updatedQuantity) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Exceeded Quantity'),
                                          content: const Text('The total amount will exceed the available quantity.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    totalAmount = updatedTotalAmount;
                                    textFieldController.text = totalAmount.toString();
                                    String selectedPackage = selectedPackageAmount!.replaceAll('KG', '');
                                    double packageAmount = double.tryParse(selectedPackage) ?? 0;
                                    double calculatedAmount = totalAmount / packageAmount;
                                    totalAmountController.text = calculatedAmount.toString();
                                  }
                                });
                              },
                              icon: const Icon(Icons.add),
                              iconSize: 24,
                              color: Colors.white,
                              splashRadius: 24,
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),

                          ],
                        ),
                      ),

                      const Expanded(
                        flex: 1,
                        child: Text(
                          '  Stocks: ',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 1,
                        child: Text(
                          updatedRetailProduct['no_item_received'].toString(),
                          style: const TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Repack Amount in Sacks: ',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: totalAmountController,
                      enabled: false,
                      readOnly: true,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                      textAlign: TextAlign.center, // Aligns the text to the center
                      decoration: InputDecoration(
                        suffixText: '$selectedPackageAmount SACKS',
                        labelStyle: const TextStyle(color: Colors.white),
                        suffixStyle: const TextStyle(color: Colors.white),

                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),


                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: (textFieldController.text.isNotEmpty && textFieldController.text != '0.0')
                                ? const Text('Confirm Repacking', style: TextStyle(fontSize: 32),)
                                : const Text('Invalid Value', style: TextStyle(fontSize: 32),),
                            content: (textFieldController.text.isNotEmpty && textFieldController.text != '0.0')
                                ? Text('Confirm repacking amount to wholesale of ${updatedRetailProduct['item_name']} (${totalAmountController.text}) $selectedPackageAmount Sacks', style: const TextStyle(fontSize: 24),)
                                : const Text('Please input a valid value to distribute', style: TextStyle(fontSize: 24),),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel', style: TextStyle(fontSize: 24),),
                              ),
                              ElevatedButton(
                                onPressed: (textFieldController.text.isNotEmpty && textFieldController.text != '0.0' )
                                    ? () {
                                  // Store the values in a map
                                  Map<String, dynamic> repackData = {
                                    'branch_id': updatedRetailProduct['branch_id'],
                                    'repacked_retails': {
                                      'no_item': textFieldController.text,
                                      'item_id': updatedRetailProduct['item_id'],
                                      'rice_category': updatedRetailProduct['rice_category']?.toString().toLowerCase(),
                                    },
                                    'repacked_sacks': {
                                      'package' : selectedPackageAmount,
                                      'sack_amount': totalAmountController.text,
                                      'item_name': updatedRetailProduct['item_name'],
                                    },
                                  };

                                  // print(distributionData);
                                  repackToSacks(repackData);

                                  widget.fetchData();
                                  widget.fetchRetailData();

                                  _handleDialogDismissed();

                                  Navigator.pop(context);
                                  Navigator.pop(context);



                                }
                                    : null,
                                child: const Text('Repack'),
                              )
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Repack'),
                  )



                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
