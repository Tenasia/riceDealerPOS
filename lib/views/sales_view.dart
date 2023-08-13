import 'package:flutter/material.dart';
import 'package:rice_dealer_pos/components/clock_widget.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';
import 'package:rice_dealer_pos/components/menu.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:rice_dealer_pos/modals/sales/refund_items.dart';
import 'package:rice_dealer_pos/printing/printing_item_discounts.dart';
import 'package:rice_dealer_pos/printing/printing_item_sales.dart';
import 'package:rice_dealer_pos/printing/printing_z_reading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rice_dealer_pos/modals/sales/view_sales.dart';
typedef ToggleMenuVisibilityCallback = void Function();

enum StateType {saleRecords, transactionRecords, saleTransactionRecords, dailySaleRecords, monthlySaleRecords}

class SalesView extends StatefulWidget {

  final ToggleMenuVisibilityCallback toggleMenuVisibility;
  SalesView({required this.toggleMenuVisibility});

  @override
  _SalesViewState createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {

  List<Map<String, dynamic>> sales = [];

  StateType _currentState = StateType.saleRecords; // Declare and initialize the _currentState variable


  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int currentPage = 1;
  String? branch_name;


  List<bool> checkedStates = [];

  Future<void> fetchSalesData() async {
    final data = await DatabaseHelper.getSales(currentPage, rowsPerPage);
    print(data.length);
    setState(() {
      sales = List<Map<String, dynamic>>.from(data);
    });
  }


  Future<List<Map<String, dynamic>>> fetchTransactionsData() async {
    final data = await DatabaseHelper.getAllTradeTransactions();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchBranchTransactionsData() async {
    final data = await DatabaseHelper.getSalesTransactions();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchDailyTotalSales() async {
    final data = await DatabaseHelper.getDailyTotalSales();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchMonthlyTotalSales() async {
    final data = await DatabaseHelper.getMonthlyTotalSales();
    return List<Map<String, dynamic>>.from(data);
  }

  void loadBranchName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      branch_name = prefs.getString('branch_name'); // Use a default value if the stored value is null
    });
  }

  @override
  void initState() {
    super.initState();
    fetchSalesData();
    loadBranchName();
  }


  @override
  Widget build(BuildContext context) {
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
                "Sales",
                style: TextStyle(fontSize: 24.0),
              ),
            ],
          ),
        ),
      ),
      body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle button 1 press
                            setState(() {
                              _currentState = StateType.saleRecords;
                            });

                          },
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            primary: _currentState == StateType.saleRecords ? const Color(0xff232d37) : const Color(0xff394a5a),
                          ),

                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(width: 10),
                              Text('Customer Sales', style: TextStyle(fontSize: 24),),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle button 2 press
                          setState(() {
                            _currentState = StateType.dailySaleRecords;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          primary: _currentState == StateType.dailySaleRecords ? const Color(0xff232d37) : const Color(0xff394a5a),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/peso-svgrepo-com.svg',
                              width: 30,
                              height: 30,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            const Text('Daily Sales', style: TextStyle(fontSize: 24),),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle button 2 press
                          setState(() {
                            _currentState = StateType.monthlySaleRecords;
                          });

                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          primary: _currentState == StateType.monthlySaleRecords ? const Color(0xff232d37) : const Color(0xff394a5a),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/peso-svgrepo-com.svg',
                              width: 30,
                              height: 30,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            const Text('Monthly Sales', style: TextStyle(fontSize: 24),),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (branch_name != 'Main Branch')
                    Expanded(
                      child: SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle button 1 press
                            setState(() {
                              _currentState = StateType.saleTransactionRecords;
                            });

                          },
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            primary: _currentState == StateType.saleTransactionRecords ? const Color(0xff232d37) : const Color(0xff394a5a),
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/building-02-svgrepo-com.svg',
                                width: 30,
                                height: 30,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              const Text('Transactions', style: TextStyle(fontSize: 24),),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (branch_name == 'Main Branch')
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle button 2 press
                            setState(() {
                              _currentState = StateType.transactionRecords;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            primary: _currentState == StateType.transactionRecords ? const Color(0xff232d37) : const Color(0xff394a5a),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/building-02-svgrepo-com.svg',
                                width: 30,
                                height: 30,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              const Text('Branch Transactions', style: TextStyle(fontSize: 24),),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (_currentState == StateType.saleRecords)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xff232d37),
                    child: Theme(
                      data: Theme.of(context).copyWith(cardColor: const Color(0xff232d37)),
                      child: DataTableTheme(
                        data: DataTableThemeData(
                          dataRowColor: MaterialStateColor.resolveWith((states) => const Color(0xff232d37)),
                          headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xff232d37)),
                        ),
                        child: sales.isNotEmpty
                            ? PaginatedDataTable(
                          columns: const <DataColumn>[
                            DataColumn(
                              label: Text(
                                'OR No.',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Customer',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Staff',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Sales Date',
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
                          source: _SalesDataSource(context, sales, onDataFetch: fetchSalesData),
                          rowsPerPage: rowsPerPage,
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
                          showCheckboxColumn: false, // Set to true if you want a checkbox column
                        )
                            : Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_currentState == StateType.dailySaleRecords)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xff232d37),
                    child: Theme(
                      data: Theme.of(context).copyWith(cardColor: const Color(0xff232d37)),
                      child: DataTableTheme(
                        data: DataTableThemeData(
                          dataRowColor: MaterialStateColor.resolveWith((states) => const Color(0xff232d37)),
                          headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xff232d37)),
                        ),
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: fetchDailyTotalSales(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                   Text('Loading Daily Sales', style: TextStyle(fontSize: 50, fontFamily: 'Poppins'),),
                                   SizedBox(height: 20,),
                                   CircularProgressIndicator(
                                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                   ),
                                ],
                              );
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.hasData) {
                              // Data is available, initialize the data source and display the table
                              final dataSource = _DailySalesDataSource(context, snapshot.data!);
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return PaginatedDataTable(
                                    columns: const <DataColumn>[
                                      DataColumn(
                                        label: Text(
                                          'Sales Date (Day)',
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Gross Sales',
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Trans. #',
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Action',
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                    source: dataSource,
                                    rowsPerPage: rowsPerPage,
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
                                    showCheckboxColumn: false, // Set to true if you want a checkbox column
                                  );
                                }
                              );
                            }
                            return const Text('No data available'); // Handle the case when data is not available
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              if (_currentState == StateType.monthlySaleRecords)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xff232d37),
                    child: Theme(
                      data: Theme.of(context).copyWith(cardColor: const Color(0xff232d37)),
                      child: DataTableTheme(
                        data: DataTableThemeData(
                          dataRowColor: MaterialStateColor.resolveWith((states) => const Color(0xff232d37)),
                          headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xff232d37)),
                        ),
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: fetchMonthlyTotalSales(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Loading Monthly Sales', style: TextStyle(fontSize: 50, fontFamily: 'Poppins'),),
                                  SizedBox(height: 20,),
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ],
                              );
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.hasData) {
                              // Data is available, initialize the data source and display the table
                              final dataSource = _MonthlySalesDataSource(context, snapshot.data!);
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return PaginatedDataTable(
                                    columns: const <DataColumn>[
                                      DataColumn(
                                        label: Text(
                                          'Sales Date (Month)',
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Gross Sales',
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'No. Transaction',
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Action',
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                    source: dataSource,
                                    rowsPerPage: rowsPerPage,
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
                                    showCheckboxColumn: false, // Set to true if you want a checkbox column
                                  );
                                }
                              );
                            }
                            return const Text('No data available'); // Handle the case when data is not available
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              if (_currentState == StateType.transactionRecords)
                Expanded(
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
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: fetchTransactionsData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Loading Branch Transactions', style: TextStyle(fontSize: 50, fontFamily: 'Poppins'),),
                                  SizedBox(height: 20,),
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ],
                              );
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.hasData) {
                              // Data is available, initialize the data source and display the table
                              final dataSource = _TransactionDataSource(context, snapshot.data!);
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return PaginatedDataTable(
                                    columns: const <DataColumn>[
                                    DataColumn(
                                      label: Text(
                                        'OR No.',
                                        style: TextStyle(
                                          fontSize: 25,
                                          color: Colors.white,
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                    ),
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
                                        'Staff',
                                        style: TextStyle(
                                          fontSize: 25,
                                          color: Colors.white,
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Transaction Date',
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
                                    source: dataSource,
                                    rowsPerPage: rowsPerPage,
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
                                    showCheckboxColumn: false, // Set to true if you want a checkbox column
                                  );
                                }
                              );
                            }
                            return const Text('No data available'); // Handle the case when data is not available
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              if (_currentState == StateType.saleTransactionRecords)
                Expanded(
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
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: fetchBranchTransactionsData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Loading Branch Transactions', style: TextStyle(fontSize: 50, fontFamily: 'Poppins'),),
                                  SizedBox(height: 20,),
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ],
                              );
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.hasData) {
                              // Data is available, initialize the data source and display the table
                              final dataSource = _TransactionDataSource(context, snapshot.data!);
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return PaginatedDataTable(
                                    columns: const <DataColumn>[
                                      DataColumn(
                                        label: Text(
                                          'OR No.',
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
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
                                          'Staff',
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Transaction Date',
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
                                    source: dataSource,
                                    rowsPerPage: rowsPerPage,
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
                                    showCheckboxColumn: false, // Set to true if you want a checkbox column
                                  );
                                }
                              );
                            }
                            return const Text('No data available'); // Handle the case when data is not available
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

class _SalesDataSource extends DataTableSource {

  final BuildContext context;
  List<Map<String, dynamic>> sales;
  final Future<void> Function() onDataFetch; // Callback function to be invoked to fetch data

  _SalesDataSource(this.context, this.sales, {required this.onDataFetch});

  @override
  DataRow? getRow(int index) {

    final product = sales[index];
    final color = index % 2 == 0 ? Colors.grey[300]! : Colors.grey[200]!;

    bool hasItemsToRefund = product['no_of_item'] != product['no_of_refunded_item'];

    String createdAtString = product['created_at'];
    DateTime createdAt = DateTime.parse(createdAtString);
    String formattedTime = DateFormat('MMM d yyyy | hh:mm a').format(createdAt);

    return DataRow(
      color: MaterialStateColor.resolveWith((states) => color),
      cells: <DataCell>[
        DataCell(FittedBox(
          child: Text(
            product['inv_number'],
            style: const TextStyle(color: Colors.black, fontSize: 20), // Set text color to black
          ),
        )),
        DataCell(Text(
          product['customer_name'],
          style: const TextStyle(color: Colors.black, fontSize: 18), // Set text color to black
        )),
        DataCell(
          Text(
            product['staff_name'] != null ? product['staff_name'] : 'N/A',
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),

        DataCell(Text(
          formattedTime,
          style: const TextStyle(color: Colors.black, fontSize: 16), // Set text color to black
        )),
        DataCell(Text(
          '₱${double.parse(product['cart_total']?.toString() ?? '0.0').toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.black, fontSize: 20), // Set text color to black
        )),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () async {

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ViewSalesDialog(formattedTime: formattedTime, product: product);
                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green[400]!),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/view-svgrepo-com.svg',
                    width: 50,
                    height: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 5),

              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: hasItemsToRefund
                      ? () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return refundDialog(
                          onDialogDismissed: () {
                            onDataFetch().then((_) {
                              onDataFetch();

                            });
                          },
                          product: product,
                          formattedTime: formattedTime,
                        );
                      },
                    );
                  }
                      : null,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(hasItemsToRefund ? Colors.red[400]! : Colors.grey[500]!),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/refund-back-svgrepo-com.svg',
                    width: 50,
                    height: 50,
                    color: Colors.white,
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
  int get rowCount => sales.length;

  @override
  int get selectedRowCount => 0;
}

class _DailySalesDataSource extends DataTableSource {

  final BuildContext context;
  List<Map<String, dynamic>> dailySales;

  _DailySalesDataSource(this.context, this.dailySales);

  @override
  DataRow? getRow(int index) {
    final dailySale = dailySales[dailySales.length - 1 - index];
    final color = index % 2 == 0 ? Colors.grey[300]! : Colors.grey[200]!;
    String createdAtString = dailySale['total_sales_day'];
    final itemSales = dailySale['items'];
    final discountedSales = double.parse(dailySale['discount_total']);

    DateTime createdAt = DateTime.parse(createdAtString);
    String formattedTime = DateFormat('MMM d yyyy | EEEE').format(createdAt);

    return DataRow(
      color: MaterialStateColor.resolveWith((states) => color),
      cells: <DataCell>[
        DataCell(FittedBox(
          child: Text(
            formattedTime,
            style: const TextStyle(color: Colors.black, fontSize: 24), // Set text color to black
          ),
        )),
        DataCell(Text(
          '₱${dailySale['gross_sales'].toString()}',
          style: const TextStyle(color: Colors.black, fontSize: 24), // Set text color to black
        )),
        DataCell(Text(
          dailySale['no_of_transactions'].toString(),
          style: const TextStyle(color: Colors.black, fontSize: 24), // Set text color to black
        )),
        DataCell(
          Row(
            children: [
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: dailySale['no_of_transactions'] == 0 ? null : () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PrintingZReadingPage(
                            dailySale,
                            formattedTime,
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey; // Change the color to gray when disabled
                      }
                      return Colors.orange[800]!; // Default color
                    }),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.print,
                        size: 40,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Z-Print',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 5),

              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: dailySale['no_of_transactions'] == 0 ? null : () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PrintingItemSalesPage(dailySale, formattedTime);
                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey; // Change the color to gray when disabled
                      }
                      return Colors.green[400]!; // Default color
                    }),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.print,
                        size: 40,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text('Items', style: TextStyle(color: Colors.white, fontSize: 20),),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 5),

              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: discountedSales <= 0 ? null : () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PrintingItemSalesDiscountPage(dailySale, formattedTime);
                      },
                    );
                  },
                  style: discountedSales <= 0
                      ? ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  )
                      : ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.print,
                        size: 40,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Discounts',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),

              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => dailySales.length;

  @override
  int get selectedRowCount => 0;
}

