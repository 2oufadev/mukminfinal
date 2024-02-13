import 'package:flutter/material.dart';
import 'package:mukim_app/presentation/widgets/svg_icon.dart';

class MenuItem extends StatelessWidget {
  final String svg;
  final String label;
  final Function()? onTap;
  const MenuItem({required this.svg, this.onTap, required this.label, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        splashColor: Colors.amber,
        borderRadius: BorderRadius.circular(8.0),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgIcon(svg: svg),
              const SizedBox(height: 4.0),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
