import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

class AppSearchBar extends StatefulWidget {
  final String? hint;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool autofocus;

  const AppSearchBar({
    super.key,
    this.hint,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.controller,
    this.autofocus = false,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_updateState);
  }

  void _updateState() {
    final has = _controller.text.isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHint = widget.hint ?? widget.hintText;

    return Container(
      height: AppDimensions.searchBarHeight,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.s8),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              style: AppTypography.body,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              decoration: InputDecoration(
                hintText: effectiveHint,
                hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onChanged?.call('');
                widget.onClear?.call();
              },
              child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}
