import 'package:flutter/material.dart';
import 'package:rice_dealer_pos/components/clock_widget.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';


class ProductListView extends StatefulWidget {
  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredItems = [];

  void fetchData() async {
    final data = await DatabaseHelper.getProducts();
    setState(() {
      products = List<Map<String, dynamic>>.from(data);
    });
  }


  @override
  void initState() {
    super.initState();
    fetchData();
  }


  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> dataTableData = filteredItems.isNotEmpty ? filteredItems : products;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Container(), // add an empty Expanded widget to push the ClockWidget to the right
            ),
            ClockWidget(),
          ],
        ),
        automaticallyImplyLeading: false,
        flexibleSpace: Padding(
          padding: EdgeInsets.only(left: 16.0, top: 13.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Inventory",
                style: TextStyle(fontSize: 24.0),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    style: TextStyle(color: Colors.black),
                    onChanged: (value) {
                      setState(() {
                        filteredItems = products.where((item) =>
                        item['product_name']
                            .toString()
                            .toLowerCase()
                            .contains(value.toLowerCase()) ||
                            item['product_type']
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            item['cost']
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            item['srp']
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            item['stock']
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                      print(filteredItems);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for products',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 8.0,
                      ),
                      suffixIcon: Icon(Icons.search, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.grey[300],
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[200]!),
                  dividerThickness: 2.0,
                  dataRowHeight: 80.0,
                  dataTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  columns: const <DataColumn>[
                    DataColumn(
                      label: SizedBox(
                        width: 200,
                        child: Text(
                          'Product Name',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 150,
                        child: Text(
                          'Product Type',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100,
                        child: Text(
                          'Cost',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100,
                        child: Text(
                          'SRP',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100,
                        child: Text(
                          'Stock',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100,
                        child: Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    dataTableData.length,
                        (index) {
                      final product = dataTableData[index];
                      final color =
                      index % 2 == 0 ? Colors.grey[300]! : Colors.grey[200]!;
                      return DataRow(
                        color: MaterialStateColor.resolveWith((states) => color),
                        cells: <DataCell>[
                          DataCell(Text(product['product_name'])),
                          DataCell(Text(product['product_type'])),
                          DataCell(Text('\₱${product['cost']}')),
                          DataCell(Text('\₱${product['srp']}')),
                          DataCell(Text('${product['stock']}')),
                          DataCell(Text('\₱${(int.parse(product['stock']) * int.parse(product['srp'])).toStringAsFixed(2)}')),
                        ],
                      );
                    },
                  ),
                ),

              ),
            ),
          ),
        ],
      ),
    );
  }

}
