import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/work_quote.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/presentation/vm/space_board_vm.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/quick_filter_catalog.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_body.dart';
import 'package:interiorapp_flutter_client/showroom/domain/showroom_quill_document.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/vm/showroom_composer.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/vm/showroom_write_vm.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_quill_body.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_space_header.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/story/showroom_story_scenes.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/write_body_editor.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/write_pickers.dart';

class ShowroomWriteDetailScreen extends ConsumerStatefulWidget {
  const ShowroomWriteDetailScreen({super.key, this.buildId});

  final String? buildId;

  @override
  ConsumerState<ShowroomWriteDetailScreen> createState() =>
      _ShowroomWriteDetailScreenState();
}

class _ShowroomWriteDetailScreenState
    extends ConsumerState<ShowroomWriteDetailScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _budget = TextEditingController();
  final FocusNode _bodyFocus = FocusNode();
  final ScrollController _bodyScroll = ScrollController();
  QuillController? _quill;
  bool _emojiOpen = false;
  bool _normalizingQuill = false;
  int _embedSeq = 0;

  @override
  void initState() {
    super.initState();
    _bodyFocus.addListener(_onBodyFocus);
    WidgetsBinding.instance.addPostFrameCallback((_) => _seed());
  }

  void _onBodyFocus() {
    if (!mounted) return;
    setState(() {
      if (!_bodyFocus.hasFocus) _emojiOpen = false;
    });
  }

  void _ensureQuill(List<ShowroomBlock> blocks) {
    if (_quill != null) return;
    _quill = QuillController(
      document: documentFromShowroomBlocks(blocks),
      selection: const TextSelection.collapsed(offset: 0),
    );
    stripShowroomHeadings(_quill!);
    _quill!.addListener(_syncQuill);
  }

  bool _syncScheduled = false;

  void _syncQuill() {
    if (_syncScheduled || _normalizingQuill) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) return;
      final QuillController? quill = _quill;
      if (quill == null) return;
      _normalizingQuill = true;
      stripShowroomHeadings(quill);
      _normalizingQuill = false;
      final List<ShowroomBlock> blocks = blocksFromQuillDocument(
        quill.document,
      );
      final List<ShowroomBlock> current =
          ref.read(showroomComposerProvider).blocks;
      if (sameShowroomBody(current, blocks)) return;
      _composer.setBlocks(blocks);
    });
  }

  String _nextEmbedId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_embedSeq++}';

  int _caretIndex(QuillController quill) {
    final TextSelection selection = quill.selection;
    final int max = quill.document.length;
    if (!selection.isValid) return max;
    return selection.extentOffset.clamp(0, max);
  }

  void _seed() {
    if (!mounted) return;
    final SpaceBoard board = ref.read(spaceBoardProvider);
    final String? id = widget.buildId;
    final SpaceProject? project =
        id == null || id.isEmpty ? null : board.find(id);
    final ShowroomDraft draft = ref
        .read(showroomComposerProvider.notifier)
        .seed(
          project: project,
          record: project == null ? null : board.recordFor(project.id),
          photos:
              project == null
                  ? const <PublicSitePhoto>[]
                  : board.constructionFor(project.id)?.recentPhotos ??
                      const <PublicSitePhoto>[],
        );
    _title.text = draft.title;
    _budget.text = draft.budget.replaceAll('원', '').trim();
  }

  @override
  void dispose() {
    _quill?.removeListener(_syncQuill);
    _quill?.dispose();
    _bodyFocus.removeListener(_onBodyFocus);
    _bodyFocus.dispose();
    _bodyScroll.dispose();
    _title.dispose();
    _budget.dispose();
    super.dispose();
  }

  ShowroomComposer get _composer => ref.read(showroomComposerProvider.notifier);

  Future<List<String>> _pickImages({bool multiple = false}) {
    final ShowroomDraft draft = ref.read(showroomComposerProvider);
    return pickWriteImages(
      context,
      photos: draft.sitePhotos,
      used: draft.uses,
      multiple: multiple,
    );
  }

  void _insertEmoji(String emoji) {
    final QuillController? quill = _quill;
    if (quill == null || emoji.isEmpty) return;
    final int index = _caretIndex(quill);
    quill.replaceText(
      index,
      0,
      emoji,
      TextSelection.collapsed(offset: index + emoji.length),
    );
    _bodyFocus.requestFocus();
  }

  Future<ShowroomImageLayout?> _pickPhotoLayout() {
    return showModalBottomSheet<ShowroomImageLayout>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '이 사진들을 어떻게 넣을까요?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _EmbedChoice(
                        title: '슬라이더',
                        detail: '옆으로 넘기며 봐요',
                        preview: const _SliderSkeleton(),
                        onTap:
                            () => Navigator.pop(
                              context,
                              ShowroomImageLayout.slider,
                            ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _EmbedChoice(
                        title: '갤러리',
                        detail: '아래 사진을 누르면 크게 보여요',
                        preview: const _GallerySkeleton(),
                        onTap:
                            () => Navigator.pop(
                              context,
                              ShowroomImageLayout.gallery,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addArea() {
    final QuillController? quill = _quill;
    if (quill == null) return;
    final int index = _caretIndex(quill);
    insertShowroomBlock(
      quill,
      ShowroomBlock.images(
        id: _nextEmbedId('images'),
        layout: ShowroomImageLayout.beforeAfter,
        pairs: <ShowroomBeforeAfterPair>[
          ShowroomBeforeAfterPair(id: _nextEmbedId('pair')),
        ],
      ),
      index: index,
    );
    _bodyFocus.requestFocus();
  }

  void _addProcess() {
    final QuillController? quill = _quill;
    if (quill == null) return;
    insertShowroomBlock(
      quill,
      ShowroomBlock.process(
        id: _nextEmbedId('process'),
        frames: <ShowroomProcessFrame>[
          ShowroomProcessFrame(
            id: _nextEmbedId('frame'),
            imageUrl: '',
            caption: '',
          ),
        ],
      ),
      index: _caretIndex(quill),
    );
    _bodyFocus.requestFocus();
  }

  Future<void> _attachImages() async {
    final QuillController? quill = _quill;
    if (quill == null) return;
    final int index = _caretIndex(quill);
    final List<String> urls = await _pickImages(multiple: true);
    if (!mounted) return;
    if (urls.isEmpty) {
      _bodyFocus.requestFocus();
      return;
    }
    final ShowroomImageLayout layout;
    if (urls.length == 1) {
      layout = ShowroomImageLayout.photo;
    } else {
      final ShowroomImageLayout? picked = await _pickPhotoLayout();
      if (!mounted || picked == null) {
        _bodyFocus.requestFocus();
        return;
      }
      layout = picked;
    }
    insertShowroomBlock(
      quill,
      ShowroomBlock.images(
        id: _nextEmbedId('images'),
        layout: layout,
        urls: urls,
      ),
      index: index,
    );
    _bodyFocus.requestFocus();
  }

  Future<void> _attachThumbnail() async {
    final ShowroomDraft draft = ref.read(showroomComposerProvider);
    final String? url = await pickWriteImage(
      context,
      photos: draft.sitePhotos,
      used: draft.uses,
    );
    if (url == null || !mounted) return;
    _composer.setThumbnail(url);
  }

  void _onBudget(String value) {
    final String formatted = groupedDigits(value);
    if (formatted != _budget.text) {
      _budget.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    _composer.setBudget(formatted.isEmpty ? '' : '$formatted원');
  }

  Future<void> _pickIndustry(String current) async {
    final String? name = await pickIndustry(context, current: current);
    if (name == null || !mounted) return;
    _composer.setIndustry(name);
  }

  Future<void> _pickArea(int current) async {
    final int? pyeong = await pickPyeong(context, current: current);
    if (pyeong == null || !mounted) return;
    _composer.setAreaPyeong(pyeong);
  }

  Future<void> _pickPeriod(ShowroomDraft draft) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange:
          draft.periodStart != null && draft.periodEnd != null
              ? DateTimeRange(start: draft.periodStart!, end: draft.periodEnd!)
              : null,
      helpText: '시공 기간',
      saveText: '선택',
    );
    if (range == null || !mounted) return;
    _composer.setPeriodRange(range.start, range.end);
  }

  Future<void> _chooseCostDetail(WorkQuote? quote) async {
    final String? choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                if (quote != null)
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text(
                      '견적서에서 불러오기',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('공종 금액을 채워요. 경비는 기타로 묶여요.'),
                    onTap: () => Navigator.of(context).pop('quote'),
                  ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text(
                    '직접 추가',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('항목을 빈 칸부터 적어요.'),
                  onTap: () => Navigator.of(context).pop('manual'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || choice == null) return;
    if (choice == 'quote' && quote != null) {
      _composer.loadCostFromQuote(quote);
      return;
    }
    _composer.startCostDetail();
  }

  Future<void> _openPreview(ShowroomDraft draft) async {
    final bool saved =
        await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder:
                (BuildContext context) => ShowroomDraftPreview(draft: draft),
          ),
        ) ??
        false;
    if (!saved || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('쇼룸 초안을 정리했어요')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final ShowroomDraft draft = ref.watch(showroomComposerProvider);
    if (!draft.seeded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _ensureQuill(draft.blocks);
    final QuillController quill = _quill!;

    final bool fromSpace = draft.projectId.isNotEmpty;
    final SpaceBoard board = ref.read(spaceBoardProvider);
    final ConstructionProgress? progress =
        fromSpace ? board.constructionFor(draft.projectId) : null;
    final WorkQuote? quote =
        fromSpace ? board.find(draft.projectId)?.workQuote : null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('쇼룸 글쓰기')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Text(
                  fromSpace
                      ? '${draft.projectName}에서 가져왔어요'
                      : '조건과 사진을 직접 적어 주세요',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                const _BlockTitle('글'),
                const SizedBox(height: 10),
                _ThumbnailAttach(
                  url: draft.thumbnailUrl,
                  onAttach: _attachThumbnail,
                  onClear: _composer.clearThumbnail,
                ),
                const SizedBox(height: 10),
                _LineField(
                  controller: _title,
                  hint: '제목. 예: 성수동 카페',
                  onChanged: _composer.setTitle,
                ),
                const SizedBox(height: 14),
                const Text(
                  '스타일',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: styleMoodCards.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(width: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final StyleMoodCard card = styleMoodCards[index];
                      final bool selected = draft.style == card.title;
                      return _StylePick(
                        card: card,
                        selected: selected,
                        onTap: () => _composer.setStyle(card.title),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                const _BlockTitle('이 공간'),
                const SizedBox(height: 10),
                _ChoiceRow(
                  label: '업종',
                  value: draft.industry.trim().isEmpty ? '선택' : draft.industry,
                  filled: draft.industry.trim().isNotEmpty,
                  onTap: () => _pickIndustry(draft.industry),
                ),
                const SizedBox(height: 8),
                _ChoiceRow(
                  label: '평수',
                  value: draft.area,
                  filled: true,
                  onTap: () => _pickArea(draft.areaPyeong),
                ),
                const SizedBox(height: 8),
                _LineField(
                  controller: _budget,
                  hint: '금액',
                  onChanged: _onBudget,
                  suffix: '원',
                  keyboard: TextInputType.number,
                ),
                _WonReading(
                  text: CostFormattingViewModel.wonReading(_budget.text),
                ),
                const SizedBox(height: 8),
                _ChoiceRow(
                  label: '기간',
                  value:
                      draft.period.trim().isEmpty ? '캘린더에서 선택' : draft.period,
                  filled: draft.period.trim().isNotEmpty,
                  onTap: () => _pickPeriod(draft),
                ),
                if (!draft.showCostDetail) ...[
                  const SizedBox(height: 8),
                  _AddCostDetail(onTap: () => _chooseCostDetail(quote)),
                ] else ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: _BlockTitle('세부 공사비')),
                      IconButton(
                        onPressed: _composer.clearCostDetail,
                        icon: const Icon(Icons.close, size: 18),
                        color: AppColors.textSecondary,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    draft.costFromQuote
                        ? '견적서의 공종 금액으로 채웠어요. 경비처럼 공정이 아닌 항목은 기타로 묶여 있어요.'
                        : '항목은 직접 적어도 돼요. 빼려면 오른쪽 X를 누르세요.',
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _CostEditor(
                    lines: draft.costLines,
                    onAdd: _composer.addCostLine,
                    onLine: _composer.updateCostLine,
                    onRemove: _composer.removeCostLine,
                  ),
                ],
                const SizedBox(height: 28),
                const _BlockTitle('본문'),
                const SizedBox(height: 4),
                const Text(
                  '한 장은 바로 들어가고, 여러 장이면 슬라이더와 갤러리 중 배치를 골라요. 전후와 현장 기록은 글 사이에 넣어요.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                ShowroomQuillBody(
                  controller: quill,
                  focusNode: _bodyFocus,
                  scrollController: _bodyScroll,
                  pickImages: _pickImages,
                  chooseLayout: _pickPhotoLayout,
                  loadRecord:
                      progress != null && progress.trades.isNotEmpty
                          ? () => _composer.framesFromRecord(progress)
                          : null,
                ),
              ],
            ),
          ),
          if (_bodyFocus.hasFocus)
            ShowroomQuillToolbar(
              controller: quill,
              focusNode: _bodyFocus,
              emojiOpen: _emojiOpen,
              onEmojiToggle: () => setState(() => _emojiOpen = !_emojiOpen),
              onEmoji: _insertEmoji,
              onImage: _attachImages,
              onArea: _addArea,
              onRecord: _addProcess,
            ),
          _PreviewBar(
            enabled: draft.canPreview,
            onPressed: () => _openPreview(draft),
          ),
        ],
      ),
    );
  }
}

class _EmbedChoice extends StatelessWidget {
  const _EmbedChoice({
    required this.title,
    required this.detail,
    required this.preview,
    required this.onTap,
  });

  final String title;
  final String detail;
  final Widget preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F6F8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              preview,
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderSkeleton extends StatelessWidget {
  const _SliderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 72,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          minWidth: 0,
          maxWidth: double.infinity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LayoutBone(width: 96, height: 72, strong: true),
              SizedBox(width: 6),
              _LayoutBone(width: 96, height: 72),
              SizedBox(width: 6),
              _LayoutBone(width: 96, height: 72),
            ],
          ),
        ),
      ),
    );
  }
}

