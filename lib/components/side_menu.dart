import 'package:flutter/material.dart';


class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuItemSelected;

  const SideMenu({
    Key? key,
    required this.selectedIndex,
    required this.onMenuItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.red[400],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Bulacan Branch",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 10),
                Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 50,
                ),
                SizedBox(height: 10),
                Text(
                  "John Alvic P. Viojan",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Material(
            elevation: 4.0,
            color: selectedIndex == 0 ? Colors.red[400] : Colors.transparent,
            child: ListTile(
              onTap: () {
                onMenuItemSelected(0);
              },
              selected: selectedIndex == 0,
              title: Center(
                child: Text(
                  "Dashboard",
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Material(
            elevation: 4.0,
            color: selectedIndex == 1 ? Colors.red[400] : Colors.transparent,
            child: ListTile(
              onTap: () {
                onMenuItemSelected(1);
              },
              selected: selectedIndex == 1,
              title: Center(
                child: Text(
                  "Cart",
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Material(
            elevation: 4.0,
            color: selectedIndex == 2 ? Colors.red[400] : Colors.transparent,
            child: ListTile(
              onTap: () {
                onMenuItemSelected(2);
              },
              selected: selectedIndex == 2,
              title: Center(
                child: Text(
                  "Inventory",
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }
}

