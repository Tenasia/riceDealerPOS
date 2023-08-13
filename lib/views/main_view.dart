import 'package:flutter/material.dart';
import 'package:rice_dealer_pos/components/side_menu.dart';
import 'package:rice_dealer_pos/views/product_list_view.dart';
import 'package:rice_dealer_pos/views/cart_view.dart';
import 'package:rice_dealer_pos/views/sales_view.dart';
import 'package:rice_dealer_pos/views/request_view.dart';
import 'package:rice_dealer_pos/modals/requests/request_items//add_request_modal.dart';
import 'package:rice_dealer_pos/modals/requests/request_items/add_request_main_modal.dart';
import 'package:rice_dealer_pos/modals/requests/request_items/add_request_branches_modal.dart';

import 'package:rice_dealer_pos/views/settings_view.dart';
import 'package:rice_dealer_pos/modals/requests/request_reprice/add_request_reprice.dart';
import 'package:rice_dealer_pos/modals/requests/request_pullout/add_request_pullout.dart';
import 'package:rice_dealer_pos/modals/products/mix_rice.dart';
class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with SingleTickerProviderStateMixin {
  bool isMenuCollapsed = true; // Set it to true to make it collapsed by default
  int selectedMenuIndex = 0;

  Map<String, dynamic>? selectedProduct;

  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  CartView? cartView; // Declare cartView as nullable

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 250),
      vsync: this,
    );
    _widthAnimation = Tween<double>(begin: 0.0, end: 0.065).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    cartView = CartView(
      toggleMenuVisibility: toggleMenuVisibility,
      items: [],
    );

  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleMenuVisibility() {
    setState(() {
      isMenuCollapsed = !isMenuCollapsed;
      if (isMenuCollapsed) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

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
        content = cartView ?? Container(); // Use the stored cartView instance here
        // content = DashboardView(toggleMenuVisibility: toggleMenuVisibility);
        break;
      case 1:
        content = SalesView(toggleMenuVisibility: toggleMenuVisibility);
        break;
      case 2:
        content = ProductListView(
            toggleMenuVisibility: toggleMenuVisibility,
            mixRice: (dynamic product){
              setState(() {
                selectedMenuIndex = 10;
                selectedProduct = product;
              });
            },
        );
        break;
      case 3:
        content = RequestView(
          onAddRequestItemPressed: () {
            setState(() {
              selectedMenuIndex = 4;
            });
          },
          onRequestPricePressed: () {
            setState(() {
              selectedMenuIndex = 6;
            });
          },
          onRequestPullOutPressed: () {
            setState(() {
              selectedMenuIndex = 7;
            });
          },
          onAddRequestMainItemPressed: (){
            setState(() {
              selectedMenuIndex = 8;
            });
          },
          onAddRequestBranchesItemPressed: (){
            setState(() {
              selectedMenuIndex = 9;
            });
          },
          toggleMenuVisibility: toggleMenuVisibility,
        );
        break;
      case 4:
        content = AddRequestItem(
          onSelectIndex: (index) {
            setState(() {
              selectedMenuIndex = index;
            });
          },
        );
        break;
      case 5:
        content = SettingsView(toggleMenuVisibility: toggleMenuVisibility);
        break;
      case 6:
        content = AddRequestReprice(
          onSelectIndex: (index) {
            setState(() {
              selectedMenuIndex = index;
            });
          },
        );
        break;
      case 7:
        content = AddRequestPullOut(
          onSelectIndex: (index) {
            setState(() {
              selectedMenuIndex = index;
            });
          },
        );
        break;
      case 8:
        content = AddRequestMainItem(
          onSelectIndex: (index) {
            setState(() {
              selectedMenuIndex = index;
            });
          },
        );
        break;
      case 9:
        content = AddRequestBranchesModal(
          onSelectIndex: (index) {
            setState(() {
              selectedMenuIndex = index;
            });
          },
        );
        break;
      case 10:
        content = MixWholesale(
          product: selectedProduct,
          onSelectIndex: (index) {
            setState(() {
              selectedMenuIndex = index;
            });
          },
        );
        break;


      default:
        content = cartView ?? Container(); // Use the stored cartView instance here
    }

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * _widthAnimation.value,
                        child: child,
                      );
                    },
                    child: SideMenu(
                      selectedIndex: selectedMenuIndex,
                      onMenuItemSelected: onMenuItemSelected,
                    ),
                  ),
                  Expanded(
                    child: content,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}





