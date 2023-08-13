import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rice_dealer_pos/views/settings_view.dart';
import '../../../api/database_helper.dart';


class RequestPulloutDialog extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Function(int) onSelectIndex;

  const RequestPulloutDialog({
    Key? key,
    required this.items,
    required this.onSelectIndex,
  }) : super(key: key);

  @override
  _RequestPulloutDialogState createState() => _RequestPulloutDialogState();
}

class _RequestPulloutDialogState extends State<RequestPulloutDialog> {


  String note = '';

  void requestPullOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? user_id = await prefs.getInt('loggedInUserId');

    Map<String, dynamic> data = {
      'userId': user_id,
      'branchId': branchId,
      'reason': note,
      'items': widget.items,
    };

    try {
      await DatabaseHelper.sendRequestPullOut(data);

      // Navigate to another page
      widget.onSelectIndex(3);

    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        height: 25,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              if (widget.items.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Cannot Pullout Items', style: TextStyle(fontSize: 32)),
                      content: const Text('The list is empty. Cannot pullout items.', style: TextStyle(fontSize: 24)),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel', style: TextStyle(fontSize: 24)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        ElevatedButton(
                          child: const Text('OK', style: TextStyle(fontSize: 24)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Center(
                          child: SingleChildScrollView(
                            child: AlertDialog(
                              title: const Text('Confirm Pullout Items', style: TextStyle(fontSize: 32)),
                              content: Column(
                                children: [
                                  const Text(
                                    'Are you sure about the requested items?',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(height: 24),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'State the reason for pulling out items:',
                                        style: TextStyle(fontSize: 18, color: Colors.grey[200]),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        maxLines: null, // Set to null for a multi-line input field
                                        decoration: const InputDecoration(
                                          hintText: 'Enter your note...',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            note = value;
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
                                      note = '';
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('Request', style: TextStyle(fontSize: 24)),
                                  onPressed: note.isNotEmpty
                                      ? () {
                                    requestPullOut();
                                    Navigator.of(context).pop();
                                  }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );

              }
            });
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.green[500],
            onPrimary: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/request-sent-svgrepo-com.svg',
                  width: 40,
                  height: 40,
                  color: Colors.white,
                ),
                const SizedBox(width: 15,),
                const Text(
                  'Request Pullout',
                  style: TextStyle(fontSize: 30),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
