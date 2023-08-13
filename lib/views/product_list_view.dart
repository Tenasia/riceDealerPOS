
import 'package:flutter/material.dart';
import 'package:rice_dealer_pos/components/clock_widget.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';
import 'package:rice_dealer_pos/components/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rice_dealer_pos/modals/products/retail_to_wholesale.dart';
import 'package:rice_dealer_pos/modals/products/wholesale_to_retail.dart';
import 'package:rice_dealer_pos/views/main_view.dart';
typedef ToggleMenuVisibilityCallback = void Function();

enum StateType {
  retail,
  wholesale,
}


class ProductListView extends StatefulWidget {

  final ToggleMenuVisibilityCallback toggleMenuVisibility;
  final void Function(dynamic product) mixRice;


  ProductListView({required this.toggleMenuVisibility, required this.mixRice});

  @override
  _ProductListViewState createState() => _ProductListViewState();

}

class _ProductListViewState extends State<ProductListView> {


  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> retail_products = [];

  List<Map<String, dynamic>> packages = [];
  String? selectedPackage;



  List<Map<String, dynamic>> filteredItems = [];

  List<Map<String, dynamic>> distributionList = [];

  List<Map<String, dynamic>> getFilteredPackages() {
    return products
        .where((product) => product['package_category'] == selectedPackage)
        .toList();
  }


  StateType _currentState = StateType.retail; // Declare and initialize the _currentState variable


  int rowsPerPage = 9;
  int currentPage = 0;


  Future<void> fetchData() async {
    final productData = await DatabaseHelper.getProducts();
    setState(() {
      products = List<Map<String, dynamic>>.from(productData);
    });
  }


  Future<void> fetchRetails() async {
    final retailData = await DatabaseHelper.getRetails();
    setState(() {
      retail_products = List<Map<String, dynamic>>.from(retailData);
    });
  }


  void fetchPackages() async{
    final data = await DatabaseHelper.getAllPackages();

    setState(() {
      packages = List<Map<String, dynamic>>.from(data);
    });
    if (packages.isNotEmpty) {
      selectedPackage = packages[0]['package'];
    }
  }

  void navigateToMixRice(dynamic product) async {
    widget.mixRice(product);
    fetchData();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchPackages();
    fetchRetails();


  }


  void distributeToRetail(data) async {

    try {
      await DatabaseHelper.distributeSacks(data);
    } catch (e) {
    }
  }




  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> dataTableData = filteredItems.isNotEmpty ? filteredItems : products;

