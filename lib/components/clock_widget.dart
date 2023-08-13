import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/calendar-days-svgrepo-com.svg',
              width: 30,
              height: 30,
              color: Colors.white,
            ),
            const SizedBox(width: 8), // Adjust the spacing between the icon and text
            Text(DateFormat('MMM dd yyyy (EEEE) | hh:mm:ss a').format(DateTime.now()), style: const TextStyle(fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,),),
          ],
        );
      },
    );
  }
}