class _GallerySkeleton extends StatelessWidget {
  const _GallerySkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 72,
      child: Column(
        children: [
          Expanded(flex: 5, child: _LayoutBone(strong: true)),
          SizedBox(height: 6),
          SizedBox(
            height: 22,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                minWidth: 0,
                maxWidth: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LayoutBone(width: 28, height: 22, strong: true),
                    SizedBox(width: 4),
                    _LayoutBone(width: 28, height: 22),
                    SizedBox(width: 4),
                    _LayoutBone(width: 28, height: 22),
                    SizedBox(width: 4),
                    _LayoutBone(width: 28, height: 22),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayoutBone extends StatelessWidget {
  const _LayoutBone({this.width, this.height, this.strong = false});

  final double? width;
  final double? height;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: strong ? const Color(0xFFD5DDE6) : AppColors.imagePlaceholder,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _PreviewBar extends StatelessWidget {
  const _PreviewBar({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          children: [
            if (!enabled)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '제목과 본문이 필요해요',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: enabled ? onPressed : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: const Color(0xFFE4E6EA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  '미리보기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailAttach extends StatelessWidget {
  const _ThumbnailAttach({
    required this.url,
    required this.onAttach,
    required this.onClear,
  });

  final String url;
  final VoidCallback onAttach;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bool filled = url.trim().isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: AppColors.surface,
        child: InkWell(
          onTap: filled ? null : onAttach,
          child: Ink(
            height: 168,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child:
                filled
                    ? Stack(
                      fit: StackFit.expand,
                      children: [
                        AppNetworkImage(url: url),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Row(
                            children: [
                              _ThumbAction(
                                icon: Icons.photo_library_outlined,
                                label: '바꾸기',
                                onTap: onAttach,
                              ),
                              const SizedBox(width: 6),
                              _ThumbAction(
                                icon: Icons.close,
                                label: '삭제',
                                onTap: onClear,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                    : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '썸네일 첨부',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '갤러리 또는 현장 사진',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}

class _ThumbAction extends StatelessWidget {
  const _ThumbAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xE6FFFFFF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textPrimary),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StylePick extends StatelessWidget {
  const _StylePick({
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final StyleMoodCard card;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(card.gradientStart),
                        Color(card.gradientEnd),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 7),
                child: Text(
                  card.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCostDetail extends StatelessWidget {
  const _AddCostDetail({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F1F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.add,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '세부 공사비 추가',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '없어도 돼요.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.value,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 42,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color:
                          filled
                              ? AppColors.textPrimary
                              : const Color(0xFFB0B6BE),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
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

class _CostEditor extends StatefulWidget {
  const _CostEditor({
    required this.lines,
    required this.onAdd,
    required this.onLine,
    required this.onRemove,
  });

  final List<ShowroomCostLine> lines;
  final VoidCallback onAdd;
  final void Function(int index, {String? name, String? amount}) onLine;
  final ValueChanged<int> onRemove;

  @override
  State<_CostEditor> createState() => _CostEditorState();
}

class _CostEditorState extends State<_CostEditor> {
  static const List<String> _itemHints = <String>[
    '예: 철거 · 설비',
    '예: 목공',
    '예: 도배',
    '예: 조명',
  ];

  late final List<TextEditingController> _names;
  late final List<TextEditingController> _amounts;

  @override
  void initState() {
    super.initState();
    _names = <TextEditingController>[
      for (final ShowroomCostLine line in widget.lines)
        TextEditingController(text: line.name),
    ];
    _amounts = <TextEditingController>[
      for (final ShowroomCostLine line in widget.lines)
        TextEditingController(text: groupedDigits(line.amount)),
    ];
  }

  void _commitMoney(TextEditingController controller, String value) {
    final String formatted = groupedDigits(value);
    if (formatted != controller.text) {
      controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  String _storedMoney(String formatted) =>
      formatted.isEmpty ? '' : '$formatted원';

  String _readingOf(String formatted) =>
      CostFormattingViewModel.wonReading(formatted);

  void _add() {
    setState(() {
      _names.add(TextEditingController());
      _amounts.add(TextEditingController());
    });
    widget.onAdd();
  }

  void _remove(int index) {
    final TextEditingController name = _names.removeAt(index);
    final TextEditingController amount = _amounts.removeAt(index);
    setState(() {});
    widget.onRemove(index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      name.dispose();
      amount.dispose();
    });
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _names) {
      controller.dispose();
    }
    for (final TextEditingController controller in _amounts) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _names.length; i++) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _LineField(
                  controller: _names[i],
                  hint: _itemHints[i % _itemHints.length],
                  onChanged: (String value) => widget.onLine(i, name: value),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LineField(
                      controller: _amounts[i],
                      hint: '금액',
                      suffix: '원',
                      keyboard: TextInputType.number,
                      onChanged: (String value) {
                        _commitMoney(_amounts[i], value);
                        widget.onLine(
                          i,
                          amount: _storedMoney(_amounts[i].text),
                        );
                      },
                    ),
                    _WonReading(text: _readingOf(_amounts[i].text)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _remove(i),
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: _add,
            child: const Text(
              '항목 추가',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _WonReading extends StatelessWidget {
  const _WonReading({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, right: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _BlockTitle extends StatelessWidget {
  const _BlockTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _LineField extends StatelessWidget {
  const _LineField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.suffix,
    this.keyboard,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final String? suffix;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFB0B6BE),
          fontWeight: FontWeight.w500,
        ),
        suffixText: suffix,
        suffixStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class ShowroomDraftPreview extends StatelessWidget {
  const ShowroomDraftPreview({super.key, required this.draft});

  final ShowroomDraft draft;

  @override
  Widget build(BuildContext context) {
    final bool hasThumbnail = draft.thumbnailUrl.trim().isNotEmpty;
    final List<(String, String)> spaceFacts = <(String, String)>[
      if (draft.industry.trim().isNotEmpty) ('업종', draft.industry.trim()),
      if (draft.area.trim().isNotEmpty) ('평수', draft.area.trim()),
      if (draft.budget.trim().isNotEmpty) ('예산', draft.budget.trim()),
      if (draft.period.trim().isNotEmpty) ('기간', draft.period.trim()),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('미리보기'),
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        forceMaterialTransparency: true,
        notificationPredicate: (ScrollNotification notification) => false,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (hasThumbnail)
                  showroomThumbnailBar(
                    context,
                    imageUrl: draft.thumbnailUrl,
                    style: draft.style,
                    title: draft.title,
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: ResponsiveSize.textInset(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!hasThumbnail) ...[
                              if (draft.style.trim().isNotEmpty) ...[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: const Color(0xFFE4E4E4),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      child: Text(
                                        draft.style.trim(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                          color: storyInk,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                              Text(
                                draft.title.trim(),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.6,
                                  height: 1.2,
                                  color: storyInk,
                                ),
                              ),
                            ],
                            if (spaceFacts.isNotEmpty ||
                                (draft.showCostDetail &&
                                    showroomHasCostDetail(draft.cost))) ...[
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 28, 0, 10),
                                child: Text(
                                  '이 공간',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    color: storyInk,
                                  ),
                                ),
                              ),
                              ShowroomFactCard(
                                facts: spaceFacts,
                                cost: draft.showCostDetail ? draft.cost : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ShowroomBodyView(blocks: draft.blocks),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '작성 마치기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
