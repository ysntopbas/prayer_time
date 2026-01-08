import 'package:flutter/material.dart';
import 'package:prayer_time/core/theme/app_theme.dart';

/// Aranabilir bottom sheet widget'ı
/// Herhangi bir liste için kullanılabilir
class SearchableBottomSheet<T> extends StatefulWidget {
  /// Bottom sheet başlığı
  final String title;

  /// Arama placeholder metni
  final String searchHint;

  /// Listelenecek öğeler
  final List<T> items;

  /// Arama fonksiyonu - async destekler
  final Future<List<T>> Function(String query)? onSearch;

  /// Senkron arama fonksiyonu
  final List<T> Function(String query)? onSearchSync;

  /// Her bir öğe için widget oluşturucu
  final Widget Function(BuildContext context, T item, VoidCallback onTap)
  itemBuilder;

  /// Öğe seçildiğinde çağrılır
  final void Function(T item) onItemSelected;

  /// Bottom sheet'in başlangıç boyutu (0.0 - 1.0)
  final double initialChildSize;

  /// Bottom sheet'in minimum boyutu (0.0 - 1.0)
  final double minChildSize;

  /// Bottom sheet'in maksimum boyutu (0.0 - 1.0)
  final double maxChildSize;

  const SearchableBottomSheet({
    super.key,
    required this.title,
    required this.searchHint,
    required this.items,
    this.onSearch,
    this.onSearchSync,
    required this.itemBuilder,
    required this.onItemSelected,
    this.initialChildSize = 0.7,
    this.minChildSize = 0.5,
    this.maxChildSize = 0.95,
  });

  /// Bottom sheet'i gösterir
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String searchHint,
    required List<T> items,
    Future<List<T>> Function(String query)? onSearch,
    List<T> Function(String query)? onSearchSync,
    required Widget Function(BuildContext context, T item, VoidCallback onTap)
    itemBuilder,
    required void Function(T item) onItemSelected,
    double initialChildSize = 0.7,
    double minChildSize = 0.5,
    double maxChildSize = 0.95,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchableBottomSheet<T>(
        title: title,
        searchHint: searchHint,
        items: items,
        onSearch: onSearch,
        onSearchSync: onSearchSync,
        itemBuilder: itemBuilder,
        onItemSelected: onItemSelected,
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
      ),
    );
  }

  @override
  State<SearchableBottomSheet<T>> createState() =>
      _SearchableBottomSheetState<T>();
}

class _SearchableBottomSheetState<T> extends State<SearchableBottomSheet<T>> {
  late List<T> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(String query) async {
    if (widget.onSearch != null) {
      final results = await widget.onSearch!(query);
      setState(() => _filteredItems = results);
    } else if (widget.onSearchSync != null) {
      setState(() => _filteredItems = widget.onSearchSync!(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.prayerBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              const _HandleBar(),

              // Title with close button
              _TitleBar(
                title: widget.title,
                onClose: () => Navigator.pop(context),
              ),

              // Search bar
              _SearchBar(
                controller: _searchController,
                hintText: widget.searchHint,
                onChanged: _handleSearch,
              ),

              Divider(height: 1, color: AppTheme.cardBorderColor),

              // Item list
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  itemCount: _filteredItems.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppTheme.cardBorderColor),
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    return widget.itemBuilder(context, item, () {
                      widget.onItemSelected(item);
                      Navigator.pop(context, item);
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Handle bar widget
class _HandleBar extends StatelessWidget {
  const _HandleBar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppTheme.textWhite40,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Title bar with close button
class _TitleBar extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _TitleBar({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppTheme.textWhite),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// Search bar widget
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final void Function(String) onChanged;

  const _SearchBar({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppTheme.textWhite),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppTheme.textWhite50),
          prefixIcon: Icon(Icons.search, color: AppTheme.textWhite60),
          filled: true,
          fillColor: AppTheme.chipBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.cardBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.cardBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryGreen),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
