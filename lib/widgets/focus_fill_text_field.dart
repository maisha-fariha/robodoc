import 'package:flutter/material.dart';

class FocusFillTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final Widget? suffixIcon;
  final Color baseFillColor;
  final Color focusedFillColor;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const FocusFillTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.baseFillColor,
    required this.focusedFillColor,
    this.keyboardType,
    this.autofillHints,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
    this.onChanged,
  });

  @override
  State<FocusFillTextField> createState() => _FocusFillTextFieldState();
}

class _FocusFillTextFieldState extends State<FocusFillTextField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant FocusFillTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChange);
      widget.focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        autofillHints: widget.autofillHints,
        obscureText: widget.obscureText,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onFieldSubmitted,
        validator: widget.validator,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          filled: true,
          fillColor: widget.focusNode.hasFocus
              ? widget.focusedFillColor
              : widget.baseFillColor,
          suffixIcon: widget.suffixIcon,
        ),
      ),
    );
  }
}

