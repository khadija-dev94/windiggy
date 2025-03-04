import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  @required
  String hintText;
  @required
  String errorText;
  @required
  TextEditingController controller;
  @required
  TextInputType textType;
  @required
  bool obscure;

  InputField(
    this.hintText,
    this.errorText,
    this.controller,
    this.textType,
    this.obscure,
  );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.08,
          minHeight: MediaQuery.of(context).size.height * 0.06),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextFormField(
          validator: (value) {
            if (value.isEmpty) {
              return errorText;
            }
            return null;
          },
          keyboardType: textType,
          obscureText: obscure,
          textAlign: TextAlign.left,
          controller: controller,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Roboto Regular',
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: 'Roboto Regular',
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
