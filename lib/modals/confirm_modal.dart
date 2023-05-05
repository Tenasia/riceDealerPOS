import 'package:flutter/material.dart';

class ConfirmModal extends StatelessWidget{
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  ConfirmModal({required this.message, required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context){
    return AlertDialog(
      title: Text('Confirm Checkout'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onConfirm,
          child: Text('Checkout'),
        ),
        TextButton(
          onPressed: (){
            Navigator.of(context).pop();
            onCancel();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
