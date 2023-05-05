import 'package:flutter/material.dart';
import 'package:rice_dealer_pos/components/clock_widget.dart';
class DashboardView extends StatelessWidget{
  @override
  Widget build(BuildContext context){
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
                "Dashboard",
                style: TextStyle(fontSize: 24.0),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: Text(
            "This is the Dashboard screen",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}