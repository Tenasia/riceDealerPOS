import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';
import 'package:rice_dealer_pos/views/main_view.dart';
class CurrentCustomerDropdown extends StatefulWidget {
  final String? selectedCustomer;
  final String? selectedCustomerName;
  final List<Map<String, dynamic>> customers;
  final void Function(String, String) onCustomerChanged;

  const CurrentCustomerDropdown({
    required this.selectedCustomer,
    required this.selectedCustomerName,
    required this.customers,
    required this.onCustomerChanged,
  });

  @override
  _CurrentCustomerDropdownState createState() => _CurrentCustomerDropdownState();
}

class _CurrentCustomerDropdownState extends State<CurrentCustomerDropdown> {
  String? dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.selectedCustomer;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.red[400],
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.grey[800],
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    const Text(
                      'Current Customer:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: widget.selectedCustomer,
                      // isExpanded: true,
                      items: widget.customers.map((customer) {
                        final String id = customer['id'].toString();
                        final String name = customer['customer_name'];
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }).toList(),
                      iconEnabledColor: Colors.white,
                      underline: Container(),
                      onChanged: (value) {
                        setState(() {
                          dropdownValue = value;
                          final selectedCustomerData = widget.customers.firstWhere(
                                (customer) => customer['id'].toString() == value,
                            orElse: () => {},
                          );

                          String selectedCustomerName = selectedCustomerData['customer_name'];

                          if (selectedCustomerData != null) {
                            widget.onCustomerChanged(value!, selectedCustomerName);
                          } else {
                            widget.onCustomerChanged('', '');
                          }
                        });
                      },
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

