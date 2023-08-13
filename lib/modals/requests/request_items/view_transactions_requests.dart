import 'package:flutter/material.dart';

class ViewTransactionsDialog extends StatefulWidget {
  final Map<String, dynamic> trade;
  final String formattedTime;

  ViewTransactionsDialog({
    required this.trade,
    required this.formattedTime,
  });

  @override
  _ViewTransactionsDialogState createState() => _ViewTransactionsDialogState();
}

class _ViewTransactionsDialogState extends State<ViewTransactionsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: [
                      const Text(
                        'Invoice Number',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.trade['inv_number']}',
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
                        'Purchase Date',
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
                        'Purchased By',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.trade['staff_name']}',
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
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.trade['payment_method']}',
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
          ),
          const SizedBox(height: 25),
          Divider(
            color: Colors.grey[400],
            thickness: 1.0,
            height: 20.0,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(
                  label: Text(
                    'Branch',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
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
                    'Rice Type',
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
                    'QTY',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ],
              rows: List<DataRow>.generate(
                widget.trade['items'].length,
                    (index) {
                  final tradedItem = widget.trade['items'][index];
                  final branchName = tradedItem['branch_name'];
                  final itemName = tradedItem['item_name'];
                  final packageType = tradedItem['package_category'];
                  final riceType = tradedItem['rice_category'];
                  final noItem = tradedItem['no_item'];

                  return DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(
                          '$branchName',
                          style: const TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
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
                          '$riceType',
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
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
