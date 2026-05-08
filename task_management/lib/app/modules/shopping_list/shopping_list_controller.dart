import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../core/widgets/app_snackbar.dart';

class ShoppingListController extends GetxController {
  static const String _listsBoxName = 'shopping_lists';
  static const String _legacyItemsBoxName = 'shopping_items';

  final lists = <Map<String, dynamic>>[].obs;
  final selectedListKey = Rxn<dynamic>();
  final loading = false.obs;

  Box<dynamic>? _listsBox;

  List<Map<String, dynamic>> get currentItems {
    final currentList = selectedList;
    if (currentList == null) {
      return const [];
    }

    return List<Map<String, dynamic>>.from(
      (currentList['items'] as List<dynamic>? ?? const []).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    );
  }

  Map<String, dynamic>? get selectedList {
    final key = selectedListKey.value;
    if (key == null) {
      return null;
    }

    for (final list in lists) {
      if (list['key'] == key) {
        return list;
      }
    }

    return null;
  }

  int get totalCount => currentItems.length;

  int get completedCount =>
      currentItems.where((item) => item['completed'] == true).length;

  int get totalListsCount => lists.length;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    loading.value = true;
    _listsBox ??= await Hive.openBox(_listsBoxName);
    await _migrateLegacyItemsIfNeeded();

    final loadedLists = <Map<String, dynamic>>[];
    for (final key in _listsBox!.keys) {
      final raw = _listsBox!.get(key);
      if (raw is Map) {
        final rawItems = raw['items'] as List<dynamic>? ?? const [];
        final parsedItems = rawItems
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(growable: false);

        parsedItems.sort((a, b) {
          if (a['completed'] != b['completed']) {
            return a['completed'] == true ? 1 : -1;
          }
          return (b['createdAt'] as String).compareTo(a['createdAt'] as String);
        });

        loadedLists.add({
          'key': key,
          'title': (raw['title'] ?? '').toString(),
          'createdAt': (raw['createdAt'] ?? '').toString(),
          'items': parsedItems,
        });
      }
    }

    loadedLists.sort((a, b) {
      return (b['createdAt'] as String).compareTo(a['createdAt'] as String);
    });

    lists.assignAll(loadedLists);
    if (loadedLists.isEmpty) {
      selectedListKey.value = null;
    } else if (!loadedLists.any(
      (list) => list['key'] == selectedListKey.value,
    )) {
      selectedListKey.value = loadedLists.first['key'];
    }

