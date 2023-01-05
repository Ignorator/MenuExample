import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget
{
  String message = ' ';
  ProgressDialog({Key? key, required this.message}) : super(key: key);


  @override
  Widget build(BuildContext context)
  {
    return Dialog(
        backgroundColor: Colors.white12,
        child: Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                height: 300.0,
                width: double.infinity,
                child: Column(
                    children: [
                      const SizedBox(height: 120.0,),
                      const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),),
                      Text(
                        message,
                        style: const TextStyle(color: Colors.black),
                      )
                    ]
                ),
              ),
            )
        )
    );
  }
}