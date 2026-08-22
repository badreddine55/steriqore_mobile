import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';
import '../../../../shared/widgets/role_based_bottom_nav.dart';

class StockItem {
  final String id;
  final String reference;
  final String name;
  final String category;
  final int currentQuantity;
  final int minThreshold;
  final String unit;
  final DateTime lastRestocked;

  const StockItem({
    required this.id,
    required this.reference,
    required this.name,
    required this.category,
    required this.currentQuantity,
    required this.minThreshold,
    required this.unit,
    required this.lastRestocked,
  });

  bool get isLowStock => currentQuantity <= minThreshold;

  factory StockItem.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return StockItem(
      id: json['id']?.toString() ?? 'STK-${json['reference'] ?? '001'}',
      reference: json['reference']?.toString() ?? json['code']?.toString() ?? 'REF-001',
      name: json['name']?.toString() ?? json['product_name']?.toString() ?? 'Dental Product',
      category: json['category']?.toString() ?? 'Sterilization & Instruments',
      currentQuantity: int.tryParse(json['current_quantity']?.toString() ?? json['quantity']?.toString() ?? '0') ?? 0,
      minThreshold: int.tryParse(json['min_threshold']?.toString() ?? json['minimum_quantity']?.toString() ?? '5') ?? 5,
      unit: json['unit']?.toString() ?? 'units',
      lastRestocked: parseDate(json['last_restocked'] ?? json['updated_at'] ?? json['created_at']),
    );
  }
}

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';

  List<StockItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStockLevels();
  }

  Future<void> _fetchStockLevels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = sl<DioClient>();
      final response = await dio.get(ApiConstants.stockLevels);

      final dynamic data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('data') && data['data'] is List) {
        list = data['data'] as List;
      } else if (data is Map && data.containsKey('stock') && data['stock'] is List) {
        list = data['stock'] as List;
      }

      final parsed = list
          .whereType<Map<String, dynamic>>()
          .map((item) => StockItem.fromJson(item))
          .toList();

      setState(() {
        _items = parsed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _items = [];
        _isLoading = false;
        _errorMessage = 'Could not load inventory from server.';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StockItem> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    return _items.where((item) {
      if (query.isNotEmpty) {
        final match = item.name.toLowerCase().contains(query) ||
            item.reference.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query);
        if (!match) return false;
      }
      if (_selectedCategory == 'low_stock' && !item.isLowStock) return false;
      if (_selectedCategory != 'all' &&
          _selectedCategory != 'low_stock' &&
          item.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  List<String> get _categories {
    final set = <String>{'all', 'low_stock'};
    for (final item in _items) {
      set.add(item.category);
    }
    return set.toList();
  }

  void _showRestockDialog(StockItem item) {
    final quantityController = TextEditingController(text: '10');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: AdminColors.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AdminColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Order Stock / Reorder', style: AdminTypography.h3),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AdminColors.textSecondary),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.name,
                style: AdminTypography.h4,
              ),
              Text(
                'Ref: ${item.reference} · Current: ${item.currentQuantity} ${item.unit}',
                style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Units to Order (${item.unit})',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  foregroundColor: AdminColors.primaryInverse,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  final added = int.tryParse(quantityController.text) ?? 0;
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order for $added ${item.unit} of ${item.name} placed.'),
                      backgroundColor: AdminColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                },
                child: const Text('Confirm Purchase Order', style: AdminTypography.button),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final lowStockCount = _items.where((i) => i.isLowStock).length;

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AdminColors.borderSubtle, height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AdminColors.textPrimary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('Stock & Inventory', style: AdminTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AdminColors.textPrimary),
            tooltip: 'Refresh Inventory',
            onPressed: _fetchStockLevels,
          ),
        ],
      ),
      bottomNavigationBar: const RoleBasedBottomNav(currentRoute: '/stock'),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Category Filters
            Container(
              color: AdminColors.surfaceElevated,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: AdminTypography.body,
                      decoration: InputDecoration(
                        hintText: 'Search products by name, reference...',
                        hintStyle: AdminTypography.bodySmall.copyWith(color: AdminColors.textTertiary),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AdminColors.textTertiary),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        filled: true,
                        fillColor: AdminColors.surfaceMuted,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        String label = cat == 'all'
                            ? 'All (${_items.length})'
                            : (cat == 'low_stock' ? '⚠️ Low Stock ($lowStockCount)' : cat);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AdminColors.primary : AdminColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected ? AdminColors.primary : AdminColors.borderSubtle,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                label,
                                style: AdminTypography.caption.copyWith(
                                  color: isSelected ? AdminColors.primaryInverse : AdminColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Container(color: AdminColors.borderSubtle, height: 1),

            // Content Area
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AdminColors.primary),
                      ),
                    )
                  : filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.inventory_2_outlined, size: 48, color: AdminColors.borderStrong),
                                const SizedBox(height: 16),
                                const Text('No Products in Inventory', style: AdminTypography.h4),
                                const SizedBox(height: 6),
                                Text(
                                  _errorMessage ?? 'No stock items found in your cabinet catalog.',
                                  textAlign: TextAlign.center,
                                  style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: AdminColors.accent,
                          onRefresh: _fetchStockLevels,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AdminColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: item.isLowStock
                                        ? AdminColors.warning.withValues(alpha: 0.5)
                                        : AdminColors.borderSubtle,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(item.name, style: AdminTypography.h4),
                                              ),
                                              if (item.isLowStock)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AdminColors.warningBg,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    'LOW STOCK',
                                                    style: AdminTypography.caption.copyWith(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                      color: AdminColors.warning,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Ref: ${item.reference} · ${item.category}',
                                            style: AdminTypography.bodySmall.copyWith(color: AdminColors.textSecondary),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                '${item.currentQuantity} ${item.unit}',
                                                style: AdminTypography.data.copyWith(
                                                  color: item.isLowStock ? AdminColors.warning : AdminColors.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                ' (Min: ${item.minThreshold})',
                                                style: AdminTypography.caption.copyWith(color: AdminColors.textTertiary),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: item.isLowStock ? AdminColors.warning : AdminColors.surfaceMuted,
                                        foregroundColor: item.isLowStock ? AdminColors.primaryInverse : AdminColors.textPrimary,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      onPressed: () => _showRestockDialog(item),
                                      child: const Text('Reorder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
