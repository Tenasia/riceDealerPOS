import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as Img;

class PrintingTransactionPage extends StatefulWidget{
  final Map<String, dynamic> receiptData;

  PrintingTransactionPage(this.receiptData);

  @override
  _PrintingTransactionPageState createState() => _PrintingTransactionPageState();
}

class _PrintingTransactionPageState extends State<PrintingTransactionPage>{
  @override
  void initState() {
    super.initState();
    getBluetooth();
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

  Future<List<int>> getTicket() async {

    DateTime now = DateTime.now();
    String formattedTime = DateFormat('hh:mm a').format(now);  // Format time as 10:09 AM
    String formattedDate = DateFormat('E d MMM y').format(now);  // Format date as Wed 19 Aug 2020
    String formattedDateTime = DateFormat('dd-MM-yyyy HH:mm:ss').format(now);

    List<dynamic> items = widget.receiptData['items'];


    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    final ByteData data = await rootBundle.load('assets/images/PhilipRicelxFA.png');
    final Uint8List imageBytes = data.buffer.asUint8List();
    final Img.Image? image = Img.decodeImage(imageBytes);

    bytes += generator.image(image!);


    bytes += generator.text("${widget.receiptData['branch_name']} Order Slip",
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    bytes += generator.text(
        "Philips Rice Dealer",
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('$formattedTime $formattedDate',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Cashier: ${widget.receiptData['employee_name']}',
        styles: const PosStyles(align: PosAlign.center));

    bytes += generator.hr();
    List<PosColumn> headerColumns = [
      PosColumn(
        text: 'Item',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: 'Package',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      PosColumn(
        text: 'Qty',
        width: 2,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      PosColumn(
        text: 'Total',
        width: 2,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ];

    bytes += generator.row(headerColumns);

// Create rows for each item
    for (var item in items) {
      List<PosColumn> itemColumns = [
        PosColumn(
          text: item['item_name'].toString(),
          width: 5,
        ),
        PosColumn(
          text: item['selling_category'] == 'Retail' ? '1KG' : item['package_category'].toString(),
          width: 3,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: item['quantity'].toString(),
          width: 2,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: item['total_price'].toString(),
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ];

      bytes += generator.row(itemColumns);
    }
    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'GROSS TOTAL',
          width: 6,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: "${widget.receiptData['total']}",
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    bytes += generator.hr(ch: '=', linesAfter: 1);

    // ticket.feed(2);
    bytes += generator.text('Thank you!',
        styles: const PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text(formattedDateTime,
        styles: const PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += generator.text(
        'Note: Goods once sold will not be taken back or exchanged.',
        styles: const PosStyles(align: PosAlign.center, bold: false));
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
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Select Printer',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '(Print Sales Receipt)',
                    style: TextStyle(
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
                label: const Text("Print Receipt", style: TextStyle(fontSize: 24.0),),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Set the button background color
                ),
              )

            ),

          ],
        ),
      ),
    );
  }
}

// Map<String, dynamic>? combinedItems = widget.itemSales['combined_items'];
// print('Total Sales: ${widget.itemSales['gross_sales']}');
// print('----------------');
//
// combinedItems?.forEach((key, value) {
// print('Item Name: ${key}');
// print('QTY: ${value['no_item']}');
// print('PKG: ${value['package_category']}');
// print('TOTAL: ${value['total']}');
// print('---------------------');
// });