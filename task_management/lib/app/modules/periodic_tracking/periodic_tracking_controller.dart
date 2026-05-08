import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../core/widgets/app_snackbar.dart';

class PeriodicTrackingController extends GetxController {
  static const String _boxName = 'periodic_tracking_items';

  final items = <Map<String, dynamic>>[].obs;
  final loading = false.obs;

  Box<dynamic>? _box;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    loading.value = true;
    _box ??= await Hive.openBox(_boxName);

    final loadedItems = <Map<String, dynamic>>[];
    for (final key in _box!.keys) {
      final raw = _box!.get(key);
      if (raw is Map) {
        final legacyIntervalMonths = raw['intervalMonths'] is int
            ? raw['intervalMonths'] as int
            : int.tryParse((raw['intervalMonths'] ?? '').toString()) ?? 1;

        loadedItems.add({
          'key': key,
          'title': (raw['title'] ?? '').toString(),
          'category': (raw['category'] ?? 'vehicle').toString(),
          'note': (raw['note'] ?? '').toString(),
          'intervalValue': raw['intervalValue'] is int
              ? raw['intervalValue'] as int
              : int.tryParse((raw['intervalValue'] ?? '').toString()) ??
                    legacyIntervalMonths,
          'intervalUnit': (raw['intervalUnit'] ?? 'months').toString(),
          'intervalMonths': legacyIntervalMonths,
          'lastDoneAt': (raw['lastDoneAt'] ?? '').toString(),
          'nextDueAt': (raw['nextDueAt'] ?? '').toString(),
        });
      }
    }

    loadedItems.sort(
      (a, b) => (a['nextDueAt'] as String).compareTo(b['nextDueAt'] as String),
    );

    items.assignAll(loadedItems);
    loading.value = false;
  }

  Future<bool> addItem({
    required String title,
    required String category,
    required int intervalValue,
    required String intervalUnit,
    required DateTime lastDoneAt,
    String note = '',
  }) async {
    final trimmedTitle = title.trim();
    final trimmedNote = note.trim();

    if (trimmedTitle.isEmpty || intervalValue <= 0) {
      AppSnackbar.showError('periodic_tracking'.tr, 'periodic_add_error'.tr);
      return false;
    }

    final nextDueAt = calculateNextDueAt(
      lastDoneAt,
      intervalValue,
      intervalUnit,
    );

    _box ??= await Hive.openBox(_boxName);
    await _box!.add({
      'title': trimmedTitle,
      'category': category,
      'note': trimmedNote,
      'intervalValue': intervalValue,
      'intervalUnit': intervalUnit,
      'intervalMonths': intervalUnit == 'months' ? intervalValue : 1,
      'lastDoneAt': lastDoneAt.toIso8601String(),
      'nextDueAt': nextDueAt.toIso8601String(),
    });

    await loadItems();
    AppSnackbar.showSuccess(trimmedTitle, 'periodic_saved'.tr);
    return true;
  }

  Future<void> markDoneToday(Map<String, dynamic> item) async {
    _box ??= await Hive.openBox(_boxName);

    final lastDoneAt = DateTime.now();
    final intervalValue =
        item['intervalValue'] as int? ?? item['intervalMonths'] as int? ?? 1;
    final intervalUnit = (item['intervalUnit'] ?? 'months').toString();
    final nextDueAt = calculateNextDueAt(
      lastDoneAt,
      intervalValue,
      intervalUnit,
    );

    await _box!.put(item['key'], {
      'title': item['title'],
      'category': item['category'],
      'note': item['note'],
      'intervalValue': intervalValue,
      'intervalUnit': intervalUnit,
      'intervalMonths': intervalUnit == 'months' ? intervalValue : 1,
      'lastDoneAt': lastDoneAt.toIso8601String(),
      'nextDueAt': nextDueAt.toIso8601String(),
    });

    await loadItems();
    AppSnackbar.showSuccess(item['title'] as String, 'periodic_updated'.tr);
  }

  Future<void> removeItem(Map<String, dynamic> item) async {
    _box ??= await Hive.openBox(_boxName);
    final restoredItem = Map<String, dynamic>.from(item);
    await _box!.delete(item['key']);
    await loadItems();
    AppSnackbar.showDelete(
      item['title'] as String,
      'periodic_deleted'.tr,
      onUndo: () async {
        await _box!.put(restoredItem['key'], {
          'title': restoredItem['title'],
          'category': restoredItem['category'],
          'note': restoredItem['note'],
          'intervalValue': restoredItem['intervalValue'],
          'intervalUnit': restoredItem['intervalUnit'],
          'intervalMonths': restoredItem['intervalMonths'],
          'lastDoneAt': restoredItem['lastDoneAt'],
          'nextDueAt': restoredItem['nextDueAt'],
        });
        await loadItems();
      },
    );
  }

  DateTime parseDate(String value) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  String statusKey(Map<String, dynamic> item) {
    final dueDate = parseDate(item['nextDueAt'] as String);
    final now = DateTime.now();
    final difference = dueDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (difference < 0) {
      return 'periodic_status_late';
    }
    if (difference <= 7) {
      return 'periodic_status_soon';
    }
    return 'periodic_status_ok';
  }

  String intervalUnitLabelKey(String unit) {
    switch (unit) {
      case 'weeks':
        return 'periodic_interval_unit_weeks';
      case 'years':
        return 'periodic_interval_unit_years';
      default:
        return 'periodic_interval_unit_months';
    }
  }

  String intervalSummary(Map<String, dynamic> item) {
    final value =
        item['intervalValue'] as int? ?? item['intervalMonths'] as int? ?? 1;
    final unit = (item['intervalUnit'] ?? 'months').toString();
    return '$value ${intervalUnitLabelKey(unit).tr.toLowerCase()}';
  }

  DateTime calculateNextDueAt(
    DateTime date,
    int intervalValue,
    String intervalUnit,
  ) {
    switch (intervalUnit) {
      case 'weeks':
        return date.add(Duration(days: intervalValue * 7));
      case 'years':
        return _addMonths(date, intervalValue * 12);
      default:
        return _addMonths(date, intervalValue);
    }
  }

  DateTime _addMonths(DateTime date, int months) {
    final targetMonth = date.month + months;
    final year = date.year + ((targetMonth - 1) ~/ 12);
    final month = ((targetMonth - 1) % 12) + 1;
    final day = date.day;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(
      year,
      month,
      day > lastDay ? lastDay : day,
      date.hour,
      date.minute,
      date.second,
    );
  }
}
