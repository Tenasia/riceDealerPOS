import 'package:flutter/material.dart';

class RequestRepriceDialog extends StatefulWidget {
  final Map<String, dynamic> request;

  RequestRepriceDialog({required this.request});

  @override
  _RequestRepriceDialogState createState() => _RequestRepriceDialogState();
}

class _RequestRepriceDialogState extends State<RequestRepriceDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
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
                'Quantity',
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
              final noItem = requestedItem['no_item'];

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
    );
  }
}
