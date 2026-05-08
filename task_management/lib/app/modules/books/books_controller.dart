import 'dart:io';
import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/widgets/app_snackbar.dart';
import '../../data/models/book_model.dart';

class BooksController extends GetxController {
  static const String statusReading = 'reading';
  static const String statusPending = 'pending';
  static const String statusCompleted = 'completed';

  static const String _boxName = 'bookshelf';
  static const String _dailyPagesKey = '_daily_pages';

  final books = <BookModel>[].obs;
  final dailyPages = 20.obs;
  final loading = false.obs;

  Box<dynamic>? _box;

  @override
  void onInit() {
    super.onInit();
    loadBooks();
  }

  Future<void> loadBooks() async {
    loading.value = true;
    _box ??= await Hive.openBox(_boxName);

    final storedDailyPages = _box!.get(_dailyPagesKey, defaultValue: 20);
    if (storedDailyPages is int && storedDailyPages >= 0) {
      dailyPages.value = storedDailyPages;
    }

    final loadedBooks = <BookModel>[];
    for (final key in _box!.keys) {
      if (key == _dailyPagesKey) {
        continue;
      }

      final raw = _box!.get(key);
      if (raw is Map) {
        loadedBooks.add(BookModel.fromMap(raw, key: key));
      }
    }

    loadedBooks.sort((a, b) {
      return b.updatedAt.compareTo(a.updatedAt);
    });

    books.assignAll(loadedBooks);
    loading.value = false;
  }

  List<BookModel> booksForStatus(String status) {
    return books.where((book) => book.status == status).toList(growable: false);
  }

  double progressFor(BookModel book) {
    return book.progress;
  }

  int remainingPagesFor(BookModel book) {
    return book.remainingPages;
  }

  int? etaDaysFor(BookModel book) {
    if (book.status != statusReading || dailyPages.value <= 0) {
      return null;
    }

    final remainingPages = remainingPagesFor(book);
    if (remainingPages <= 0) {
      return 0;
    }

    return (remainingPages / dailyPages.value).ceil();
  }

  Future<String?> persistCoverImage(String sourcePath) async {
    if (sourcePath.trim().isEmpty) {
      return null;
    }

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      return null;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final coversDirectory = Directory('${documentsDirectory.path}/book_covers');
    if (!await coversDirectory.exists()) {
      await coversDirectory.create(recursive: true);
    }

    final extensionIndex = sourcePath.lastIndexOf('.');
    final extension = extensionIndex == -1
        ? '.jpg'
        : sourcePath.substring(extensionIndex);
    final fileName = 'cover_${DateTime.now().microsecondsSinceEpoch}$extension';
    final targetFile = File('${coversDirectory.path}/$fileName');
    final copiedFile = await sourceFile.copy(targetFile.path);
    return copiedFile.path;
  }

  Future<void> saveDailyPages(int value) async {
    _box ??= await Hive.openBox(_boxName);
    final normalized = math.max(0, value);
    await _box!.put(_dailyPagesKey, normalized);
    dailyPages.value = normalized;
    AppSnackbar.showSuccess(
      'books_daily_pace_title'.tr,
      'books_daily_pace_saved'.tr,
    );
  }

  Future<bool> saveBook({
    dynamic key,
    required String title,
    required String author,
    required String imagePath,
    required int totalPages,
    required int currentPages,
    required String status,
    required String note,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedAuthor = author.trim();
    final trimmedNote = note.trim();
    final normalizedTotal = math.max(0, totalPages);

    if (trimmedTitle.isEmpty || normalizedTotal <= 0) {
      AppSnackbar.showError('bookshelf_title'.tr, 'books_add_error'.tr);
      return false;
    }

    _box ??= await Hive.openBox(_boxName);
    final normalizedCurrent = currentPages.clamp(0, normalizedTotal);
    final resolvedStatus = normalizedCurrent >= normalizedTotal
        ? statusCompleted
        : status;
    final now = DateTime.now().toIso8601String();
    final existingBook = key == null
        ? null
        : (_box!.get(key) is Map
              ? BookModel.fromMap(_box!.get(key) as Map, key: key)
              : null);
    final payload = BookModel(
      key: key,
      title: trimmedTitle,
      author: trimmedAuthor,
      imagePath: imagePath.trim(),
      totalPages: normalizedTotal,
      currentPages: resolvedStatus == statusCompleted
          ? normalizedTotal
          : normalizedCurrent,
      status: resolvedStatus,
      note: trimmedNote,
      createdAt: existingBook?.createdAt ?? now,
      updatedAt: now,
    ).toMap();

    if (key == null) {
      await _box!.add(payload);
      AppSnackbar.showSuccess(trimmedTitle, 'books_saved'.tr);
    } else {
      await _box!.put(key, payload);
      AppSnackbar.showSuccess(trimmedTitle, 'books_updated'.tr);
    }

    await loadBooks();
    return true;
  }

  Future<void> removeBook(BookModel book) async {
    _box ??= await Hive.openBox(_boxName);
    final key = book.key;
    if (key == null) {
      return;
    }

    final restoredBook = book.toMap();
    await _box!.delete(key);
    await loadBooks();
    AppSnackbar.showDelete(
      book.title,
      'books_deleted'.tr,
      onUndo: () async {
        await _box!.put(key, restoredBook);
        await loadBooks();
      },
    );
  }
}
