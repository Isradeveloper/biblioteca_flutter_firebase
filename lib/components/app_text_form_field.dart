import 'package:biblioteca_flutter_firebase/values/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField(
      {required this.textInputAction,
      required this.labelText,
      required this.keyboardType,
      required this.controller,
      super.key,
      this.onChanged,
      this.validator,
      this.obscureText,
      this.suffixIcon,
      this.onEditingComplete,
      this.autofocus,
      this.focusNode,
      this.readOnly,
      this.onTap});

  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final bool? obscureText;
  final Widget? suffixIcon;
  final String labelText;
  final bool? autofocus;
  final bool? readOnly;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final void Function()? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        focusNode: focusNode,
        onChanged: onChanged,
        autofocus: autofocus ?? false,
        validator: validator,
        obscureText: obscureText ?? false,
        obscuringCharacter: '*',
        onEditingComplete: onEditingComplete,
        onTap: onTap,
        readOnly: readOnly ?? false,
        decoration: InputDecoration(
            suffixIcon: suffixIcon,
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            errorStyle: const TextStyle(color: AppColors.primaryColor)),
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        style: const TextStyle(
            fontWeight: FontWeight.w500, color: AppColors.white),
      ),
    );
  }
}
