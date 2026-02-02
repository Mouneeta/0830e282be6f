
import 'package:flutter/material.dart';



class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  CustomAppBar({
    super.key,
    required this.title,
    required this.actions,
  });

  bool onTapped = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
      elevation: 1,
      titleSpacing: 20,
      title: Tooltip(
        triggerMode: TooltipTriggerMode.tap,
        message: title,
        showDuration: const Duration(minutes: 1),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white
          )
        ),
      ),
      automaticallyImplyLeading: false,
      );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;

}
