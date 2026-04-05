import 'package:flutter/material.dart';

class OverviewCards extends StatelessWidget {
  final int totalProducts;
  final int lowStockCount;
  final double totalValue;

  const OverviewCards({
    super.key,
    required this.totalProducts,
    required this.lowStockCount,
    required this.totalValue,
  });

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

  Widget _buildCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
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
                fontSize: 16,
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
                    context,
                    'Total Products',
                    totalProducts.toString(),
                    Icons.inventory_2_outlined,
                    Colors.blue[400]!,
                  ),
                  const SizedBox(width: 8),
                  _buildCard(
                    context,
                    'Low Stock',
                    lowStockCount.toString(),
                    Icons.warning_amber_rounded,
                    Colors.orange[400]!,
                  ),
                  const SizedBox(width: 8),
                  _buildCard(
                    context,
                    'Inventory Value',
                    _formatCurrency(totalValue),
                    Icons.account_balance_wallet_outlined,
                    Colors.green[400]!,
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
