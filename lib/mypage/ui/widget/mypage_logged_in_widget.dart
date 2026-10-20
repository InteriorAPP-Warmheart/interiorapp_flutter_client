import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/mypage_user_model.dart';
import 'package:interiorapp_flutter_client/mypage/presentation/provider/mypage_provider.dart';

class MyPageLoggedInWidget extends ConsumerWidget {
  const MyPageLoggedInWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);

    final user = ref.watch(myPageUserVmProvider);
    final notification = ref.watch(notificationSettingVmProvider);
    final savedContents = ref.watch(savedContentVmProvider);
    final recentContents = ref.watch(recentContentVmProvider);
    final completedProjects = ref.watch(completedProjectVmProvider);
    // ignore: unused_local_variable – savedContents·recentContents는 콘텐츠 기록 배지에서 사용

    return ListView(
      padding: EdgeInsets.fromLTRB(
        padding.left,
        subGap,
        padding.right,
        48,
      ),
      children: [
        // ── 프로필 카드 ───────────────────────────────────
        _ProfileCard(user: user),
        SizedBox(height: sectionGap),

        // ── 요약 통계 ─────────────────────────────────────
        _SummaryRow(
          ongoingCount: 1,                          // TODO: 진행 중 프로젝트 provider 연동
          completedCount: completedProjects.length,
          asCount: 0,                               // TODO: A/S 요청 provider 연동
        ),
        SizedBox(height: sectionGap),

        // ── 계정 섹션 ─────────────────────────────────────
        _SectionHeader(title: '계정'),
        SizedBox(height: subGap),
        _MenuGroup(
          items: [
            _MenuItem(
              icon: Icons.person_outline_rounded,
              label: '계정 정보',
              subtitle: '이름·이메일·비밀번호',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.phone_outlined,
              label: '연락처',
              subtitle: user?.phone.isNotEmpty == true
                  ? user!.phone
                  : '전화번호 미등록',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.business_outlined,
              label: '사업자 정보',
              subtitle: user?.isBusinessUser == true
                  ? (user?.businessName ?? '사업자명 미등록')
                  : '미등록',
              onTap: () {},
            ),
          ],
        ),
        SizedBox(height: sectionGap),

        // ── 콘텐츠 기록 ───────────────────────────────────
        _SectionHeader(title: '콘텐츠 기록'),
        SizedBox(height: subGap),
        _MenuGroup(
          items: [
            _MenuItem(
              icon: Icons.bookmark_outline_rounded,
              label: '저장한 콘텐츠',
              badge: savedContents.isNotEmpty
                  ? savedContents.length.toString()
                  : null,
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.history_rounded,
              label: '최근 본 콘텐츠',
              badge: recentContents.isNotEmpty
                  ? recentContents.length.toString()
                  : null,
              onTap: () {},
            ),
          ],
        ),
        SizedBox(height: sectionGap),

        // ── 프로젝트 이력 ─────────────────────────────────
        _SectionHeader(title: '프로젝트 이력'),
        SizedBox(height: subGap),
        _MenuGroup(
          items: [
            _MenuItem(
              icon: Icons.home_work_outlined,
              label: '완료된 프로젝트',
              subtitle: '지난 인테리어 시공 내역 확인',
              badge: completedProjects.isNotEmpty
                  ? completedProjects.length.toString()
                  : null,
              onTap: () {},
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
                onChanged: (_) =>
                    ref.read(notificationSettingVmProvider.notifier).togglePush(),
              ),
              onTap: () =>
                  ref.read(notificationSettingVmProvider.notifier).togglePush(),
            ),
            _MenuItem(
              icon: Icons.campaign_outlined,
              label: '마케팅·이벤트 알림',
              trailingWidget: _AppSwitch(
                value: notification.marketingEnabled,
                onChanged: (_) => ref
                    .read(notificationSettingVmProvider.notifier)
                    .toggleMarketing(),
              ),
              onTap: () => ref
                  .read(notificationSettingVmProvider.notifier)
                  .toggleMarketing(),
            ),
            _MenuItem(
              icon: Icons.construction_outlined,
              label: '프로젝트 업데이트 알림',
              trailingWidget: _AppSwitch(
                value: notification.projectUpdateEnabled,
                onChanged: (_) => ref
                    .read(notificationSettingVmProvider.notifier)
                    .toggleProjectUpdate(),
              ),
              onTap: () => ref
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
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              child: const Text('로그아웃'),
            ),
            Container(
              width: 1,
              height: 12,
              color: AppColors.border,
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              child: const Text('회원 탈퇴'),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 프로필 카드
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final MyPageUserModel? user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {}, // 프로필 편집
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.7),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 아바타
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: user?.profileImageUrl != null
                      ? ClipOval(
                          child: Image.network(
                            user!.profileImageUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: AppColors.primary,
                        ),
                ),
                const SizedBox(width: 14),
                // 이름·이메일
                Expanded(
                  child: user == null
                      ? _SkeletonText()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user!.name,
                              style: TextStyle(
                                fontSize: 16 * fontScale,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user!.email,
                              style: TextStyle(
                                fontSize: 13 * fontScale,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (user!.isBusinessUser &&
                                user!.businessName != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                user!.businessName!,
                                style: TextStyle(
                                  fontSize: 12 * fontScale,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonText extends StatelessWidget {
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
// 요약 통계 3열
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final int ongoingCount;
  final int completedCount;
  final int asCount;

  const _SummaryRow({
    required this.ongoingCount,
    required this.completedCount,
    required this.asCount,
  });

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    final items = [
      (label: '진행중인 공간', value: ongoingCount, icon: Icons.construction_rounded),
      (label: '완료된 공간', value: completedCount, icon: Icons.check_circle_rounded),
      (label: 'A/S', value: asCount, icon: Icons.handyman_outlined),
    ];

    return Row(
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < items.length - 1 ? 8 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 0.7),
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
        );
      }).toList(),
    );
  }
}

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
                    i == items.length - 1 ? const Radius.circular(16) : Radius.zero,
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
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColors.primary,
                ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
