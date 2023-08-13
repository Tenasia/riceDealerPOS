import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/database_helper.dart';

class AcceptDeliveryDialog extends StatefulWidget {

  final Map<String, dynamic> request;
  final String formattedTime;
  final void Function() fetchItemsRequests; // Callback function to be invoked to fetch data
  final VoidCallback onDialogDismissed; // Add this line


  const AcceptDeliveryDialog({required this.request, required this.formattedTime, required this.fetchItemsRequests, required this.onDialogDismissed});

  @override
  _AcceptDeliveryDialogState createState() => _AcceptDeliveryDialogState();
}

class _AcceptDeliveryDialogState extends State<AcceptDeliveryDialog> {
  List<TextEditingController> textControllers = [];

  List<List<String>> rowDataList = [];


  @override
  void initState() {
    super.initState();
    // Create controllers for each row
    for (int i = 0; i < widget.request['requested_items'].length; i++) {
      textControllers.add(TextEditingController(text: widget.request['requested_items'][i]['no_item']));
    }
  }

  @override
  void dispose() {
    // Dispose the text controllers
    for (TextEditingController controller in textControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  void getRequestItem(String jsonData) async {
    List<dynamic> dataList = json.decode(jsonData);
    List<Map<String, dynamic>> mapList = [];
    for (List<dynamic> items in dataList) {
      if (items.length >= 4) {
        Map<String, dynamic> data = {
          'item_name': items[0],
          'no_item': items[1],
          'quantity_received': items[2],
          'request_id': items[3],
        };
        mapList.add(data);
      } else {
        print('Invalid number of items in the list');
      }
    }

    try {
      await DatabaseHelper.sendDeliveryConfirmation(mapList);
      print('Success');

      // Refresh the data after sending the confirmation
    } catch (e) {
      print('Failed to send data: $e');
    }
    // Rest of your code
  }

  void _handleDialogDismissed() {

    widget.onDialogDismissed();
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: WillPopScope(
        onWillPop: () async {
          // Prevent dialog from closing when user clicks outside
          return false;
        },
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: [
                      const Text(
                        'Request Number',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.request['request_no']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Date Requested',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.formattedTime,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Requested By',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.request['staff_name']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Delivered Date',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.request['delivered_date'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.request['status']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Divider(
              color: Colors.grey[400],
              thickness: 1.0,
              height: 20.0,
            ),
            SingleChildScrollView(
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Item Name',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Package Type',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'QTY to receive',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'QTY received',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ],
                rows: List<DataRow>.generate(
                  widget.request['requested_items'].length,
                      (index) {
                    final requestedItem = widget.request['requested_items'][index];
                    final itemName = requestedItem['item_name'];
                    final packageType = requestedItem['package_size'];
                    final noItem = requestedItem['no_item'];

                    return DataRow(
                      cells: <DataCell>[
                        DataCell(
                          Text(
                            '$itemName',
                            style: const TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '$packageType',
                            style: const TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '$noItem',
                            style: const TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  double currentValue = double.tryParse(textControllers[index].text) ?? 0.0;
                                  if (currentValue > 0) {
                                    double newValue = currentValue - 1;
                                    textControllers[index].text = '$newValue';
                                  }
                                },
                              ),
                              Flexible(
                                child: SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: textControllers[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    style: const TextStyle(fontSize: 24),
                                    onChanged: (value) {
                                      // Handle onChanged event if needed
                                    },
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  double currentValue = double.tryParse(textControllers[index].text) ?? 0.0;
                                  double newValue = currentValue + 1.0;
                                  textControllers[index].text = newValue.toString();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle exit button action here
                    Navigator.pop(context);
                    textControllers.clear();
                  },
                  child: const Text(
                    'Exit',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        bool anyEmpty = textControllers.any((controller) => controller.text.isEmpty || controller.text == "0");
                        String dialogTitle = anyEmpty ? 'Incomplete Form' : 'Confirm Items Received';
                        String dialogContent = anyEmpty ? 'Please fill in all the fields of the QTY receive.' : 'Are you sure the items amount is confirmed?';

                        return AlertDialog(
                          title: Text(dialogTitle),
                          content: Text(dialogContent),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: textControllers.any((controller) => controller.text.isEmpty || controller.text == "0") ? null : () {
                                // Iterate over the rows and collect the data
                                rowDataList = List<List<String>>.generate(
                                  widget.request['requested_items'].length,
                                      (index) {
                                    final requestedItem = widget.request['requested_items'][index];
                                    final itemID = requestedItem['item_id'];
                                    final noItem = requestedItem['no_item'];
                                    final textFieldValue1 = textControllers[index].text;
                                    final requestId = widget.request['id'];

                                    return [itemID, noItem, textFieldValue1, requestId];
                                  },
                                );

                                // Convert the rowDataList to JSON
                                final jsonData = json.encode(rowDataList);
                                getRequestItem(jsonData);

                                textControllers.clear();
                                widget.fetchItemsRequests();
                                _handleDialogDismissed();

                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text('Submit', style: TextStyle(fontSize: 24)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: const Text('Cancel', style: TextStyle(fontSize: 24)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Submit', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 25),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
