import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SearchSuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const SearchSuggestionChip({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryRed.withOpacity(0.2)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRed : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(
                Icons.check,
                size: 16,
                color: AppTheme.primaryRed,
              ),
            if (isSelected) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryRed : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickSearchSection extends StatelessWidget {
  final String title;
  final List<String> suggestions;
  final Function(String) onSuggestionTap;
  final VoidCallback? onClearHistory;

  const QuickSearchSection({
    super.key,
    required this.title,
    required this.suggestions,
    required this.onSuggestionTap,
    this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const Spacer(),
            if (onClearHistory != null)
              TextButton(
                onPressed: onClearHistory,
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: AppTheme.primaryRed,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return SearchSuggestionChip(
                label: suggestion,
                onTap: () => onSuggestionTap(suggestion),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
