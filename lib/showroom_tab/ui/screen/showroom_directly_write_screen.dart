import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowroomDirectlyWriteScreen extends ConsumerWidget {
  const ShowroomDirectlyWriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('쇼룸 글쓰기(직접 작성)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Text('쇼룸 글쓰기(직접 작성)')],
        ),
      ),
    );
  }
}
