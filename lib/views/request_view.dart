import 'package:flutter/material.dart';
import 'package:rice_dealer_pos/components/clock_widget.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:rice_dealer_pos/components/menu.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rice_dealer_pos/modals/requests/request_items/view_item_requests.dart';
import 'package:rice_dealer_pos/modals/requests/request_items/view_transactions_requests.dart';
import 'package:rice_dealer_pos/modals/requests/request_reprice/view_reprice_requests.dart';
import 'package:rice_dealer_pos/modals/requests/request_items/accept_item_requests.dart';
import 'package:rice_dealer_pos/state_manager.dart';

typedef ToggleMenuVisibilityCallback = void Function();

// enum StateType {requestStocks, requestReprice, requestPullOut, acceptRequests, tradeStocks}

class RequestView extends StatefulWidget {
  late final VoidCallback onAddRequestItemPressed;
  late final VoidCallback onRequestPricePressed;
  late final VoidCallback onRequestPullOutPressed;
  late final VoidCallback onAddRequestMainItemPressed;
  late final VoidCallback onAddRequestBranchesItemPressed;



  final ToggleMenuVisibilityCallback toggleMenuVisibility;

  RequestView({required this.onAddRequestBranchesItemPressed, required this.onAddRequestMainItemPressed, required this.onAddRequestItemPressed, required this.onRequestPricePressed, required this.onRequestPullOutPressed, required this.toggleMenuVisibility});

  @override
  _RequestViewState createState() => _RequestViewState();
}

class _RequestViewState extends State<RequestView> {
  List<Map<String, dynamic>> itemRequests = [];
  List<Map<String, dynamic>> tradeTransactions = [];
  List<Map<String, dynamic>> repriceRequests = [];
  List<Map<String, dynamic>> pulloutRequests = [];

  int rowsPerPage = 9;
  int currentPage = 0;

  String? branch_name;



  TextEditingController textController = TextEditingController();
  List<TextEditingController> textControllers = [];
  String storedValue = '0';

  StateType _currentState = StateManager.currentState;
  List<List<String>> rowDataList = [];

