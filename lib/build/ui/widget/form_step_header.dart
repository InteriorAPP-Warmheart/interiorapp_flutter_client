import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/form_parts.dart';

/// 여러 단계 작성의 진행 표시. 지금 단계와 다음 단계를 함께 보여 준다.
class FormStepHeader extends StatelessWidget {
  const FormStepHeader({
    super.key,
    required this.steps,
    required this.index,
    required this.fontScale,
  });

  final List<String> steps;
  final int index;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return FormProgress(steps: steps, index: index.clamp(0, steps.length - 1));
  }
}
