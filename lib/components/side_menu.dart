import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: Material(
              elevation: 4.0,
              color: selectedIndex == 0 ? Colors.red[400] : Colors.transparent,
              child: ListTile(
                onTap: () {
                  onMenuItemSelected(0);
                },
                selected: selectedIndex == 0,
                title: Column(
                  children: const [
                    SizedBox(height: 35.0),
                    Center(
                      child: Icon(
                        Icons.shopping_cart,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
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
                title: Column(
                  children: [
                    const SizedBox(height: 35.0),
                    Center(
                      child: SvgPicture.asset(
                        'assets/icons/peso-svgrepo-com.svg',
                        width: 40,
                        height: 40,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Sales',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              elevation: 4.0,
              color: selectedIndex == 2 || selectedIndex == 10 ? Colors.red[400] : Colors.transparent,
              child: ListTile(
                onTap: () {
                  onMenuItemSelected(2);
                },
                selected: selectedIndex == 2,
                title: Column(
                  children: const [
                    SizedBox(height: 35.0),
                    Center(
                      child: Icon(
                        Icons.inventory,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Inventory',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              elevation: 4.0,
              color:
              selectedIndex == 3 || selectedIndex == 4 || selectedIndex == 6 || selectedIndex == 7 || selectedIndex == 8 || selectedIndex == 9? Colors.red[400] : Colors.transparent,
              child: ListTile(
                onTap: () {
                  onMenuItemSelected(3);
                },
                selected: selectedIndex == 3,
                title: Column(
                  children: [
                    const SizedBox(height: 35.0),
                    Center(
                      child: SvgPicture.asset(
                        'assets/icons/request-sent-svgrepo-com.svg',
                        width: 40,
                        height: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Requests',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              elevation: 4.0,
              color: selectedIndex == 5 ? Colors.red[400] : Colors.transparent,
              child: ListTile(
                onTap: () {
                  onMenuItemSelected(5);
                },
                selected: selectedIndex == 5,
                title: Column(
                  children: const [
                    SizedBox(height: 35.0),
                    Center(
                      child: Icon(
                        Icons.settings,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
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