  Future <void> fetchItemRequests() async {
    final data = await DatabaseHelper.getRequestItems();
    setState(() {
      itemRequests = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<List<Map<String, dynamic>>> fetchItemRequestsOnCall() async{
    final data = await DatabaseHelper.getRequestItems();
    return List<Map<String, dynamic>>.from(data);
  }

  void fetchTradeTransactions() async {
    final data = await DatabaseHelper.getTradeTransactions();
    setState(() {
      tradeTransactions = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<List<Map<String, dynamic>>> fetchTradeTransactionsOnCall() async{
    final data = await DatabaseHelper.getTradeTransactions();
    return List<Map<String,dynamic>>.from(data);
  }

  void fetchRepriceRequests() async{
    final data = await DatabaseHelper.getRequestRepricing();
    setState(() {
      repriceRequests = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<List<Map<String, dynamic>>> fetchRepriceRequestsOnCall() async{
    final data = await DatabaseHelper.getRequestRepricing();
    return List<Map<String, dynamic>>.from(data);
  }

  void fetchPullOutRequests() async{
    final data = await DatabaseHelper.getRequestPullOut();
    setState(() {
      pulloutRequests = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<List<Map<String, dynamic>>> fetchPullOutRequestsOnCall() async{
    final data = await DatabaseHelper.getRequestPullOut();
    return List<Map<String, dynamic>>.from(data);
  }


  void refreshData() async {
    final data = await DatabaseHelper.getRequestItems();
    setState(() {
      itemRequests = List<Map<String, dynamic>>.from(data);
    });
  }

  void loadBranchName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      branch_name = prefs.getString('branch_name') ?? ''; // Use a default value if the stored value is null
    });
  }

  void navigateToAddItem() async {
    StateManager.setCurrentState(StateType.requestStocks);
    widget.onAddRequestItemPressed();
    fetchItemRequests();
  }

  void navigateToAddMainItem() async {
    StateManager.setCurrentState(StateType.tradeStocks);
    widget.onAddRequestMainItemPressed();
    fetchItemRequests();
  }

  void navigateToAddBranchesItems() async {
    StateManager.setCurrentState(StateType.tradeStocks);
    widget.onAddRequestBranchesItemPressed();
    fetchItemRequests();
  }

  void navigateToRequestPrice() async{
    StateManager.setCurrentState(StateType.requestReprice);
    widget.onRequestPricePressed();
    fetchItemRequests();
  }

  void navigateToRequestPullOut() async{
    StateManager.setCurrentState(StateType.requestPullOut);
    widget.onRequestPullOutPressed();
    fetchItemRequests();
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
      }
    }

    try {
      await DatabaseHelper.sendDeliveryConfirmation(mapList);

      // Refresh the data after sending the confirmation
      refreshData();
    } catch (e) {

    }
    // Rest of your code
  }

  @override
  void initState() {
    super.initState();
    loadBranchName();
    // Initialize textControllers list with the same length as requests list
  }

  @override
  void dispose(){
    for (var controller in textControllers){
      controller.dispose();
    }
    super.dispose();
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
              InkWell(
                onTap: () {
                  // Call the toggleMenuVisibility callback function with the parameter set to true
                  widget.toggleMenuVisibility();
                },
                child: MenuToggleButton(
                  onPressed: () {
                    // Call the toggleMenuVisibility callback function with the parameter set to true
                    widget.toggleMenuVisibility();
                  },
                ),
              ),
              const Text(
                "Requests",
                style: TextStyle(fontSize: 24.0),
              ),
            ],
          ),

        ),
      ),
      body: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            settings: settings,
            builder: (BuildContext context) {
              return Column(
                children: [
                  Container(
                    height: 100,
                    color: Colors.red[400],
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _currentState = StateType.requestStocks;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      primary: _currentState == StateType.requestStocks ? const Color(0xff232d37) : const Color(0xff394a5a)
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
                                        const SizedBox(width: 10),
                                        const Text('Request Stocks', style: TextStyle(fontSize: 24),),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: branch_name != 'Main Branch',
                                child: Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _currentState = StateType.tradeStocks;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          primary: _currentState == StateType.tradeStocks ? const Color(0xff232d37) : const Color(0xff394a5a)
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
                                          const SizedBox(width: 10),
                                          const Text('Trade Stocks', style: TextStyle(fontSize: 24),),
                                        ],
                                      ),
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
                                        _currentState = StateType.requestReprice;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      primary: _currentState == StateType.requestReprice ?  const Color(0xff232d37) : const Color(0xff394a5a)
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
                                        const Text('Request Reprice', style: TextStyle(fontSize: 24),),
                                      ],
                                    )
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
                                        _currentState = StateType.requestPullOut;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      primary: _currentState == StateType.requestPullOut ?  const Color(0xff232d37) : const Color(0xff394a5a),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/out-svgrepo-com.svg',
                                          width: 30,
                                          height: 30,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text('Request Pullout', style: TextStyle(fontSize: 24),),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_currentState == StateType.requestStocks)
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: navigateToAddItem,
                                      style: ElevatedButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          primary: _currentState == StateType.requestStocks ? const Color(0xff232d37) : const Color(0xff394a5a)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/warehouse-inventory-stock-merchandise-svgrepo-com.svg',
                                            width: 30,
                                            height: 30,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 10),
                                          const Text('Request From Warehouse', style: TextStyle(fontSize: 24),),
                                        ],
                                      )
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_currentState == StateType.tradeStocks)
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                if (branch_name != 'Main Branch')
                                  Expanded(
                                    flex: 3,
                                    child: SizedBox(
                                      height: double.infinity,
                                      child: ElevatedButton(
                                          onPressed: navigateToAddMainItem,
                                          style: ElevatedButton.styleFrom(
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.zero,
                                              ),
                                              primary: _currentState == StateType.tradeStocks ? const Color(0xff232d37) : const Color(0xff394a5a)
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/building-02-svgrepo-com.svg',
                                                width: 30,
                                                height: 30,
                                                color: Colors.red,
                                              ),
                                              const SizedBox(width: 10),
                                              const Text('Request From Main Branch', style: TextStyle(fontSize: 24),),
                                            ],
                                          )
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    flex: 3,
                                    child: SizedBox(
                                      height: double.infinity,
                                      child: ElevatedButton(
                                          onPressed: navigateToAddBranchesItems,
                                          style: ElevatedButton.styleFrom(
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.zero,
                                              ),
                                              primary: _currentState == StateType.tradeStocks ? const Color(0xff232d37) : const Color(0xff394a5a)
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
                                              const Text('Request From Others', style: TextStyle(fontSize: 24),),
                                            ],
                                          )
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (_currentState == StateType.requestReprice)
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: navigateToRequestPrice,
                                      style: ElevatedButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          primary: _currentState == StateType.requestReprice ? const Color(0xff232d37) : const Color(0xff394a5a)
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
                                          const Text('Request Repricing Items', style: TextStyle(fontSize: 24),),
                                        ],
                                      )
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_currentState == StateType.requestPullOut)
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: navigateToRequestPullOut,
                                      style: ElevatedButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          primary: _currentState == StateType.requestPullOut ? const Color(0xff232d37) : const Color(0xff394a5a)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/out-svgrepo-com.svg',
                                            width: 30,
                                            height: 30,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 10),
                                          const Text('Request Pullout of Items', style: TextStyle(fontSize: 24),),
                                        ],
                                      )
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  if (_currentState == StateType.requestStocks)
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
                            child: FutureBuilder <List<Map<String, dynamic>>>(
                              future: fetchItemRequestsOnCall(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Loading Items Requests', style: TextStyle(fontSize: 50, fontFamily: 'Poppins'),),
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
                                  final datasource = _ItemRequestsDataSource(context, snapshot.data!, fetchData: fetchItemRequests);
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return PaginatedDataTable(
                                          columns: const <DataColumn>[
                                            DataColumn(
                                              label: Text(
                                                'Request #',
                                                style: TextStyle(
                                                  fontSize: 25,
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Date Requested',
                                                style: TextStyle(
                                                  fontSize: 25,
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Requested By',
                                                style: TextStyle(
                                                  fontSize: 25,
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Delivered Date',
                                                style: TextStyle(
                                                  fontSize: 25,
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Status',
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

                                          source: datasource,
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
                                        );
                                    }
                                  );
                                }

                                return Text("No Data");
                              }
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (_currentState == StateType.tradeStocks)
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
                              future: fetchTradeTransactionsOnCall(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting){
                                  return const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Loading Items Requests', style: TextStyle(fontSize: 50, fontFamily: 'Poppins'),),
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
                                final dataSource = _TradeRequestsDataSource(context, snapshot.data!, fetchData: fetchTradeTransactions);

                                if (snapshot.hasData) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return PaginatedDataTable(
                                        columns: const <DataColumn>[
                                          DataColumn(
                                            label: Text(
                                              'Invoice #',
                                              style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Purchase Date',
                                              style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Purchased By',
                                              style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Purchased From',
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


                                        showCheckboxColumn: false,  // Set to true if you want a checkbox column
                                      );
                                    }
                                  );
                                }
                                return Text('No data');
                              }
                            ),
                          ),
                        ),
                      ),
                    ),


                  if (_currentState == StateType.requestReprice)
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
                              future: fetchRepriceRequestsOnCall(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting){
                                  return const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Loading Items Requests', style: TextStyle(fontSize: 50, fontFamily: 'Poppins'),),
                                      SizedBox(height: 20,),
                                      CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ],
                                  );
                                }

                                if(snapshot.hasError){
                                  return Text('Error: ${snapshot.error}');
                                }

                                if(snapshot.hasData){

                                  final dataSource = _RequestRepriceDataSource(context, snapshot.data!, fetchData: fetchTradeTransactions);

                                  return PaginatedDataTable(
                                      columns: const <DataColumn>[
                                        DataColumn(
                                          label: Text(
                                            'Request #',
                                            style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.white,
                                              fontStyle: FontStyle.normal,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Date Requested',
                                            style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.white,
                                              fontStyle: FontStyle.normal,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Requested By',
                                            style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Status',
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
                                  );
                                }
                                return Text('No data');
                              }
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (_currentState == StateType.requestPullOut)
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
                              future: fetchPullOutRequestsOnCall(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting){
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Loading Items Requests', style: TextStyle(fontSize: 50, fontFamily: 'Poppins'),),
                                      SizedBox(height: 20,),
                                      CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ],
                                  );
                                }
                                if (snapshot.hasError){
                                  return Text('Error: ${snapshot.error}');
                                }

                                if (snapshot.hasData){

                                  final dataSource = _RequestRepriceDataSource(context, snapshot.data!, fetchData: fetchTradeTransactions);

                                  return PaginatedDataTable(
                                      columns: const <DataColumn>[
                                        DataColumn(
                                        label: Text(
                                          'Request #',
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Date Requested',
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Requested By',
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Status',
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
                                  );

                                }
                                return Text('No Data');
                              }
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ItemRequestsDataSource extends DataTableSource {

  final BuildContext context;
  List<Map<String, dynamic>> itemRequests;
  final Future<void> Function() fetchData; // Callback function to be invoked to fetch data


  _ItemRequestsDataSource(this.context, this.itemRequests, {required this.fetchData});

  @override
  DataRow? getRow(int index) {
    final request = itemRequests[itemRequests.length - 1 - index]; // Reverse the order of the list
    final color =
    index % 2 == 0 ? Colors.grey[300]! : Colors.grey[200]!;
    String createdAtString = request['date_request'];
    DateTime createdAt = DateTime.parse(createdAtString);
    String formattedTime = DateFormat('MMM d yyyy | hh:mm a').format(createdAt);
    return DataRow(
      color: MaterialStateColor.resolveWith((states) => color),
      cells: <DataCell>[
        DataCell(Text(request['request_no'], style: const TextStyle(color: Colors.black, fontSize: 20),)),
        DataCell(Text(formattedTime, style: const TextStyle(color: Colors.black, fontSize: 20))),
        DataCell(
          Text(
            request['staff_name'] != null ? request['staff_name'] : 'N/A',
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        DataCell(Text(request['delivered_date'] != null ? DateFormat('MMMM d, yyyy').format(DateTime.parse(request['delivered_date'])) : 'N/A', style: const TextStyle(color: Colors.black, fontSize: 20))),
        DataCell(
          request['status'] == 'For Prep'
              ? const Text('Preparing Items', style: TextStyle(color: Colors.black, fontSize: 18))
              : request['status'] == 'On Delivery'
              ? const Text('In Transit', style: TextStyle(color: Colors.black, fontSize: 18))
              : request['status'] == 'Completed'
              ? const Text('Completed', style: TextStyle(color: Colors.black, fontSize: 18))
              : request['status'] == 'Discrepance'
              ? const Text('Discrepancy', style: TextStyle(color: Colors.black, fontSize: 18))
              : Container(),
        ),
        DataCell(
          Row(
            children: [
              if (request['status'] != 'On Delivery')
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ViewItemRequestsDialog(formattedTime: formattedTime, request: request);
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
              if (request['status'] == 'On Delivery' || request['delivered_date'] == 'N/A')
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AcceptDeliveryDialog(request: request, formattedTime: formattedTime, fetchItemsRequests: fetchData,
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
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red[400]!),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/delivery-svgrepo-com.svg',
                      width: 100,
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
  int get rowCount => itemRequests.length;

  @override
  int get selectedRowCount => 0;
}

class _TradeRequestsDataSource extends DataTableSource {

  final BuildContext context;
  List<Map<String, dynamic>> tradeTransactions;
  final void Function() fetchData; // Callback function to be invoked to fetch data


  _TradeRequestsDataSource(this.context, this.tradeTransactions, {required this.fetchData});

  @override
  DataRow? getRow(int index) {
    final trade = tradeTransactions[tradeTransactions.length - 1 - index]; // Reverse the order of the list
    final color =
    index % 2 == 0 ? Colors.grey[300]! : Colors.grey[200]!;

    String createdAtString = trade['created_at'];
    DateTime createdAt = DateTime.parse(createdAtString);
    String formattedTime = DateFormat('MMM d yyyy | hh:mm a').format(createdAt);
    return DataRow(
      color: MaterialStateColor.resolveWith((states) => color),
      cells: <DataCell>[
        DataCell(Text(trade['inv_number'], style: const TextStyle(color: Colors.black, fontSize: 20),)),
        DataCell(Text(formattedTime, style: const TextStyle(color: Colors.black, fontSize: 20),)),
        DataCell(Text(trade['staff_name'], style: const TextStyle(color: Colors.black, fontSize: 20),)),
        DataCell(Text(trade['branch_name'], style: const TextStyle(color: Colors.black, fontSize: 20),)),
        DataCell(
          Row(
            children: [
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ViewTransactionsDialog(trade: trade, formattedTime: formattedTime);
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
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => tradeTransactions.length;

  @override
  int get selectedRowCount => 0;
}


class _RequestRepriceDataSource extends DataTableSource {

  final BuildContext context;
  List<Map<String, dynamic>> repriceRequests;
  final void Function() fetchData; // Callback function to be invoked to fetch data


  _RequestRepriceDataSource(this.context, this.repriceRequests, {required this.fetchData});

  @override
  DataRow? getRow(int index) {
    final request = repriceRequests[repriceRequests.length - 1 - index]; // Reverse the order of the list
    final color = index % 2 == 0 ? Colors.grey[300]! : Colors.grey[200]!;
    String createdAtString = request['date_request'];
    DateTime createdAt = DateTime.parse(createdAtString);
    String formattedTime = DateFormat('MMM d yyyy | hh:mm a').format(createdAt);
    return DataRow(
      color: MaterialStateColor.resolveWith((states) => color),
      cells: <DataCell>[
        DataCell(Text(request['request_no'], style: const TextStyle(color: Colors.black, fontSize: 20),)),
        DataCell(Text(formattedTime, style: const TextStyle(color: Colors.black, fontSize: 20),)),
        DataCell(Text(request['staff_name'], style: const TextStyle(color: Colors.black, fontSize: 20),)),
        DataCell(Text(request['status'] ?? 'TBA', style: const TextStyle(color: Colors.black, fontSize: 20),)),
        DataCell(
          Row(
            children: [
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                          return RequestRepriceDialog(request: request);
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
              const SizedBox(width: 8), // Add some spacing between the buttons
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => repriceRequests.length;

  @override
  int get selectedRowCount => 0;
}