    if (_currentState == StateType.wholesale) {
      dataTableData = []; // Set dataTableData to an empty list for the "Wholesale" state
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Container(), // add an empty Expanded widget to push the ClockWidget to the right
            ),
            const ClockWidget(),
          ],
        ),
        automaticallyImplyLeading: false,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              MenuToggleButton(onPressed: () {
                // Call the toggleMenuVisibility callback function with the parameter set to true
                widget.toggleMenuVisibility();
              }),
              const Text(
                "Inventory",
                style: TextStyle(fontSize: 24.0, fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex:1,
            child: Container(
              height: 50,
              color: Colors.red[400],
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentState = StateType.retail;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          primary: _currentState == StateType.retail ? const Color(0xff232d37) : const Color(0xff394a5a),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/wheat-svgrepo-com.svg',
                              width: 30,
                              height: 30,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8), // Adjust the spacing between the icon and text
                            const Text(
                              'Retail',
                              style: TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentState = StateType.wholesale;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          primary: _currentState == StateType.wholesale ? const Color(0xff232d37) : const Color(0xff394a5a),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/wheat-svgrepo-com.svg',
                              width: 30,
                              height: 30,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8), // Adjust the spacing between the icon and text
                            const Text(
                              'Bags',
                              style: TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),


                ],
              ),

            ),
          ),
          if (_currentState == StateType.wholesale)
            Container(
              height: 50,
              color: const Color(0xff394a5a),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  final package = packages[index]['package'];

                  return SizedBox(
                    width: 150, // Adjust the width as needed
                    // margin: EdgeInsets.symmetric(horizontal: 8), // Add margin between buttons
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Set the selected package as the state or perform any other action when the button is pressed
                          selectedPackage = package;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        primary: selectedPackage == package ? const Color(0xff232d37) : const Color(0xff394a5a),
                        // Apply any other styles or conditions based on the selected package
                      ),
                      child: Text(package, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                },
              ),
            ),


          if (_currentState == StateType.wholesale )
            SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: const Color(0xff232d37),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(cardColor: const Color(0xff232d37)),
                  child:
                  DataTableTheme(
                    data: DataTableThemeData(
                      dataRowColor: MaterialStateColor.resolveWith((states) => const Color(0xff232d37)),
                      headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xff232d37)),
                    ),
                    child: PaginatedDataTable(
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Text(
                            'Product Name',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'SRP',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Stock',
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
                          label: SizedBox(
                            child: Text(
                              'Action',
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ],

                      source: _WholesaleDataSource(context, products, selectedPackage, onDataFetch: fetchData, fetchRetailData: fetchRetails, navigateToMixPage: navigateToMixRice),

                      rowsPerPage: 9,
                      onPageChanged: (int pageIndex) {
                        setState(() {
                          currentPage = pageIndex;
                        });
                      },
                      availableRowsPerPage: const [5, 9, 15],
                      onRowsPerPageChanged: (int? newRowsPerPage) {
                        setState(() {
                          rowsPerPage = newRowsPerPage!;
                        });
                      },
                      dataRowHeight: 50.2,


                      showCheckboxColumn: false, // Set to true if you want a checkbox column
                    ),
                  ),
                ),
              ),
            ),

          if (_currentState == StateType.retail )
            SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: const Color(0xff232d37),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(cardColor: const Color(0xff232d37)),
                  child:
                  DataTableTheme(
                    data: DataTableThemeData(
                      dataRowColor: MaterialStateColor.resolveWith((states) => const Color(0xff232d37)),
                      headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xff232d37)),
                    ),
                    child: PaginatedDataTable(
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Text(
                            'Product Name',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'SRP',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Stock',
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
                          label: SizedBox(
                            child: Text(
                              'Action',
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ],



                      source: _RetailDataSource(context, retail_products, packages, fetchData: fetchData, fetchRetailData: fetchRetails, navigateToMixPage: navigateToMixRice),

                      rowsPerPage: 10,
                      onPageChanged: (int pageIndex) {
                        setState(() {
                          currentPage = pageIndex;
                        });
                      },
                      availableRowsPerPage: const [5, 10, 15],
                      onRowsPerPageChanged: (int? newRowsPerPage) {
                        setState(() {
                          rowsPerPage = newRowsPerPage!;
                        });
                      },
                      dataRowHeight: 50.2,


                      showCheckboxColumn: false, // Set to true if you want a checkbox column
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


class _WholesaleDataSource extends DataTableSource {

  final BuildContext context;
  List<Map<String, dynamic>> products;
  final Future<void> Function() onDataFetch; // Callback function to be invoked to fetch data
  final Future<void> Function() fetchRetailData; // Callback function to be invoked to fetch data
  final void Function(dynamic) navigateToMixPage; // Callback function to be invoked to fetch dat

  String? selectedPackage;

  _WholesaleDataSource(this.context, this.products, this.selectedPackage, {required this.onDataFetch, required this.fetchRetailData, required this.navigateToMixPage});

  @override
  DataRow? getRow(int index) {

    final filteredProducts = products
        .where((product) => product['package_category'] == selectedPackage)
        .toList();

    if (index >= filteredProducts.length) {
      // Return null or handle the out-of-range case based on your requirements.
      return DataRow(
        color: MaterialStateColor.resolveWith((states) => const Color(0xff232d37)),
        cells: const <DataCell>[
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),

          // Add your DataCells here
        ],
      );
    }

    final product = filteredProducts[index];
    final color = index % 2 == 0 ? Colors.grey[300]! : Colors.grey[200]!;

    print(product['no_item_received']);
    print(product['no_item_received']);
    return DataRow(
      color: MaterialStateColor.resolveWith((states) => color),
      cells: <DataCell>[
        DataCell(Text(product['item_name'], style: const TextStyle(color: Colors.black, fontSize: 20), )),
        DataCell(Text(product['rice_category'], style: const TextStyle(color: Colors.black, fontSize: 20), )),
        DataCell(Text(product['selling_price'] != null ? '₱${product['selling_price'].toString()}' : 'TBA', style: const TextStyle(color: Colors.black, fontSize: 20), )),
        DataCell(
          Text(product['no_item_received'].toString(),
          style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
          // Text(
          //   double.parse(product['no_item_received']).toStringAsFixed(2),
          //   style: const TextStyle(color: Colors.black, fontSize: 20),
          // ),
        ),
        DataCell(Text(product['selling_price'] != null && product['no_item_received'] != null
            ? '₱${(double.parse(product['selling_price'].toString()) * double.parse(product['no_item_received'].toString())).toStringAsFixed(2)}'
            : 'TBA', style: const TextStyle(color: Colors.black, fontSize: 20), )),
        DataCell(
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  barrierDismissible: false, // Prevent tapping outside to dismiss

                  context: context,
                  builder: (BuildContext context) {

                    return DistributionDialog(product: product, fetchRetailData: fetchRetailData,onDataFetch: onDataFetch, selectedPackage: selectedPackage,
                      onDialogDismissed: () {
                        fetchRetailData().then((_) {
                          fetchRetailData();
                        });
                      },
                    );
                  },
                );
              },
              child: const Text('Distribute', style: TextStyle(fontSize: 24,)),
              style: ElevatedButton.styleFrom(
                primary: Color(0xff232d37), // Set the background color of the button
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => products.length;

  @override
  int get selectedRowCount => 0;
}

class _RetailDataSource extends DataTableSource {

  final BuildContext context;
  List<Map<String, dynamic>> retailProducts;
  List<Map<String, dynamic>> packages;
  final void Function(dynamic) navigateToMixPage; // Callback function to be invoked to fetch dat
  final Future<void> Function() fetchData; // Callback function to be invoked to fetch data
  final Future<void> Function() fetchRetailData; // Callback function to be invoked to fetch data


  _RetailDataSource(this.context, this.retailProducts, this.packages, {required this.fetchData, required this.fetchRetailData, required this.navigateToMixPage});


  Future<List<Map<String, dynamic>>> fetchAvailablePackages(String itemName) async{
    final data = await DatabaseHelper.getAvailablePackages(itemName);
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  DataRow? getRow(int index) {
    final retailProduct = retailProducts[index];
    final color = index % 2 == 0 ? Colors.grey[300]! : Colors.grey[200]!;
    print(retailProduct['item_name']);
    print(retailProduct['no_item_received']);
    final packageString = packages[0].toString();
    final numericPart = packageString.replaceAll(RegExp(r'[^0-9]'), '');
    final lowestPackage = int.parse(numericPart);

    if (index >= retailProducts.length) {
      // Return null or handle the out-of-range case based on your requirements.
      return DataRow(
        color: MaterialStateColor.resolveWith((states) => const Color(0xff232d37)),
        cells: const <DataCell>[
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),

          // Add your DataCells here
        ],
      );
    }

    return DataRow(
      color: MaterialStateColor.resolveWith((states) => color),
      cells: <DataCell>[
        DataCell(Text(retailProduct['item_name'], style: const TextStyle(color: Colors.black, fontSize: 20),)),
        DataCell(Text(retailProduct['rice_category'], style: const TextStyle(color: Colors.black, fontSize: 20),)),
        DataCell(Text(retailProduct['selling_price'] != null ? '₱${retailProduct['selling_price']}' : 'TBA', style: const TextStyle(color: Colors.black, fontSize: 20),)),
        DataCell(Text(retailProduct['no_item_received'].toString(), style: const TextStyle(color: Colors.black, fontSize: 20),)),
        DataCell(Text(retailProduct['selling_price'] != null && retailProduct['no_item_received'] != null
            ? '₱${(double.parse(retailProduct['selling_price'].toString()) * double.parse(retailProduct['no_item_received'].toString())).toStringAsFixed(2)}'
            : 'TBA', style: const TextStyle(color: Colors.black, fontSize: 20),)),
        DataCell(
          Row(
            children: [
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: (double.parse(retailProduct['no_item_received'].toString()) < double.parse(lowestPackage.toString())) ? null : () async {

                    final availablePackages = await fetchAvailablePackages(retailProduct['item_name']);

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return RepackDialog(
                          retail_product: retailProduct,
                          packages: availablePackages,
                          fetchData: fetchData,
                          fetchRetailData: fetchRetailData,
                          onDialogDismissed: (){
                            fetchData().then((_) {
                              fetchData();

                            });
                          },
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: (double.parse(retailProduct['no_item_received'].toString()) < double.parse(lowestPackage.toString()))
                        ? MaterialStateProperty.all<Color>(Color(0xff232d37)) // Darker shade of blue
                        : MaterialStateProperty.all<Color>(Color(0xff232d37)),
                  ),
                  child: const Text(
                    'Repack',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    navigateToMixPage(retailProduct);
                  },
                  child: const Text('Mix', style: TextStyle(fontSize: 24,)),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber[800], // Set the background color of the button
                  ),
                ),
              ),
            ],

          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => retailProducts.length;

  @override
  int get selectedRowCount => 0;
}