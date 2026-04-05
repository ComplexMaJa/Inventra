import 'package:flutter/material.dart';

class OverviewCards extends StatefulWidget {
  final int totalProducts;
  final int lowStockCount;
  final double totalValue;
  final VoidCallback? onLowStockTap;
  final bool isLowStockActive;

  const OverviewCards({
    super.key,
    required this.totalProducts,
    required this.lowStockCount,
    required this.totalValue,
    this.onLowStockTap,
    this.isLowStockActive = false,
  });

  @override
  State<OverviewCards> createState() => _OverviewCardsState();
}

class _OverviewCardsState extends State<OverviewCards> {
  bool _showExactValue = false;

  String _formatCurrency(double value) {
    if (value == 0) return 'Rp 0';
    String str = value.toStringAsFixed(0);
    String result = '';
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        result += '.';
      }
      result += str[i];
    }
    return 'Rp $result';
  }

  String _formatCompact(double value) {
    if (value >= 1000000000000) {
      return 'Rp ${(value / 1000000000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}T';
    } else if (value >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}B';
    } else if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    } else if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
    }
    return _formatCurrency(value);
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    String? tooltip,
    bool isActive = false,
  }) {
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: tooltip != null ? Tooltip(message: tooltip, child: content) : content,
        ),
      );
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.05) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color.withOpacity(0.5) : Colors.white.withOpacity(0.03),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  _buildCard(
                    context: context,
                    title: 'Total Products',
                    value: widget.totalProducts.toString(),
                    icon: Icons.inventory_2_outlined,
                    color: Colors.blue[400]!,
                  ),
                  const SizedBox(width: 8),
                  _buildCard(
                    context: context,
                    title: 'Low Stock',
                    value: widget.lowStockCount.toString(),
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange[400]!,
                    onTap: widget.onLowStockTap,
                    tooltip: widget.isLowStockActive ? 'Clear low stock filter' : 'Tap to filter low stock items',
                    isActive: widget.isLowStockActive,
                  ),
                  const SizedBox(width: 8),
                  _buildCard(
                    context: context,
                    title: 'Inventory Value',
                    value: _showExactValue 
                        ? _formatCurrency(widget.totalValue) 
                        : _formatCompact(widget.totalValue),
                    icon: Icons.account_balance_wallet_outlined,
                    color: Colors.green[400]!,
                    onTap: () {
                      setState(() {
                        _showExactValue = !_showExactValue;
                      });
                    },
                    tooltip: 'Tap to see exact value',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
