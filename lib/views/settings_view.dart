import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rice_dealer_pos/components/clock_widget.dart';
import 'package:rice_dealer_pos/components/menu.dart';
import 'package:rice_dealer_pos/views/main_view.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rice_dealer_pos/pages/login_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ToggleMenuVisibilityCallback = void Function();
int branchId = 0;

class SettingsView extends StatefulWidget {

  final ToggleMenuVisibilityCallback toggleMenuVisibility;


  SettingsView({required this.toggleMenuVisibility});

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

void _clearAndNavigateToLoginPage(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('loggedInUserId');
  prefs.remove('loggedInRoleId');

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}

class _SettingsViewState extends State<SettingsView> {
  int? loggedInRoleId; // Declare the class-level variable
  String? employee_fullname;
  String? role_status;
  
  String openingAmountInput = '';
  String closingAmountInput = '';

  String? currentOpeningAmount;
  String? currentClosingAmount;

  Future<void> getRoleId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedInRoleId = prefs.getInt('loggedInRoleId');
  }

  List<Map<String, dynamic>> branches = [];
  Map<String, dynamic> openingClosingAmounts = {};

  int? selectedBranchId; // Change the type to int?

  void fetchData() async {
    final data = await DatabaseHelper.getAllBranches();
    setState(() {
      branches = List<Map<String, dynamic>>.from(data);
      selectedBranchId = branchId;
      // Check if the selectedBranchId is a valid ID in the branches list
      if (!branches.any((branch) => branch['id'] == selectedBranchId.toString())) {
        selectedBranchId = null; // Set to null if the ID is not found
      }
    });

    fetchOpeningClosingAmounts();
  }


  void fetchUsers() async {
    List<dynamic> data = await DatabaseHelper.getUsers();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? user_id = await prefs.getInt('loggedInUserId');

    // Iterate through the data list
    for (var user in data) {
      if (user['id'] == user_id.toString()) {
        // Concatenate the first_name and last_name
        employee_fullname = '${user['first_name']} ${user['last_name']}';
        role_status = '${user['role_name']}';
        break; // Exit the loop since we found the match
      }
    }
  }


