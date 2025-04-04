import 'package:flutter/material.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Logo'),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.person_rounded), // 로그인 여부에 따라 아이콘 변경
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_rounded), // 알람 여부에 따라 아이콘 변경
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
