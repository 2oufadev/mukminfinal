import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String? hint;
  final String? initial;
  final TextInputType? type;
  final EdgeInsets? padding;
  final Widget? suffix;
  final TextEditingController? ctrl;
  final obscur;
  final Color? inputTextColor;
  const CustomInputField({
    this.hint,
    this.initial,
    this.obscur = false,
    this.ctrl,
    this.suffix,
    this.padding,
    this.type,
    Key? key,
    this.inputTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 32.0),
      child: TextFormField(
        initialValue: initial,
        controller: ctrl,
        keyboardType: type ?? TextInputType.text,
        style: TextStyle(
          color: inputTextColor ?? Color.fromRGBO(162, 204, 128, 1),
        ),
        cursorColor: Colors.white,
        obscureText: obscur,
        decoration: InputDecoration(
            suffixIconConstraints:
                BoxConstraints(maxHeight: 28.0, maxWidth: 80),
            suffixIcon: suffix,
            hintText: hint?.toUpperCase(),
            hintStyle: TextStyle(color: Colors.amber.withOpacity(0.6)),
            focusedBorder: OutlineInputBorder(
              gapPadding: 0.0,
              borderSide: BorderSide(
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.black54,
            border: OutlineInputBorder(
              gapPadding: 0.0,
              borderSide: BorderSide(
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(8.0),
            )),
      ),
    );
  }
}
