import 'package:flutter/material.dart';

class MenuToggleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MenuToggleButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(
        Icons.menu,
        color: Colors.white,
      ),
    );
  }
}
