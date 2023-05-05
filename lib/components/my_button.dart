import 'package:flutter/material.dart';
import 'package:rice_dealer_pos/views/main_view.dart';
class MyButton extends StatelessWidget {


  final Function()? onTap;
  final double width;

  const MyButton({
    super.key,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainView()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(25),
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: Center(
              child: Text(
                  "Sign In",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                  ),
              ),
          ),
        ),
      ),
    );
  }
}