import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as Img;

import '../api/database_helper.dart';


class PrintingItemSalesDiscountPage extends StatefulWidget{
  final Map<String, dynamic> itemSales;
  final String formattedTime;

  PrintingItemSalesDiscountPage(this.itemSales, this.formattedTime);

  @override
  _PrintingItemSalesDiscountPageState createState() => _PrintingItemSalesDiscountPageState();
}

class _PrintingItemSalesDiscountPageState extends State<PrintingItemSalesDiscountPage>{

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

  Future<List<Map<String, dynamic>>> fetchDailyItemDiscounts(String totalSalesDay) async {
    final data = await DatabaseHelper.getDailyItemDiscountSold(totalSalesDay);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchMonthlyItemDiscounts(String totalSalesMonth) async {
    final data = await DatabaseHelper.getMonthlyItemDiscountSold(totalSalesMonth);
    return List<Map<String, dynamic>>.from(data);
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

    DateTime now = DateTime.now();
    String formattedTime = DateFormat('hh:mm a').format(now);  // Format time as 10:09 AM
    String formattedDate = DateFormat('E d MMM y').format(now);  // Format date as Wed 19 Aug 2020

    String salesMonthDay = widget.itemSales['total_sales_month'] != null
        ? '${widget.itemSales['total_sales_month']}-01'
        : widget.itemSales['total_sales_day'];


    List<Map<String, dynamic>> discountedItems;

    if (widget.itemSales['total_sales_month'] != null) {
      discountedItems = await fetchMonthlyItemDiscounts(widget.itemSales['total_sales_month']);
    } else {
      discountedItems = await fetchDailyItemDiscounts(widget.itemSales['total_sales_day']);
    }

    DateTime forDate = DateTime.parse(salesMonthDay);
    DateTime toDate = forDate;
    if (widget.itemSales['total_sales_month'] != null) {
      toDate = DateTime(forDate.year, forDate.month + 1, forDate.day);
    } else {
      toDate = forDate.add(const Duration(days: 1));
    }

    String formattedForDate = DateFormat("MMMM d'${_getDaySuffix(forDate.day)}', hh:mm a").format(forDate);
    String formattedToDate = DateFormat("MMMM d'${_getDaySuffix(toDate.day)}', hh:mm a").format(toDate);

    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    final ByteData data = await rootBundle.load('assets/images/PhilipRicelxFA.png');
    final Uint8List imageBytes = data.buffer.asUint8List();
    final Img.Image? image = Img.decodeImage(imageBytes);

    bytes += generator.image(image!);

    String reportTitle = widget.itemSales['total_sales_day'] != null ? 'Daily Item Discount Sales' : 'Monthly Item Discount Sales';
    bytes += generator.text(
      reportTitle,
      styles: const PosStyles(align: PosAlign.center),
    );

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

    // Printed Date
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

    // For Date
    bytes += generator.text(
      "",
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );

    bytes += generator.hr();
    List<PosColumn> headerColumns = [
      PosColumn(
        text: 'Item Name',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: 'PKG',
        width: 2,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
      PosColumn(
        text: 'QTY.',
        width: 2,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
      PosColumn(
        text: 'Total',
        width: 3,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
      PosColumn(
        text: 'DISC.',
        width: 2,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ];

    bytes += generator.row(headerColumns);

    // Create rows for each item
    for (var item in discountedItems) {

      String packageCategory = item['package_category'].toString().replaceFirst('KG', ' KG');

      List<PosColumn> itemColumns = [
        PosColumn(
          text: item['item_name'].toString(),
          width: 3,
        ),
        PosColumn(
          text: item['package_category'] == 'Retail' ? '1 KG' : packageCategory,
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: item['no_item'].toString(),
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: item['total'].toString(),
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: item['discount'].toString(),
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ];

      bytes += generator.row(itemColumns);
    }
    // bytes += generator.emptyRow(); // Add an empty row for spacing
    bytes += generator.hr(ch: '-');

    List<PosColumn> itemColumns = [
      PosColumn(
        text: '',
        width: 4,
      ),
      PosColumn(
        text: '',
        width: 2,
        styles: const PosStyles(align: PosAlign.right),
      ),

      PosColumn(
        text: 'Total DISC. :',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: widget.itemSales['discount_total'],
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ];

    bytes += generator.row(itemColumns);

    bytes += generator.text(
      "",
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );

    bytes += generator.text(
        "Item Sales End",
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.cut();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {

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
                    '(Print Item Sales Discount)',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  label: const Text("Print Item Sales Discounts", style: TextStyle(fontSize: 24.0),),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue[400], // Set the button background color
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}