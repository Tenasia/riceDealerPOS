import 'package:flutter/material.dart';

class ViewSalesDialog extends StatefulWidget {
  final List<dynamic> items;
  final String formattedTime;
  final Map<String, dynamic> product;

  const ViewSalesDialog({required this.items, required this.formattedTime, required this.product});


  @override
  _ViewSalesDialogState createState() => _ViewSalesDialogState();
}

class _ViewSalesDialogState extends State<ViewSalesDialog> {

  @override
  Widget build(BuildContext context) {

    return Dialog(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: [
                    const Text(
                      'OR No.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.product['inv_number']}',
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
                      'Customer',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.product['customer_name']}',
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
                      'Sales Date',
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
                      'Staff',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.product['staff_name'] ?? 'N/A'}',
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
                      'Total',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₱${double.parse(widget.product['cart_total']?.toString() ?? '0.0').toStringAsFixed(2)}',
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

          DataTable(
            // DataTable configuration and columns here
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'PRD Name',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'PKG Type',
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
              DataColumn(
                label: Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'RFD QTY',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'RFD AMT',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              // Add more DataColumn as needed
            ],
            rows: List<DataRow>.generate(
              widget.items.length,
                  (index) {
                final item = widget.items[index];
                final total = item['total'].toString();
                return DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Text(
                        item['item_name'],
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        (item['package_category'] == '1KG') ? 'Retail' : item['package_category'],
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        (item['refunded_no_item'] != null)
                            ? (double.parse(item['no_item'].toString()) - double.parse(item['refunded_no_item'].toString())).toString()
                            : item['no_item'].toString(),
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₱${item['price']}',
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₱$total',
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        item['refunded_no_item'] != null && double.parse(item['refunded_no_item']) > 0.00
                            ? '${item['refunded_no_item']}'
                            : 'N/A',
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        item['refunded_price'] != null && double.parse(item['refunded_price']) > 0.00
                            ? '₱${item['refunded_price']}'
                            : 'N/A',
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    // Add a cell which finds the total, multiplying the no_item and price
                    // Add more DataCell as needed
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
