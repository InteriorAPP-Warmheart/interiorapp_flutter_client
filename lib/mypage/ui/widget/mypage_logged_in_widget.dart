import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// 내공간 현황 칸을 다시 쓸 때 연다.
// import 'package:interiorapp_flutter_client/app/shell/shell_tab.dart';
// import 'package:interiorapp_flutter_client/app/shell/tab_provider.dart';
// import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/mypage_user_model.dart';
import 'package:interiorapp_flutter_client/mypage/presentation/provider/mypage_provider.dart';
import 'package:interiorapp_flutter_client/mypage/ui/widget/profile_photo_cover.dart';

class MyPageLoggedInWidget extends ConsumerWidget {
  const MyPageLoggedInWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EdgeInsets padding = ResponsiveSize.textInset(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);

    final user = ref.watch(myPageUserVmProvider);
    final notification = ref.watch(notificationSettingVmProvider);
    final savedContents = ref.watch(savedContentVmProvider);
    final recentContents = ref.watch(recentContentVmProvider);
    // final board = ref.watch(spaceBoardProvider);
    // final int ongoingCount = board.received.length + board.ongoing.length;
    // final int finishedCount = board.finished.length;

    final double tabSlot = MediaQuery.paddingOf(context).bottom;

    return ListView(
      padding: EdgeInsets.only(top: subGap, bottom: tabSlot + subGap),
      children: [
        // ── 프로필. 위는 사진, 아래는 계정 정보 ──
        _ProfileCard(
          user: user,
          horizontal: padding.left,
          onEdit: () => context.push('/my/profile'),
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
        // 내공간 현황 칸. 탭 이동만으로는 마이페이지에 둘 이유가 없어서 잠시 빼 둠.
        // _SummaryRow(
        //   ongoingCount: ongoingCount,
        //   completedCount: finishedCount,
        //   asCount: 0,
        //   onTap: () => _openMySpace(context, ref),
        // ),
        // SizedBox(height: sectionGap),

        // ── 콘텐츠 기록 ───────────────────────────────────
        _SectionHeader(title: '콘텐츠 기록'),
        SizedBox(height: subGap),
        _MenuGroup(
          items: [
            _MenuItem(
              icon: Icons.bookmark_outline_rounded,
              label: '저장한 콘텐츠',
              badge:
                  savedContents.isNotEmpty
                      ? savedContents.length.toString()
                      : null,
              onTap: () => context.push('/my/history?tab=saved'),
            ),
            _MenuItem(
              icon: Icons.history_rounded,
              label: '최근 본 콘텐츠',
              badge:
                  recentContents.isNotEmpty
                      ? recentContents.length.toString()
                      : null,
              onTap: () => context.push('/my/history?tab=recent'),
            ),
          ],
        ),
        SizedBox(height: sectionGap),

        // ── 알림 ──────────────────────────────────────────
        _SectionHeader(title: '알림'),
        SizedBox(height: subGap),
        _MenuGroup(
          items: [
            _MenuItem(
              icon: Icons.notifications_none_rounded,
              label: '푸시 알림',
              trailingWidget: _AppSwitch(
                value: notification.pushEnabled,
                onChanged:
                    (_) =>
                        ref
                            .read(notificationSettingVmProvider.notifier)
                            .togglePush(),
              ),
              onTap:
                  () =>
                      ref
                          .read(notificationSettingVmProvider.notifier)
                          .togglePush(),
            ),
            _MenuItem(
              icon: Icons.campaign_outlined,
              label: '마케팅·이벤트 알림',
              trailingWidget: _AppSwitch(
                value: notification.marketingEnabled,
                onChanged:
                    (_) =>
                        ref
                            .read(notificationSettingVmProvider.notifier)
                            .toggleMarketing(),
              ),
              onTap:
                  () =>
                      ref
                          .read(notificationSettingVmProvider.notifier)
                          .toggleMarketing(),
            ),
            _MenuItem(
              icon: Icons.construction_outlined,
              label: '시공 진행사항 알림',
              trailingWidget: _AppSwitch(
                value: notification.projectUpdateEnabled,
                onChanged:
                    (_) =>
                        ref
                            .read(notificationSettingVmProvider.notifier)
                            .toggleProjectUpdate(),
              ),
              onTap:
                  () =>
                      ref
                          .read(notificationSettingVmProvider.notifier)
                          .toggleProjectUpdate(),
            ),
          ],
        ),
        SizedBox(height: sectionGap),

        // ── 정책·지원 ──────────────────────────────────────
        _SectionHeader(title: '정책·지원'),
        SizedBox(height: subGap),
        _MenuGroup(
          items: [
            _MenuItem(
              icon: Icons.description_outlined,
              label: '서비스 이용약관',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.privacy_tip_outlined,
              label: '개인정보 처리방침',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.headset_mic_outlined,
              label: '고객 지원',
              subtitle: '문의·신고·FAQ',
              onTap: () {},
            ),
          ],
        ),
        SizedBox(height: sectionGap),

        // ── 로그아웃 / 탈퇴 ───────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('로그아웃'),
            ),
            Container(width: 1, height: 12, color: AppColors.border),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('회원 탈퇴'),
            ),
          ],
        ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 프로필. 위는 사진, 아래 카드에 계정 정보를 모은다.
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.user,
    required this.horizontal,
    required this.onEdit,
  });

  final MyPageUserModel? user;
  final double horizontal;
  final VoidCallback onEdit;

  static const double _overlap = 28;

  @override
  Widget build(BuildContext context) {
    final String? photo = user?.profileImageUrl;
    final bool hasPhoto = photo != null && photo.isNotEmpty;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double coverHeight = ProfilePhotoCover.heightFor(
          constraints.maxWidth,
        );
        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: coverHeight,
              child: ProfilePhotoCover(photoUrl: hasPhoto ? photo : null),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                coverHeight - _overlap,
                horizontal,
                0,
              ),
              child: _ProfileSheet(user: user, onEdit: onEdit),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet({required this.user, required this.onEdit});

  final MyPageUserModel? user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final MyPageUserModel? current = user;
    final bool showBusiness =
        current != null &&
        current.isBusinessUser &&
        ((current.businessName ?? '').isNotEmpty ||
            (current.businessNumber ?? '').isNotEmpty);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.7),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
        child:
            current == null
                ? const _SkeletonText()
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            current.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18 * fontScale,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: onEdit,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            textStyle: TextStyle(
                              fontSize: 13 * fontScale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('정보 수정'),
                        ),
                      ],
                    ),
                    if (current.email.isNotEmpty)
                      _ProfileLine(
                        icon: Icons.mail_outline_rounded,
                        text: current.email,
                        fontScale: fontScale,
                      ),
                    if (current.phone.isNotEmpty)
                      _ProfileLine(
                        icon: Icons.phone_outlined,
                        text: current.phone,
                        fontScale: fontScale,
                      ),
                    if (showBusiness) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppColors.border),
                      if ((current.businessName ?? '').isNotEmpty)
                        _ProfileLine(
                          icon: Icons.storefront_outlined,
                          text: current.businessName!,
                          fontScale: fontScale,
                        ),
                      if ((current.businessNumber ?? '').isNotEmpty)
                        _ProfileLine(
                          icon: Icons.badge_outlined,
                          text: current.businessNumber!,
                          fontScale: fontScale,
                        ),
                    ],
                  ],
                ),
      ),
    );
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({
    required this.icon,
    required this.text,
    required this.fontScale,
  });

  final IconData icon;
  final String text;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13 * fontScale,
                height: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonText extends StatelessWidget {
  const _SkeletonText();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 120,
          height: 11,
          decoration: BoxDecoration(
            color: AppColors.imagePlaceholder,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 요약 통계 3열. 내공간 탭으로만 보내서 잠시 빼 둠.
// ─────────────────────────────────────────────────────────────────────────────

// void _openMySpace(BuildContext context, WidgetRef ref) {
//   ref.read(tabProvider.notifier).open(ShellTab.mySpace);
//   if (GoRouterState.of(context).uri.path != '/') {
//     context.go('/');
//   }
// }
//
/*
class _SummaryRow extends StatelessWidget {
  final int ongoingCount;
  final int completedCount;
  final int asCount;
  final VoidCallback onTap;

  const _SummaryRow({
    required this.ongoingCount,
    required this.completedCount,
    required this.asCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    final items = [
      (label: '진행중인 공간', value: ongoingCount, icon: Icons.construction_rounded),
      (
        label: '완료된 공간',
        value: completedCount,
        icon: Icons.check_circle_rounded,
      ),
      (label: 'A/S', value: asCount, icon: Icons.handyman_outlined),
    ];

    return Row(
      children:
          items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < items.length - 1 ? 8 : 0),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 0.7),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 8,
                        ),
                        child: Column(
                          children: [
                            Icon(item.icon, size: 20, color: AppColors.primary),
                            const SizedBox(height: 5),
                            Text(
                              item.value.toString(),
                              style: TextStyle(
                                fontSize: 18 * fontScale,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11 * fontScale,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
*/

// ─────────────────────────────────────────────────────────────────────────────
// 섹션 헤더 (Section 위젯 스타일 통일)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

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

// ─────────────────────────────────────────────────────────────────────────────
// 메뉴 그룹 (카드 컨테이너)
// ─────────────────────────────────────────────────────────────────────────────

class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.7),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: i == 0 ? const Radius.circular(16) : Radius.zero,
                bottom:
                    i == items.length - 1
                        ? const Radius.circular(16)
                        : Radius.zero,
              ),
              child: items[i],
            ),
            if (i < items.length - 1)
              const Divider(
                height: 1,
                indent: 62,
                endIndent: 0,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 개별 메뉴 아이템
// ─────────────────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? badge;
  final Widget? trailingWidget;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.badge,
    this.trailingWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              // 아이콘 박스
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12 * fontScale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 배지
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 12 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              // trailing (스위치 or 화살표)
              if (trailingWidget != null)
                trailingWidget!
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 앱 스위치
// ─────────────────────────────────────────────────────────────────────────────

class _AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AppSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        return AppColors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.border;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
