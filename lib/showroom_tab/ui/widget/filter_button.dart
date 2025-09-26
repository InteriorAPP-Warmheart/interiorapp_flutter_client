import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/showroom_tab/ui/widget/filter_bottomsheet.dart';

class FilterButton extends StatelessWidget {
  final String text;

  const FilterButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // 바텀시트가 전체 높이의 80% 이상 사용 가능하도록 설정
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => FilterBottomSheet(),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
