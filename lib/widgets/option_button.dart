import 'package:flutter/material.dart';
import 'package:winds_of_war/theme/colors.dart';

class OptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const OptionButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3.0),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.buttonColor,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            minimumSize: const Size(100, 40), //////// HERE
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17.0,
            ),
          )),
    );
  }
}