    loading.value = false;
  }

  Future<bool> addList(String title, {bool showSuccessSnackbar = false}) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      AppSnackbar.showError('shopping_list'.tr, 'shopping_list_add_error'.tr);
      return false;
    }

    _listsBox ??= await Hive.openBox(_listsBoxName);
    final key = await _listsBox!.add({
      'title': trimmedTitle,
      'createdAt': DateTime.now().toIso8601String(),
      'items': <Map<String, dynamic>>[],
    });

    selectedListKey.value = key;
    await loadItems();
    if (showSuccessSnackbar) {
      AppSnackbar.showSuccess(trimmedTitle, 'shopping_list_saved'.tr);
    }
    return true;
  }

  void selectList(dynamic key) {
    selectedListKey.value = key;
  }

  Future<bool> addItem(String title) async {
    final String trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      AppSnackbar.showError('shopping_list'.tr, 'shopping_add_error'.tr);
      return false;
    }

    final currentList = selectedList;
    if (currentList == null) {
      AppSnackbar.showError('shopping_list'.tr, 'shopping_list_add_error'.tr);
      return false;
    }

    final updatedItems = currentItems.toList(growable: true);
    updatedItems.add({
      'title': trimmedTitle,
      'completed': false,
      'createdAt': DateTime.now().toIso8601String(),
    });

    await _saveList(currentList, updatedItems);
    await loadItems();
    return true;
  }

  Future<void> toggleItem(Map<String, dynamic> item) async {
    final currentList = selectedList;
    if (currentList == null) {
      return;
    }

    final updatedItems = currentItems
        .map(
          (currentItem) =>
              currentItem['createdAt'] == item['createdAt'] &&
                  currentItem['title'] == item['title']
              ? {
                  ...currentItem,
                  'completed': !(currentItem['completed'] == true),
                }
              : currentItem,
        )
        .toList(growable: false);

    await _saveList(currentList, updatedItems);
    await loadItems();
  }

  Future<void> removeItem(Map<String, dynamic> item) async {
    final currentList = selectedList;
    if (currentList == null) {
      return;
    }

    final originalItems = currentItems.toList(growable: false);

    final updatedItems = currentItems
        .where(
          (currentItem) =>
              !(currentItem['createdAt'] == item['createdAt'] &&
                  currentItem['title'] == item['title']),
        )
        .toList(growable: false);

    await _saveList(currentList, updatedItems);
    await loadItems();
    AppSnackbar.showDelete(
      item['title'] as String,
      'delete_success'.tr,
      onUndo: () async {
        await _saveList(currentList, originalItems);
        await loadItems();
      },
    );
  }

  Future<void> removeList(Map<String, dynamic> list) async {
    _listsBox ??= await Hive.openBox(_listsBoxName);
    final restoredList = Map<String, dynamic>.from(list);
    final wasSelected = selectedListKey.value == list['key'];
    await _listsBox!.delete(list['key']);
    if (selectedListKey.value == list['key']) {
      selectedListKey.value = null;
    }
    await loadItems();
    AppSnackbar.showDelete(
      list['title'] as String,
      'shopping_list_deleted'.tr,
      onUndo: () async {
        await _listsBox!.put(restoredList['key'], {
          'title': restoredList['title'],
          'createdAt': restoredList['createdAt'],
          'items': restoredList['items'],
        });
        if (wasSelected) {
          selectedListKey.value = restoredList['key'];
        }
        await loadItems();
      },
    );
  }

  Future<void> clearAllItems() async {
    final currentList = selectedList;
    if (currentList == null) {
      return;
    }

    await _saveList(currentList, const []);
    await loadItems();
    AppSnackbar.showSuccess('shopping_list'.tr, 'shopping_clear_success'.tr);
  }

  Future<void> clearCompletedItems() async {
    final currentList = selectedList;
    if (currentList == null) {
      return;
    }

    final updatedItems = currentItems
        .where((item) => item['completed'] != true)
        .toList(growable: false);

    if (updatedItems.length == currentItems.length) {
      return;
    }

    await _saveList(currentList, updatedItems);
    await loadItems();
    AppSnackbar.showSuccess(
      'shopping_list'.tr,
      'shopping_clear_checked_success'.tr,
    );
  }

  Future<void> _saveList(
    Map<String, dynamic> list,
    List<Map<String, dynamic>> items,
  ) async {
    _listsBox ??= await Hive.openBox(_listsBoxName);
    await _listsBox!.put(list['key'], {
      'title': list['title'],
      'createdAt': list['createdAt'],
      'items': items,
    });
  }

  Future<void> _migrateLegacyItemsIfNeeded() async {
    final legacyBox = await Hive.openBox(_legacyItemsBoxName);
    if (_listsBox == null || _listsBox!.isNotEmpty || legacyBox.isEmpty) {
      return;
    }

    final legacyItems = <Map<String, dynamic>>[];
    for (final key in legacyBox.keys) {
      final raw = legacyBox.get(key);
      if (raw is Map) {
        legacyItems.add({
          'title': (raw['title'] ?? '').toString(),
          'completed': raw['completed'] == true,
          'createdAt': (raw['createdAt'] ?? '').toString(),
        });
      }
    }

    if (legacyItems.isEmpty) {
      return;
    }

    final createdAt = DateTime.now().toIso8601String();
    final newKey = await _listsBox!.add({
      'title': 'shopping_default_list'.tr,
      'createdAt': createdAt,
      'items': legacyItems,
    });
    selectedListKey.value = newKey;
  }
}