class _MonthlySalesDataSource extends DataTableSource {

  final BuildContext context;
  List<Map<String, dynamic>> monthlySales;

  _MonthlySalesDataSource(this.context, this.monthlySales);

  @override
  DataRow? getRow(int index) {
    final monthlySale = monthlySales[monthlySales.length - 1 - index];
    final transactions = monthlySale['transactions'];
    final color = index % 2 == 0 ? Colors.grey[300]! : Colors.grey[200]!;
    String createdAtString = '${monthlySale['total_sales_month']}-01';
    DateTime createdAt = DateTime.parse(createdAtString);
    String formattedTime = DateFormat('MMMM yyyy ', 'en_US').format(createdAt);
    final discountedSales = double.parse(monthlySale['discount_total']);

    return DataRow(
      color: MaterialStateColor.resolveWith((states) => color),
      cells: <DataCell>[
        DataCell(FittedBox(
          child: Text(
            formattedTime,
            style: const TextStyle(color: Colors.black, fontSize: 24), // Set text color to black
          ),
        )),
        DataCell(Text(
          '₱${monthlySale['gross_sales'].toString()}',
          style: const TextStyle(color: Colors.black, fontSize: 24), // Set text color to black
        )),
        DataCell(Text(
          monthlySale['no_of_transactions'].toString(),
          style: const TextStyle(color: Colors.black, fontSize: 24), // Set text color to black
        )),
        DataCell(
          Row(
            children: [
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: monthlySale['no_of_transactions'] == "0" ? null : () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PrintingZReadingPage(
                            monthlySale,
                            formattedTime,
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey; // Change the color to gray when disabled
                      }
                      return Colors.orange[800]!; // Default color
                    }),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.print,
                        size: 40,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Z-Print',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                )
                ,
              ),
              const SizedBox(width: 5),

              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: monthlySale['no_of_transactions'] == "0" ? null : () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PrintingItemSalesPage(monthlySale, formattedTime);
                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey; // Change the color to gray when disabled
                      }
                      return Colors.green[400]!; // Default color
                    }),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.print,
                        size: 40,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text('Items', style: TextStyle(color: Colors.white, fontSize: 20),),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 5),

              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: discountedSales <= 0 ? null : () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PrintingItemSalesDiscountPage(monthlySale, formattedTime);
                      },
                    );
                  },
                  style: discountedSales <= 0
                      ? ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  )
                      : ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.print,
                        size: 40,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Discounts',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
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
  int get rowCount => monthlySales.length;

  @override
  int get selectedRowCount => 0;
}
class _TransactionDataSource extends DataTableSource {

