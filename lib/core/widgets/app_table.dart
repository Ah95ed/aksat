import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

class AppTableColumn {
  const AppTableColumn({
    required this.title,
    this.hideOnMobile = false,
    this.width,
    this.alignment = AlignmentDirectional.centerStart,
  });

  final String title;
  final bool hideOnMobile;
  final double? width;
  final AlignmentGeometry alignment;
}

class AppTableCell {
  const AppTableCell({
    required this.child,
    this.hideOnMobile = false,
    this.width,
    this.alignment = AlignmentDirectional.centerStart,
  });

  final Widget child;
  final bool hideOnMobile;
  final double? width;
  final AlignmentGeometry alignment;
}

class AppTableRow {
  const AppTableRow({
    required this.cells,
    this.backgroundColor,
    this.onTap,
  });

  final List<AppTableCell> cells;
  final Color? backgroundColor;
  final VoidCallback? onTap;
}

class AppTable extends StatelessWidget {
  const AppTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth = 600.0,
  });

  final List<AppTableColumn> columns;
  final List<AppTableRow> rows;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppDimens.breakpointMd;

    final visibleColumns = columns.where((col) => !isMobile || !col.hideOnMobile).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header row
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.gray200,
                      width: 2.0,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: visibleColumns.map((col) {
                    final cellWidget = Container(
                      alignment: col.alignment,
                      child: Text(
                        col.title,
                        style: AppTextStyles.smBold(AppColors.gray700),
                      ),
                    );
                    if (col.width != null) {
                      return SizedBox(width: col.width, child: cellWidget);
                    }
                    return Expanded(child: cellWidget);
                  }).toList(),
                ),
              ),

              // Data rows
              ...rows.map((row) {
                final visibleCells = row.cells.where((cell) => !isMobile || !cell.hideOnMobile).toList();

                Widget rowContent = Container(
                  decoration: BoxDecoration(
                    color: row.backgroundColor ?? Colors.transparent,
                    border: const Border(
                      bottom: BorderSide(
                        color: AppColors.gray100,
                        width: 1.0,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: visibleCells.map((cell) {
                      final cellWidget = Container(
                        alignment: cell.alignment,
                        child: cell.child,
                      );
                      if (cell.width != null) {
                        return SizedBox(width: cell.width, child: cellWidget);
                      }
                      return Expanded(child: cellWidget);
                    }).toList(),
                  ),
                );

                if (row.onTap != null) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: row.onTap,
                      hoverColor: AppColors.gray50,
                      splashColor: AppColors.gray100,
                      child: rowContent,
                    ),
                  );
                }

                return rowContent;
              }),
            ],
          ),
        ),
      ),
    );
  }
}
