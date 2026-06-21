import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable data table with search, sort, and pagination.
class AdminDataTable extends StatefulWidget {
  final String title;
  final List<String> columns;
  final List<Map<String, dynamic>> rows;
  final List<String> displayKeys;
  final bool isLoading;
  final String? errorMessage;
  final String searchHint;
  final String emptyMessage;
  final String emptyActionText;
  final Function(String)? onSearch;
  final Function(Map<String, dynamic>)? onEdit;
  final Function(Map<String, dynamic>)? onDelete;
  final VoidCallback? onAdd;
  final VoidCallback? onRetry;

  const AdminDataTable({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    required this.displayKeys,
    this.isLoading = false,
    this.errorMessage,
    this.searchHint = 'Search...',
    this.emptyMessage = 'No data found',
    this.emptyActionText = 'Add New',
    this.onSearch,
    this.onEdit,
    this.onDelete,
    this.onAdd,
    this.onRetry,
  });

  @override
  State<AdminDataTable> createState() => _AdminDataTableState();
}

class _AdminDataTableState extends State<AdminDataTable> {
  final _searchController = TextEditingController();
  int _currentPage = 0;
  static const _rowsPerPage = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _paginatedRows {
    final start = _currentPage * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, widget.rows.length);
    return widget.rows.sublist(start, end);
  }

  int get _totalPages => (widget.rows.length / _rowsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title, search, and add button
        Row(
          children: [
            Text(widget.title, style: AppTypography.titleLarge),
            const Spacer(),
            if (widget.onAdd != null)
              ElevatedButton.icon(
                onPressed: widget.onAdd,
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: Text(
                  'Add New',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
          ],
        ),
        AppSpacing.gapH16,
        // Search bar
        if (widget.onSearch != null)
          TextField(
            controller: _searchController,
            onChanged: widget.onSearch,
            decoration: InputDecoration(
              hintText: widget.searchHint,
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusSm,
                borderSide: const BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearch?.call('');
                      },
                      icon: const Icon(Icons.clear, size: 18),
                    )
                  : null,
            ),
          ),
        if (widget.onSearch != null) AppSpacing.gapH16,
        // Table content — loading / error / empty / data
        if (widget.isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  AppSpacing.gapH16,
                  Text(
                    'Loading ${widget.title.toLowerCase()}...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppSpacing.gapH24,
                  // ALWAYS show create button even while loading
                  if (widget.onAdd != null)
                    ElevatedButton.icon(
                      onPressed: widget.onAdd,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(
                        widget.emptyActionText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        else if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                  ),
                  AppSpacing.gapH16,
                  Text(
                    'Error Loading Data',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.gapH8,
                  Text(
                    widget.errorMessage!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapH16,
                  if (widget.onRetry != null)
                    ElevatedButton.icon(
                      onPressed: widget.onRetry,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Retry', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
          )
        else if (widget.rows.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                  AppSpacing.gapH16,
                  Text(
                    widget.emptyMessage,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.gapH8,
                  Text(
                    'Get started by adding your first item',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppSpacing.gapH24,
                  if (widget.onAdd != null)
                    ElevatedButton.icon(
                      onPressed: widget.onAdd,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(
                        widget.emptyActionText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      for (int i = 0; i < widget.columns.length; i++)
                        Expanded(
                          flex: i == 0 ? 2 : 1,
                          child: Text(
                            widget.columns[i],
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      if (widget.onEdit != null || widget.onDelete != null)
                        const SizedBox(
                          width: 80,
                          child: Text('Actions',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Table rows
                ...List.generate(_paginatedRows.length, (index) {
                  final row = _paginatedRows[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: index < _paginatedRows.length - 1
                          ? const Border(
                              bottom: BorderSide(
                                color: AppColors.border,
                                width: 0.5,
                              ),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        for (int i = 0;
                            i < widget.displayKeys.length;
                            i++)
                          Expanded(
                            flex: i == 0 ? 2 : 1,
                            child: Text(
                              '${row[widget.displayKeys[i]] ?? '-'}',
                              style: AppTypography.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (widget.onEdit != null ||
                            widget.onDelete != null)
                          SizedBox(
                            width: 80,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.onEdit != null)
                                  InkWell(
                                    onTap: () => widget.onEdit!(row),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: AppColors.info,
                                      ),
                                    ),
                                  ),
                                if (widget.onDelete != null) ...[
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => widget.onDelete!(row),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.delete_outlined,
                                        size: 18,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        // Pagination
        if (_totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 20,
                ),
                Text(
                  'Page ${_currentPage + 1} of $_totalPages',
                  style: AppTypography.labelMedium,
                ),
                IconButton(
                  onPressed: _currentPage < _totalPages - 1
                      ? () => setState(() => _currentPage++)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  iconSize: 20,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
