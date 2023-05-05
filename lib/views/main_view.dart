import 'package:flutter/material.dart';
import 'package:rice_dealer_pos/components/side_menu.dart';
import 'package:rice_dealer_pos/views/product_list_view.dart';
import 'package:rice_dealer_pos/views/cart_view.dart';
import 'package:rice_dealer_pos/views/dashboard_view.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int selectedMenuIndex = 0;
  CartView cartView = CartView(cartItems: []);

  void onMenuItemSelected(int index) {
    setState(() {
      selectedMenuIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (selectedMenuIndex) {
      case 0:
        content = DashboardView();
        break;
      case 1:
        content = cartView;
        break;
      case 2:
        content = ProductListView();
        break;
      default:
        content = DashboardView();
    }

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // default flex = 1
            // and it takes 1/6 part of the screen
            Expanded(
              child: SideMenu(
                selectedIndex: selectedMenuIndex,
                onMenuItemSelected: onMenuItemSelected,
              ),
            ),

            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}
