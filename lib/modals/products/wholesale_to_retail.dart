import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/database_helper.dart';

class DistributionDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final void Function() onDataFetch; // Callback function to be invoked to fetch data
  final void Function() fetchRetailData; // Callback function to be invoked to fetch data
  final VoidCallback onDialogDismissed; // Add this line

  final String? selectedPackage;

  const DistributionDialog({
    required this.product,
    required this.onDataFetch,
    required this.fetchRetailData,
    required this.selectedPackage,
    required this.onDialogDismissed,
  });

  @override
  _DistributionDialogState createState() => _DistributionDialogState();
}

class _DistributionDialogState extends State<DistributionDialog> {
  TextEditingController textFieldController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textFieldController.addListener(calculateDistributedAmount);
  }

  @override
  void dispose() {
    textFieldController.dispose();
    totalAmountController.dispose();
    super.dispose();
  }

  void distributeToRetail(data) async {

    try {
      await DatabaseHelper.distributeSacks(data);
    } catch (e) {
      print('Failed to send data: $e');
    }
  }

  void _handleDialogDismissed() {

    widget.onDialogDismissed();
  }

  void calculateDistributedAmount() {
    setState(() {
      double enteredQuantity = double.tryParse(textFieldController.text) ?? 0;
      double maxQuantity = double.parse(widget.product['no_item_received'].toString());

      if (enteredQuantity < 0 || enteredQuantity > maxQuantity) {
        textFieldController.text = enteredQuantity.clamp(0, maxQuantity).toString();
      }

      // Calculate the distributed amount
      double distributedAmount = enteredQuantity * double.parse(widget.selectedPackage!.replaceAll('KG', '')).toDouble();
      totalAmountController.text = distributedAmount.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.product['item_name'] + ' (' + widget.selectedPackage + ')',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Distribute to Retail Sacks:   ',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: 75,
                    child: TextFormField(
                      controller: textFieldController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        prefixStyle: TextStyle(color: Colors.grey[600]),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    '  Stocks: ',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: Text(
                    widget.product['no_item_received'].toString(),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Distributed Amount in KG: ',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: totalAmountController,
                    readOnly: true,
                    enabled: false,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      suffixText: 'KG',
                      labelStyle: TextStyle(color: Colors.white),
                      suffixStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
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
                          title: (textFieldController.text.isNotEmpty && int.tryParse(textFieldController.text) != 0)
                              ? const Text('Confirm Distribution')
                              : const Text('Invalid Value'),
                          content: (textFieldController.text.isNotEmpty && int.tryParse(textFieldController.text) != 0)
                              ? Text('Confirm distribution amount to retail of ${widget.product['item_name']} ${totalAmountController.text} KG')
                              : const Text('Please input a valid value to distribute'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: (textFieldController.text.isNotEmpty && int.tryParse(textFieldController.text) != 0)
                                  ? () {
                                // Store the values in a map
                                Map<String, dynamic> distributionData = {
                                  'branch_id': widget.product['branch_id'],
                                  'distributed_sacks': {
                                    'no_item': textFieldController.text,
                                    'item_id': widget.product['item_id'],
                                    'rice_category': widget.product['rice_category']?.toString().toLowerCase(),
                                  },
                                  'retail': {
                                    'retail_amount': totalAmountController.text,
                                    'item_name': widget.product['item_name'],
                                  },
                                };



                                distributeToRetail(distributionData);

                                widget.onDataFetch();
                                widget.fetchRetailData();

                                _handleDialogDismissed();
                                Navigator.pop(context);
                                Navigator.pop(context);


                              }
                                  : null,
                              child: const Text('Distribute'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Distribute'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
