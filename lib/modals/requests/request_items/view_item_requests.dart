import 'package:flutter/material.dart';

class ViewItemRequestsDialog extends StatefulWidget {

  final Map<String, dynamic> request;
  final String formattedTime;

  const ViewItemRequestsDialog({required this.request, required this.formattedTime});

  @override
  _ViewItemRequestsDialogState createState() => _ViewItemRequestsDialogState();
}

class _ViewItemRequestsDialogState extends State<ViewItemRequestsDialog> {
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
              columns: <DataColumn>[
                const DataColumn(
                  label: Text(
                    'Item Name',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Rice Type',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Package Type',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'QTY',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
                if (widget.request['status'] != 'For Prep' && widget.request['status'] != 'On Delivery')
                  const DataColumn(
                    label: Text(
                      'QTY Received',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                if (widget.request['status'] == 'Discrepance')
                  const DataColumn(
                    label: Text(
                      'QTY Difference',
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
                  final itemID = requestedItem['item_name'];
                  final packageType = requestedItem['package_size'];
                  final riceType = requestedItem['rice_category'];
                  final noItem = requestedItem['no_item'];
                  final noItemReceived = requestedItem['no_item_received'];
                  final remainingItems =
                      (double.tryParse(noItem ?? '0') ?? 0) - (double.tryParse(noItemReceived ?? '0') ?? 0);
                  final remainingItemsString = remainingItems.abs().toStringAsFixed(2);

                  return DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(
                          '$itemID',
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
                      if (widget.request['status'] != 'For Prep' && widget.request['status'] != 'On Delivery')
                        DataCell(
                          Text(
                            '$noItemReceived',
                            style: const TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      if (widget.request['status'] == 'Discrepance')
                        DataCell(
                          Text(
                            remainingItemsString,
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
