import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/mypage_user_model.dart';
import 'package:interiorapp_flutter_client/mypage/presentation/provider/mypage_provider.dart';
import 'package:interiorapp_flutter_client/mypage/ui/widget/profile_photo_cover.dart';

/// 프로필 카드로 들어오는 계정 화면.
/// 이름·이메일·비밀번호, 연락처, 사업자 정보를 여기서 보고 고친다.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MyPageUserModel? user = ref.watch(myPageUserVmProvider);
    final EdgeInsets padding = ResponsiveSize.textInset(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('프로필')),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + subGap,
              ),
              children: [
                ProfilePhotoCover(
                  photoUrl: user.profileImageUrl,
                  onChangePhoto: () => _changePhoto(context, ref, user),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    sectionGap,
                    padding.right,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                const _SectionHeader(title: '계정'),
                SizedBox(height: subGap),
                _FieldGroup(
                  rows: [
                    _FieldRow(
                      label: '이름',
                      value: _filled(user.name, '이름 미등록'),
                      placeholder: user.name.trim().isEmpty,
                      onTap: () => _editText(
                        context,
                        ref,
                        title: '이름',
                        initial: user.name,
                        hint: '이름을 입력해 주세요',
                        validate: _nameError,
                        apply: (value) => user.copyWith(name: value.trim()),
                      ),
                    ),
                    _FieldRow(
                      label: '이메일',
                      value: _filled(user.email, '이메일 미등록'),
                      placeholder: user.email.trim().isEmpty,
                      onTap: () => _editText(
                        context,
                        ref,
                        title: '이메일',
                        initial: user.email,
                        hint: 'name@email.com',
                        keyboardType: TextInputType.emailAddress,
                        validate: _emailError,
                        apply: (value) => user.copyWith(email: value.trim()),
                      ),
                    ),
                    _FieldRow(
                      label: '비밀번호',
                      value: '변경',
                      emphasized: true,
                      onTap: () => _changePassword(context),
                    ),
                  ],
                ),
                SizedBox(height: sectionGap),
                const _SectionHeader(title: '연락처'),
                SizedBox(height: subGap),
                _FieldGroup(
                  rows: [
                    _FieldRow(
                      label: '전화번호',
                      value: _filled(user.phone, '전화번호 미등록'),
                      placeholder: user.phone.trim().isEmpty,
                      onTap: () => _editText(
                        context,
                        ref,
                        title: '전화번호',
                        initial: user.phone,
                        hint: '010-0000-0000',
                        keyboardType: TextInputType.phone,
                        validate: _phoneError,
                        apply: (value) =>
                            user.copyWith(phone: _formatPhone(value)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sectionGap),
                const _SectionHeader(title: '사업자'),
                SizedBox(height: subGap),
                _FieldGroup(
                  rows: [
                    _FieldRow(
                      label: '사업자 정보',
                      trailing: _AccountSwitch(
                        value: user.isBusinessUser,
                        onChanged: (bool next) => _save(
                          context,
                          ref,
                          user.copyWith(isBusinessUser: next),
                        ),
                      ),
                      onTap: () => _save(
                        context,
                        ref,
                        user.copyWith(isBusinessUser: !user.isBusinessUser),
                      ),
                    ),
                    if (user.isBusinessUser) ...[
                      _FieldRow(
                        label: '상호',
                        value: _filled(user.businessName, '상호 미등록'),
                        placeholder: _blank(user.businessName),
                        onTap: () => _editText(
                          context,
                          ref,
                          title: '상호',
                          initial: user.businessName ?? '',
                          hint: '상호를 입력해 주세요',
                          validate: _businessNameError,
                          apply: (value) =>
                              user.copyWith(businessName: value.trim()),
                        ),
                      ),
                      _FieldRow(
                        label: '사업자등록번호',
                        value: _filled(user.businessNumber, '번호 미등록'),
                        placeholder: _blank(user.businessNumber),
                        onTap: () => _editText(
                          context,
                          ref,
                          title: '사업자등록번호',
                          initial: user.businessNumber ?? '',
                          hint: '000-00-00000',
                          keyboardType: TextInputType.number,
                          validate: _businessNumberError,
                          apply: (value) => user.copyWith(
                            businessNumber: _formatBusinessNumber(value),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Text(
      title,
      style: TextStyle(
        fontSize: 17 * fontScale,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _FieldGroup extends StatelessWidget {
  const _FieldGroup({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.7),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i < rows.length - 1)
                const Divider(height: 1, indent: 16, color: AppColors.border),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.onTap,
    this.value,
    this.placeholder = false,
    this.emphasized = false,
    this.trailing,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool placeholder;
  final bool emphasized;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final Color valueColor = emphasized
        ? AppColors.primary
        : placeholder
            ? AppColors.textSecondary
            : AppColors.textPrimary;

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              if (value != null)
                Expanded(
                  child: Text(
                    value!,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
                      color: valueColor,
                    ),
                  ),
                )
              else
                const Spacer(),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ] else ...[
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountSwitch extends StatelessWidget {
  const _AccountSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      thumbColor: const WidgetStatePropertyAll(AppColors.white),
      trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.border;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

Future<void> _changePhoto(
  BuildContext context,
  WidgetRef ref,
  MyPageUserModel user,
) async {
  try {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null || !context.mounted) return;
    await _save(context, ref, user.copyWith(profileImageUrl: file.path));
  } catch (_) {
    if (!context.mounted) return;
    _toast(context, '사진을 불러오지 못했어요');
  }
}

Future<void> _editText(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String initial,
  required String hint,
  required String? Function(String value) validate,
  required MyPageUserModel Function(String value) apply,
  TextInputType keyboardType = TextInputType.text,
}) async {
  final String? next = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return _TextEditSheet(
        title: title,
        initial: initial,
        hint: hint,
        keyboardType: keyboardType,
        validate: validate,
      );
    },
  );
  if (next == null || !context.mounted) return;
  await _save(context, ref, apply(next));
}

Future<void> _changePassword(BuildContext context) async {
  final bool? changed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => const _PasswordSheet(),
  );
  if (changed != true || !context.mounted) return;
  _toast(context, '비밀번호를 변경했어요');
}

Future<void> _save(
  BuildContext context,
  WidgetRef ref,
  MyPageUserModel next,
) async {
  try {
    await ref.read(myPageUserVmProvider.notifier).updateUser(next);
  } catch (_) {
    if (!context.mounted) return;
    _toast(context, '저장하지 못했어요');
  }
}

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

bool _blank(String? value) => value == null || value.trim().isEmpty;

String _filled(String? value, String fallback) {
  if (_blank(value)) return fallback;
  return value!.trim();
}

String? _nameError(String raw) {
  final String value = raw.trim();
  if (value.isEmpty) return '이름을 입력해 주세요';
  if (value.length > 20) return '이름은 20자까지 입력할 수 있어요';
  return null;
}

String? _emailError(String raw) {
  final String value = raw.trim();
  if (value.isEmpty) return '이메일을 입력해 주세요';
  final bool ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  if (!ok) return '이메일 형식을 확인해 주세요';
  return null;
}

String? _phoneError(String raw) {
  final String digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  if (digits.length < 10 || digits.length > 11) {
    return '전화번호 10~11자리를 입력해 주세요';
  }
  return null;
}

String? _businessNameError(String raw) {
  final String value = raw.trim();
  if (value.isEmpty) return '상호를 입력해 주세요';
  if (value.length > 30) return '상호는 30자까지 입력할 수 있어요';
  return null;
}

String? _businessNumberError(String raw) {
  final String digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '사업자등록번호를 입력해 주세요';
  if (digits.length != 10) return '사업자등록번호 10자리를 입력해 주세요';
  return null;
}

String _formatPhone(String raw) {
  final String digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  if (digits.length == 11) {
    return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
  }
  if (digits.length == 10) {
    return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
  }
  return raw.trim();
}

String _formatBusinessNumber(String raw) {
  final String digits = raw.replaceAll(RegExp(r'\D'), '');
  return '${digits.substring(0, 3)}-${digits.substring(3, 5)}-${digits.substring(5)}';
}

class _TextEditSheet extends StatefulWidget {
  const _TextEditSheet({
    required this.title,
    required this.initial,
    required this.hint,
    required this.keyboardType,
    required this.validate,
  });

  final String title;
  final String initial;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String value) validate;

  @override
  State<_TextEditSheet> createState() => _TextEditSheetState();
}

class _TextEditSheetState extends State<_TextEditSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String? error = widget.validate(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 17 * fontScale,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                autofocus: true,
                keyboardType: widget.keyboardType,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                style: TextStyle(fontSize: 15 * fontScale),
                decoration: _fieldDecoration(
                  context,
                  hint: widget.hint,
                  error: _error,
                ),
              ),
              const SizedBox(height: 16),
              AppButton(label: '저장', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordSheet extends StatefulWidget {
  const _PasswordSheet();

  @override
  State<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<_PasswordSheet> {
  final TextEditingController _next = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final String next = _next.text;
    if (next.length < 8) {
      setState(() => _error = '8자 이상 입력해 주세요');
      return;
    }
    if (next != _confirm.text) {
      setState(() => _error = '비밀번호가 서로 달라요');
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 16),
              Text(
                '비밀번호 변경',
                style: TextStyle(
                  fontSize: 17 * fontScale,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _next,
                autofocus: true,
                obscureText: true,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                style: TextStyle(fontSize: 15 * fontScale),
                decoration: _fieldDecoration(context, hint: '새 비밀번호'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirm,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                style: TextStyle(fontSize: 15 * fontScale),
                decoration: _fieldDecoration(
                  context,
                  hint: '새 비밀번호 확인',
                  error: _error,
                ),
              ),
              const SizedBox(height: 16),
              AppButton(label: '변경', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(
  BuildContext context, {
  required String hint,
  String? error,
}) {
  final double fontScale = ResponsiveSize.fontScale(context);
  return InputDecoration(
    hintText: hint,
    errorText: error,
    hintStyle: TextStyle(
      fontSize: 15 * fontScale,
      color: AppColors.textSecondary,
    ),
    filled: true,
    fillColor: AppColors.background,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border, width: 0.7),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border, width: 0.7),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
    ),
  );
}

