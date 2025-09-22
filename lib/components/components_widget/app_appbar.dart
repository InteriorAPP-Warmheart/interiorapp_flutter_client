import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Logo'),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.search_rounded), // 검색
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.shopping_cart_rounded), // 장바구니
        ),
        IconButton(
          onPressed: () {
            context.push('/settings');
          },
          icon: Icon(Icons.person_rounded), // 로그인 여부에 따라 아이콘 변경
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
