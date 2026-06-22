import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_themes.dart';
import '../../core/widgets/app_side_drawer.dart';
import '../../data/models/book_model.dart';
import '../../data/services/ad_service.dart';
import '../../data/services/theme_service.dart';
import 'books_controller.dart';

Color _readableAccent(Color accent, ThemeData theme) {
  if (accent.computeLuminance() > 0.62) {
    return Color.alphaBlend(
      Colors.black.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.24 : 0.42,
      ),
      accent,
    );
  }

  return accent;
}

Color _foregroundForBackground(Color background, ThemeData theme) {
  return background.computeLuminance() > 0.56
      ? theme.colorScheme.onSurface
      : Colors.white;
}

class BooksView extends GetView<BooksController> {
  const BooksView({super.key});

  String _statusLabel(String status) {
    switch (status) {
      case BooksController.statusReading:
        return 'books_tab_reading'.tr;
      case BooksController.statusCompleted:
        return 'books_tab_completed'.tr;
      default:
        return 'books_tab_pending'.tr;
    }
  }

  String _emptyTitle(String status) {
    switch (status) {
      case BooksController.statusReading:
        return 'books_empty_title_reading'.tr;
      case BooksController.statusCompleted:
        return 'books_empty_title_completed'.tr;
      default:
        return 'books_empty_title_pending'.tr;
    }
  }

  String _emptyBody(String status) {
    switch (status) {
      case BooksController.statusReading:
        return 'books_empty_body_reading'.tr;
      case BooksController.statusCompleted:
        return 'books_empty_body_completed'.tr;
      default:
        return 'books_empty_body_pending'.tr;
    }
  }

