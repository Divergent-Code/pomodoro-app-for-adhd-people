import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? label;
  final Color? color;
  final double? width;
  final double? height;
  final bool isTextButton;

  const CustomButton({
    Key? key,
    this.onPressed,
    this.icon,
    this.label,
    this.color,
    this.width,
    this.height,
    this.isTextButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isTextButton && label != null) {
      return SizedBox(
        width: width ?? 120,
        height: height ?? 40,
        child: GestureDetector(
          onTap: onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color ?? Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                label!,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (icon != null && label != null) {
      return SizedBox(
        width: width ?? 110,
        height: height ?? 45,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(
            label!,
            style: TextStyle(fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: color ?? Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    if (icon != null) {
      return SizedBox(
        width: width ?? 45,
        height: height ?? 45,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: color,
        ),
      );
    }

    if (label != null) {
      return SizedBox(
        width: width ?? 120,
        height: height ?? 40,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            label!,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }
}
