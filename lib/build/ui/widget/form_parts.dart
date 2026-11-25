import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

/// 상담 준비·입지 작성 화면이 같이 쓰는 입력 조각. 남색 하나로 고른 것과 누를 곳을 표시한다.

/// 단계 맨 위 제목과 한 줄 설명.
class FormIntro extends StatelessWidget {
  const FormIntro({super.key, required this.title, this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24 * fontScale,
              height: 1.3,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),
          if (body != null && body!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              body!,
              style: TextStyle(
                fontSize: 15 * fontScale,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 한 묶음의 흰 카드. 제목이 있으면 카드 안 맨 위에 둔다.
class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    required this.child,
    this.title,
    this.optional = false,
    this.trailing,
  });

  final Widget child;
  final String? title;
  final bool optional;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.7),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  Expanded(
                    child: FormLabel(
                      label: title!,
                      optional: optional,
                      large: true,
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 14),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

/// 입력 칸 위 이름. 선택 항목이면 옆에 작게 "선택"을 붙인다.
class FormLabel extends StatelessWidget {
  const FormLabel({
    super.key,
    required this.label,
    this.optional = false,
    this.large = false,
  });

  final String label;
  final bool optional;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Text.rich(
      TextSpan(
        text: label,
        style: TextStyle(
          fontSize: (large ? 17 : 15) * fontScale,
          height: 1.3,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: AppColors.textPrimary,
        ),
        children: [
          if (optional)
            TextSpan(
              text: '  선택',
              style: TextStyle(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// 이름과 그 아래 입력을 한 덩어리로 둔다.
class FormItem extends StatelessWidget {
  const FormItem({
    super.key,
    required this.label,
    required this.child,
    this.optional = false,
    this.help,
  });

  final String label;
  final Widget child;
  final bool optional;
  final String? help;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormLabel(label: label, optional: optional),
        if (help != null) ...[
          const SizedBox(height: 4),
          Text(
            help!,
            style: TextStyle(
              fontSize: 13 * fontScale,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

InputDecoration formInputDecoration(
  BuildContext context, {
  required String hint,
  String? suffixText,
}) {
  final double fontScale = ResponsiveSize.fontScale(context);
  final OutlineInputBorder idle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  );
  return InputDecoration(
    hintText: hint,
    suffixText: suffixText,
    suffixStyle: TextStyle(
      fontSize: 16 * fontScale,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    hintStyle: TextStyle(
      fontSize: 16 * fontScale,
      color: AppColors.textSecondary.withValues(alpha: 0.6),
    ),
    filled: true,
    fillColor: AppColors.background,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: idle,
    enabledBorder: idle,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
    ),
  );
}

/// 글 입력. 회색 바탕에 테두리 없이 두고, 쓰는 중에만 남색 테두리를 둔다.
class FormTextInput extends StatelessWidget {
  const FormTextInput({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.inputFormatters,
    this.suffixText,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: maxLines > 1 ? (maxLines < 3 ? maxLines : 3) : 1,
      keyboardType: keyboardType,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      scrollPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 96),
      style: TextStyle(
        fontSize: 16 * fontScale,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      cursorColor: AppColors.primary,
      decoration: formInputDecoration(
        context,
        hint: hint,
        suffixText: suffixText,
      ),
    );
  }
}

/// 주소 검색 칸. 누르면 검색 화면을 연다.
class FormAddressInput extends StatelessWidget {
  const FormAddressInput({
    super.key,
    required this.address,
    required this.onTap,
  });

  final String address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final bool empty = address.trim().isEmpty;
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 12, 15),
          child: Row(
            children: [
              Icon(
                Icons.place_outlined,
                size: 20,
                color: empty ? AppColors.textSecondary : AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  empty ? '주소 검색' : address,
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    height: 1.35,
                    fontWeight: empty ? FontWeight.w400 : FontWeight.w600,
                    color:
                        empty
                            ? AppColors.textSecondary.withValues(alpha: 0.6)
                            : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                empty ? '검색' : '바꾸기',
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 고르는 칩. 고른 칩은 남색 바탕에 흰 글자, 나머지는 회색 바탕이다.
class FormChoiceChips extends StatelessWidget {
  const FormChoiceChips({
    super.key,
    required this.values,
    required this.isSelected,
    required this.onTap,
  });

  final List<String> values;
  final bool Function(String value) isSelected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final String value in values)
          Builder(
            builder: (BuildContext context) {
              final bool on = isSelected(value);
              return Semantics(
                button: true,
                selected: on,
                child: Material(
                  color: on ? AppColors.primary : AppColors.background,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    onTap: () => onTap(value),
                    customBorder: const StadiumBorder(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      constraints: const BoxConstraints(minHeight: 42),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 15 * fontScale,
                          height: 1.3,
                          fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                          color: on ? AppColors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// 켜고 끄는 한 줄. "아직 몰라요"처럼 아래 입력을 접을 때 쓴다.
class FormToggleRow extends StatelessWidget {
  const FormToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 단계 진행. 번호와 이름을 나란히 두고, 지난 단계는 체크, 지금 단계는 남색으로 둔다.
class FormProgress extends StatelessWidget {
  const FormProgress({super.key, required this.steps, required this.index});

  final List<String> steps;
  final int index;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double needed = steps.fold<double>(
          0,
          (double sum, String step) => sum + 48 + step.length * 14 * fontScale,
        );
        final bool compact = needed > constraints.maxWidth;
        return _row(fontScale, compact);
      },
    );
  }

  Widget _row(double fontScale, bool compact) {
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  height: 2,
                  decoration: BoxDecoration(
                    color: i <= index ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          _StepMark(
            number: i + 1,
            label: steps[i],
            done: i < index,
            current: i == index,
            showLabel: !compact || i == index,
            fontScale: fontScale,
          ),
        ],
      ],
    );
  }
}

class _StepMark extends StatelessWidget {
  const _StepMark({
    required this.number,
    required this.label,
    required this.done,
    required this.current,
    required this.showLabel,
    required this.fontScale,
  });

  final int number;
  final String label;
  final bool done;
  final bool current;
  final bool showLabel;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool on = done || current;
    return Semantics(
      label: '$number단계 $label${current ? ', 지금 단계' : ''}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: on ? AppColors.primary : AppColors.surface,
              border: Border.all(
                color: on ? AppColors.primary : AppColors.border,
                width: 1.4,
              ),
            ),
            child:
                done
                    ? const Icon(Icons.check, size: 14, color: AppColors.white)
                    : Text(
                      '$number',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: on ? AppColors.white : AppColors.textSecondary,
                      ),
                    ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14 * fontScale,
                fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                color:
                    current ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