  Future<void> _showDailyPaceDialog(BuildContext context) async {
    final paceController = TextEditingController(
      text: controller.dailyPages.value.toString(),
    );
    final theme = Theme.of(context);
    final accent = _readableAccent(
      AppThemes.iconPaletteFor(ThemeService.currentTheme.value).tasks,
      theme,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: theme.surfaceBorderColor),
        ),
        title: Text('books_daily_pace_title'.tr),
        content: TextField(
          controller: paceController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'books_daily_pace_hint'.tr,
            prefixIcon: Icon(Icons.speed_rounded, color: accent),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              final pace = int.tryParse(paceController.text.trim()) ?? 0;
              await controller.saveDailyPages(pace);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: theme.semanticPalette.onAccent,
            ),
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  Future<void> _showBookSheet(BuildContext context, {BookModel? book}) async {
    final titleController = TextEditingController(text: book?.title ?? '');
    final authorController = TextEditingController(text: book?.author ?? '');
    final totalPagesController = TextEditingController(
      text: (book?.totalPages ?? '').toString(),
    );
    final currentPagesController = TextEditingController(
      text: (book?.currentPages ?? '').toString(),
    );
    final noteController = TextEditingController(text: book?.note ?? '');
    final selectedStatus = (book?.status ?? BooksController.statusReading).obs;
    final selectedImagePath = RxnString(
      book?.imagePath.isNotEmpty == true ? book!.imagePath : null,
    );
    final isEditing = book != null;
    final imagePicker = ImagePicker();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final accent = _readableAccent(
          AppThemes.iconPaletteFor(ThemeService.currentTheme.value).tasks,
          theme,
        );
        final actionButtonColor = _foregroundForBackground(accent, theme);

        Future<void> pickImage(ImageSource source) async {
          final picked = await imagePicker.pickImage(
            source: source,
            imageQuality: 88,
            maxWidth: 1400,
          );
          if (picked == null) {
            return;
          }

          final savedPath = await controller.persistCoverImage(picked.path);
          if (savedPath != null) {
            selectedImagePath.value = savedPath;
          }
        }

        Future<void> saveBookAndClose() async {
          FocusScope.of(sheetContext).unfocus();
          final saved = await controller.saveBook(
            key: book?.key,
            title: titleController.text,
            author: authorController.text,
            imagePath: selectedImagePath.value ?? '',
            totalPages: int.tryParse(totalPagesController.text.trim()) ?? 0,
            currentPages: int.tryParse(currentPagesController.text.trim()) ?? 0,
            status: selectedStatus.value,
            note: noteController.text,
          );
          if (saved && sheetContext.mounted) {
            Navigator.of(sheetContext).pop();
            await AdService.registerBookSaved();
          }
        }

        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border(
                  top: BorderSide(color: theme.surfaceBorderColor),
                  left: BorderSide(color: theme.surfaceBorderColor),
                  right: BorderSide(color: theme.surfaceBorderColor),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.semanticPalette.sheetHandle,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: theme.semanticPalette.softSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: theme.semanticPalette.softSurfaceBorder,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            style: IconButton.styleFrom(
                              foregroundColor: theme.colorScheme.onSurface,
                              backgroundColor:
                                  theme.semanticPalette.transparent,
                            ),
                            tooltip: 'cancel'.tr,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.auto_stories_rounded,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isEditing ? 'books_edit'.tr : 'books_add'.tr,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.semanticPalette.softSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Color.alphaBlend(
                                accent.withValues(alpha: 0.18),
                                theme.semanticPalette.softSurfaceBorder,
                              ),
                            ),
                          ),
                          child: IconButton(
                            onPressed: saveBookAndClose,
                            style: IconButton.styleFrom(
                              foregroundColor: accent,
                              backgroundColor:
                                  theme.semanticPalette.transparent,
                            ),
                            tooltip: 'save'.tr,
                            icon: const Icon(Icons.save_rounded),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => _BookCoverPicker(
                        imagePath: selectedImagePath.value,
                        accent: accent,
                        onPickCamera: () => pickImage(ImageSource.camera),
                        onPickGallery: () => pickImage(ImageSource.gallery),
                        onRemove: selectedImagePath.value == null
                            ? null
                            : () => selectedImagePath.value = null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'books_title'.tr,
                        hintText: 'books_title_hint'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: authorController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'books_author'.tr,
                        hintText: 'books_author_hint'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: totalPagesController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'books_total_pages'.tr,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: currentPagesController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'books_current_pages'.tr,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus.value,
                      decoration: InputDecoration(
                        labelText: 'books_status'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: BooksController.statusReading,
                          child: Text('books_tab_reading'.tr),
                        ),
                        DropdownMenuItem(
                          value: BooksController.statusPending,
                          child: Text('books_tab_pending'.tr),
                        ),
                        DropdownMenuItem(
                          value: BooksController.statusCompleted,
                          child: Text('books_tab_completed'.tr),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          selectedStatus.value = value;
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'books_note'.tr,
                        hintText: 'books_note_hint'.tr,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (isEditing)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                Navigator.of(sheetContext).pop();
                                await controller.removeBook(book);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.semanticPalette.danger,
                                side: BorderSide(
                                  color: theme.semanticPalette.danger,
                                ),
                              ),
                              icon: const Icon(Icons.delete_outline_rounded),
                              label: Text('delete'.tr),
                            ),
                          ),
                        if (isEditing) const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: saveBookAndClose,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: actionButtonColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: Icon(
                              isEditing
                                  ? Icons.save_rounded
                                  : Icons.add_rounded,
                            ),
                            label: Text(isEditing ? 'save'.tr : 'books_add'.tr),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = _readableAccent(
      AppThemes.iconPaletteFor(ThemeService.currentTheme.value).tasks,
      theme,
    );
    final subtitleColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.78 : 0.68,
    );
    final selectedTabLabelColor = _foregroundForBackground(accent, theme);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: const AppSideDrawer(),
        appBar: AppBar(
          title: Text('bookshelf_title'.tr),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => _showDailyPaceDialog(context),
              icon: const Icon(Icons.speed_rounded),
              tooltip: 'books_daily_pace_title'.tr,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showBookSheet(context),
          backgroundColor: accent,
          foregroundColor: theme.semanticPalette.onAccent,
          icon: const Icon(Icons.library_add_rounded),
          label: Text('books_add'.tr),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Obx(
                  () => Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.surfaceBorderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: accent.withValues(
                                  alpha: isDark ? 0.22 : 0.12,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.chrome_reader_mode_rounded,
                                color: accent,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'bookshelf_title'.tr,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'bookshelf_subtitle'.tr,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _BooksStatPill(
                                label: 'books_total_books'.tr,
                                value: controller.books.length.toString(),
                                accent: accent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _showDailyPaceDialog(context),
                                  child: _BooksStatPill(
                                    label: 'books_daily_pace_title'.tr,
                                    value:
                                        '${controller.dailyPages.value} ${'books_pages_unit'.tr}',
                                    accent: accent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.surfaceBorderColor),
                  ),
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                    labelColor: selectedTabLabelColor,
                    unselectedLabelColor: subtitleColor,
                    indicator: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    tabs: [
                      Tab(text: 'books_tab_reading'.tr),
                      Tab(text: 'books_tab_pending'.tr),
                      Tab(text: 'books_tab_completed'.tr),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(
                  () => TabBarView(
                    children: [
                      _BooksStatusPane(
                        books: controller.booksForStatus(
                          BooksController.statusReading,
                        ),
                        emptyTitle: _emptyTitle(BooksController.statusReading),
                        emptyBody: _emptyBody(BooksController.statusReading),
                        accent: accent,
                        onAdd: () => _showBookSheet(context),
                        onOpen: (book) => _showBookSheet(context, book: book),
                        onDelete: controller.removeBook,
                        statusLabel: _statusLabel,
                        controller: controller,
                      ),
                      _BooksStatusPane(
                        books: controller.booksForStatus(
                          BooksController.statusPending,
                        ),
                        emptyTitle: _emptyTitle(BooksController.statusPending),
                        emptyBody: _emptyBody(BooksController.statusPending),
                        accent: accent,
                        onAdd: () => _showBookSheet(context),
                        onOpen: (book) => _showBookSheet(context, book: book),
                        onDelete: controller.removeBook,
                        statusLabel: _statusLabel,
                        controller: controller,
                      ),
                      _BooksStatusPane(
                        books: controller.booksForStatus(
                          BooksController.statusCompleted,
                        ),
                        emptyTitle: _emptyTitle(
                          BooksController.statusCompleted,
                        ),
                        emptyBody: _emptyBody(BooksController.statusCompleted),
                        accent: accent,
                        onAdd: () => _showBookSheet(context),
                        onOpen: (book) => _showBookSheet(context, book: book),
                        onDelete: controller.removeBook,
                        statusLabel: _statusLabel,
                        controller: controller,
                      ),
                    ],
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

class _BooksStatPill extends StatelessWidget {
  const _BooksStatPill({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = _readableAccent(accent, theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accentColor.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.18 : 0.08,
          ),
          theme.cardColor,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.semanticPalette.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _BooksStatusPane extends StatelessWidget {
  const _BooksStatusPane({
    required this.books,
    required this.emptyTitle,
    required this.emptyBody,
    required this.accent,
    required this.onAdd,
    required this.onOpen,
    required this.onDelete,
    required this.statusLabel,
    required this.controller,
  });

  final List<BookModel> books;
  final String emptyTitle;
  final String emptyBody;
  final Color accent;
  final VoidCallback onAdd;
  final ValueChanged<BookModel> onOpen;
  final Future<void> Function(BookModel) onDelete;
  final String Function(String) statusLabel;
  final BooksController controller;

  int _shelfCapacity(double width) {
    if (width >= 1180) return 5;
    if (width >= 920) return 4;
    if (width >= 640) return 3;
    return 2;
  }

  List<List<BookModel>> _buildShelves(List<BookModel> source, int capacity) {
    final shelves = <List<BookModel>>[];
    for (var index = 0; index < source.length; index += capacity) {
      final end = (index + capacity) > source.length
          ? source.length
          : index + capacity;
      shelves.add(source.sublist(index, end));
    }
    return shelves;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleColor = theme.colorScheme.onSurface.withValues(alpha: 0.68);

    if (controller.loading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (books.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.surfaceBorderColor),
            ),
            child: Column(
              children: [
                Icon(Icons.auto_stories_rounded, size: 42, color: accent),
                const SizedBox(height: 12),
                Text(
                  emptyTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  emptyBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: _foregroundForBackground(accent, theme),
                  ),
                  icon: const Icon(Icons.library_add_rounded),
                  label: Text('books_add'.tr),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final shelfCapacity = _shelfCapacity(constraints.maxWidth);
        final shelves = _buildShelves(books, shelfCapacity);

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
          itemCount: shelves.length,
          separatorBuilder: (context, index) => const SizedBox(height: 18),
          itemBuilder: (context, shelfIndex) {
            return _ShelfSection(
              books: shelves[shelfIndex],
              capacity: shelfCapacity,
              accent: accent,
              onOpen: onOpen,
              onDelete: onDelete,
              statusLabel: statusLabel,
              controller: controller,
              shelfIndex: shelfIndex,
            );
          },
        );
      },
    );
  }
}

class _ShelfSection extends StatelessWidget {
  const _ShelfSection({
    required this.books,
    required this.capacity,
    required this.accent,
    required this.onOpen,
    required this.onDelete,
    required this.statusLabel,
    required this.controller,
    required this.shelfIndex,
  });

  final List<BookModel> books;
  final int capacity;
  final Color accent;
  final ValueChanged<BookModel> onOpen;
  final Future<void> Function(BookModel) onDelete;
  final String Function(String) statusLabel;
  final BooksController controller;
  final int shelfIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.semanticPalette.softSurface.withValues(alpha: 0.18),
            theme.semanticPalette.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(capacity, (slotIndex) {
          final book = slotIndex < books.length ? books[slotIndex] : null;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: slotIndex == capacity - 1 ? 0 : 10,
              ),
              child: book == null
                  ? const SizedBox(height: 260)
                  : _BookCard(
                      book: book,
                      accent: accent,
                      onOpen: () => onOpen(book),
                      onDelete: () => onDelete(book),
                      statusLabel: statusLabel(book.status),
                      controller: controller,
                      shelfIndex: shelfIndex,
                      slotIndex: slotIndex,
                    ),
            ),
          );
        }),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.book,
    required this.accent,
    required this.onOpen,
    required this.onDelete,
    required this.statusLabel,
    required this.controller,
    required this.shelfIndex,
    required this.slotIndex,
  });

  final BookModel book;
  final Color accent;
  final VoidCallback onOpen;
  final Future<void> Function() onDelete;
  final String statusLabel;
  final BooksController controller;
  final int shelfIndex;
  final int slotIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = controller.progressFor(book);
    final currentPages = book.currentPages;
    final totalPages = book.totalPages;
    final etaDays = controller.etaDaysFor(book);
    final hasNote = book.note.trim().isNotEmpty;
    final readableAccent = _readableAccent(accent, theme);
    final spinePalette = <Color>[
      readableAccent,
      theme.colorScheme.primary,
      theme.colorScheme.tertiary,
      theme.semanticPalette.warning,
      theme.semanticPalette.success,
    ];
    final spineColor =
        spinePalette[(shelfIndex + slotIndex) % spinePalette.length];
    final jacketColor = Color.alphaBlend(
      spineColor.withValues(alpha: 0.14),
      theme.cardColor,
    );
    final coverHasImage = book.imagePath.trim().isNotEmpty;
    final overlayForeground = coverHasImage
        ? Colors.white
        : theme.semanticPalette.contrastForeground;
    final overlayMutedForeground = coverHasImage
        ? Colors.white.withValues(alpha: 0.86)
        : theme.semanticPalette.mutedForeground;
    final progressTrackColor = coverHasImage
        ? Colors.white.withValues(alpha: 0.22)
        : theme.semanticPalette.softSurfaceBorder;
    final progressValueColor = coverHasImage ? Colors.white : spineColor;
    final cardShadowColor = coverHasImage
        ? theme.semanticPalette.overlayShadow.withValues(
            alpha: isDark ? 0.08 : 0.05,
          )
        : theme.semanticPalette.overlayShadow.withValues(alpha: 0.14);
    final coverOverlayColor = coverHasImage
        ? Color.alphaBlend(
            theme.scaffoldBackgroundColor.withValues(
              alpha: isDark ? 0.36 : 0.28,
            ),
            Colors.black.withValues(alpha: isDark ? 0.22 : 0.10),
          )
        : theme.colorScheme.onSurface.withValues(alpha: 0.18);

    return AspectRatio(
      aspectRatio: 0.60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [jacketColor, theme.cardColor],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.surfaceBorderColor),
              boxShadow: [
                BoxShadow(
                  color: cardShadowColor,
                  blurRadius: coverHasImage ? 10 : 16,
                  spreadRadius: coverHasImage ? 0 : 1,
                  offset: Offset(0, coverHasImage ? 6 : 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _BookCover(
                      imagePath: book.imagePath,
                      accent: spineColor,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 10, color: spineColor),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasNote)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor.withValues(
                                alpha: 0.90,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Icon(
                              Icons.format_quote_rounded,
                              size: 14,
                              color: spineColor,
                            ),
                          ),
                        Material(
                          color: theme.scaffoldBackgroundColor.withValues(
                            alpha: 0.90,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          child: InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: theme.semanticPalette.danger,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.46, 1.0],
                          colors: [
                            theme.semanticPalette.transparent,
                            coverOverlayColor.withValues(
                              alpha: coverHasImage ? 0.18 : 0.10,
                            ),
                            coverOverlayColor,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 44, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: overlayForeground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.author.trim().isEmpty
                                ? statusLabel
                                : book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: overlayMutedForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: progressTrackColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progressValueColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '$currentPages/$totalPages',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: overlayMutedForeground,
                                  ),
                                ),
                              ),
                              Text(
                                '${(progress * 100).round()}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: progressValueColor,
                                ),
                              ),
                            ],
                          ),
                          if (etaDays != null && etaDays > 0) ...[
                            const SizedBox(height: 6),
                            Text(
                              'books_eta_days'.trParams({'days': '$etaDays'}),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: coverHasImage
                                    ? overlayMutedForeground
                                    : progressValueColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookCoverPicker extends StatelessWidget {
  const _BookCoverPicker({
    required this.imagePath,
    required this.accent,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onRemove,
  });

  final String? imagePath;
  final Color accent;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleColor = theme.colorScheme.onSurface.withValues(alpha: 0.68);
    final actionColor = _readableAccent(accent, theme);
    final actionSurface = Color.alphaBlend(
      actionColor.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.16 : 0.08,
      ),
      theme.cardColor,
    );
    final outlineButtonStyle = OutlinedButton.styleFrom(
      foregroundColor: actionColor,
      backgroundColor: actionSurface,
      side: BorderSide(color: actionColor.withValues(alpha: 0.24)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      iconColor: actionColor,
      textStyle: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
    final removeButtonStyle = TextButton.styleFrom(
      foregroundColor: theme.semanticPalette.danger,
      backgroundColor: Color.alphaBlend(
        theme.semanticPalette.danger.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.16 : 0.08,
        ),
        theme.cardColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      iconColor: theme.semanticPalette.danger,
      textStyle: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.semanticPalette.softSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.semanticPalette.softSurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'books_cover'.tr,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final compactLayout = constraints.maxWidth < 420;

              if (compactLayout) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.15,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _BookCover(
                          imagePath: imagePath ?? '',
                          accent: accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'books_cover_hint'.tr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: outlineButtonStyle,
                      onPressed: onPickGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text('books_pick_gallery'.tr),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: outlineButtonStyle,
                      onPressed: onPickCamera,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text('books_pick_camera'.tr),
                    ),
                    if (onRemove != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        style: removeButtonStyle,
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: Text('books_remove_cover'.tr),
                      ),
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 0.76,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _BookCover(
                          imagePath: imagePath ?? '',
                          accent: accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'books_cover_hint'.tr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: subtitleColor,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          style: outlineButtonStyle,
                          onPressed: onPickGallery,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text('books_pick_gallery'.tr),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          style: outlineButtonStyle,
                          onPressed: onPickCamera,
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: Text('books_pick_camera'.tr),
                        ),
                        if (onRemove != null) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            style: removeButtonStyle,
                            onPressed: onRemove,
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: Text('books_remove_cover'.tr),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.imagePath, required this.accent});

  final String imagePath;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final file = imagePath.trim().isEmpty ? null : File(imagePath);
    final hasImage = file != null && file.existsSync();

    if (hasImage) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _BookCoverFallback(accent: accent),
      );
    }

    return _BookCoverFallback(accent: accent);
  }
}

class _BookCoverFallback extends StatelessWidget {
  const _BookCoverFallback({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.scaffoldBackgroundColor,
            accent.withValues(alpha: 0.22),
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.menu_book_rounded, size: 44, color: accent),
      ),
    );
  }
}
