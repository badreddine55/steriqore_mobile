import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_search_bar.dart';

class PatientSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;

  const PatientSearchBar({
    super.key,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppSearchBar(
      hint: 'Search by patient name or dossier ID...',
      onChanged: onSearch,
      onClear: onClear,
    );
  }
}