  void loadBranchId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      branchId = prefs.getInt('branchId') ?? 0; // Use a default value if the stored value is null
    });
  }

  void saveBranchId(int branch_id, String branch_name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('branchId', branch_id);
    await prefs.setString('branch_name', branch_name);

    setState(() {
      branchId = branch_id;
      branch_name = branch_name;
    });

    print(branch_name);

    await fetchOpeningClosingAmounts();
  }

  Future<void> enterOpeningAmount(amount) async {

    try {
      await DatabaseHelper.setOpeningAmount(amount);
    } catch (e) {

    }
  }

  Future<void> enterClosingAmount(amount) async{
    try{
      await DatabaseHelper.setClosingAmount(amount);
    } catch(e){

    }
  }

  Future<void> fetchOpeningClosingAmounts() async {
    final data = await DatabaseHelper.getOpeningClosingAmounts();

    setState(() {
      currentOpeningAmount = data['opening_amount'];
      currentClosingAmount = data['closing_amount'];
    });

  }






  @override
  void initState() {
    super.initState();
    fetchData();
    loadBranchId();
    getRoleId();
    fetchUsers();

    fetchOpeningClosingAmounts();


    if (selectedBranchId == null || !branches.any((branch) => branch['id'] == selectedBranchId.toString())) {
      selectedBranchId = branches.isNotEmpty ? int.parse(branches[0]['id']) : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "Settings",
                style: TextStyle(fontSize: 24.0),
              ),
            ],
          ),
        ),
      ),
      body:
      Container(
        color: Colors.grey[200],
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Set the desired darker shade of gray
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                      Icons.person,
                                      size: 48,
                                      color: Colors.black,
                                    ),
                                  Text(
                                    "$employee_fullname", // Replace with your first name and last name combined
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Staff Position: $role_status", // Replace with the staff position text
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Column(
                              children: [

                              ],
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: currentOpeningAmount != null
                                  ? null
                                  : () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        return Center(
                                          child: SingleChildScrollView(
                                            child: AlertDialog(
                                              title: const Text('Enter Opening Amount', style: TextStyle(fontSize: 32)),
                                              content: Column(
                                                children: [
                                                  const Text(
                                                    'Enter the opening amount for this branch',
                                                    style: TextStyle(fontSize: 24),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Input the opening amount:',
                                                        style: TextStyle(fontSize: 18, color: Colors.grey[200]),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      TextField(
                                                        maxLines: null, // Set to null for a multi-line input field
                                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                                        decoration: const InputDecoration(
                                                          hintText: 'Enter the amount',
                                                          border: OutlineInputBorder(),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            openingAmountInput = value;
                                                            // note = value;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Cancel', style: TextStyle(fontSize: 24)),
                                                  onPressed: () {
                                                    setState((){
                                                      openingAmountInput = '';
                                                      // note = '';
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                ElevatedButton(
                                                  onPressed: openingAmountInput.isNotEmpty
                                                      ? () async {
                                                    // requestPullOut();
                                                    await enterOpeningAmount(openingAmountInput);

                                                    await fetchOpeningClosingAmounts();

                                                    Navigator.of(context).pop();
                                                  }
                                                      : null,
                                                  style: ElevatedButton.styleFrom(
                                                    primary: Colors.green,
                                                  ),
                                                  child: const Text('Apply', style: TextStyle(fontSize: 24)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: currentOpeningAmount != null
                                    ? MaterialStateProperty.all(Colors.grey)
                                    : MaterialStateProperty.all(Colors.green),
                              ),
                              child: const Text('Enter Opening Amount', style: TextStyle(fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.w400),),
                            ),
                          ),

                          SizedBox(
                            height:50,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currentOpeningAmount != null
                                      ? "Today's Opening Amount: ₱$currentOpeningAmount"
                                      : "Opening Amount Isn't Set Yet",
                                  style: TextStyle(color: Colors.black, fontSize: 16),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 12.5),
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: currentOpeningAmount == null || currentClosingAmount != null
                                  ? null
                                  : () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        return Center(
                                          child: SingleChildScrollView(
                                            child: AlertDialog(
                                              title: const Text('Enter Closing Amount', style: TextStyle(fontSize: 32)),
                                              content: Column(
                                                children: [
                                                  const Text(
                                                    'Enter the closing amount for this branch',
                                                    style: TextStyle(fontSize: 24),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Input the closing amount:',
                                                        style: TextStyle(fontSize: 18, color: Colors.grey[200]),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      TextField(
                                                        maxLines: null, // Set to null for a multi-line input field
                                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                                        decoration: const InputDecoration(
                                                          hintText: 'Enter the amount',
                                                          border: OutlineInputBorder(),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            closingAmountInput = value;
                                                            // note = value;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Cancel', style: TextStyle(fontSize: 24)),
                                                  onPressed: () {
                                                    setState((){
                                                      closingAmountInput = '';
                                                      // note = '';
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                ElevatedButton(
                                                  onPressed: closingAmountInput.isNotEmpty
                                                      ? () async {
                                                    // requestPullOut();
                                                    await enterClosingAmount(closingAmountInput);

                                                    await fetchOpeningClosingAmounts();

                                                    Navigator.of(context).pop();
                                                  }
                                                      : null,
                                                  style: ElevatedButton.styleFrom(
                                                    primary: Colors.deepOrangeAccent,
                                                  ),
                                                  child: const Text('Apply', style: TextStyle(fontSize: 24)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: currentOpeningAmount == null || currentClosingAmount != null
                                    ? MaterialStateProperty.all(Colors.grey)
                                    : MaterialStateProperty.all(Colors.deepOrangeAccent),
                              ),
                              child: const Text('Enter Closing Amount', style: TextStyle(fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.w400),),
                            ),
                          ),
                          SizedBox(
                            height:50,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currentClosingAmount != null
                                      ? "Today's Closing Amount: ₱$currentClosingAmount"
                                      : "Closing Amount Isn't Set Yet",
                                  style: TextStyle(color: Colors.black, fontSize: 16),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 50,),

                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _clearAndNavigateToLoginPage(context);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red, // Set the background color to red
                              ),
                              child: const Text('Log Out', style: TextStyle(fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.w400),),
                            ),
                          ),
                          const SizedBox(width: 25,)
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 20),
                        SvgPicture.asset(
                          'assets/icons/building-02-svgrepo-com.svg',
                          width: 50,
                          height: 50,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 20),

                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Current Branch',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        Align(
                          alignment: Alignment.center,
                          child: DropdownButton(
                            value: selectedBranchId,
                            items: branches.map((branch) {
                              final branchName = branch['branch_name']; // Store branch name in a separate variable

                              return DropdownMenuItem<int>(
                                value: int.parse(branch['id']),
                                child: Text(
                                  branchName, // Use the stored branch name variable here
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                              );
                            }).toList(),
                            iconEnabledColor: Colors.black,
                            dropdownColor: Colors.grey[300],
                            underline: Container(),
                            onChanged: loggedInRoleId != 1
                                ? null
                                : (value) {
                              setState(() {
                                selectedBranchId = value as int?;
                                final branchName = branches
                                    .firstWhere((branch) => branch['id'] == value.toString())['branch_name'];
                                saveBranchId(value!, branchName);
                                // fetchOpeningClosingAmounts();
                              });
                            },
                            onTap: loggedInRoleId == 1 ? null : () {},
                          ),
                        ),

                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Expanded(
                          flex: 6,
                          child: SingleChildScrollView(
                            child: Image.asset(
                              'assets/images/company_logo_gray.png',
                              width: 400,
                              height: 400,
                            ),
                          ),
                        ),


                      ],
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}