  final BuildContext context;
  List<Map<String, dynamic>> transactions;


  _TransactionDataSource(this.context, this.transactions);

  @override
  DataRow? getRow(int index) {
    final transaction = transactions[transactions.length - 1 - index];
    final items = transaction['items'];
    final color = index % 2 == 0 ? Colors.grey[300]! : Colors.grey[200]!;
    String createdAtString = transaction['created_at'];
    DateTime createdAt = DateTime.parse(createdAtString);
    String formattedTime = DateFormat('MMM d yyyy | hh:mm a').format(createdAt);

    return DataRow(
      color: MaterialStateColor.resolveWith((states) => color),
      cells: <DataCell>[
        DataCell(FittedBox(
          child: Text(
            transaction['inv_number'],
            style: const TextStyle(color: Colors.black, fontSize: 20), // Set text color to black
          ),
        )),
        DataCell(Text(
          '${transaction['customer_branch_name']}',
          style: const TextStyle(color: Colors.black, fontSize: 18), // Set text color to black
        )),
        DataCell(Text(
          transaction['staff_name'],
          style: const TextStyle(color: Colors.black, fontSize: 18), // Set text color to black
        )),
        DataCell(Text(
          formattedTime,
          style: const TextStyle(color: Colors.black, fontSize: 18), // Set text color to black
        )),
        DataCell(Text(
          '₱${double.parse(transaction['cart_total']?.toString() ?? '0.0').toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.black, fontSize: 20), // Set text color to black
        )),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns children along the center of the main axis
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
                                          '${transaction['inv_number']}',
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
                                          formattedTime,
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
                                          '${transaction['staff_name'] ?? 'N/A'}',
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
                                          '₱${double.parse(transaction['cart_total']?.toString() ?? '0.0').toStringAsFixed(2)}',
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

                              Divider(  // Add the Divider widget here
                                color: Colors.grey[400],
                                thickness: 1.0,
                                height: 20.0,
                              ),

                              DataTable(
                                // DataTable configuration and columns here
                                columns: const <DataColumn>[
                                  DataColumn(
                                    label: Text('Branch',
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text('PRD Name',
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text('PKG Type',
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text('QTY',
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text('Price',
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text('Total',
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
                                  items.length,
                                      (index) {
                                    final item = items[index];
                                    final total = item['total'].toString();
                                    return DataRow(
                                      cells: <DataCell>[

                                        DataCell(Text(item['branch_name'],
                                          style: const TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                        ),

                                        DataCell(Text(item['item_name'],
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

                                        DataCell(Text(item['no_item'].toString(),
                                          style: const TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                        ),
                                        DataCell(Text('₱${item['price']}',
                                          style: const TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                        ),
                                        DataCell(Text('₱$total',
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
                            ],
                          ),
                        );                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green[400]!),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/view-svgrepo-com.svg',
                    width: 50,
                    height: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => transactions.length;

  @override
  int get selectedRowCount => 0;
}

