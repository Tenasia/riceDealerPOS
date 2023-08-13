import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as Img;

class PrintingZReadingPage extends StatefulWidget{
  final Map<String, dynamic> zReading;
  final String formattedTime;
  PrintingZReadingPage(this.zReading, this.formattedTime);

  @override
  _PrintingZReadingPageState createState() => _PrintingZReadingPageState();
}

class _PrintingZReadingPageState extends State<PrintingZReadingPage>{

  @override
  void initState() {
    super.initState();
    getBluetooth();
    loadBranchName();
  }

  @override
  void dispose(){
    BluetoothThermalPrinter();
    super.dispose();
  }

  bool connected = false;
  List availableBluetoothDevices = [];

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths!;
    });
  }

  Future<void> setConnect(String mac) async {
    final String? result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result");
    if (result == "true") {
      setState(() {
        connected = true;
      });
    }
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      BluetoothThermalPrinter.disconnect();
      setState(() {
        connected = false;
      });
    } else {
      //Handle Not Connected Scenario
    }
  }

  Future<void> printGraphics() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getGraphicsTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      BluetoothThermalPrinter.disconnect();
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<List<int>> getGraphicsTicket() async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    // Print QR Code using native function
    bytes += generator.qrcode('example.com');

    bytes += generator.hr();

    // Print Barcode using native function
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    bytes += generator.cut();

    return bytes;
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }


  String branch_name = '';

  void loadBranchName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      branch_name = prefs.getString('branch_name') ?? ''; // Use a default value if the stored value is null
    });
  }

  Future<List<int>> getTicket() async {

    String salesMonthDay = widget.zReading['total_sales_month'] != null
        ? '${widget.zReading['total_sales_month']}-01'
        : widget.zReading['total_sales_day'];

    DateTime now = DateTime.now();
    String formattedTime = DateFormat('hh:mm a').format(now);  // Format time as 10:09 AM
    String formattedDate = DateFormat('E d MMM y').format(now);  // Format date as Wed 19 Aug 2020

    DateTime forDate = DateTime.parse(salesMonthDay);
    DateTime toDate = forDate;
    if (widget.zReading['total_sales_month'] != null) {
      toDate = DateTime(forDate.year, forDate.month + 1, forDate.day);
    } else {
      toDate = forDate.add(const Duration(days: 1));
    }

    String formattedForDate = DateFormat("MMMM d'${_getDaySuffix(forDate.day)}', hh:mm a").format(forDate);
    String formattedToDate = DateFormat("MMMM d'${_getDaySuffix(toDate.day)}', hh:mm a").format(toDate);
    String reportTitle = widget.zReading['total_sales_day'] != null ? 'Daily Z-Report' : 'Monthly Z-Report';

    double totalPreviousSales = double.parse(widget.zReading['total_previous_sales']) ?? 0.0;
    double grossSales = double.parse(widget.zReading['gross_sales']);
    double runningTotal = totalPreviousSales + grossSales;


    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    final ByteData data = await rootBundle.load('assets/images/PhilipRicelxFA.png');
    final Uint8List imageBytes = data.buffer.asUint8List();
    final Img.Image? image = Img.decodeImage(imageBytes);

    bytes += generator.image(image!);

    bytes += generator.text(
      reportTitle,
      styles: const PosStyles(align: PosAlign.center),
    );

    // Printed Date
    bytes += generator.row([
      PosColumn(
        text: 'Printed: ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '$formattedTime $formattedDate',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Branch: ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '$branch_name',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);

    // For Date
    bytes += generator.row([
      PosColumn(
        text: 'For: ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '$formattedForDate',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);

    // To Date
    bytes += generator.row([
      PosColumn(
        text: 'To: ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '$formattedToDate',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);

    bytes += generator.text(
      "",
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );

    bytes += generator.row([
      PosColumn(
        text: 'Gross Sales: ',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '${widget.zReading['gross_sales']}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Cash Sales: ',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '${widget.zReading['cash_sales']}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'GCash Sales: ',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '${widget.zReading['gcash_sales']}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Bank Transfer: ',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '${widget.zReading['bank_transfer']}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Discount Amount: ',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '${widget.zReading['discount_total']}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.text(
      "",
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.row([
      PosColumn(
        text: 'Start Invoice #: ',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '${widget.zReading['start_inv_number']}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Ending Invoice #: ',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '${widget.zReading['end_inv_number']}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.text(
      "",
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.row([
      PosColumn(
        text: 'Refunded Trans: ',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '${widget.zReading['no_of_refunded_transactions']}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Refunded Amount: ',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '${widget.zReading['refunded_total']}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.text(
      "",
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.row([
      PosColumn(
        text: 'No. Transactions: ',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '${widget.zReading['no_of_transactions']}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (widget.zReading.containsKey('opening_amount')) {
      bytes += generator.row([
        PosColumn(
          text: 'Opening Amount: ',
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: '${widget.zReading['opening_amount']}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: '',
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Closing Amount: ',
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: '${widget.zReading['closing_amount']}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: '',
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }



    bytes += generator.text(
      "",
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.row([
      PosColumn(
        text: 'Previous Reading: ',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '${widget.zReading['total_previous_sales']}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Net Sales: ',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '${widget.zReading['gross_sales']}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Running Total: ',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '$runningTotal',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.text(
        "",
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
    );

    // bytes += generator.emptyRow(); // Add an empty row for spacing

    bytes += generator.hr();

    bytes += generator.text(
        "Z-Reading End",
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.cut();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {

    print(widget.zReading);

    return Dialog(
      child: SizedBox(
        width: 500,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Select Printer',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '(Print Z-Reading)',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Date: ${widget.formattedTime}',
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded( // Wrap the Column with Expanded
              child: availableBluetoothDevices.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'No Devices',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: availableBluetoothDevices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      String select = availableBluetoothDevices[index];
                      List list = select.split("#");
                      String mac = list[1];
                      setConnect(mac);

                    },
                    title: Row(
                      children: [
                        const Icon(Icons.print),
                        const SizedBox(width: 8), // Add spacing between icon and text
                        Text('${availableBluetoothDevices[index].split("#")[0]}'),
                      ],
                    ),
                    subtitle: Text("${availableBluetoothDevices[index].split("#")[1]}"),
                  );
                },
              ),
            ),
            SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    printTicket();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.print, size: 35),
                  label: const Text("Print Z-Reading", style: TextStyle(fontSize: 24.0),),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange[800], // Set the button background color
                  ),
                )

            ),

          ],
        ),
      ),
    );
  }
}